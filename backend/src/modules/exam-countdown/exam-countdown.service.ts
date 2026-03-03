import { ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { CreateExamCountdownDto } from './dto/create-exam-countdown.dto';
import { UpdateExamCountdownDto } from './dto/update-exam-countdown.dto';

@Injectable()
export class ExamCountdownService {
  constructor(private readonly prismaService: PrismaService) {}

  async listByUser(userId: string) {
    const exams = await this.prismaService.examCountdown.findMany({
      where: { userId },
      orderBy: { examDate: 'asc' },
    });
    return exams.map((exam) => this.toResponse(exam));
  }

  async create(userId: string, payload: CreateExamCountdownDto) {
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

  async update(userId: string, id: string, payload: UpdateExamCountdownDto) {
    const existing = await this.prismaService.examCountdown.findUnique({
      where: { id },
    });
    if (!existing) {
      throw new NotFoundException('考试倒计时不存在');
    }
    if (existing.userId !== userId) {
      throw new ForbiddenException('无权限修改该考试倒计时');
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

  async remove(userId: string, id: string) {
    const existing = await this.prismaService.examCountdown.findUnique({
      where: { id },
    });
    if (!existing) {
      throw new NotFoundException('考试倒计时不存在');
    }
    if (existing.userId !== userId) {
      throw new ForbiddenException('无权限删除该考试倒计时');
    }

    await this.prismaService.examCountdown.delete({ where: { id } });
  }

  private toResponse(exam: {
    id: string;
    userId: string;
    examName: string;
    examDate: Date;
    examType: string;
    note: string | null;
    createdAt: Date;
  }) {
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
}
