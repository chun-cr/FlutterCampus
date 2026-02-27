/// 失物招领实体
class LostAndFound {
  final String id;
  final String title;
  final String description;
  final String location; // 地点
  final LostFoundType type;
  final String? imageUrl;
  final String publisherId;
  final String? contactInfo;
  final DateTime createdAt;
  final bool isResolved; // 是否已解决

  LostAndFound({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.type,
    this.imageUrl,
    required this.publisherId,
    this.contactInfo,
    required this.createdAt,
    this.isResolved = false,
  });

  /// 相对时间
  String get relativeTime {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inMinutes < 60) return '${diff.inMinutes}分钟前';
    if (diff.inHours < 24) return '${diff.inHours}小时前';
    if (diff.inDays < 30) return '${diff.inDays}天前';
    return '${createdAt.month}月${createdAt.day}日';
  }

  LostAndFound copyWith({
    String? id,
    String? title,
    String? description,
    String? location,
    LostFoundType? type,
    String? imageUrl,
    String? publisherId,
    String? contactInfo,
    DateTime? createdAt,
    bool? isResolved,
  }) {
    return LostAndFound(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      publisherId: publisherId ?? this.publisherId,
      contactInfo: contactInfo ?? this.contactInfo,
      createdAt: createdAt ?? this.createdAt,
      isResolved: isResolved ?? this.isResolved,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location,
      'type': type.name,
      'imageUrl': imageUrl,
      'publisherId': publisherId,
      'contactInfo': contactInfo,
      'createdAt': createdAt.toIso8601String(),
      'isResolved': isResolved,
    };
  }

  factory LostAndFound.fromJson(Map<String, dynamic> json) {
    return LostAndFound(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      location: json['location'] as String,
      type: LostFoundType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => LostFoundType.found,
      ),
      imageUrl: json['imageUrl'] as String?,
      publisherId: json['publisherId'] as String,
      contactInfo: json['contactInfo'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isResolved: json['isResolved'] as bool? ?? false,
    );
  }

  @override
  String toString() => 'LostAndFound($title, ${type.label})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LostAndFound &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// 失物招领类型
enum LostFoundType {
  lost, // 寻物
  found; // 招领

  String get label {
    switch (this) {
      case LostFoundType.lost:
        return '寻物';
      case LostFoundType.found:
        return '招领';
    }
  }
}

/// 闲置物品实体
class SecondHandItem {
  final String id;
  final String title;
  final String? description;
  final double price;
  final double? originalPrice;
  final String? imageUrl;
  final String sellerId;
  final ItemCondition condition;
  final DateTime createdAt;
  final bool isSold;

  SecondHandItem({
    required this.id,
    required this.title,
    this.description,
    required this.price,
    this.originalPrice,
    this.imageUrl,
    required this.sellerId,
    this.condition = ItemCondition.good,
    required this.createdAt,
    this.isSold = false,
  });

  /// 折扣率展示，如 '3折'
  String? get discountDisplay {
    if (originalPrice == null || originalPrice! <= 0) return null;
    final discount = (price / originalPrice! * 10).toStringAsFixed(1);
    return '$discount折';
  }

