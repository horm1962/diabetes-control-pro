import { Controller, Get, Post, Body, UseGuards, Request } from '@nestjs/common';
import { LabResultsService } from './lab_results.service';
import { CreateLabResultDto } from './lab_result.dto';
import { AuthGuard } from '../auth/auth.guard';

@Controller('lab-results')
@UseGuards(AuthGuard)
export class LabResultsController {
  constructor(private readonly labResultsService: LabResultsService) {}

  @Post()
  async create(@Body() createDto: CreateLabResultDto, @Request() req) {
    return this.labResultsService.create(createDto, { id: req.user.id } as any);
  }

  @Get()
  async findAll(@Request() req) {
    return this.labResultsService.findAllByUser({ id: req.user.id } as any);
  }
}
