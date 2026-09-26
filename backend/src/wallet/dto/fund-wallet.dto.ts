import { ApiProperty } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { IsNumber, Max, Min } from 'class-validator';

export class FundWalletDto {
  @ApiProperty({ example: 50000, minimum: 100, maximum: 10_000_000 })
  @Type(() => Number)
  @IsNumber(
    { maxDecimalPlaces: 2, allowNaN: false, allowInfinity: false },
    { message: 'Amount must be a valid number with at most 2 decimal places' },
  )
  @Min(100, { message: 'Minimum funding amount is ₦100' })
  @Max(10_000_000, { message: 'Maximum funding amount is ₦10,000,000' })
  amount: number;
}

export class WalletResponseDto {
  @ApiProperty() walletBalance: number;
}
