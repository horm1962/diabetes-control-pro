import { Controller, Get, Post, Patch, Body, UseGuards, Request, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Profile } from './profile.entity';
import { User, UserRole } from './user.entity';
import { AuthGuard } from '../auth/auth.guard';

@Controller('users/profile')
@UseGuards(AuthGuard)
export class ProfileController {
  constructor(
    @InjectRepository(Profile)
    private profileRepository: Repository<Profile>,
    @InjectRepository(User)
    private userRepository: Repository<User>,
  ) {}

  @Get()
  async getProfile(@Request() req) {
    const profile = await this.profileRepository.findOne({
      where: { user: { id: req.user.id } },
    });
    if (!profile) {
      throw new NotFoundException('Perfil no encontrado. Por favor completa tu perfil.');
    }
    return profile;
  }

  @Post()
  async createOrUpdateProfile(@Request() req, @Body() profileData: any) {
    const userId = req.user.id;
    const user = await this.userRepository.findOne({ where: { id: userId } });
    if (!user) {
      throw new NotFoundException('Usuario no encontrado');
    }

    // No permitir que el campo doctorId se modifique por esta ruta
    const { doctorId, doctor, ...safeProfileData } = profileData;

    let profile: Profile | null = await this.profileRepository.findOne({
      where: { user: { id: userId } },
    });

    if (!profile) {
      profile = this.profileRepository.create({
        ...safeProfileData,
        user,
      } as Partial<Profile>);
    } else {
      Object.assign(profile, safeProfileData);
    }

    return await this.profileRepository.save(profile);
  }

  /**
   * El paciente vincula a su médico buscándolo por ID.
   * POST /users/profile/link-doctor  { doctorId: "uuid" }
   */
  @Post('link-doctor')
  async linkDoctor(@Request() req, @Body() body: { doctorId: string }) {
    const userId = req.user.id;

    // Verificar que el doctorId es realmente un médico
    const doctor = await this.userRepository.findOne({
      where: { id: body.doctorId, role: UserRole.DOCTOR },
    });
    if (!doctor) {
      throw new NotFoundException('No se encontró ningún médico con ese ID');
    }

    const profile = await this.profileRepository.findOne({
      where: { user: { id: userId } },
    });
    if (!profile) {
      throw new NotFoundException('Completa tu perfil antes de vincular a un médico');
    }

    profile.doctorId = doctor.id;
    await this.profileRepository.save(profile);

    return { message: 'Médico vinculado exitosamente', doctorEmail: doctor.email };
  }

  /**
   * El paciente desvincula a su médico.
   * POST /users/profile/unlink-doctor
   */
  @Post('unlink-doctor')
  async unlinkDoctor(@Request() req) {
    const userId = req.user.id;
    const profile = await this.profileRepository.findOne({
      where: { user: { id: userId } },
    });
    if (!profile) {
      throw new NotFoundException('Perfil no encontrado');
    }

    profile.doctorId = null;
    await this.profileRepository.save(profile);

    return { message: 'Médico desvinculado exitosamente' };
  }
}
