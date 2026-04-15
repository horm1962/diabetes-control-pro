import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { NutritionLog } from './nutrition.entity';
import { CreateNutritionDto } from './nutrition.dto';
import { User } from '../users/user.entity';

@Injectable()
export class NutritionService {
  constructor(
    @InjectRepository(NutritionLog)
    private nutritionRepository: Repository<NutritionLog>,
  ) {}

  async create(createNutritionDto: CreateNutritionDto, user: User) {
    const nutritionLog = this.nutritionRepository.create({
      ...createNutritionDto,
      user,
    });
    return await this.nutritionRepository.save(nutritionLog);
  }

  async findAllByUser(user: User) {
    return await this.nutritionRepository.find({
      where: { user: { id: user.id } },
      order: { timestamp: 'DESC' },
    });
  }
}
