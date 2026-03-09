import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/book.dart';
import '../models/borrow_request.dart';
import '../repositories/borrow_repository.dart';

// ---------------------------------------------------------------------------
// Repository Provider
// ---------------------------------------------------------------------------

final borrowRepositoryProvider = Provider<BorrowRepository>((ref) {
  return BorrowRepository();
});

// ---------------------------------------------------------------------------
// 图书详情 Provider
// ---------------------------------------------------------------------------

/// 根据 bookId 获取图书详情
final bookDetailProvider =
    FutureProvider.family<Book, String>((ref, bookId) async {
  final repo = ref.watch(borrowRepositoryProvider);
  return repo.fetchById(bookId);
});

// ---------------------------------------------------------------------------
// 预约状态查询 Provider
// ---------------------------------------------------------------------------

/// 当前用户对某本书的活跃预约（pending/borrowed），null 表示可发起新预约
final myActiveReservationProvider =
    FutureProvider.family<BorrowRequest?, String>((ref, bookId) async {
  final repo = ref.watch(borrowRepositoryProvider);
  return repo.fetchMyActiveReservation(bookId);
});

/// 我的借阅/预约列表（按时间倒序）
final myBorrowsProvider = FutureProvider<List<BorrowRequest>>((ref) async {
  final repo = ref.watch(borrowRepositoryProvider);
  return repo.fetchMyBorrows();
});

/// 当前用户借阅统计（借阅中数量 + 即将到期数量）
final myBorrowStatsProvider = FutureProvider<BorrowStats>((ref) async {
  final repo = ref.watch(borrowRepositoryProvider);
  return repo.fetchMyStats();
});


// ---------------------------------------------------------------------------
// 预约操作 StateNotifier（创建预约）
// ---------------------------------------------------------------------------

/// 预约操作状态：AsyncValue<String?>，成功时 String 为取书码
class ReservationNotifier extends StateNotifier<AsyncValue<String?>> {
  ReservationNotifier(this._repo) : super(const AsyncValue.data(null));

  final BorrowRepository _repo;

  /// 发起预约；成功返回取书码，失败保留错误状态
  Future<String?> createReservation(String bookId) async {
    if (state is AsyncLoading) return null;
    state = const AsyncValue.loading();
    try {
      final code = await _repo.createReservation(bookId);
      state = AsyncValue.data(code);
      return code;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  void reset() => state = const AsyncValue.data(null);
}

final reservationNotifierProvider = StateNotifierProvider.autoDispose<
    ReservationNotifier, AsyncValue<String?>>((ref) {
  final repo = ref.watch(borrowRepositoryProvider);
  return ReservationNotifier(repo);
});

// ---------------------------------------------------------------------------
// 借阅状态变更 StateNotifier（确认取书 / 确认归还 / 取消预约）
// ---------------------------------------------------------------------------

/// 借阅操作：一次只执行一个操作，成功后返回 true
class BorrowActionNotifier extends StateNotifier<AsyncValue<void>> {
  BorrowActionNotifier(this._repo) : super(const AsyncValue.data(null));

  final BorrowRepository _repo;

  /// 用户确认已取书（pending → borrowed）
  Future<bool> confirmPickup(String requestId) async {
    if (state is AsyncLoading) return false;
    state = const AsyncValue.loading();
    try {
      await _repo.confirmPickup(requestId);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  /// 用户确认已归还（borrowed → returned）
  Future<bool> confirmReturn(String requestId) async {
    if (state is AsyncLoading) return false;
    state = const AsyncValue.loading();
    try {
      await _repo.confirmReturn(requestId);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  /// 取消预约（pending → cancelled）
  Future<bool> cancelReservation(String requestId) async {
    if (state is AsyncLoading) return false;
    state = const AsyncValue.loading();
    try {
      await _repo.cancelReservation(requestId);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  void reset() => state = const AsyncValue.data(null);
}

final borrowActionNotifierProvider = StateNotifierProvider.autoDispose<
    BorrowActionNotifier, AsyncValue<void>>((ref) {
  final repo = ref.watch(borrowRepositoryProvider);
  return BorrowActionNotifier(repo);
});
