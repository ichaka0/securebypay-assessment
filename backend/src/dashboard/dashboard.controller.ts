import { Controller, Get, Query, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOkResponse, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import type { AuthUser } from '../auth/interfaces/auth-user.interface';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { DashboardService } from './dashboard.service';
import { GrowthQueryDto, OverviewQueryDto } from './dto/dashboard-query.dto';
import {
  BannerDto,
  GrowthResponseDto,
  OverviewResponseDto,
} from './dto/dashboard-response.dto';

@ApiTags('Dashboard')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('dashboard')
export class DashboardController {
  constructor(private readonly dashboardService: DashboardService) {}

  @Get('overview')
  @ApiOkResponse({ type: OverviewResponseDto })
  overview(
    @CurrentUser() user: AuthUser,
    @Query() { period }: OverviewQueryDto,
  ): Promise<OverviewResponseDto> {
    return this.dashboardService.getOverview(user.id, period);
  }

  @Get('growth')
  @ApiOkResponse({ type: GrowthResponseDto })
  growth(
    @CurrentUser() user: AuthUser,
    @Query() { range }: GrowthQueryDto,
  ): Promise<GrowthResponseDto> {
    return this.dashboardService.getGrowth(user.id, range);
  }

  @Get('banners')
  @ApiOkResponse({ type: [BannerDto] })
  banners(): BannerDto[] {
    return this.dashboardService.getBanners();
  }
}
