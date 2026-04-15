import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { User } from './user.entity';
import { Profile } from './profile.entity';
import { DoctorController } from './doctor.controller';
import { GlucoseModule } from '../glucose/glucose.module';
import { ProfileController } from './profile.controller';

@Module({
  imports: [
    TypeOrmModule.forFeature([User, Profile]),
    GlucoseModule,
  ],
  controllers: [DoctorController, ProfileController],
  exports: [TypeOrmModule],
})
export class UsersModule {}
