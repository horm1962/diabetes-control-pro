import { IsNumber, IsOptional, IsString, Min, Max } from 'class-validator';

export class CreateVitalSignDto {
  @IsNumber()
  @Min(30)
  @Max(300)
  systolic: number;

  @IsNumber()
  @Min(20)
  @Max(200)
  diastolic: number;

  @IsNumber()
  @IsOptional()
  @Min(30)
  @Max(250)
  heartRate?: number;

  @IsString()
  @IsOptional()
  notes?: string;
}
