import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, ManyToOne } from 'typeorm';
import { User } from '../users/user.entity';

@Entity('vital_signs')
export class VitalSign {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column('int')
  systolic: number;

  @Column('int')
  diastolic: number;

  @Column('int', { nullable: true })
  heartRate: number;

  @CreateDateColumn()
  timestamp: Date;

  @Column({ nullable: true })
  notes: string;

  @ManyToOne(() => User, (user) => user.id, { onDelete: 'CASCADE' })
  user: User;
}
