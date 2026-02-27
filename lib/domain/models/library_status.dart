/// 图书馆状态实体（聚合当前借阅与自习室信息）
class LibraryStatus {
  final int currentBorrowCount; // 当前借阅数量
  final int expiringCount; // 即将到期数量
  final int availableSeats; // 剩余座位数
  final String recommendedArea; // 推荐区域，如 '三楼 A区'
  final List<BorrowedBook> borrowedBooks;
  final List<StudyRoom> studyRooms;

  LibraryStatus({
    required this.currentBorrowCount,
    required this.expiringCount,
    required this.availableSeats,
    required this.recommendedArea,
    this.borrowedBooks = const [],
    this.studyRooms = const [],
  });

  LibraryStatus copyWith({
    int? currentBorrowCount,
    int? expiringCount,
    int? availableSeats,
    String? recommendedArea,
    List<BorrowedBook>? borrowedBooks,
    List<StudyRoom>? studyRooms,
  }) {
    return LibraryStatus(
      currentBorrowCount: currentBorrowCount ?? this.currentBorrowCount,
      expiringCount: expiringCount ?? this.expiringCount,
      availableSeats: availableSeats ?? this.availableSeats,
      recommendedArea: recommendedArea ?? this.recommendedArea,
      borrowedBooks: borrowedBooks ?? this.borrowedBooks,
      studyRooms: studyRooms ?? this.studyRooms,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentBorrowCount': currentBorrowCount,
      'expiringCount': expiringCount,
      'availableSeats': availableSeats,
      'recommendedArea': recommendedArea,
      'borrowedBooks': borrowedBooks.map((b) => b.toJson()).toList(),
      'studyRooms': studyRooms.map((r) => r.toJson()).toList(),
    };
  }

  factory LibraryStatus.fromJson(Map<String, dynamic> json) {
    return LibraryStatus(
      currentBorrowCount: json['currentBorrowCount'] as int,
      expiringCount: json['expiringCount'] as int,
      availableSeats: json['availableSeats'] as int,
      recommendedArea: json['recommendedArea'] as String,
      borrowedBooks: (json['borrowedBooks'] as List?)
              ?.map((b) => BorrowedBook.fromJson(b as Map<String, dynamic>))
              .toList() ??
          [],
      studyRooms: (json['studyRooms'] as List?)
              ?.map((r) => StudyRoom.fromJson(r as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// 借阅中的图书
class BorrowedBook {
  final String id;
  final String title;
  final String author;
  final String isbn;
  final DateTime borrowDate;
  final DateTime dueDate;
  final bool isExpiring; // 即将到期（<=3天）

  BorrowedBook({
    required this.id,
    required this.title,
    required this.author,
    required this.isbn,
    required this.borrowDate,
    required this.dueDate,
    bool? isExpiring,
  }) : isExpiring = isExpiring ??
            dueDate.difference(DateTime.now()).inDays <= 3;

  /// 剩余天数
  int get remainingDays => dueDate.difference(DateTime.now()).inDays;

  /// 是否已逾期
  bool get isOverdue => DateTime.now().isAfter(dueDate);

  BorrowedBook copyWith({
    String? id,
    String? title,
    String? author,
    String? isbn,
    DateTime? borrowDate,
    DateTime? dueDate,
    bool? isExpiring,
  }) {
    return BorrowedBook(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      isbn: isbn ?? this.isbn,
      borrowDate: borrowDate ?? this.borrowDate,
      dueDate: dueDate ?? this.dueDate,
      isExpiring: isExpiring ?? this.isExpiring,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'isbn': isbn,
      'borrowDate': borrowDate.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
    };
  }

  factory BorrowedBook.fromJson(Map<String, dynamic> json) {
    return BorrowedBook(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      isbn: json['isbn'] as String,
      borrowDate: DateTime.parse(json['borrowDate'] as String),
      dueDate: DateTime.parse(json['dueDate'] as String),
    );
  }

  @override
  String toString() => 'BorrowedBook($title, due: $dueDate)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BorrowedBook &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// 自习室信息
class StudyRoom {
  final String id;
  final String name; // e.g. '三楼 A区'
  final int totalSeats;
  final int availableSeats;
  final bool isOpen;

  StudyRoom({
    required this.id,
    required this.name,
    required this.totalSeats,
    required this.availableSeats,
    required this.isOpen,
  });

  /// 座位使用率
  double get occupancyRate =>
      totalSeats > 0 ? (totalSeats - availableSeats) / totalSeats : 0;

  StudyRoom copyWith({
    String? id,
    String? name,
    int? totalSeats,
    int? availableSeats,
    bool? isOpen,
  }) {
    return StudyRoom(
      id: id ?? this.id,
      name: name ?? this.name,
      totalSeats: totalSeats ?? this.totalSeats,
      availableSeats: availableSeats ?? this.availableSeats,
      isOpen: isOpen ?? this.isOpen,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'totalSeats': totalSeats,
      'availableSeats': availableSeats,
      'isOpen': isOpen,
    };
  }

  factory StudyRoom.fromJson(Map<String, dynamic> json) {
    return StudyRoom(
      id: json['id'] as String,
      name: json['name'] as String,
      totalSeats: json['totalSeats'] as int,
      availableSeats: json['availableSeats'] as int,
      isOpen: json['isOpen'] as bool,
    );
  }

  @override
  String toString() => 'StudyRoom($name, $availableSeats/$totalSeats)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudyRoom &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
