import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/seat.dart';
import '../models/seat_reservation.dart';

/// 座位预约数据仓库
class SeatRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ---------------------------------------------------------------------------
  // 座位查询
  // ---------------------------------------------------------------------------

  /// 获取座位列表，并根据当日预约状态动态计算每个座位的 [SeatStatus]
  ///
  /// - [floor]：楼层，如 "3楼"
  /// - [zone]：区域，如 "A区"
  /// - [date]：查询日期
  Future<List<Seat>> fetchSeats({
    required String floor,
    required String zone,
    required DateTime date,
  }) async {
    final user = _supabase.auth.currentUser;

    try {
      // 1. 拉取该楼层+区域所有启用座位
      final seatsResp = await _supabase
          .from('seat')
          .select()
          .eq('floor', floor)
          .eq('zone', zone)
          .eq('is_enabled', true)
          .order('seat_number');

      final seats = (seatsResp as List)
          .map((json) => Seat.fromJson(json as Map<String, dynamic>))
          .toList();

      if (seats.isEmpty) return seats;

      // 2. 先获取该楼层+区域所有座位的 id 列表，再查预约记录
      final dateStr = _formatDate(date);
      final seatIds = seats.map((s) => s.id).toList();
      final reservationsResp = await _supabase
          .from('seat_reservation')
          .select('seat_id, user_id')
          .inFilter('seat_id', seatIds)
          .eq('date', dateStr)
          .inFilter('status', ['reserved', 'using']);

      // seatId → userId 映射
      final occupiedMap = <String, String>{};
      for (final row in (reservationsResp as List)) {
        final seatId = row['seat_id'] as String;
        final userId = row['user_id'] as String;
        occupiedMap[seatId] = userId;
      }

      // 3. 合并状态
      return seats.map((seat) {
        if (occupiedMap.containsKey(seat.id)) {
          final isMyReservation =
              user != null && occupiedMap[seat.id] == user.id;
          return seat.copyWith(
            status: isMyReservation
                ? SeatStatus.myReservation
                : SeatStatus.occupied,
          );
        }
        return seat; // 默认 available
      }).toList();
    } catch (e) {
      throw Exception('获取座位列表失败：$e');
    }
  }

  // ---------------------------------------------------------------------------
  // 预约操作
  // ---------------------------------------------------------------------------

  /// 发起预约，返回 6 位预约码
  ///
  /// 防重规则：同一用户同一天只能有一个进行中的预约（reserved/using）
  Future<String> createReservation({
    required String seatId,
    required DateTime date,
    required String startTime,
    required String endTime,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('用户未登录，请先登录');

    final dateStr = _formatDate(date);

    // 1. 检查当天是否已有进行中的预约
    final existing = await _supabase
        .from('seat_reservation')
        .select('id')
        .eq('user_id', user.id)
        .eq('date', dateStr)
        .inFilter('status', ['reserved', 'using']).maybeSingle();

    if (existing != null) {
      throw Exception('您今天已有一个进行中的座位预约，无法重复预约');
    }

    // 2. 检查该时段该座位是否已被占用
    final conflict = await _supabase
        .from('seat_reservation')
        .select('id')
        .eq('seat_id', seatId)
        .eq('date', dateStr)
        .inFilter('status', ['reserved', 'using']).maybeSingle();

    if (conflict != null) {
      throw Exception('该座位已被预约，请选择其他座位');
    }


    // 3. 生成唯一预约码（最多重试 5 次）
    String code = '';
    for (int i = 0; i < 5; i++) {
      code = _generateCode();
      final codeConflict = await _supabase
          .from('seat_reservation')
          .select('id')
          .eq('reservation_code', code)
          .maybeSingle();
      if (codeConflict == null) break;
      if (i == 4) throw Exception('生成预约码失败，请重试');
    }

    // 5. 插入记录（seat_reservation 表只存 seat_id，不存冗余的 floor/zone/seat_number）
    try {
      await _supabase.from('seat_reservation').insert({
        'user_id': user.id,
        'seat_id': seatId,
        'status': 'reserved',
        'reservation_code': code,
        'date': dateStr,
        'start_time': startTime,
        'end_time': endTime,
      });
      return code;
    } on PostgrestException catch (e) {
      // 唯一约束冲突（数据库层兜底）：座位在此时段已被预约
      if (e.code == '23505' ||
          e.message.contains('duplicate') ||
          e.message.contains('conflict') ||
          e.message.contains('unique')) {
        throw Exception('该座位在此时段已被预约，请选择其他座位或时段');
      }
      throw Exception('预约失败：${e.message}');
    } catch (e) {
      throw Exception('预约失败：$e');
    }
  }

  /// 签到：reserved → using，记录 checked_in_at
  Future<void> checkIn(String reservationId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('用户未登录');

    try {
      await _supabase
          .from('seat_reservation')
          .update({
            'status': 'using',
            'checked_in_at': DateTime.now().toIso8601String(),
          })
          .eq('id', reservationId)
          .eq('user_id', user.id)
          .eq('status', 'reserved'); // 只允许 reserved 状态签到
    } catch (e) {
      throw Exception('签到失败：$e');
    }
  }

  /// 签退：using → completed，记录 checked_out_at
  Future<void> checkOut(String reservationId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('用户未登录');

    try {
      await _supabase
          .from('seat_reservation')
          .update({
            'status': 'completed',
            'checked_out_at': DateTime.now().toIso8601String(),
          })
          .eq('id', reservationId)
          .eq('user_id', user.id)
          .eq('status', 'using'); // 只允许 using 状态签退
    } catch (e) {
      throw Exception('签退失败：$e');
    }
  }

  /// 取消预约：reserved → cancelled
  Future<void> cancelReservation(String reservationId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('用户未登录');

    try {
      await _supabase
          .from('seat_reservation')
          .update({'status': 'cancelled'})
          .eq('id', reservationId)
          .eq('user_id', user.id)
          .eq('status', 'reserved'); // 只允许 reserved 状态取消
    } catch (e) {
      throw Exception('取消预约失败：$e');
    }
  }

  // ---------------------------------------------------------------------------
  // 查询
  // ---------------------------------------------------------------------------

  /// 查询当前用户的所有座位预约记录（按时间倒序）
  Future<List<SeatReservation>> fetchMyReservations() async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('用户未登录');

    try {
      final response = await _supabase
          .from('seat_reservation')
          .select('*, seat(floor, zone, seat_number, has_power, has_window)')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) =>
              SeatReservation.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('获取预约记录失败：$e');
    }
  }

  /// 获取指定樓层+区域今日可用座位数（供首页卡片展示）
  Future<int> fetchAvailableCount({
    required String floor,
    required String zone,
  }) async {
    try {
      final today = DateTime.now();
      final dateStr = _formatDate(today);

      // 查该樓层+区域所有启用座位
      final seatIdsResp = await _supabase
          .from('seat')
          .select('id')
          .eq('floor', floor)
          .eq('zone', zone)
          .eq('is_enabled', true);
      final seatIds = (seatIdsResp as List).map((r) => r['id'] as String).toList();
      final total = seatIds.length;
      if (seatIds.isEmpty) return 0;

      // 查今天已占用座位数
      final occupiedResp = await _supabase
          .from('seat_reservation')
          .select('seat_id')
          .inFilter('seat_id', seatIds)
          .eq('date', dateStr)
          .inFilter('status', ['reserved', 'using']);

      final occupied = (occupiedResp as List).length;
      return (total - occupied).clamp(0, total);
    } catch (_) {
      return 0;
    }
  }

  // ---------------------------------------------------------------------------
  // 静态工具
  // ---------------------------------------------------------------------------

  /// 获取可选时间段列表（08:00~21:00，每小时一段）
  static List<Map<String, String>> getTimeSlots() {
    final slots = <Map<String, String>>[];
    for (int h = 8; h < 21; h++) {
      final start = '${h.toString().padLeft(2, '0')}:00';
      final end = '${(h + 1).toString().padLeft(2, '0')}:00';
      slots.add({'start': start, 'end': end, 'label': '$start-$end'});
    }
    return slots;
  }

  /// 查询当天进行中的预约（reserved/using），供首页提示条使用
  Future<SeatReservation?> fetchMyTodayReservation() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;
    final dateStr = _formatDate(DateTime.now());
    try {
      final response = await _supabase
          .from('seat_reservation')
          .select('*, seat(floor, zone, seat_number, has_power, has_window)')
          .eq('user_id', user.id)
          .eq('date', dateStr)
          .inFilter('status', ['reserved', 'using'])
          .maybeSingle();
      if (response == null) return null;
      return SeatReservation.fromJson(response);
    } catch (_) {
      return null;
    }
  }

  /// 格式化日期为 "yyyy-MM-dd"
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// 生成 6 位大写字母 + 数字随机组合，去掉易混淆字符 I/O/1/0
  String _generateCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rng = Random.secure();
    return List.generate(6, (_) => chars[rng.nextInt(chars.length)]).join();
  }
}
