import { Column, Entity, Index, JoinColumn, ManyToOne } from 'typeorm';
import { BaseEntity } from '../../common/entities/base.entity';
import { decimalTransformer } from '../../common/transformers/decimal.transformer';
import { User } from '../../users/entities/user.entity';

export enum ShipmentStatus {
  PENDING_PAYMENT = 'pending_payment',
  IN_TRANSIT = 'in_transit',
  DELAYED = 'delayed',
  DELIVERED = 'delivered',
}

export enum ShipmentType {
  EXPORT = 'export',
  IMPORT = 'import',
}

@Entity('shipments')
export class Shipment extends BaseEntity {
  @Index({ unique: true })
  @Column({ name: 'tracking_id', length: 32 })
  trackingId: string;

  @Column({ length: 150 })
  sender: string;

  @Column({ length: 150 })
  receiver: string;

  @Column({ name: 'pickup_from', length: 150 })
  pickupFrom: string;

  @Column({ name: 'delivery_to', length: 150 })
  deliveryTo: string;

  /** ISO 3166-1 alpha-2 code used by the UI to render a flag. */
  @Column({ name: 'pickup_country', length: 2, default: 'NG' })
  pickupCountry: string;

  @Column({ name: 'delivery_country', length: 2, default: 'NG' })
  deliveryCountry: string;

  @Column({
    type: 'numeric',
    precision: 14,
    scale: 2,
    transformer: decimalTransformer,
  })
  amount: number;

  @Column({ type: 'enum', enum: ShipmentStatus })
  status: ShipmentStatus;

  @Column({ type: 'enum', enum: ShipmentType })
  type: ShipmentType;

  @Column({ name: 'processing_hours', type: 'int' })
  processingHours: number;

  @Column({ name: 'is_paid', default: false })
  isPaid: boolean;

  /** When the shipment was booked; drives dashboard stats and charts. */
  @Index()
  @Column({ name: 'shipped_at', type: 'timestamptz' })
  shippedAt: Date;

  @Index()
  @Column({ name: 'user_id', type: 'uuid' })
  userId: string;

  @ManyToOne(() => User, (user) => user.shipments, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'user_id' })
  user: User;
}
