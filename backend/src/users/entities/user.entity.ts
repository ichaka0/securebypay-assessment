import { Column, Entity, Index, OneToMany } from 'typeorm';
import { BaseEntity } from '../../common/entities/base.entity';
import { decimalTransformer } from '../../common/transformers/decimal.transformer';
import { Shipment } from '../../shipments/entities/shipment.entity';

@Entity('users')
export class User extends BaseEntity {
  @Column({ name: 'first_name', length: 100 })
  firstName: string;

  @Column({ name: 'last_name', length: 100 })
  lastName: string;

  @Index({ unique: true })
  @Column({ length: 255 })
  email: string;

  @Column({ name: 'phone_number', length: 20 })
  phoneNumber: string;

  @Column({ name: 'password_hash', select: false })
  passwordHash: string;

  @Column({
    name: 'wallet_balance',
    type: 'numeric',
    precision: 14,
    scale: 2,
    default: 0,
    transformer: decimalTransformer,
  })
  walletBalance: number;

  @Column({
    name: 'reset_token_hash',
    type: 'varchar',
    length: 64,
    nullable: true,
    select: false,
  })
  resetTokenHash: string | null = null;

  @Column({
    name: 'reset_token_expires_at',
    type: 'timestamptz',
    nullable: true,
    select: false,
  })
  resetTokenExpiresAt: Date | null = null;

  @OneToMany(() => Shipment, (shipment) => shipment.user)
  shipments: Shipment[];
}
