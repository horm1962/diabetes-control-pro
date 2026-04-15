import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { TreatmentLog } from './treatment.entity';
import { CreateTreatmentDto } from './treatment.dto';
import { User } from '../users/user.entity';

@Injectable()
export class TreatmentService {
  constructor(
    @InjectRepository(TreatmentLog)
    private treatmentRepository: Repository<TreatmentLog>,
  ) {}

  async create(createTreatmentDto: CreateTreatmentDto, user: User) {
    const treatmentLog = this.treatmentRepository.create({
      ...createTreatmentDto,
      user: { id: user.id } as User,
    });
    return await this.treatmentRepository.save(treatmentLog);
  }

  async findAllByUser(user: User) {
    return await this.treatmentRepository.find({
      where: { user: { id: user.id } },
      order: { timestamp: 'DESC' },
    });
  }
}
