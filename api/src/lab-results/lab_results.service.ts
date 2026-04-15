import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { LabResult } from './lab_result.entity';
import { CreateLabResultDto } from './lab_result.dto';
import { User } from '../users/user.entity';

@Injectable()
export class LabResultsService {
  constructor(
    @InjectRepository(LabResult)
    private labResultRepository: Repository<LabResult>,
  ) {}

  async create(createDto: CreateLabResultDto, user: User) {
    const labResult = this.labResultRepository.create({
      ...createDto,
      user: { id: user.id } as User,
    });
    return await this.labResultRepository.save(labResult);
  }

  async findAllByUser(user: User) {
    return await this.labResultRepository.find({
      where: { user: { id: user.id } },
      order: { createdAt: 'DESC' },
    });
  }
}
