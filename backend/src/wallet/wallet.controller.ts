import { Body, Controller, HttpCode, Post, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOkResponse, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import type { AuthUser } from '../auth/interfaces/auth-user.interface';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { FundWalletDto, WalletResponseDto } from './dto/fund-wallet.dto';
import { WalletService } from './wallet.service';

@ApiTags('Wallet')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('wallet')
export class WalletController {
  constructor(private readonly walletService: WalletService) {}

  @Post('fund')
  @HttpCode(200)
  @ApiOkResponse({ type: WalletResponseDto })
  fund(
    @CurrentUser() user: AuthUser,
    @Body() dto: FundWalletDto,
  ): Promise<WalletResponseDto> {
    return this.walletService.fund(user.id, dto.amount);
  }
}
