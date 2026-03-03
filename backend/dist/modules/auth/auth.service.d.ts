import { JwtService } from '@nestjs/jwt';
import { PrismaService } from '../../prisma/prisma.service';
import { LoginDto } from './dto/login.dto';
import { RegisterDto } from './dto/register.dto';
import { PublicUser } from './auth.types';
export declare class AuthService {
    private readonly prismaService;
    private readonly jwtService;
    constructor(prismaService: PrismaService, jwtService: JwtService);
    register(payload: RegisterDto): Promise<{
        token: string;
        user: PublicUser;
    }>;
    login(payload: LoginDto): Promise<{
        token: string;
        user: PublicUser;
    }>;
    getProfile(userId: string): Promise<PublicUser>;
    private buildAuthResponse;
    private toPublicUser;
}
