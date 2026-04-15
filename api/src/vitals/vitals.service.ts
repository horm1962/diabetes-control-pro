import { Injectable, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { VitalSign } from './vitals.entity';
import { CreateVitalSignDto } from './vitals.dto';
import { User } from '../users/user.entity';

@Injectable()
export class VitalsService {
  constructor(
    @InjectRepository(VitalSign)
    private vitalsRepository: Repository<VitalSign>,
  ) {}

  async create(createDto: CreateVitalSignDto, user: User) {
    if (createDto.diastolic >= createDto.systolic) {
      throw new BadRequestException('La presión diastólica no puede ser mayor o igual a la sistólica.');
    }

    const vitalSign = this.vitalsRepository.create({
      ...createDto,
      user: { id: user.id } as User,
    });
    return await this.vitalsRepository.save(vitalSign);
  }

  async findAllByUser(user: User) {
    return await this.vitalsRepository.find({
      where: { user: { id: user.id } },
      order: { timestamp: 'DESC' },
    });
  }
}
