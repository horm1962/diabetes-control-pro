import {
  Controller, Get, Post, Body, UseGuards, Request,
  Param, ForbiddenException, NotFoundException,
} from '@nestjs/common';
import { AuthGuard } from '../auth/auth.guard';
import { UserRole } from '../users/user.entity';
import { GlucoseService } from '../glucose/glucose.service';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from '../users/user.entity';
import { Profile } from './profile.entity';

@Controller('doctor')
@UseGuards(AuthGuard)
export class DoctorController {
  constructor(
    @InjectRepository(User)
    private usersRepository: Repository<User>,
    @InjectRepository(Profile)
    private profileRepository: Repository<Profile>,
    private glucoseService: GlucoseService,
  ) {}

  /**
   * Médico: ver todos sus pacientes vinculados.
   * Solo devuelve los pacientes que eligieron a este médico en su perfil.
   */
  @Get('patients')
  async listPatients(@Request() req) {
    if (req.user.role !== UserRole.DOCTOR) {
      throw new ForbiddenException('Solo los médicos pueden acceder a esta ruta');
    }

    const profiles = await this.profileRepository.find({
      where: { doctorId: req.user.sub },
      relations: ['user'],
    });

    return profiles.map((profile) => ({
      id: profile.user?.id,
      email: profile.user?.email,
      profile: {
        firstName: profile.firstName,
        lastName: profile.lastName,
        diabetesType: profile.diabetesType,
        therapyType: profile.therapyType,
        targetGlucoseLow: profile.targetGlucoseLow,
        targetGlucoseHigh: profile.targetGlucoseHigh,
        weightKg: profile.weightKg,
        heightCm: profile.heightCm,
      },
    }));
  }

  /**
   * Médico: ver resumen clínico de un paciente vinculado.
   */
  @Get('patient/:id/summary')
  async getPatientSummary(@Param('id') patientId: string, @Request() req) {
    if (req.user.role !== UserRole.DOCTOR) {
      throw new ForbiddenException();
    }

    // Verificar que el paciente está efectivamente vinculado a este médico
    const profile = await this.profileRepository.findOne({
      where: { user: { id: patientId }, doctorId: req.user.sub },
      relations: ['user'],
    });

    if (!profile) {
      throw new NotFoundException('Paciente no encontrado o no vinculado a este médico');
    }

    const patient = profile.user;
    const latestGlucose = await this.glucoseService.findLatestByUser(patient);
    const glucoseLogs = await this.glucoseService.findAllByUser(patient);

    // Calcular estadísticas básicas
    let avgGlucose = 0;
    let inRangeCount = 0;
    if (glucoseLogs.length > 0) {
      avgGlucose = glucoseLogs.reduce((sum, log) => sum + Number(log.value), 0) / glucoseLogs.length;
      inRangeCount = glucoseLogs.filter(
        (log) => Number(log.value) >= Number(profile.targetGlucoseLow) && Number(log.value) <= Number(profile.targetGlucoseHigh),
      ).length;
    }

    const tirPercent = glucoseLogs.length > 0 ? Math.round((inRangeCount / glucoseLogs.length) * 100) : 0;

    return {
      patient: {
        id: patient.id,
        email: patient.email,
      },
      profile: {
        firstName: profile.firstName,
        lastName: profile.lastName,
        diabetesType: profile.diabetesType,
        therapyType: profile.therapyType,
        targetGlucoseLow: profile.targetGlucoseLow,
        targetGlucoseHigh: profile.targetGlucoseHigh,
        weightKg: profile.weightKg,
        heightCm: profile.heightCm,
        medications: profile.medications,
        insulinType: profile.insulinType,
        allergies: profile.allergies,
      },
      stats: {
        totalLogs: glucoseLogs.length,
        avgGlucose: Math.round(avgGlucose),
        tirPercent,
        latestValue: latestGlucose ? Number(latestGlucose.value) : null,
        latestTimestamp: latestGlucose?.timestamp ?? null,
      },
      recentLogs: glucoseLogs.slice(0, 10).map((log) => ({
        value: log.value,
        context: log.context,
        timestamp: log.timestamp,
        notes: log.notes,
      })),
    };
  }

  /**
   * Doctor: buscar médico por email para que el paciente lo vincule.
   * Este endpoint lo usa el paciente (cualquier rol autenticado puede buscar).
   */
  @Get('search/:email')
  async findDoctorByEmail(@Param('email') email: string, @Request() req) {
    const doctor = await this.usersRepository.findOne({
      where: { email, role: UserRole.DOCTOR },
      relations: ['profile'],
    });

    if (!doctor) {
      throw new NotFoundException('No se encontró ningún médico con ese correo');
    }

    return {
      id: doctor.id,
      email: doctor.email,
      name: doctor.profile
        ? `Dr. ${doctor.profile.firstName} ${doctor.profile.lastName}`
        : doctor.email,
    };
  }
}
