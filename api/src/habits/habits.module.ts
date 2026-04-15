import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { HabitsController } from './habits.controller';
import { HabitsService } from './habits.service';
import { HabitsLog } from './habits.entity';

@Module({
  imports: [TypeOrmModule.forFeature([HabitsLog])],
  controllers: [HabitsController],
  providers: [HabitsService],
  exports: [HabitsService],
})
export class HabitsModule {}
