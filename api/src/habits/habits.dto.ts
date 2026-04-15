import { IsString, IsNumber, IsOptional } from 'class-validator';

export class CreateHabitsDto {
  @IsNumber()
  @IsOptional()
  sleepHours?: number;

  @IsNumber()
  @IsOptional()
  waterGlasses?: number;

  @IsString()
  @IsOptional()
  mood?: string;

  @IsString()
  @IsOptional()
  notes?: string;
}
