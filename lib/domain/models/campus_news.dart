/// 校园资讯/新闻实体
class CampusNews {
  final String id;
  final String title;
  final String? summary;
  final String? imageUrl;
  final String source; // 来源，如 '教务处'
  final NewsCategory category;
  final DateTime publishedAt;
  final bool isTop; // 置顶

  CampusNews({
    required this.id,
    required this.title,
    this.summary,
    this.imageUrl,
    required this.source,
    required this.category,
    required this.publishedAt,
    this.isTop = false,
  });

  /// 相对发布时间，如 '1小时前'
  String get relativeTime {
    final diff = DateTime.now().difference(publishedAt);
    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inMinutes < 60) return '${diff.inMinutes}分钟前';
    if (diff.inHours < 24) return '${diff.inHours}小时前';
    if (diff.inDays < 30) return '${diff.inDays}天前';
    return '${publishedAt.month}月${publishedAt.day}日';
  }

  CampusNews copyWith({
    String? id,
    String? title,
    String? summary,
    String? imageUrl,
    String? source,
    NewsCategory? category,
    DateTime? publishedAt,
    bool? isTop,
  }) {
    return CampusNews(
      id: id ?? this.id,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      imageUrl: imageUrl ?? this.imageUrl,
      source: source ?? this.source,
      category: category ?? this.category,
      publishedAt: publishedAt ?? this.publishedAt,
      isTop: isTop ?? this.isTop,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'imageUrl': imageUrl,
      'source': source,
      'category': category.name,
      'publishedAt': publishedAt.toIso8601String(),
      'isTop': isTop,
    };
  }

  factory CampusNews.fromJson(Map<String, dynamic> json) {
    return CampusNews(
      id: json['id'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String?,
      imageUrl: json['imageUrl'] as String?,
      source: json['source'] as String,
      category: NewsCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => NewsCategory.notice,
      ),
      publishedAt: DateTime.parse(json['publishedAt'] as String),
      isTop: json['isTop'] as bool? ?? false,
    );
  }

  @override
  String toString() => 'CampusNews($title)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CampusNews &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// 资讯分类
enum NewsCategory {
  notice, // 通知公告
  activity, // 校园活动
  academic, // 学术讲座
  life; // 生活资讯

  String get label {
    switch (this) {
      case NewsCategory.notice:
        return '通知公告';
      case NewsCategory.activity:
        return '校园活动';
      case NewsCategory.academic:
        return '学术讲座';
      case NewsCategory.life:
        return '生活资讯';
    }
  }
}
