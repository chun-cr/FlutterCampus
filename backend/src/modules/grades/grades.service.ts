import { ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { CreateGradeDto } from './dto/create-grade.dto';
import { UpdateGradeDto } from './dto/update-grade.dto';

@Injectable()
export class GradesService {
  constructor(private readonly prismaService: PrismaService) {}

  async listByUser(userId: string) {
    const grades = await this.prismaService.grade.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
    });

    return grades.map((grade) => this.toResponse(grade));
  }

  async create(userId: string, payload: CreateGradeDto) {
    const gradePoint =
      payload.gradePoint ?? GradesService.calculateGradePoint(payload.score);

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

  async update(userId: string, id: string, payload: UpdateGradeDto) {
    const existing = await this.prismaService.grade.findUnique({
      where: { id },
    });
    if (!existing) {
      throw new NotFoundException('成绩不存在');
    }
    if (existing.userId !== userId) {
      throw new ForbiddenException('无权限修改该成绩');
    }

    const score = payload.score ?? existing.score;
    const gradePoint =
      payload.gradePoint ?? GradesService.calculateGradePoint(score);

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

  async remove(userId: string, id: string) {
    const existing = await this.prismaService.grade.findUnique({
      where: { id },
    });
    if (!existing) {
      throw new NotFoundException('成绩不存在');
    }
    if (existing.userId !== userId) {
      throw new ForbiddenException('无权限删除该成绩');
    }

    await this.prismaService.grade.delete({ where: { id } });
  }

  private toResponse(grade: {
    id: string;
    userId: string;
    courseName: string;
    semester: string;
    score: number;
    gradePoint: number;
    credit: number;
    status: string;
    createdAt: Date;
  }) {
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

  private static calculateGradePoint(score: number) {
    if (score >= 90) return 4.0;
    if (score >= 85) return 3.7;
    if (score >= 82) return 3.3;
    if (score >= 78) return 3.0;
    if (score >= 75) return 2.7;
    if (score >= 72) return 2.3;
    if (score >= 68) return 2.0;
    if (score >= 64) return 1.5;
    if (score >= 60) return 1.0;
    return 0.0;
  }
}
