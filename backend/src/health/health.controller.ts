import { Controller, Get } from '@nestjs/common';
import { ApiOkResponse, ApiTags } from '@nestjs/swagger';
import { SkipThrottle } from '@nestjs/throttler';
import { DataSource } from 'typeorm';

@ApiTags('Health')
@SkipThrottle()
@Controller()
export class HealthController {
  constructor(private readonly dataSource: DataSource) {}

  
  @Get('health')
  @ApiOkResponse({ schema: { example: { status: 'ok', database: 'up' } } })
  async check() {
    let database: 'up' | 'down' = 'up';
    try {
      await this.dataSource.query('SELECT 1');
    } catch {
      database = 'down';
    }
    return { status: 'ok', database };
  }

  /** Liveness only; doesn't touch the database so Neon can scale to zero. */
  @Get('ping')
  @ApiOkResponse({ schema: { example: { status: 'ok' } } })
  ping() {
    return { status: 'ok' };
  }
}
