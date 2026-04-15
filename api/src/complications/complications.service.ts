import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ComplicationLog } from './complication.entity';
import { CreateComplicationDto } from './complication.dto';
import { User } from '../users/user.entity';

@Injectable()
export class ComplicationsService {
  constructor(
    @InjectRepository(ComplicationLog)
    private complicationRepository: Repository<ComplicationLog>,
  ) {}

  async create(createDto: CreateComplicationDto, user: User) {
    const log = this.complicationRepository.create({
      ...createDto,
      user,
    });
    return await this.complicationRepository.save(log);
  }

  async findAllByUser(user: User) {
    return await this.complicationRepository.find({
      where: { user: { id: user.id } },
      order: { timestamp: 'DESC' },
    });
  }
}
