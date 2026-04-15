import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, ManyToOne } from 'typeorm';
import { User } from '../users/user.entity';

export enum TreatmentType {
  INSULIN = 'insulin',
  ORAL_MEDICATION = 'oral_medication',
  OTHER = 'other',
}

@Entity('treatment_logs')
export class TreatmentLog {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({
    type: 'enum',
    enum: TreatmentType,
    default: TreatmentType.INSULIN,
  })
  type: TreatmentType;

  @Column()
  medicationName: string;

  @Column('decimal')
  dosage: number; // e.g. units of insulin or mg of oral medication

  @Column({ nullable: true })
  unit: string;

  @CreateDateColumn()
  timestamp: Date;

  @Column({ nullable: true })
  notes: string;

  @ManyToOne(() => User, (user) => user.id, { onDelete: 'CASCADE' })
  user: User;
}
