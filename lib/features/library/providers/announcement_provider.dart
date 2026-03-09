import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/announcement.dart';
import '../repositories/announcement_repository.dart';

/// AnnouncementRepository 的全局 Provider
final announcementRepositoryProvider = Provider<AnnouncementRepository>((ref) {
  return AnnouncementRepository();
});

/// 馆内公告 Provider：图书馆首页公告轮播使用
final announcementsProvider = FutureProvider<List<Announcement>>((ref) async {
  final repo = ref.watch(announcementRepositoryProvider);
  return repo.fetchAll(limit: 10);
});
