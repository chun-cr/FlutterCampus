import { Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../../prisma/prisma.service';
import { QueryNewsDto } from './dto/query-news.dto';

@Injectable()
export class NewsService {
  constructor(private readonly prismaService: PrismaService) {}

  async list(query: QueryNewsDto) {
    const where: Prisma.CampusNewsWhereInput = query.category
      ? { category: query.category }
      : {};

    const take = query.limit ?? 20;
    const skip = query.offset ?? 0;

    const [items, total] = await Promise.all([
      this.prismaService.campusNews.findMany({
        where,
        orderBy: [{ isTop: 'desc' }, { publishedAt: 'desc' }],
        take,
        skip,
      }),
      this.prismaService.campusNews.count({ where }),
    ]);

    return {
      total,
      items: items.map((item) => this.toResponse(item)),
    };
  }

  private toResponse(item: {
    id: string;
    title: string;
    summary: string | null;
    imageUrl: string | null;
    source: string;
    category: string;
    isTop: boolean;
    publishedAt: Date;
  }) {
    return {
      id: item.id,
      title: item.title,
      summary: item.summary,
      imageUrl: item.imageUrl,
      source: item.source,
      category: item.category,
      publishedAt: item.publishedAt.toISOString(),
      isTop: item.isTop,
    };
  }
}
