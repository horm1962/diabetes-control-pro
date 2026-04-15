import { Controller, Get, UseGuards, Request } from '@nestjs/common';
import { ReportsService } from './reports.service';
import { AuthGuard } from '../auth/auth.guard';
import { InjectRepository } from '@nestjs/typeorm';
import { Profile } from '../users/profile.entity';
import { Repository } from 'typeorm';

@Controller('reports')
@UseGuards(AuthGuard)
export class ReportsController {
  constructor(
    private readonly reportsService: ReportsService,
    @InjectRepository(Profile)
    private profileRepository: Repository<Profile>,
  ) {}

  @Get('glucose')
  async getGlucoseReport(@Request() req) {
    const profile = await this.profileRepository.findOne({
      where: { user: { id: req.user.id } },
    });
    return this.reportsService.generateGlucoseReport({ id: req.user.id } as any, profile);
  }
}
