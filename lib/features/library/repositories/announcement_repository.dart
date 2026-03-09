import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/announcement.dart';

/// 图书馆公告数据仓库：封装对 Supabase library_announcements 表的查询
class AnnouncementRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// 获取馆内公告列表，按发布时间倒序排列
  Future<List<Announcement>> fetchAll({int limit = 10}) async {
    try {
      final response = await _supabase
          .from('library_announcements')
          .select()
          .order('published_at', ascending: false)
          .limit(limit);

      return _mapResponse(response);
    } catch (e) {
      throw Exception('获取馆内公告失败：$e');
    }
  }

  /// 将 Supabase 返回的 JSON 列表映射为 Announcement 模型列表
  List<Announcement> _mapResponse(List<dynamic> response) {
    return response.map((json) {
      return Announcement.fromJson(Map<String, dynamic>.from(json as Map));
    }).toList();
  }
}
