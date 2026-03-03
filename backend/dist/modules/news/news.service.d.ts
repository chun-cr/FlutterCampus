import { PrismaService } from '../../prisma/prisma.service';
import { QueryNewsDto } from './dto/query-news.dto';
export declare class NewsService {
    private readonly prismaService;
    constructor(prismaService: PrismaService);
    list(query: QueryNewsDto): Promise<{
        total: number;
        items: {
            id: string;
            title: string;
            summary: string | null;
            imageUrl: string | null;
            source: string;
            category: string;
            publishedAt: string;
            isTop: boolean;
        }[];
    }>;
    private toResponse;
}
