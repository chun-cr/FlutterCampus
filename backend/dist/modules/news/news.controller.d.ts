import { QueryNewsDto } from './dto/query-news.dto';
import { NewsService } from './news.service';
export declare class NewsController {
    private readonly newsService;
    constructor(newsService: NewsService);
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
}
