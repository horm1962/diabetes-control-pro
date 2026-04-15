import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, ManyToOne } from 'typeorm';
import { User } from '../users/user.entity';

export enum ComplicationType {
  HYPOGLYCEMIA = 'hypoglycemia',
  HYPERGLYCEMIA = 'hyperglycemia',
  KETOACIDOSIS = 'ketoacidosis',
  RETINOPATHY = 'retinopathy',
  NEUROPATHY = 'neuropathy',
  NEPHROPATHY = 'nephropathy',
  CARDIOVASCULAR = 'cardiovascular',
}

@Entity('complications_logs')
export class ComplicationLog {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({
    type: 'enum',
    enum: ComplicationType,
  })
  type: ComplicationType;

  @Column({ type: 'text' })
  symptoms: string;

  @Column({ type: 'int', default: 1 }) // 1: Mild, 2: Moderate, 3: Severe
  severity: number;

  @Column({ type: 'timestamp' })
  timestamp: Date;

  @Column({ type: 'text', nullable: true })
  actionTaken: string;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  user: User;

  @CreateDateColumn()
  createdAt: Date;
}
