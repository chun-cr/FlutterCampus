import { IsDateString, IsNotEmpty, IsOptional, IsString } from 'class-validator';

export class CreateExamCountdownDto {
  @IsString()
  @IsNotEmpty()
  examName: string;

  @IsDateString()
  examDate: string;

  @IsString()
  @IsNotEmpty()
  examType: string;

  @IsOptional()
  @IsString()
  note?: string;
}
