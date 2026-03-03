/// 考试类型
enum ExamType {
  midterm, // 期中考试
  final_, // 期末考试
  cet4, // 四级
  cet6, // 六级
  postgraduate, // 考研
  custom; // 自定义

  String get label {
    switch (this) {
      case ExamType.midterm:
        return '期中考试';
      case ExamType.final_:
        return '期末考试';
      case ExamType.cet4:
        return '四级';
      case ExamType.cet6:
        return '六级';
      case ExamType.postgraduate:
        return '考研';
      case ExamType.custom:
        return '自定义';
    }
  }

  static ExamType fromString(String value) {
    switch (value) {
      case 'midterm':
        return ExamType.midterm;
      case 'final_':
        return ExamType.final_;
      case 'cet4':
        return ExamType.cet4;
      case 'cet6':
        return ExamType.cet6;
      case 'postgraduate':
        return ExamType.postgraduate;
      default:
        return ExamType.custom;
    }
  }
}

/// 考试倒计时实体
class ExamCountdown {
  ExamCountdown({
    required this.id,
    required this.userId,
    required this.examName,
    required this.examDate,
    required this.examType,
    this.note,
    required this.createdAt,
  });

  factory ExamCountdown.fromJson(Map<String, dynamic> json) {
    return ExamCountdown(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      examName: json['exam_name'] as String,
      examDate: DateTime.parse(json['exam_date'] as String),
      examType: ExamType.fromString(json['exam_type'] as String),
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
  final String id;
  final String userId;
  final String examName;
  final DateTime examDate;
  final ExamType examType;
  final String? note;
  final DateTime createdAt;

  /// 距离考试剩余天数（负数表示已过期）
  int get daysRemaining {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final examDay = DateTime(examDate.year, examDate.month, examDate.day);
    return examDay.difference(today).inDays;
  }

  /// 是否已过期
  bool get isExpired => daysRemaining < 0;

  /// 是否紧急（7天内）
  bool get isUrgent => !isExpired && daysRemaining <= 7;

  ExamCountdown copyWith({
    String? id,
    String? userId,
    String? examName,
    DateTime? examDate,
    ExamType? examType,
    String? note,
    DateTime? createdAt,
  }) {
    return ExamCountdown(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      examName: examName ?? this.examName,
      examDate: examDate ?? this.examDate,
      examType: examType ?? this.examType,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'exam_name': examName,
      'exam_date': examDate.toIso8601String(),
      'exam_type': examType.name,
      'note': note,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() => 'ExamCountdown($examName: $daysRemaining days)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExamCountdown &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
