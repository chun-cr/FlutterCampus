import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../domain/models/book.dart';

/// 图书数据仓库：封装所有对 Supabase books 表的查询操作
class BookRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// 获取推荐图书（首页展示，限制条数）
  Future<List<Book>> fetchRecommended({int limit = 3}) async {
    try {
      final response = await _supabase
          .from('books')
          .select()
          .limit(limit);

      return _mapResponseToBooks(response);
    } catch (e) {
      throw Exception('获取推荐图书失败：$e');
    }
  }

  /// 获取全部图书（全部图书页使用）
  Future<List<Book>> fetchAll() async {
    try {
      final response = await _supabase
          .from('books')
          .select()
          .order('title', ascending: true);

      return _mapResponseToBooks(response);
    } catch (e) {
      throw Exception('获取全部图书失败：$e');
    }
  }

  /// 将 Supabase 返回的 snake_case 字段映射到 Book 模型的 camelCase 字段
  List<Book> _mapResponseToBooks(List<dynamic> response) {
    return response.map((json) {
      final mappedJson = {
        'id': json['id']?.toString() ?? '',
        'title': json['title'] ?? '',
        'author': json['author'] ?? '',
        'isbn': json['isbn'] ?? '',
        'category': json['category'],
        'summary': json['summary'],
        'location': json['location'] ?? '',
        'totalCopies': json['total_copies'] ?? 0,
        'availableCopies': json['available_copies'] ?? 0,
        'coverUrl': json['cover_url'],
      };
      return Book.fromJson(mappedJson);
    }).toList();
  }
}
