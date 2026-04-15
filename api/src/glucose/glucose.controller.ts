import { Controller, Get, Post, Body, UseGuards, Request } from '@nestjs/common';
import { GlucoseService } from './glucose.service';
import { CreateGlucoseDto } from './glucose.dto';
import { AuthGuard } from '../auth/auth.guard';

@Controller('glucose')
@UseGuards(AuthGuard)
export class GlucoseController {
  constructor(private readonly glucoseService: GlucoseService) {}

  @Post()
  async create(@Body() createGlucoseDto: CreateGlucoseDto, @Request() req) {
    return this.glucoseService.create(createGlucoseDto, { id: req.user.id } as any);
  }

  @Get()
  async findAll(@Request() req) {
    return this.glucoseService.findAllByUser({ id: req.user.id } as any);
  }

  @Get('latest')
  async findLatest(@Request() req) {
    return this.glucoseService.findLatestByUser({ id: req.user.id } as any);
  }
}
