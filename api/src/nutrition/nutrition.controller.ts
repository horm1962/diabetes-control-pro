import { Controller, Get, Post, Body, UseGuards, Request } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { NutritionService } from './nutrition.service';
import { CreateNutritionDto } from './nutrition.dto';
import { AuthGuard } from '../auth/auth.guard';

@Controller('nutrition')
@UseGuards(AuthGuard)
export class NutritionController {
  constructor(
    private readonly nutritionService: NutritionService,
  ) {}

  @Post()
  async create(@Body() createNutritionDto: CreateNutritionDto, @Request() req) {
    return this.nutritionService.create(createNutritionDto, { id: req.user.id } as any);
  }

  @Get()
  async findAll(@Request() req) {
    return this.nutritionService.findAllByUser({ id: req.user.id } as any);
  }
}
