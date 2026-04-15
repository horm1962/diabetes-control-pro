import 'reflect-metadata';
import * as dotenv from 'dotenv';
dotenv.config();

import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // Activar validación global de DTOs
  app.useGlobalPipes(new ValidationPipe({
    whitelist: true,           // Elimina propiedades no declaradas en el DTO
    forbidNonWhitelisted: true, // Rechaza request con propiedades extra
    transform: true,           // Auto-transforma tipos (string → number, etc.)
  }));

  app.enableCors({
    origin: '*',
    methods: 'GET,HEAD,PUT,PATCH,POST,DELETE,OPTIONS',
    credentials: true,
  });

  const secretPrefix = process.env.JWT_SECRET ? process.env.JWT_SECRET.substring(0, 4) : 'UNDEFINED';
  const port = process.env.PORT || 3000;
  
  await app.listen(port, '0.0.0.0');
  
  console.log(`[Diagnostic] JWT_SECRET Prefix: ${secretPrefix}...`);
  console.log(`[Diagnostic] Environment: ${process.env.NODE_ENV}`);
  console.log(`Application is running on: http://0.0.0.0:${port}`);
}
bootstrap();
