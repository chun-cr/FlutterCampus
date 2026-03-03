import { PrismaService } from '../../prisma/prisma.service';
import { CreateExamCountdownDto } from './dto/create-exam-countdown.dto';
import { UpdateExamCountdownDto } from './dto/update-exam-countdown.dto';
export declare class ExamCountdownService {
    private readonly prismaService;
    constructor(prismaService: PrismaService);
    listByUser(userId: string): Promise<{
        id: string;
        user_id: string;
        exam_name: string;
        exam_date: string;
        exam_type: string;
        note: string | null;
        created_at: string;
    }[]>;
    create(userId: string, payload: CreateExamCountdownDto): Promise<{
        id: string;
        user_id: string;
        exam_name: string;
        exam_date: string;
        exam_type: string;
        note: string | null;
        created_at: string;
    }>;
    update(userId: string, id: string, payload: UpdateExamCountdownDto): Promise<{
        id: string;
        user_id: string;
        exam_name: string;
        exam_date: string;
        exam_type: string;
        note: string | null;
        created_at: string;
    }>;
    remove(userId: string, id: string): Promise<void>;
    private toResponse;
}
