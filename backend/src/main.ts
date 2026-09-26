import { Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { NestFactory } from '@nestjs/core';
import { NestExpressApplication } from '@nestjs/platform-express';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { AppModule } from './app.module';
import { configureApp } from './app.setup';

async function bootstrap() {
  const app = await NestFactory.create<NestExpressApplication>(AppModule);
  configureApp(app);

  const swaggerConfig = new DocumentBuilder()
    .setTitle('MyShipment API')
    .setDescription('Auth, dashboard, shipments and wallet endpoints')
    .setVersion('1.0')
    .addBearerAuth()
    .build();
  SwaggerModule.setup(
    'docs',
    app,
    SwaggerModule.createDocument(app, swaggerConfig),
  );

  const port = app.get(ConfigService).get<number>('port', 3000);
  await app.listen(port);
  Logger.log(
    `API ready on http://localhost:${port}/api (docs: /docs)`,
    'Bootstrap',
  );
}

void bootstrap();
