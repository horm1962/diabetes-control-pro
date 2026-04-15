import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, ManyToOne } from 'typeorm';
import { User } from '../users/user.entity';

@Entity('habits_logs')
export class HabitsLog {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column('decimal', { nullable: true })
  sleepHours: number;

  @Column('int', { nullable: true })
  waterGlasses: number;

  @Column({ nullable: true })
  mood: string;

  @CreateDateColumn()
  timestamp: Date;

  @Column({ nullable: true })
  notes: string;

  @ManyToOne(() => User, (user) => user.id, { onDelete: 'CASCADE' })
  user: User;
}
