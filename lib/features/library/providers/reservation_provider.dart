import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/book_reservation.dart';
import '../repositories/reservation_repository.dart';

// ---------------------------------------------------------------------------
// Repository Provider
// ---------------------------------------------------------------------------

final reservationRepositoryProvider = Provider<ReservationRepository>((ref) {
  return ReservationRepository();
});

// ---------------------------------------------------------------------------
// 我的预约列表 Provider
// ---------------------------------------------------------------------------

final myReservationsProvider =
    FutureProvider<List<BookReservation>>((ref) async {
      final repo = ref.watch(reservationRepositoryProvider);
      return repo.fetchMyReservations();
    });

// ---------------------------------------------------------------------------
// 首页快捷卡片统计 Provider
// ---------------------------------------------------------------------------

final myReservationStatsProvider =
    FutureProvider<ReservationStats>((ref) async {
      final repo = ref.watch(reservationRepositoryProvider);
      return repo.fetchMyStats();
    });

// ---------------------------------------------------------------------------
// 预约操作 StateNotifier（取消预约）
// ---------------------------------------------------------------------------

class ReservationActionNotifier extends StateNotifier<AsyncValue<void>> {
  ReservationActionNotifier(this._repo) : super(const AsyncValue.data(null));

  final ReservationRepository _repo;

  Future<bool> cancelReservation(String reservationId) async {
    if (state is AsyncLoading) return false;
    state = const AsyncValue.loading();
    try {
      await _repo.cancelReservation(reservationId);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  void reset() => state = const AsyncValue.data(null);
}

final reservationActionNotifierProvider = StateNotifierProvider.autoDispose<
    ReservationActionNotifier,
    AsyncValue<void>>((ref) {
  final repo = ref.watch(reservationRepositoryProvider);
  return ReservationActionNotifier(repo);
});
