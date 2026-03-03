import { Request } from 'express';
import { AuthUser } from '../auth/auth.types';
import { CreateGradeDto } from './dto/create-grade.dto';
import { UpdateGradeDto } from './dto/update-grade.dto';
import { GradesService } from './grades.service';
type AuthedRequest = Request & {
    user: AuthUser;
};
export declare class GradesController {
    private readonly gradesService;
    constructor(gradesService: GradesService);
    list(request: AuthedRequest): Promise<{
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
    create(request: AuthedRequest, payload: CreateGradeDto): Promise<{
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
    update(request: AuthedRequest, id: string, payload: UpdateGradeDto): Promise<{
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
    remove(request: AuthedRequest, id: string): Promise<{
        success: boolean;
    }>;
}
export {};
