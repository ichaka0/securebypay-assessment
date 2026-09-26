import {
  BadRequestException,
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { DataSource, EntityManager, Repository } from 'typeorm';
import { User } from '../users/entities/user.entity';
import { buildDemoShipments } from './demo-shipments';
import { ListShipmentsQueryDto } from './dto/list-shipments-query.dto';
import {
  PaginatedShipmentsDto,
  PayShipmentResponseDto,
  ShipmentResponseDto,
} from './dto/shipment-response.dto';
import { Shipment } from './entities/shipment.entity';

@Injectable()
export class ShipmentsService {
  constructor(
    @InjectRepository(Shipment)
    private readonly shipments: Repository<Shipment>,
    private readonly dataSource: DataSource,
  ) {}

  /** Newest-first page of the user's shipments. */
  async list(
    userId: string,
    { page, limit }: ListShipmentsQueryDto,
  ): Promise<PaginatedShipmentsDto> {
    const [rows, total] = await this.shipments.findAndCount({
      where: { userId },
      order: { shippedAt: 'DESC' },
      skip: (page - 1) * limit,
      take: limit,
    });
    return {
      items: rows.map((row) => ShipmentResponseDto.fromEntity(row)),
      page,
      limit,
      total,
    };
  }

  /**
   * Pays for an unpaid shipment from the user's wallet.
   * Row locks prevent double-payment and overdrawing on concurrent requests.
   */
  async pay(
    userId: string,
    shipmentId: string,
  ): Promise<PayShipmentResponseDto> {
    return this.dataSource.transaction(async (manager) => {
      const shipment = await manager.getRepository(Shipment).findOne({
        where: { id: shipmentId, userId },
        lock: { mode: 'pessimistic_write' },
      });
      if (!shipment) throw new NotFoundException('Shipment not found');
      if (shipment.isPaid) {
        throw new ConflictException('This shipment has already been paid for');
      }

      const user = await manager.getRepository(User).findOneOrFail({
        where: { id: userId },
        lock: { mode: 'pessimistic_write' },
      });
      if (user.walletBalance < shipment.amount) {
        throw new BadRequestException(
          'Insufficient wallet balance. Please fund your wallet and try again.',
        );
      }

      user.walletBalance = Number(
        (user.walletBalance - shipment.amount).toFixed(2),
      );
      shipment.isPaid = true;
      await manager.save([user, shipment]);

      return {
        shipment: ShipmentResponseDto.fromEntity(shipment),
        walletBalance: user.walletBalance,
      };
    });
  }

  /** Inserts demo shipments for a newly registered user. */
  async seedDemoShipments(user: User, manager: EntityManager): Promise<void> {
    const repo = manager.getRepository(Shipment);
    const rows = buildDemoShipments().map((seed) =>
      repo.create({ ...seed, userId: user.id }),
    );
    await repo.save(rows);
  }
}
