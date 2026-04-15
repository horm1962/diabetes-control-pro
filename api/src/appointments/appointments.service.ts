import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Appointment } from './appointment.entity';
import { CreateAppointmentDto, UpdateAppointmentStatusDto } from './appointment.dto';
import { User } from '../users/user.entity';

@Injectable()
export class AppointmentsService {
  constructor(
    @InjectRepository(Appointment)
    private appointmentRepository: Repository<Appointment>,
  ) {}

  async create(createDto: CreateAppointmentDto, user: User) {
    const appointment = this.appointmentRepository.create({
      ...createDto,
      user: { id: user.id } as User,
    });
    return await this.appointmentRepository.save(appointment);
  }

  async findAllByUser(user: User) {
    return await this.appointmentRepository.find({
      where: { user: { id: user.id } },
      order: { dateTime: 'ASC' },
    });
  }

  async updateStatus(id: string, updateDto: UpdateAppointmentStatusDto, user: User) {
    const appointment = await this.appointmentRepository.findOne({
      where: { id, user: { id: user.id } },
    });

    if (!appointment) {
      throw new NotFoundException('Cita médica no encontrada');
    }

    appointment.status = updateDto.status;
    return await this.appointmentRepository.save(appointment);
  }
}
