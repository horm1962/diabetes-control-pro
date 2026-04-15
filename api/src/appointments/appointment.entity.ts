import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, ManyToOne } from 'typeorm';
import { User } from '../users/user.entity';

@Entity('appointments')
export class Appointment {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  title: string;

  @Column('timestamp')
  dateTime: Date;

  @Column({ nullable: true })
  specialty: string;

  @Column({ nullable: true })
  doctorName: string;

  @Column({ nullable: true })
  notes: string;

  @Column({ default: 'scheduled' })
  status: string; // scheduled, completed, cancelled

  @CreateDateColumn()
  createdAt: Date;

  @ManyToOne(() => User, (user) => user.id, { onDelete: 'CASCADE' })
  user: User;
}
