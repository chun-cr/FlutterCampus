import { IsIn, IsInt, IsOptional, IsString, Max, Min } from 'class-validator';

const newsCategories = ['notice', 'activity', 'academic', 'life'] as const;

export class QueryNewsDto {
  @IsOptional()
  @IsString()
  @IsIn(newsCategories)
  category?: (typeof newsCategories)[number];

  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(50)
  limit?: number;

  @IsOptional()
  @IsInt()
  @Min(0)
  offset?: number;
}
