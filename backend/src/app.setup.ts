import { ValidationPipe } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { NestExpressApplication } from '@nestjs/platform-express';
import helmet from 'helmet';
import type { AppConfig } from './config/configuration';
import { AllExceptionsFilter } from './common/filters/http-exception.filter';
import { validationExceptionFactory } from './common/pipes/validation.factory';

/**
 * Applies global middleware, pipes and filters. Shared by `main.ts` and the
 * e2e tests so both run with exactly the same configuration.
 */
export function configureApp(app: NestExpressApplication): void {
  const config = app.get(ConfigService);

  app.setGlobalPrefix('api');
  app.use(helmet());
  const cors = config.getOrThrow<AppConfig['cors']>('cors');
  app.enableCors({ origin: cors.allowAll ? true : cors.origins });

  // Hosting platforms (Render, Railway, Fly…) sit behind a proxy. Trust its
  // X-Forwarded-For header so rate limiting sees each client's real IP
  // instead of lumping every user under the proxy's address.
  if (config.get<boolean>('isProduction')) {
    app.set('trust proxy', 1);
  }
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
      exceptionFactory: validationExceptionFactory,
    }),
  );
  app.useGlobalFilters(new AllExceptionsFilter());
}
