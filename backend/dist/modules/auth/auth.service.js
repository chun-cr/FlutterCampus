"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AuthService = void 0;
const common_1 = require("@nestjs/common");
const jwt_1 = require("@nestjs/jwt");
const bcrypt = __importStar(require("bcrypt"));
const prisma_service_1 = require("../../prisma/prisma.service");
let AuthService = class AuthService {
    prismaService;
    jwtService;
    constructor(prismaService, jwtService) {
        this.prismaService = prismaService;
        this.jwtService = jwtService;
    }
    async register(payload) {
        const exists = await this.prismaService.user.findUnique({
            where: { email: payload.email },
        });
        if (exists) {
            throw new common_1.ConflictException('邮箱已被注册');
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
    async login(payload) {
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
            throw new common_1.UnauthorizedException('账号或密码错误');
        }
        const isMatch = await bcrypt.compare(payload.password, user.passwordHash);
        if (!isMatch) {
            throw new common_1.UnauthorizedException('账号或密码错误');
        }
        return this.buildAuthResponse(user.id, user.email, this.toPublicUser(user));
    }
    async getProfile(userId) {
        const user = await this.prismaService.user.findUnique({
            where: { id: userId },
        });
        if (!user) {
            throw new common_1.UnauthorizedException('用户不存在');
        }
        return this.toPublicUser(user);
    }
    buildAuthResponse(userId, email, user) {
        const token = this.jwtService.sign({ sub: userId, email });
        return {
            token,
            user,
        };
    }
    toPublicUser(user) {
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
};
exports.AuthService = AuthService;
exports.AuthService = AuthService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService,
        jwt_1.JwtService])
], AuthService);
//# sourceMappingURL=auth.service.js.map