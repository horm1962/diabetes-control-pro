import { Controller, Get, Post, Body, UseGuards, Request } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ComplicationsService } from './complications.service';
import { CreateComplicationDto } from './complication.dto';
import { AuthGuard } from '../auth/auth.guard';

@Controller('complications')
@UseGuards(AuthGuard)
export class ComplicationsController {
  constructor(
    private readonly complicationsService: ComplicationsService,
  ) {}

  @Post()
  async create(@Body() createDto: CreateComplicationDto, @Request() req) {
    return this.complicationsService.create(createDto, { id: req.user.id } as any);
  }

  @Get()
  async findAll(@Request() req) {
    return this.complicationsService.findAllByUser({ id: req.user.id } as any);
  }
}
