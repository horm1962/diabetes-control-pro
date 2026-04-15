import { Entity, Column, PrimaryGeneratedColumn, OneToOne, ManyToOne, JoinColumn, UpdateDateColumn, CreateDateColumn } from 'typeorm';
import { User } from './user.entity';
import { NumericTransformer } from '../common/transformers/numeric.transformer';

const numericTransformer = new NumericTransformer();

export enum DiabetesType {
  TYPE1 = 'type1',
  TYPE2 = 'type2',
  GESTATIONAL = 'gestational',
}

export enum TherapyType {
  INSULIN = 'insulin',
  ORAL = 'oral',
  COMBINED = 'combined',
  DIET_ONLY = 'diet_only',
}

@Entity('profiles')
export class Profile {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  firstName: string;

  @Column()
  lastName: string;

  @Column({
    type: 'enum',
    enum: DiabetesType,
  })
  diabetesType: DiabetesType;

  @Column({
    type: 'enum',
    enum: TherapyType,
    default: TherapyType.DIET_ONLY,
  })
  therapyType: TherapyType;

  @Column({ type: 'date' })
  birthDate: string;

  @Column({
    type: 'decimal',
    precision: 5,
    scale: 2,
    transformer: numericTransformer,
  })
  weightKg: number;

  @Column({
    type: 'decimal',
    precision: 5,
    scale: 2,
    transformer: numericTransformer,
  })
  heightCm: number;

  @Column({
    type: 'decimal',
    precision: 5,
    scale: 2,
    default: 70,
    transformer: numericTransformer,
  })
  targetGlucoseLow: number;

  @Column({
    type: 'decimal',
    precision: 5,
    scale: 2,
    default: 140,
    transformer: numericTransformer,
  })
  targetGlucoseHigh: number;

  @Column({ nullable: true })
  insulinType: string | null;

  @Column({ type: 'text', nullable: true })
  medications: string | null;

  @Column({ type: 'text', nullable: true })
  allergies: string | null;

  @OneToOne(() => User, (user) => user.profile)
  @JoinColumn()
  user: User;

  // Médico vinculado por el paciente (el paciente elige su médico)
  @ManyToOne(() => User, { nullable: true, eager: false })
  @JoinColumn({ name: 'doctor_id' })
  doctor: User | null;

  @Column({ nullable: true, name: 'doctor_id', type: 'uuid' })
  doctorId: string | null;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
