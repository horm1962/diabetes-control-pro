import { IsNumber, IsOptional, IsString } from 'class-validator';

export class CreateLabResultDto {
  @IsNumber()
  @IsOptional()
  hba1c?: number;

  @IsNumber()
  @IsOptional()
  cholesterolResult?: number;

  @IsNumber()
  @IsOptional()
  triglycerides?: number;

  @IsNumber()
  @IsOptional()
  creatinine?: number;

  @IsNumber()
  @IsOptional()
  hemoglobin?: number;

  @IsNumber()
  @IsOptional()
  urea?: number;

  @IsNumber()
  @IsOptional()
  cystatinC?: number;

  @IsString()
  @IsOptional()
  notes?: string;
}
