import { Controller, Get, Post, Body, UseGuards, Request } from '@nestjs/common';
import { VitalsService } from './vitals.service';
import { CreateVitalSignDto } from './vitals.dto';
import { AuthGuard } from '../auth/auth.guard';

@Controller('vitals')
@UseGuards(AuthGuard)
export class VitalsController {
  constructor(private readonly vitalsService: VitalsService) {}

  @Post()
  async create(@Body() createDto: CreateVitalSignDto, @Request() req) {
    return this.vitalsService.create(createDto, { id: req.user.id } as any);
  }

  @Get()
  async findAll(@Request() req) {
    return this.vitalsService.findAllByUser({ id: req.user.id } as any);
  }
}
