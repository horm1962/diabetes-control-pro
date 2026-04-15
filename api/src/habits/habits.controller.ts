import { Controller, Get, Post, Body, UseGuards, Request } from '@nestjs/common';
import { HabitsService } from './habits.service';
import { CreateHabitsDto } from './habits.dto';
import { AuthGuard } from '../auth/auth.guard';

@Controller('habits')
@UseGuards(AuthGuard)
export class HabitsController {
  constructor(private readonly habitsService: HabitsService) {}

  @Post()
  async create(@Body() createHabitsDto: CreateHabitsDto, @Request() req) {
    return this.habitsService.create(createHabitsDto, { id: req.user.id } as any);
  }

  @Get()
  async findAll(@Request() req) {
    return this.habitsService.findAllByUser({ id: req.user.id } as any);
  }
}
