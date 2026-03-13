import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/book_reservation.dart';

// ---------------------------------------------------------------------------
// 图书预定统计数据模型
// ---------------------------------------------------------------------------
class ReservationStats {
  const ReservationStats({
    required this.queuingCount,
    required this.availableCount,
  });

  final int queuingCount;
  final int availableCount;
}

// ---------------------------------------------------------------------------
// 图书预定数据仓库
// ---------------------------------------------------------------------------
class ReservationRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<BookReservation>> fetchMyReservations() async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('用户未登录');

    try {
      final response = await _supabase
          .from('book_reservations')
          .select('*, books(title, author, cover_url, location)')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      return (response as List).map((item) {
        final json = item as Map<String, dynamic>;

        return BookReservation.fromJson({
          ...json,
          // 当前数据库未单独存总排队人数，这里先用 queuePosition 兜底展示。
          'queueTotal': json['queue_position'],
        });
      }).toList();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<ReservationStats> fetchMyStats() async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('用户未登录');

    try {
      final response = await _supabase
          .from('book_reservations')
          .select('status')
          .eq('user_id', user.id);

      final rows = response as List;
      int queuingCount = 0;
      int availableCount = 0;

      for (final row in rows) {
        final status = (row as Map<String, dynamic>)['status'] as String? ?? '';
        if (status == 'queuing') {
          queuingCount++;
        } else if (status == 'available') {
          availableCount++;
        }
      }

      return ReservationStats(
        queuingCount: queuingCount,
        availableCount: availableCount,
      );
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<String> createReservation(String bookId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('用户未登录');

    try {
      if (bookId.trim().isEmpty) {
        throw Exception('图书 id 不能为空');
      }

      final existing = await _supabase
          .from('book_reservations')
          .select('id, status')
          .eq('user_id', user.id)
          .eq('book_id', bookId)
          .inFilter('status', ['queuing', 'available'])
          .maybeSingle();

      if (existing != null) {
        throw Exception('您已预约过这本书，请勿重复操作');
      }

      final queueRows = await _supabase
          .from('book_reservations')
          .select('id')
          .eq('book_id', bookId)
          .eq('status', 'queuing');

      final queuePosition = (queueRows as List).length + 1;

      final inserted = await _supabase
          .from('book_reservations')
          .insert({
            'user_id': user.id,
            'book_id': bookId,
            'status': 'queuing',
            'queue_position': queuePosition,
          })
          .select('id')
          .single();

      return inserted['id'] as String? ?? '';
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> cancelReservation(String reservationId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('用户未登录');

    try {
      await _supabase
          .from('book_reservations')
          .update({
            'status': 'cancelled',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', reservationId)
          .eq('user_id', user.id)
          .eq('status', 'queuing');
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
