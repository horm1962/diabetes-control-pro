import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { HabitsLog } from './habits.entity';
import { CreateHabitsDto } from './habits.dto';
import { User } from '../users/user.entity';

@Injectable()
export class HabitsService {
  constructor(
    @InjectRepository(HabitsLog)
    private habitsRepository: Repository<HabitsLog>,
  ) {}

  async create(createHabitsDto: CreateHabitsDto, user: User) {
    const habitsLog = this.habitsRepository.create({
      ...createHabitsDto,
      user: { id: user.id } as User,
    });
    return await this.habitsRepository.save(habitsLog);
  }

  async findAllByUser(user: User) {
    return await this.habitsRepository.find({
      where: { user: { id: user.id } },
      order: { timestamp: 'DESC' },
    });
  }
}
