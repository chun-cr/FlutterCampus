import { IsIn, IsNotEmpty, IsNumber, IsOptional, IsString, Min } from 'class-validator';

const gradeStatusValues = ['passed', 'failed', 'retake', 'pending'] as const;

export class CreateGradeDto {
  @IsString()
  @IsNotEmpty()
  courseName: string;

  @IsString()
  @IsNotEmpty()
  semester: string;

  @IsNumber()
  @Min(0)
  score: number;

  @IsNumber()
  @Min(0)
  credit: number;

  @IsOptional()
  @IsNumber()
  @Min(0)
  gradePoint?: number;

  @IsOptional()
  @IsString()
  @IsIn(gradeStatusValues)
  status?: (typeof gradeStatusValues)[number];
}
