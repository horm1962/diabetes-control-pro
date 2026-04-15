import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { GlucoseLog } from './glucose.entity';
import { CreateGlucoseDto } from './glucose.dto';
import { User } from '../users/user.entity';

@Injectable()
export class GlucoseService {
  constructor(
    @InjectRepository(GlucoseLog)
    private glucoseRepository: Repository<GlucoseLog>,
  ) {}

  async create(createGlucoseDto: CreateGlucoseDto, user: User) {
    const glucoseLog = this.glucoseRepository.create({
      ...createGlucoseDto,
      user,
    });
    return await this.glucoseRepository.save(glucoseLog);
  }

  async findAllByUser(user: User) {
    return await this.glucoseRepository.find({
      where: { user: { id: user.id } },
      order: { timestamp: 'DESC' },
    });
  }

  async findLatestByUser(user: User) {
    return await this.glucoseRepository.findOne({
      where: { user: { id: user.id } },
      order: { timestamp: 'DESC' },
    });
  }
}
