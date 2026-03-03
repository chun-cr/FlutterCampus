import { Request } from 'express';
import { AuthUser } from '../auth/auth.types';
import { CreateExamCountdownDto } from './dto/create-exam-countdown.dto';
import { UpdateExamCountdownDto } from './dto/update-exam-countdown.dto';
import { ExamCountdownService } from './exam-countdown.service';
type AuthedRequest = Request & {
    user: AuthUser;
};
export declare class ExamCountdownController {
    private readonly examCountdownService;
    constructor(examCountdownService: ExamCountdownService);
    list(request: AuthedRequest): Promise<{
        id: string;
        user_id: string;
        exam_name: string;
        exam_date: string;
        exam_type: string;
        note: string | null;
        created_at: string;
    }[]>;
    create(request: AuthedRequest, payload: CreateExamCountdownDto): Promise<{
        id: string;
        user_id: string;
        exam_name: string;
        exam_date: string;
        exam_type: string;
        note: string | null;
        created_at: string;
    }>;
    update(request: AuthedRequest, id: string, payload: UpdateExamCountdownDto): Promise<{
        id: string;
        user_id: string;
        exam_name: string;
        exam_date: string;
        exam_type: string;
        note: string | null;
        created_at: string;
    }>;
    remove(request: AuthedRequest, id: string): Promise<{
        success: boolean;
    }>;
}
export {};
