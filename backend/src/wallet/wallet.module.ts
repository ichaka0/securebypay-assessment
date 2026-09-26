import { Module } from '@nestjs/common';
import { UsersModule } from '../users/users.module';
import { WalletController } from './wallet.controller';
import { WalletService } from './wallet.service';

@Module({
  imports: [UsersModule],
  controllers: [WalletController],
  providers: [WalletService],
})
export class WalletModule {}
