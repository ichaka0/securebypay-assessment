import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Shipment, ShipmentType } from '../shipments/entities/shipment.entity';
import { UsersService } from '../users/users.service';
import { GrowthRange, OverviewPeriod } from './dto/dashboard-query.dto';
import {
  BannerDto,
  GrowthPointDto,
  GrowthResponseDto,
  OverviewResponseDto,
  StatDto,
} from './dto/dashboard-response.dto';

const DAY_MS = 24 * 60 * 60 * 1000;
const PERIOD_DAYS: Record<OverviewPeriod, number> = {
  [OverviewPeriod.WEEK]: 7,
  [OverviewPeriod.MONTH]: 30,
  [OverviewPeriod.YEAR]: 365,
};
const MONTHS = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];
const WEEKDAYS = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

const BANNERS: BannerDto[] = [
  {
    id: 'business-needs',
    title: 'KEEP UP WITH YOUR BUSINESS NEEDS',
    imageKey: 'globe_boxes',
  },
  {
    id: 'ship-300',
    title: 'SHIP TO OVER 300 COUNTRIES FROM NIGERIA',
    subtitle: 'Fast delivery and easy customs processing.',
    imageKey: 'globe_boxes',
  },
  {
    id: 'invite-earn',
    title: 'INVITE FRIENDS AND EARN ON EVERY SHIPMENT',
    subtitle: 'Share your referral link today.',
    imageKey: 'globe_boxes',
  },
];

interface TypeCounts {
  total: number;
  exports: number;
  imports: number;
}

/** Read-only aggregates that power the dashboard screen. */
@Injectable()
export class DashboardService {
  constructor(
    @InjectRepository(Shipment)
    private readonly shipments: Repository<Shipment>,
    private readonly usersService: UsersService,
  ) {}

  /** Wallet balance plus shipment counts for `period`, vs. the prior period. */
  async getOverview(
    userId: string,
    period: OverviewPeriod,
    now = new Date(),
  ): Promise<OverviewResponseDto> {
    const span = PERIOD_DAYS[period] * DAY_MS;
    const currentStart = new Date(now.getTime() - span);
    const previousStart = new Date(now.getTime() - 2 * span);

    const [user, current, previous] = await Promise.all([
      this.usersService.getById(userId),
      this.countByType(userId, currentStart, now),
      this.countByType(userId, previousStart, currentStart),
    ]);

    return {
      period,
      walletBalance: user.walletBalance,
      totalShipments: this.stat(current.total, previous.total),
      totalExports: this.stat(current.exports, previous.exports),
      totalImports: this.stat(current.imports, previous.imports),
    };
  }

  /**
   * Shipment value per bucket: 12 months (year), 30 days (month) or
   * 7 days (week). Empty buckets are returned as 0 so the chart is continuous.
   */
  async getGrowth(
    userId: string,
    range: GrowthRange,
    now = new Date(),
  ): Promise<GrowthResponseDto> {
    const byMonth = range === GrowthRange.YEAR;
    const buckets = byMonth
      ? this.monthBuckets(now)
      : this.dayBuckets(now, range === GrowthRange.WEEK ? 7 : 30);

    const rows = await this.shipments
      .createQueryBuilder('s')
      .select(
        `to_char(s.shipped_at AT TIME ZONE 'UTC', '${byMonth ? 'YYYY-MM' : 'YYYY-MM-DD'}')`,
        'bucket',
      )
      .addSelect('COALESCE(SUM(s.amount), 0)', 'value')
      .where('s.user_id = :userId', { userId })
      .andWhere('s.shipped_at >= :from AND s.shipped_at <= :to', {
        from: buckets[0].start,
        to: now,
      })
      .groupBy('bucket')
      .getRawMany<{ bucket: string; value: string }>();

    const totals = new Map(rows.map((r) => [r.bucket, parseFloat(r.value)]));
    const points: GrowthPointDto[] = buckets.map((b) => ({
      label: b.label,
      value: totals.get(b.key) ?? 0,
    }));
    return { range, points };
  }

  getBanners(): BannerDto[] {
    return BANNERS;
  }

  private async countByType(
    userId: string,
    from: Date,
    to: Date,
  ): Promise<TypeCounts> {
    const rows = await this.shipments
      .createQueryBuilder('s')
      .select('s.type', 'type')
      .addSelect('COUNT(*)', 'count')
      .where('s.user_id = :userId', { userId })
      .andWhere('s.shipped_at > :from AND s.shipped_at <= :to', { from, to })
      .groupBy('s.type')
      .getRawMany<{ type: ShipmentType; count: string }>();

    const counts = { exports: 0, imports: 0 };
    for (const row of rows) {
      if (row.type === ShipmentType.EXPORT) counts.exports = Number(row.count);
      if (row.type === ShipmentType.IMPORT) counts.imports = Number(row.count);
    }
    return { ...counts, total: counts.exports + counts.imports };
  }

  private stat(current: number, previous: number): StatDto {
    const changePercent =
      previous === 0
        ? current > 0
          ? 100
          : 0
        : Math.round(((current - previous) / previous) * 100);
    return { value: current, changePercent };
  }

  /** The 12 calendar months ending with the current one (UTC). */
  private monthBuckets(now: Date) {
    return Array.from({ length: 12 }, (_, i) => {
      const start = new Date(
        Date.UTC(now.getUTCFullYear(), now.getUTCMonth() - 11 + i, 1),
      );
      const key = `${start.getUTCFullYear()}-${String(start.getUTCMonth() + 1).padStart(2, '0')}`;
      return { key, label: MONTHS[start.getUTCMonth()], start };
    });
  }

  /** The last `days` calendar days including today (UTC). */
  private dayBuckets(now: Date, days: number) {
    const today = Date.UTC(
      now.getUTCFullYear(),
      now.getUTCMonth(),
      now.getUTCDate(),
    );
    return Array.from({ length: days }, (_, i) => {
      const start = new Date(today - (days - 1 - i) * DAY_MS);
      const key = start.toISOString().slice(0, 10);
      const label =
        days <= 7 ? WEEKDAYS[start.getUTCDay()] : String(start.getUTCDate());
      return { key, label, start };
    });
  }
}
