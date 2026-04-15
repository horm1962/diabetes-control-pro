import { IsNumber, IsEnum, IsDateString, IsOptional, IsString } from 'class-validator';
import { GlucoseContext } from './glucose.entity';

export class CreateGlucoseDto {
  @IsNumber()
  value: number;

  @IsEnum(GlucoseContext)
  context: GlucoseContext;

  @IsDateString()
  timestamp: string;

  @IsOptional()
  @IsString()
  notes?: string;
}
