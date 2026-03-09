/// 预约状态枚举（与数据库 CHECK 约束一致）
enum BorrowStatus {
  pending,   // 已预约，待到馆取书
  borrowed,  // 用户已确认取书，借阅中
  returned,  // 用户已确认归还
  cancelled, // 用户取消预约
}

/// 预约记录数据模型（对应 borrow_request 表，含 join books 的书籍信息）
class BorrowRequest {
  final String id;
  final String userId;
  final String bookId;

  // --- join books 表字段（方便直接展示，避免二次查询）---
  final String bookTitle;
  final String? bookCoverUrl;
  final String bookLocation;

  final BorrowStatus status;
  final String reservationCode; // 6位取书码，如 "A3K9BF"
  final DateTime createdAt;
  final DateTime? confirmedAt;  // 用户点击"确认已取书"时间
  final DateTime? dueDate;      // 应还日期 = confirmedAt + 30天
  final DateTime? returnedAt;   // 用户点击"确认归还"时间

  const BorrowRequest({
    required this.id,
    required this.userId,
    required this.bookId,
    required this.bookTitle,
    this.bookCoverUrl,
    required this.bookLocation,
    required this.status,
    required this.reservationCode,
    required this.createdAt,
    this.confirmedAt,
    this.dueDate,
    this.returnedAt,
  });

  /// 是否即将到期（距 dueDate 不足3天，仅 borrowed 状态有效）
  bool get isDueSoon {
    if (dueDate == null) return false;
    final diff = dueDate!.difference(DateTime.now()).inDays;
    return diff >= 0 && diff <= 3;
  }

  /// 距还书剩余天数（负数表示已逾期）
  int? get daysUntilDue {
    if (dueDate == null) return null;
    return dueDate!.difference(DateTime.now()).inDays;
  }

  /// 状态中文标签（含即将到期特殊情况）
  String get statusLabel {
    if (status == BorrowStatus.borrowed && isDueSoon) return '即将到期';
    switch (status) {
      case BorrowStatus.pending:
        return '待取书';
      case BorrowStatus.borrowed:
        return '借阅中';
      case BorrowStatus.returned:
        return '已归还';
      case BorrowStatus.cancelled:
        return '已取消';
    }
  }

  factory BorrowRequest.fromJson(Map<String, dynamic> json) {
    // 支持两种数据结构：
    // 1. 直接 join：json['books'] 是嵌套 Map
    // 2. 平铺（fallback）：json['book_title'] 等
    final booksData = json['books'] as Map<String, dynamic>?;

    return BorrowRequest(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      bookId: json['book_id'] as String,
      bookTitle: booksData?['title'] as String? ??
          json['book_title'] as String? ??
          '',
      bookCoverUrl: booksData?['cover_url'] as String? ??
          json['book_cover_url'] as String?,
      bookLocation: booksData?['location'] as String? ??
          json['book_location'] as String? ??
          '',
      status: _parseStatus(json['status'] as String? ?? 'pending'),
      reservationCode: json['reservation_code'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      confirmedAt: json['confirmed_at'] != null
          ? DateTime.parse(json['confirmed_at'] as String)
          : null,
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : null,
      returnedAt: json['returned_at'] != null
          ? DateTime.parse(json['returned_at'] as String)
          : null,
    );
  }

  static BorrowStatus _parseStatus(String raw) {
    switch (raw) {
      case 'borrowed':
        return BorrowStatus.borrowed;
      case 'returned':
        return BorrowStatus.returned;
      case 'cancelled':
        return BorrowStatus.cancelled;
      case 'pending':
      default:
        return BorrowStatus.pending;
    }
  }
}
