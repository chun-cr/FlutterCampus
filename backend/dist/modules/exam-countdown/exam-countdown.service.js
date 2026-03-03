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
Object.defineProperty(exports, "__esModule", { value: true });
exports.ExamCountdownService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../../prisma/prisma.service");
let ExamCountdownService = class ExamCountdownService {
    prismaService;
    constructor(prismaService) {
        this.prismaService = prismaService;
    }
    async listByUser(userId) {
        const exams = await this.prismaService.examCountdown.findMany({
            where: { userId },
            orderBy: { examDate: 'asc' },
        });
        return exams.map((exam) => this.toResponse(exam));
    }
    async create(userId, payload) {
        const exam = await this.prismaService.examCountdown.create({
            data: {
                userId,
                examName: payload.examName,
                examDate: new Date(payload.examDate),
                examType: payload.examType,
                note: payload.note ?? null,
            },
        });
        return this.toResponse(exam);
    }
    async update(userId, id, payload) {
        const existing = await this.prismaService.examCountdown.findUnique({
            where: { id },
        });
        if (!existing) {
            throw new common_1.NotFoundException('考试倒计时不存在');
        }
        if (existing.userId !== userId) {
            throw new common_1.ForbiddenException('无权限修改该考试倒计时');
        }
        const exam = await this.prismaService.examCountdown.update({
            where: { id },
            data: {
                examName: payload.examName,
                examDate: payload.examDate ? new Date(payload.examDate) : undefined,
                examType: payload.examType,
                note: payload.note,
            },
        });
        return this.toResponse(exam);
    }
    async remove(userId, id) {
        const existing = await this.prismaService.examCountdown.findUnique({
            where: { id },
        });
        if (!existing) {
            throw new common_1.NotFoundException('考试倒计时不存在');
        }
        if (existing.userId !== userId) {
            throw new common_1.ForbiddenException('无权限删除该考试倒计时');
        }
        await this.prismaService.examCountdown.delete({ where: { id } });
    }
    toResponse(exam) {
        return {
            id: exam.id,
            user_id: exam.userId,
            exam_name: exam.examName,
            exam_date: exam.examDate.toISOString(),
            exam_type: exam.examType,
            note: exam.note,
            created_at: exam.createdAt.toISOString(),
        };
    }
};
exports.ExamCountdownService = ExamCountdownService;
exports.ExamCountdownService = ExamCountdownService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], ExamCountdownService);
//# sourceMappingURL=exam-countdown.service.js.map