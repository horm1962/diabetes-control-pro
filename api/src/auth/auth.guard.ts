import { Injectable, CanActivate, ExecutionContext, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { Request } from 'express';

@Injectable()
export class AuthGuard implements CanActivate {
  constructor(private jwtService: JwtService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const token = this.extractTokenFromHeader(request);

    if (!token) {
      console.warn('AuthGuard: No token found in headers');
      throw new UnauthorizedException('Token no encontrado');
    }

    console.log('AuthGuard: Validating token starting with:', token.substring(0, 10) + '...');

    try {
      const payload = await this.jwtService.verifyAsync(token);
      
      if (!payload?.sub) {
        throw new UnauthorizedException('Token sin identificador de usuario');
      }

      request.user = {
        ...payload,
        id: payload.sub,
      };
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : 'Unknown error';
      console.error(`JWT Verification Error [Length: ${token.length}]:`, errorMessage);
      throw new UnauthorizedException('Token inválido o expirado');
    }
    return true;
  }

  private extractTokenFromHeader(request: Request): string | undefined {
    const [type, token] = request.headers.authorization?.split(' ') ?? [];
    return type === 'Bearer' ? token : undefined;
  }
}