  SecondHandItem copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    double? originalPrice,
    String? imageUrl,
    String? sellerId,
    ItemCondition? condition,
    DateTime? createdAt,
    bool? isSold,
  }) {
    return SecondHandItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      imageUrl: imageUrl ?? this.imageUrl,
      sellerId: sellerId ?? this.sellerId,
      condition: condition ?? this.condition,
      createdAt: createdAt ?? this.createdAt,
      isSold: isSold ?? this.isSold,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'originalPrice': originalPrice,
      'imageUrl': imageUrl,
      'sellerId': sellerId,
      'condition': condition.name,
      'createdAt': createdAt.toIso8601String(),
      'isSold': isSold,
    };
  }

  factory SecondHandItem.fromJson(Map<String, dynamic> json) {
    return SecondHandItem(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      originalPrice: (json['originalPrice'] as num?)?.toDouble(),
      imageUrl: json['imageUrl'] as String?,
      sellerId: json['sellerId'] as String,
      condition: ItemCondition.values.firstWhere(
        (e) => e.name == json['condition'],
        orElse: () => ItemCondition.good,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      isSold: json['isSold'] as bool? ?? false,
    );
  }

  @override
  String toString() => 'SecondHandItem($title, ¥$price)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SecondHandItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// 物品成色
enum ItemCondition {
  brandNew, // 全新
  likeNew, // 几乎全新
  good, // 成色不错
  fair; // 有使用痕迹

  String get label {
    switch (this) {
      case ItemCondition.brandNew:
        return '全新';
      case ItemCondition.likeNew:
        return '几乎全新';
      case ItemCondition.good:
        return '成色不错';
      case ItemCondition.fair:
        return '有使用痕迹';
    }
  }
}

/// 互助任务/找搭子 实体
class HelpTask {
  final String id;
  final String title;
  final String? description;
  final HelpTaskType type;
  final String publisherId;
  final double? reward; // 悬赏金额（跑腿等）
  final int? requiredCount; // 需要人数
  final int currentCount; // 已参与人数
  final DateTime createdAt;
  final bool isCompleted;

  HelpTask({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    required this.publisherId,
    this.reward,
    this.requiredCount,
    this.currentCount = 0,
    required this.createdAt,
    this.isCompleted = false,
  });

  /// 标签展示，如 '跑腿 · 悬赏 ¥2' 或 '运动 · 缺2人'
  String get tagDisplay {
    final parts = <String>[type.label];
    if (reward != null && reward! > 0) {
      parts.add('悬赏 ¥${reward!.toStringAsFixed(0)}');
    }
    if (requiredCount != null) {
      final needed = requiredCount! - currentCount;
      if (needed > 0) parts.add('缺${needed}人');
    }
    return parts.join(' · ');
  }

  /// 相对时间
  String get relativeTime {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inMinutes < 60) return '${diff.inMinutes}分钟前';
    if (diff.inHours < 24) return '${diff.inHours}小时前';
    if (diff.inDays < 30) return '${diff.inDays}天前';
    return '${createdAt.month}月${createdAt.day}日';
  }

  HelpTask copyWith({
    String? id,
    String? title,
    String? description,
    HelpTaskType? type,
    String? publisherId,
    double? reward,
    int? requiredCount,
    int? currentCount,
    DateTime? createdAt,
    bool? isCompleted,
  }) {
    return HelpTask(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      publisherId: publisherId ?? this.publisherId,
      reward: reward ?? this.reward,
      requiredCount: requiredCount ?? this.requiredCount,
      currentCount: currentCount ?? this.currentCount,
      createdAt: createdAt ?? this.createdAt,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'publisherId': publisherId,
      'reward': reward,
      'requiredCount': requiredCount,
      'currentCount': currentCount,
      'createdAt': createdAt.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  factory HelpTask.fromJson(Map<String, dynamic> json) {
    return HelpTask(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      type: HelpTaskType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => HelpTaskType.errand,
      ),
      publisherId: json['publisherId'] as String,
      reward: (json['reward'] as num?)?.toDouble(),
      requiredCount: json['requiredCount'] as int?,
      currentCount: json['currentCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  @override
  String toString() => 'HelpTask($title, ${type.label})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HelpTask &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// 互助任务类型
enum HelpTaskType {
  errand, // 跑腿
  sport, // 运动
  study, // 学习
  other; // 其他

  String get label {
    switch (this) {
      case HelpTaskType.errand:
        return '跑腿';
      case HelpTaskType.sport:
        return '运动';
      case HelpTaskType.study:
        return '学习';
      case HelpTaskType.other:
        return '其他';
    }
  }
}
