import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ComplicationLog } from './complication.entity';
import { ComplicationsController } from './complications.controller';
import { ComplicationsService } from './complications.service';
import { User } from '../users/user.entity';
import { AuthModule } from '../auth/auth.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([ComplicationLog, User]),
    AuthModule,
  ],
  controllers: [ComplicationsController],
  providers: [ComplicationsService],
  exports: [ComplicationsService],
})
export class ComplicationsModule {}
