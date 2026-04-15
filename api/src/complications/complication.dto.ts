import { IsEnum, IsString, IsNumber, IsDateString, IsOptional, Min, Max } from 'class-validator';
import { ComplicationType } from './complication.entity';

export class CreateComplicationDto {
  @IsEnum(ComplicationType)
  type: ComplicationType;

  @IsString()
  symptoms: string;

  @IsNumber()
  @Min(1)
  @Max(3)
  severity: number;

  @IsDateString()
  timestamp: string;

  @IsOptional()
  @IsString()
  actionTaken?: string;
}
