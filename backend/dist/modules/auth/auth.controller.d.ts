import { Request } from 'express';
import { AuthService } from './auth.service';
import { LoginDto } from './dto/login.dto';
import { RegisterDto } from './dto/register.dto';
import { AuthUser } from './auth.types';
type AuthedRequest = Request & {
    user: AuthUser;
};
export declare class AuthController {
    private readonly authService;
    constructor(authService: AuthService);
    register(payload: RegisterDto): Promise<{
        token: string;
        user: import("./auth.types").PublicUser;
    }>;
    login(payload: LoginDto): Promise<{
        token: string;
        user: import("./auth.types").PublicUser;
    }>;
    me(request: AuthedRequest): Promise<import("./auth.types").PublicUser>;
}
export {};
