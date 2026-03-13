enum ReservationStatus {
  queuing,
  available,
  expired,
  cancelled,
}

// ---------------------------------------------------------------------------
// 图书预定数据模型
// ---------------------------------------------------------------------------
class BookReservation {
  const BookReservation({
    required this.id,
    required this.bookId,
    required this.bookTitle,
    required this.bookAuthor,
    this.bookCoverUrl,
    required this.bookLocation,
    required this.status,
    required this.queuePosition,
    required this.queueTotal,
    this.estimatedReturnDate,
    this.availableDeadline,
    required this.createdAt,
  });

  final String id;
  final String bookId;
  final String bookTitle;
  final String bookAuthor;
  final String? bookCoverUrl;
  final String bookLocation;
  final ReservationStatus status;
  final int queuePosition;
  final int queueTotal;
  final DateTime? estimatedReturnDate;
  final DateTime? availableDeadline;
  final DateTime createdAt;

  factory BookReservation.fromJson(Map<String, dynamic> json) {
    final booksData = _parseBooksData(json['books']);
    final queuePosition = _parseInt(
      json['queue_position'] ?? json['queuePosition'],
    );

    return BookReservation(
      id: json['id'] as String? ?? '',
      bookId: json['book_id'] as String? ?? json['bookId'] as String? ?? '',
      bookTitle: booksData?['title'] as String? ??
          json['book_title'] as String? ??
          json['bookTitle'] as String? ??
          '',
      bookAuthor: booksData?['author'] as String? ??
          json['book_author'] as String? ??
          json['bookAuthor'] as String? ??
          '',
      bookCoverUrl: booksData?['cover_url'] as String? ??
          json['book_cover_url'] as String? ??
          json['bookCoverUrl'] as String?,
      bookLocation: booksData?['location'] as String? ??
          json['book_location'] as String? ??
          json['bookLocation'] as String? ??
          '',
      status: _parseStatus(json['status'] as String? ?? 'queuing'),
      queuePosition: queuePosition,
      queueTotal: _parseInt(
        json['queue_total'] ?? json['queueTotal'],
        fallback: queuePosition,
      ),
      estimatedReturnDate: json['estimated_return_date'] != null
          ? _parseDateTime(json['estimated_return_date'])
          : json['estimatedReturnDate'] != null
              ? _parseDateTime(json['estimatedReturnDate'])
          : null,
      availableDeadline: json['available_deadline'] != null
          ? _parseDateTime(json['available_deadline'])
          : json['availableDeadline'] != null
              ? _parseDateTime(json['availableDeadline'])
          : null,
      createdAt: _parseDateTime(json['created_at'] ?? json['createdAt']) ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'bookId': bookId,
    'bookTitle': bookTitle,
    'bookAuthor': bookAuthor,
    'bookCoverUrl': bookCoverUrl,
    'bookLocation': bookLocation,
    'status': status.name,
    'queuePosition': queuePosition,
    'queueTotal': queueTotal,
    'estimatedReturnDate': estimatedReturnDate?.toIso8601String(),
    'availableDeadline': availableDeadline?.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
  };

  String get statusLabel {
    switch (status) {
      case ReservationStatus.queuing:
        return '预约中';
      case ReservationStatus.available:
        return '可借阅';
      case ReservationStatus.expired:
        return '已失效';
      case ReservationStatus.cancelled:
        return '已取消';
    }
  }

  int get deadlineRemainingDays {
    if (availableDeadline == null) return 0;
    final diff = availableDeadline!.difference(DateTime.now());
    if (diff.isNegative) return 0;
    return (diff.inSeconds / Duration.secondsPerDay).ceil();
  }

  static ReservationStatus _parseStatus(String raw) {
    switch (raw) {
      case 'available':
        return ReservationStatus.available;
      case 'expired':
        return ReservationStatus.expired;
      case 'cancelled':
        return ReservationStatus.cancelled;
      case 'queuing':
      default:
        return ReservationStatus.queuing;
    }
  }

  static Map<String, dynamic>? _parseBooksData(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is List && raw.isNotEmpty && raw.first is Map<String, dynamic>) {
      return raw.first as Map<String, dynamic>;
    }
    return null;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static int _parseInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }
}
