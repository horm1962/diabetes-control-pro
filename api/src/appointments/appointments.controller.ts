import { Controller, Get, Post, Body, Patch, Param, UseGuards, Request } from '@nestjs/common';
import { AppointmentsService } from './appointments.service';
import { CreateAppointmentDto, UpdateAppointmentStatusDto } from './appointment.dto';
import { AuthGuard } from '../auth/auth.guard';

@Controller('appointments')
@UseGuards(AuthGuard)
export class AppointmentsController {
  constructor(private readonly appointmentsService: AppointmentsService) {}

  @Post()
  async create(@Body() createDto: CreateAppointmentDto, @Request() req) {
    return this.appointmentsService.create(createDto, { id: req.user.id } as any);
  }

  @Get()
  async findAll(@Request() req) {
    return this.appointmentsService.findAllByUser({ id: req.user.id } as any);
  }

  @Patch(':id/status')
  async updateStatus(
    @Param('id') id: string,
    @Body() updateDto: UpdateAppointmentStatusDto,
    @Request() req
  ) {
    return this.appointmentsService.updateStatus(id, updateDto, { id: req.user.id } as any);
  }
}
