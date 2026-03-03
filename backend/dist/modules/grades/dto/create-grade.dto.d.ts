declare const gradeStatusValues: readonly ["passed", "failed", "retake", "pending"];
export declare class CreateGradeDto {
    courseName: string;
    semester: string;
    score: number;
    credit: number;
    gradePoint?: number;
    status?: (typeof gradeStatusValues)[number];
}
export {};
