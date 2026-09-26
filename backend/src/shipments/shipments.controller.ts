import {
  Controller,
  Get,
  HttpCode,
  Param,
  ParseUUIDPipe,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import {
  ApiBadRequestResponse,
  ApiBearerAuth,
  ApiConflictResponse,
  ApiOkResponse,
  ApiTags,
} from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import type { AuthUser } from '../auth/interfaces/auth-user.interface';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { ListShipmentsQueryDto } from './dto/list-shipments-query.dto';
import {
  PaginatedShipmentsDto,
  PayShipmentResponseDto,
} from './dto/shipment-response.dto';
import { ShipmentsService } from './shipments.service';

@ApiTags('Shipments')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('shipments')
export class ShipmentsController {
  constructor(private readonly shipmentsService: ShipmentsService) {}

  @Get()
  @ApiOkResponse({ type: PaginatedShipmentsDto })
  list(
    @CurrentUser() user: AuthUser,
    @Query() query: ListShipmentsQueryDto,
  ): Promise<PaginatedShipmentsDto> {
    return this.shipmentsService.list(user.id, query);
  }

  @Post(':id/pay')
  @HttpCode(200)
  @ApiOkResponse({ type: PayShipmentResponseDto })
  @ApiBadRequestResponse({ description: 'Insufficient wallet balance' })
  @ApiConflictResponse({ description: 'Already paid' })
  pay(
    @CurrentUser() user: AuthUser,
    @Param('id', ParseUUIDPipe) id: string,
  ): Promise<PayShipmentResponseDto> {
    return this.shipmentsService.pay(user.id, id);
  }
}
