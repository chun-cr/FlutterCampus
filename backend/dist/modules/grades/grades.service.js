"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var GradesService_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.GradesService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../../prisma/prisma.service");
let GradesService = GradesService_1 = class GradesService {
    prismaService;
    constructor(prismaService) {
        this.prismaService = prismaService;
    }
    async listByUser(userId) {
        const grades = await this.prismaService.grade.findMany({
            where: { userId },
            orderBy: { createdAt: 'desc' },
        });
        return grades.map((grade) => this.toResponse(grade));
    }
    async create(userId, payload) {
        const gradePoint = payload.gradePoint ?? GradesService_1.calculateGradePoint(payload.score);
        const grade = await this.prismaService.grade.create({
            data: {
                userId,
                courseName: payload.courseName,
                semester: payload.semester,
                score: payload.score,
                gradePoint,
                credit: payload.credit,
                status: payload.status ?? 'passed',
            },
        });
        return this.toResponse(grade);
    }
    async update(userId, id, payload) {
        const existing = await this.prismaService.grade.findUnique({
            where: { id },
        });
        if (!existing) {
            throw new common_1.NotFoundException('成绩不存在');
        }
        if (existing.userId !== userId) {
            throw new common_1.ForbiddenException('无权限修改该成绩');
        }
        const score = payload.score ?? existing.score;
        const gradePoint = payload.gradePoint ?? GradesService_1.calculateGradePoint(score);
        const grade = await this.prismaService.grade.update({
            where: { id },
            data: {
                courseName: payload.courseName,
                semester: payload.semester,
                score: payload.score,
                gradePoint,
                credit: payload.credit,
                status: payload.status,
            },
        });
        return this.toResponse(grade);
    }
    async remove(userId, id) {
        const existing = await this.prismaService.grade.findUnique({
            where: { id },
        });
        if (!existing) {
            throw new common_1.NotFoundException('成绩不存在');
        }
        if (existing.userId !== userId) {
            throw new common_1.ForbiddenException('无权限删除该成绩');
        }
        await this.prismaService.grade.delete({ where: { id } });
    }
    toResponse(grade) {
        return {
            id: grade.id,
            user_id: grade.userId,
            course_name: grade.courseName,
            semester: grade.semester,
            score: grade.score,
            grade_point: grade.gradePoint,
            credit: grade.credit,
            status: grade.status,
            created_at: grade.createdAt.toISOString(),
        };
    }
    static calculateGradePoint(score) {
        if (score >= 90)
            return 4.0;
        if (score >= 85)
            return 3.7;
        if (score >= 82)
            return 3.3;
        if (score >= 78)
            return 3.0;
        if (score >= 75)
            return 2.7;
        if (score >= 72)
            return 2.3;
        if (score >= 68)
            return 2.0;
        if (score >= 64)
            return 1.5;
        if (score >= 60)
            return 1.0;
        return 0.0;
    }
};
exports.GradesService = GradesService;
exports.GradesService = GradesService = GradesService_1 = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], GradesService);
//# sourceMappingURL=grades.service.js.map