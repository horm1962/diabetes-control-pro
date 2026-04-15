import { Controller, Get, Post, Body, UseGuards, Request } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ActivityService } from './activity.service';
import { CreateActivityDto } from './activity.dto';
import { AuthGuard } from '../auth/auth.guard';

@Controller('activity')
@UseGuards(AuthGuard)
export class ActivityController {
  constructor(
    private readonly activityService: ActivityService,
  ) {}

  @Post()
  async create(@Body() createActivityDto: CreateActivityDto, @Request() req) {
    return this.activityService.create(createActivityDto, { id: req.user.id } as any);
  }

  @Get()
  async findAll(@Request() req) {
    return this.activityService.findAllByUser({ id: req.user.id } as any);
  }
}
