import { IsEnum, IsNumber, IsOptional, IsString, IsDateString } from 'class-validator';
import { MealType } from './nutrition.entity';

export class CreateNutritionDto {
  @IsEnum(MealType)
  mealType: MealType;

  @IsOptional()
  @IsNumber()
  carbsG?: number;

  @IsOptional()
  @IsNumber()
  proteinG?: number;

  @IsOptional()
  @IsNumber()
  fatG?: number;

  @IsOptional()
  @IsNumber()
  calories?: number;

  @IsOptional()
  @IsString()
  notes?: string;

  @IsDateString()
  timestamp: string;
}
