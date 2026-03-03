class Book {
  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.isbn,
    this.category,
    this.summary,
    required this.location,
    required this.totalCopies,
    required this.availableCopies,
    this.coverUrl,
  });

  factory Book.fromJson(Map<String, dynamic> json) => Book(
    id: json['id'],
    title: json['title'],
    author: json['author'],
    isbn: json['isbn'],
    category: json['category'],
    summary: json['summary'],
    location: json['location'],
    totalCopies: json['totalCopies'],
    availableCopies: json['availableCopies'],
    coverUrl: json['coverUrl'],
  );
  final String id;
  final String title;
  final String author;
  final String isbn;
  final String? category;
  final String? summary;
  final String location;
  final int totalCopies;
  final int availableCopies;
  final String? coverUrl;

  bool get isAvailable => availableCopies > 0;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'author': author,
    'isbn': isbn,
    'category': category,
    'summary': summary,
    'location': location,
    'totalCopies': totalCopies,
    'availableCopies': availableCopies,
    'coverUrl': coverUrl,
  };
}

class BookLoan {
  BookLoan({
    required this.id,
    required this.book,
    required this.borrowDate,
    required this.dueDate,
    this.returnDate,
    this.isRenewed = false,
  });
  final String id;
  final Book book;
  final DateTime borrowDate;
  final DateTime dueDate;
  final DateTime? returnDate;
  final bool isRenewed;

  bool get isOverdue => returnDate == null && DateTime.now().isAfter(dueDate);

  int get remainingDays {
    if (returnDate != null) return 0;
    return dueDate.difference(DateTime.now()).inDays;
  }
}
