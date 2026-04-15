import { IsString, IsNumber, IsEnum, IsOptional, IsDateString, Min } from 'class-validator';
import { Intensity } from './activity.entity';

export class CreateActivityDto {
  @IsString()
  activityType: string;

  @IsNumber()
  @Min(1)
  durationMinutes: number;

  @IsEnum(Intensity)
  intensity: Intensity;

  @IsOptional()
  @IsNumber()
  @Min(0)
  caloriesBurned?: number;

  @IsDateString()
  timestamp: string;

  @IsOptional()
  @IsString()
  notes?: string;
}
