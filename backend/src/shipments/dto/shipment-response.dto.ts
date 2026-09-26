import { ApiProperty } from '@nestjs/swagger';
import {
  Shipment,
  ShipmentStatus,
  ShipmentType,
} from '../entities/shipment.entity';

export class ShipmentResponseDto {
  @ApiProperty() id: string;
  @ApiProperty({ example: 'MAF-100-234-291' }) trackingId: string;
  @ApiProperty() sender: string;
  @ApiProperty() receiver: string;
  @ApiProperty() pickupFrom: string;
  @ApiProperty({ example: 'NG' }) pickupCountry: string;
  @ApiProperty() deliveryTo: string;
  @ApiProperty({ example: 'NG' }) deliveryCountry: string;
  @ApiProperty() amount: number;
  @ApiProperty({ enum: ShipmentStatus }) status: ShipmentStatus;
  @ApiProperty({ enum: ShipmentType }) type: ShipmentType;
  @ApiProperty() processingHours: number;
  @ApiProperty() isPaid: boolean;
  @ApiProperty() shippedAt: Date;

  static fromEntity(s: Shipment): ShipmentResponseDto {
    return {
      id: s.id,
      trackingId: s.trackingId,
      sender: s.sender,
      receiver: s.receiver,
      pickupFrom: s.pickupFrom,
      pickupCountry: s.pickupCountry,
      deliveryTo: s.deliveryTo,
      deliveryCountry: s.deliveryCountry,
      amount: s.amount,
      status: s.status,
      type: s.type,
      processingHours: s.processingHours,
      isPaid: s.isPaid,
      shippedAt: s.shippedAt,
    };
  }
}

export class PaginatedShipmentsDto {
  @ApiProperty({ type: [ShipmentResponseDto] }) items: ShipmentResponseDto[];
  @ApiProperty() page: number;
  @ApiProperty() limit: number;
  @ApiProperty() total: number;
}

export class PayShipmentResponseDto {
  @ApiProperty({ type: ShipmentResponseDto }) shipment: ShipmentResponseDto;
  @ApiProperty() walletBalance: number;
}
