import { PrismaService } from '../../prisma/prisma.service';
import { CreateGradeDto } from './dto/create-grade.dto';
import { UpdateGradeDto } from './dto/update-grade.dto';
export declare class GradesService {
    private readonly prismaService;
    constructor(prismaService: PrismaService);
    listByUser(userId: string): Promise<{
        id: string;
        user_id: string;
        course_name: string;
        semester: string;
        score: number;
        grade_point: number;
        credit: number;
        status: string;
        created_at: string;
    }[]>;
    create(userId: string, payload: CreateGradeDto): Promise<{
        id: string;
        user_id: string;
        course_name: string;
        semester: string;
        score: number;
        grade_point: number;
        credit: number;
        status: string;
        created_at: string;
    }>;
    update(userId: string, id: string, payload: UpdateGradeDto): Promise<{
        id: string;
        user_id: string;
        course_name: string;
        semester: string;
        score: number;
        grade_point: number;
        credit: number;
        status: string;
        created_at: string;
    }>;
    remove(userId: string, id: string): Promise<void>;
    private toResponse;
    private static calculateGradePoint;
}
