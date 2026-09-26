import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsEnum, IsOptional } from 'class-validator';

export enum OverviewPeriod {
  WEEK = 'week',
  MONTH = 'month',
  YEAR = 'year',
}

export enum GrowthRange {
  WEEK = 'week',
  MONTH = 'month',
  YEAR = 'year',
}

export class OverviewQueryDto {
  @ApiPropertyOptional({ enum: OverviewPeriod, default: OverviewPeriod.MONTH })
  @IsOptional()
  @IsEnum(OverviewPeriod)
  period: OverviewPeriod = OverviewPeriod.MONTH;
}

export class GrowthQueryDto {
  @ApiPropertyOptional({ enum: GrowthRange, default: GrowthRange.YEAR })
  @IsOptional()
  @IsEnum(GrowthRange)
  range: GrowthRange = GrowthRange.YEAR;
}
