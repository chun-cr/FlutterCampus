import { IsIn, IsNumber, IsOptional, IsString, Min } from 'class-validator';

const gradeStatusValues = ['passed', 'failed', 'retake', 'pending'] as const;

export class UpdateGradeDto {
  @IsOptional()
  @IsString()
  courseName?: string;

  @IsOptional()
  @IsString()
  semester?: string;

  @IsOptional()
  @IsNumber()
  @Min(0)
  score?: number;

  @IsOptional()
  @IsNumber()
  @Min(0)
  credit?: number;

  @IsOptional()
  @IsNumber()
  @Min(0)
  gradePoint?: number;

  @IsOptional()
  @IsString()
  @IsIn(gradeStatusValues)
  status?: (typeof gradeStatusValues)[number];
}
