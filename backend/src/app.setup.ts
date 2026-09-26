import { INestApplication, ValidationPipe } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import helmet from 'helmet';
import { AllExceptionsFilter } from './common/filters/http-exception.filter';
import { validationExceptionFactory } from './common/pipes/validation.factory';

/**
 * Applies global middleware, pipes and filters. Shared by `main.ts` and the
 * e2e tests so both run with exactly the same configuration.
 */
export function configureApp(app: INestApplication): void {
  const config = app.get(ConfigService);

  app.setGlobalPrefix('api');
  app.use(helmet());
  const origin = config.get<string>('corsOrigin', '*');
  app.enableCors({
    origin: origin === '*' ? true : origin.split(',').map((o) => o.trim()),
  });
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
