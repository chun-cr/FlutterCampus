import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/book.dart';
import '../repositories/book_repository.dart';

/// BookRepository 的全局 Provider
final bookRepositoryProvider = Provider<BookRepository>((ref) {
  return BookRepository();
});

/// 推荐图书 Provider：首页展示，固定获取 3 本
final recommendedBooksProvider = FutureProvider<List<Book>>((ref) async {
  final repo = ref.watch(bookRepositoryProvider);
  return repo.fetchRecommended(limit: 3);
});

/// 全部图书 Provider：全部图书页使用
final allBooksProvider = FutureProvider<List<Book>>((ref) async {
  final repo = ref.watch(bookRepositoryProvider);
  return repo.fetchAll();
});
