import { Injectable } from '@nestjs/common';
import { UsersService } from '../users/users.service';
import { WalletResponseDto } from './dto/fund-wallet.dto';

/**
 * Wallet operations. Funding is simulated (no payment gateway in scope);
 * the balance is credited directly.
 */
@Injectable()
export class WalletService {
  constructor(private readonly usersService: UsersService) {}

  async fund(userId: string, amount: number): Promise<WalletResponseDto> {
    await this.usersService.adjustWalletBalance(userId, amount);
    const user = await this.usersService.getById(userId);
    return { walletBalance: user.walletBalance };
  }
}
