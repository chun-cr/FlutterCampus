/// 图书馆公告数据模型
/// 对应数据库表 library_announcements
class Announcement {
  const Announcement({
    required this.id,
    required this.title,
    required this.type,
    required this.date,
    this.content,
    this.isUrgent = false,
  });

  final String id;
  final String title;

  /// 公告类型，例如 "通知"、"活动"
  final String type;

  /// 格式化后的日期字符串，例如 "2025-06-12"（来自 published_at）
  final String date;

  /// 公告正文（可选）
  final String? content;

  /// 是否紧急
  final bool isUrgent;

  /// 从 Supabase 查询结果 JSON 映射为模型
  factory Announcement.fromJson(Map<String, dynamic> json) {
    // 将 published_at 转换为 yyyy-MM-dd 格式
    final publishedAt = json['published_at'] as String?;
    String formattedDate = '';
    if (publishedAt != null && publishedAt.isNotEmpty) {
      try {
        final dt = DateTime.parse(publishedAt);
        formattedDate =
            '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
      } catch (_) {
        formattedDate = publishedAt.substring(0, 10);
      }
    }

    return Announcement(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      type: json['type'] as String? ?? '通知',
      date: formattedDate,
      content: json['content'] as String?,
      isUrgent: json['is_urgent'] as bool? ?? false,
    );
  }
}
