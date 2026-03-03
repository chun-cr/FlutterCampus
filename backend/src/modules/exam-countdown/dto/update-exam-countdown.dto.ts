import { IsDateString, IsOptional, IsString } from 'class-validator';

export class UpdateExamCountdownDto {
  @IsOptional()
  @IsString()
  examName?: string;

  @IsOptional()
  @IsDateString()
  examDate?: string;

  @IsOptional()
  @IsString()
  examType?: string;

  @IsOptional()
  @IsString()
  note?: string;
}
