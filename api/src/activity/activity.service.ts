import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ActivityLog } from './activity.entity';
import { CreateActivityDto } from './activity.dto';
import { User } from '../users/user.entity';

@Injectable()
export class ActivityService {
  constructor(
    @InjectRepository(ActivityLog)
    private activityRepository: Repository<ActivityLog>,
  ) {}

  async create(createActivityDto: CreateActivityDto, user: User) {
    const activityLog = this.activityRepository.create({
      ...createActivityDto,
      user,
    });
    return await this.activityRepository.save(activityLog);
  }

  async findAllByUser(user: User) {
    return await this.activityRepository.find({
      where: { user: { id: user.id } },
      order: { timestamp: 'DESC' },
    });
  }
}
