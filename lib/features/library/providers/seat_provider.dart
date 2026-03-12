import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/seat.dart';
import '../models/seat_reservation.dart';
import '../repositories/seat_repository.dart';

// ---------------------------------------------------------------------------
// Repository Provider
// ---------------------------------------------------------------------------

final seatRepositoryProvider = Provider<SeatRepository>((ref) {
  return SeatRepository();
});

// ---------------------------------------------------------------------------
// 查询参数：楼层 + 区域 + 日期（用于 FutureProvider.family）
// ---------------------------------------------------------------------------

class SeatQuery {
  const SeatQuery({
    required this.floor,
    required this.zone,
    required this.date,
  });

  final String floor;
  final String zone;
  final DateTime date;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SeatQuery &&
          other.floor == floor &&
          other.zone == zone &&
          other.date.year == date.year &&
          other.date.month == date.month &&
          other.date.day == date.day;

  @override
  int get hashCode => Object.hash(floor, zone, date.year, date.month, date.day);
}

// ---------------------------------------------------------------------------
// 座位列表 Provider
// ---------------------------------------------------------------------------

/// 获取指定楼层/区域/日期的座位列表（含当日占用状态）
final seatsProvider =
    FutureProvider.family<List<Seat>, SeatQuery>((ref, query) async {
  final repo = ref.watch(seatRepositoryProvider);
  return repo.fetchSeats(
    floor: query.floor,
    zone: query.zone,
    date: query.date,
  );
});

// ---------------------------------------------------------------------------
// 我的预约列表 Provider
// ---------------------------------------------------------------------------

/// 当前用户的所有预约记录（按时间倒序）
final myReservationsProvider =
    FutureProvider<List<SeatReservation>>((ref) async {
  final repo = ref.watch(seatRepositoryProvider);
  return repo.fetchMyReservations();
});

// ---------------------------------------------------------------------------
// 首页座位卡片：今日可用数量
// ---------------------------------------------------------------------------

/// 默认查询：今天 三楼 A区 可用座位数（供首页功能卡片展示）
final seatAvailableCountProvider = FutureProvider<int>((ref) async {
  final repo = ref.watch(seatRepositoryProvider);
  return repo.fetchAvailableCount(
    floor: '三楼',
    zone: 'A区',
  );
});

// ---------------------------------------------------------------------------
// 当天进行中的预约（供座位预约页顶部提示条使用）
// ---------------------------------------------------------------------------

/// 查询当天 reserved/using 状态的预约，有则返回，无则 null
final myTodayReservationProvider =
    FutureProvider<SeatReservation?>((ref) async {
  final repo = ref.watch(seatRepositoryProvider);
  return repo.fetchMyTodayReservation();
});

// ---------------------------------------------------------------------------
// 预约操作 StateNotifier（创建预约，防重复提交）
// ---------------------------------------------------------------------------

/// 预约操作状态：AsyncValue<String?>，成功时 String 为预约码
class SeatReservationNotifier extends StateNotifier<AsyncValue<String?>> {
  SeatReservationNotifier(this._repo) : super(const AsyncValue.data(null));

  final SeatRepository _repo;

  /// 发起预约；成功返回预约码，失败保留错误状态
  Future<String?> createReservation({
    required String seatId,
    required DateTime date,
    required String startTime,
    required String endTime,
  }) async {
    if (state is AsyncLoading) return null;
    state = const AsyncValue.loading();
    try {
      final code = await _repo.createReservation(
        seatId: seatId,
        date: date,
        startTime: startTime,
        endTime: endTime,
      );
      state = AsyncValue.data(code);
      return code;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  void reset() => state = const AsyncValue.data(null);
}

final seatReservationNotifierProvider = StateNotifierProvider.autoDispose<
    SeatReservationNotifier, AsyncValue<String?>>((ref) {
  final repo = ref.watch(seatRepositoryProvider);
  return SeatReservationNotifier(repo);
});

// ---------------------------------------------------------------------------
// 座位操作 StateNotifier（签到 / 签退 / 取消，防重复提交）
// ---------------------------------------------------------------------------

/// 座位操作状态：AsyncValue<void>
class SeatActionNotifier extends StateNotifier<AsyncValue<void>> {
  SeatActionNotifier(this._repo) : super(const AsyncValue.data(null));

  final SeatRepository _repo;

  /// 签到（reserved → using）
  Future<bool> checkIn(String reservationId) async {
    if (state is AsyncLoading) return false;
    state = const AsyncValue.loading();
    try {
      await _repo.checkIn(reservationId);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  /// 签退（using → completed）
  Future<bool> checkOut(String reservationId) async {
    if (state is AsyncLoading) return false;
    state = const AsyncValue.loading();
    try {
      await _repo.checkOut(reservationId);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  /// 取消预约（reserved → cancelled）
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

final seatActionNotifierProvider = StateNotifierProvider.autoDispose<
    SeatActionNotifier, AsyncValue<void>>((ref) {
  final repo = ref.watch(seatRepositoryProvider);
  return SeatActionNotifier(repo);
});
