import { Controller, Get, Post, Body, UseGuards, Request } from '@nestjs/common';
import { TreatmentService } from './treatment.service';
import { CreateTreatmentDto } from './treatment.dto';
import { AuthGuard } from '../auth/auth.guard';

@Controller('treatment')
@UseGuards(AuthGuard)
export class TreatmentController {
  constructor(private readonly treatmentService: TreatmentService) {}

  @Post()
  async create(@Body() createTreatmentDto: CreateTreatmentDto, @Request() req) {
    return this.treatmentService.create(createTreatmentDto, { id: req.user.id } as any);
  }

  @Get()
  async findAll(@Request() req) {
    return this.treatmentService.findAllByUser({ id: req.user.id } as any);
  }
}
