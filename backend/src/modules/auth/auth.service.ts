import { ConflictException, Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { PrismaService } from '../../prisma/prisma.service';
import { LoginDto } from './dto/login.dto';
import { RegisterDto } from './dto/register.dto';
import { PublicUser } from './auth.types';

@Injectable()
export class AuthService {
  constructor(
    private readonly prismaService: PrismaService,
    private readonly jwtService: JwtService,
  ) {}

  async register(payload: RegisterDto) {
    const exists = await this.prismaService.user.findUnique({
      where: { email: payload.email },
    });
    if (exists) {
      throw new ConflictException('邮箱已被注册');
    }

    const passwordHash = await bcrypt.hash(payload.password, 10);
    const user = await this.prismaService.user.create({
      data: {
        email: payload.email,
        passwordHash,
        username: payload.username,
        name: payload.name,
        phone: payload.phone,
        type: payload.type,
        studentId: payload.studentId ?? null,
        department: payload.department ?? null,
        avatar: payload.avatar ?? null,
      },
    });

    return this.buildAuthResponse(user.id, user.email, this.toPublicUser(user));
  }

  async login(payload: LoginDto) {
    const user = await this.prismaService.user.findFirst({
      where: {
        OR: [
          { email: payload.identifier },
          { phone: payload.identifier },
          { studentId: payload.identifier },
        ],
      },
    });
    if (!user) {
      throw new UnauthorizedException('账号或密码错误');
    }

    const isMatch = await bcrypt.compare(payload.password, user.passwordHash);
    if (!isMatch) {
      throw new UnauthorizedException('账号或密码错误');
    }

    return this.buildAuthResponse(user.id, user.email, this.toPublicUser(user));
  }

  async getProfile(userId: string) {
    const user = await this.prismaService.user.findUnique({
      where: { id: userId },
    });
    if (!user) {
      throw new UnauthorizedException('用户不存在');
    }
    return this.toPublicUser(user);
  }

  private buildAuthResponse(userId: string, email: string, user: PublicUser) {
    const token = this.jwtService.sign({ sub: userId, email });
    return {
      token,
      user,
    };
  }

  private toPublicUser(user: {
    id: string;
    email: string;
    username: string;
    name: string;
    phone: string;
    type: string;
    studentId: string | null;
    department: string | null;
    avatar: string | null;
  }): PublicUser {
    return {
      id: user.id,
      email: user.email,
      username: user.username,
      name: user.name,
      phone: user.phone,
      type: user.type,
      studentId: user.studentId,
      department: user.department,
      avatar: user.avatar,
    };
  }
}
