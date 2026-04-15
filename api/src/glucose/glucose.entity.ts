import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, ManyToOne } from 'typeorm';
import { User } from '../users/user.entity';
import { NumericTransformer } from '../common/transformers/numeric.transformer';

const numericTransformer = new NumericTransformer();

export enum GlucoseContext {
  FASTING = 'fasting',
  PRE_MEAL = 'pre_meal',
  POST_MEAL = 'post_meal',
  BEFORE_BED = 'before_bed',
  OTHER = 'other',
}

@Entity('glucose_logs')
export class GlucoseLog {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({
    type: 'decimal',
    precision: 5,
    scale: 2,
    transformer: numericTransformer,
  })
  value: number;

  @Column({
    type: 'enum',
    enum: GlucoseContext,
    default: GlucoseContext.OTHER,
  })
  context: GlucoseContext;

  @Column({ type: 'timestamp' })
  timestamp: Date;

  @Column({ type: 'text', nullable: true })
  notes: string;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  user: User;

  @CreateDateColumn()
  createdAt: Date;
}
