import { Controller, Get, Query } from '@nestjs/common';
import { QueryNewsDto } from './dto/query-news.dto';
import { NewsService } from './news.service';

@Controller('news')
export class NewsController {
  constructor(private readonly newsService: NewsService) {}

  @Get()
  async list(@Query() query: QueryNewsDto) {
    return this.newsService.list(query);
  }
}
