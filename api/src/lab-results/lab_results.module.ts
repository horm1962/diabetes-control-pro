import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { LabResultsController } from './lab_results.controller';
import { LabResultsService } from './lab_results.service';
import { LabResult } from './lab_result.entity';

@Module({
  imports: [TypeOrmModule.forFeature([LabResult])],
  controllers: [LabResultsController],
  providers: [LabResultsService],
  exports: [LabResultsService],
})
export class LabResultsModule {}
