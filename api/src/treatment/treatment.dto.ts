import { IsString, IsNotEmpty, IsNumber, IsOptional, IsEnum } from 'class-validator';
import { TreatmentType } from './treatment.entity';

export class CreateTreatmentDto {
  @IsEnum(TreatmentType)
  type: TreatmentType;

  @IsString()
  @IsNotEmpty()
  medicationName: string;

  @IsNumber()
  @IsNotEmpty()
  dosage: number;

  @IsString()
  @IsOptional()
  unit?: string;

  @IsString()
  @IsOptional()
  notes?: string;
}
