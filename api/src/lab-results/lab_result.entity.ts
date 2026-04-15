import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, ManyToOne, UpdateDateColumn } from 'typeorm';
import { User } from '../users/user.entity';
import { NumericTransformer } from '../common/transformers/numeric.transformer';

const numericTransformer = new NumericTransformer();

@Entity('lab_results')
export class LabResult {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({
    nullable: true,
    type: 'decimal',
    precision: 5,
    scale: 2,
    transformer: numericTransformer,
  })
  hba1c: number;

  @Column({
    nullable: true,
    type: 'decimal',
    precision: 6,
    scale: 2,
    transformer: numericTransformer,
  })
  cholesterolResult: number;

  @Column({
    nullable: true,
    type: 'decimal',
    precision: 6,
    scale: 2,
    transformer: numericTransformer,
  })
  triglycerides: number;

  @Column({
    nullable: true,
    type: 'decimal',
    precision: 6,
    scale: 2,
    transformer: numericTransformer,
  })
  creatinine: number;

  @Column({
    nullable: true,
    type: 'decimal',
    precision: 6,
    scale: 2,
    transformer: numericTransformer,
  })
  hemoglobin: number;

  @Column({
    nullable: true,
    type: 'decimal',
    precision: 6,
    scale: 2,
    transformer: numericTransformer,
  })
  urea: number;

  @Column({
    nullable: true,
    type: 'decimal',
    precision: 6,
    scale: 2,
    transformer: numericTransformer,
  })
  cystatinC: number;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  @ManyToOne(() => User, (user) => user.profile, { onDelete: 'CASCADE' })
  user: User;
}
