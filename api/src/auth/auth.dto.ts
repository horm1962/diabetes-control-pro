import { IsEmail, IsNotEmpty, MinLength, IsEnum, IsOptional, IsIn, Matches } from 'class-validator';
import { UserRole } from '../users/user.entity';

export class RegisterDto {
  @IsEmail({}, { message: 'Email inválido' })
  email: string;

  @IsNotEmpty()
  @MinLength(6, { message: 'La contraseña debe tener al menos 6 caracteres' })
  @Matches(/^(?=.*[a-zA-Z])(?=.*\d)/, {
    message: 'La contraseña debe contener al menos una letra y un número',
  })
  password: string;

  @IsEnum(UserRole)
  @IsOptional()
  @IsIn([UserRole.PATIENT, UserRole.DOCTOR], {
    message: 'Solo se permite registrarse como paciente o médico',
  })
  role?: UserRole;
}

export class LoginDto {
  @IsEmail({}, { message: 'Email inválido' })
  email: string;

  @IsNotEmpty()
  password: string;
}
