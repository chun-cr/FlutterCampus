declare const newsCategories: readonly ["notice", "activity", "academic", "life"];
export declare class QueryNewsDto {
    category?: (typeof newsCategories)[number];
    limit?: number;
    offset?: number;
}
export {};
