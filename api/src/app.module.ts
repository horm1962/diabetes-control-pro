import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { GlucoseModule } from './glucose/glucose.module';
import { NutritionModule } from './nutrition/nutrition.module';
import { ActivityModule } from './activity/activity.module';
import { ComplicationsModule } from './complications/complications.module';
import { TreatmentModule } from './treatment/treatment.module';
import { HabitsModule } from './habits/habits.module';
import { ReportsModule } from './reports/reports.module';
import { LabResultsModule } from './lab-results/lab_results.module';
import { VitalsModule } from './vitals/vitals.module';
import { AppointmentsModule } from './appointments/appointments.module';

@Module({
  imports: [
    TypeOrmModule.forRoot({
      type: 'postgres',
      url: process.env.DATABASE_URL,
      host: process.env.DATABASE_URL ? undefined : (process.env.DB_HOST || 'localhost'),
      port: process.env.DATABASE_URL ? undefined : (parseInt(process.env.DB_PORT) || 5432),
      username: process.env.DATABASE_URL ? undefined : (process.env.DB_USERNAME || 'postgres'),
      password: process.env.DATABASE_URL ? undefined : (process.env.DB_PASSWORD || 'postgres'),
      database: process.env.DATABASE_URL ? undefined : (process.env.DB_NAME || 'diabetes_db'),
      entities: [__dirname + '/**/*.entity{.ts,.js}'],
      synchronize: true, // Lo mantenemos en true para que cree las tablas automáticamente en Supabase al inicio
      ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false,
    }),
    AuthModule,
    UsersModule,
    GlucoseModule,
    NutritionModule,
    ActivityModule,
    ComplicationsModule,
    TreatmentModule,
    HabitsModule,
    ReportsModule,
    LabResultsModule,
    VitalsModule,
    AppointmentsModule,
  ],
})
export class AppModule {}
