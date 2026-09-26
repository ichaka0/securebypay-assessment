import { ApiProperty } from '@nestjs/swagger';
import { GrowthRange, OverviewPeriod } from './dashboard-query.dto';

export class StatDto {
  @ApiProperty({ example: 34 }) value: number;
  /** Percentage change vs. the previous period, e.g. 10 for +10%. */
  @ApiProperty({ example: 10 }) changePercent: number;
}

export class OverviewResponseDto {
  @ApiProperty({ enum: OverviewPeriod }) period: OverviewPeriod;
  @ApiProperty() walletBalance: number;
  @ApiProperty({ type: StatDto }) totalShipments: StatDto;
  @ApiProperty({ type: StatDto }) totalExports: StatDto;
  @ApiProperty({ type: StatDto }) totalImports: StatDto;
}

export class GrowthPointDto {
  @ApiProperty({ example: 'Jan' }) label: string;
  @ApiProperty({ example: 120000 }) value: number;
}

export class GrowthResponseDto {
  @ApiProperty({ enum: GrowthRange }) range: GrowthRange;
  @ApiProperty({ type: [GrowthPointDto] }) points: GrowthPointDto[];
}

export class BannerDto {
  @ApiProperty() id: string;
  @ApiProperty({ example: 'KEEP UP WITH YOUR BUSINESS NEEDS' }) title: string;
  @ApiProperty({ required: false }) subtitle?: string;
  /** Key of a bundled frontend asset for the illustration. */
  @ApiProperty({ example: 'globe_boxes' }) imageKey: string;
}
