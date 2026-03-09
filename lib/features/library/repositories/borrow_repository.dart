import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../domain/models/book.dart';
import '../models/borrow_request.dart';

/// 借阅数据仓库：用户自助确认模式
class BorrowRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ---------------------------------------------------------------------------
  // 图书查询
  // ---------------------------------------------------------------------------

  /// 根据 bookId 获取单本图书详情
  Future<Book> fetchById(String bookId) async {
    try {
      final response = await _supabase
          .from('books')
          .select()
          .eq('id', bookId)
          .single();

      return Book.fromJson({
        'id': response['id']?.toString() ?? '',
        'title': response['title'] ?? '',
        'author': response['author'] ?? '',
        'isbn': response['isbn'] ?? '',
        'category': response['category'],
        'summary': response['summary'],
        'location': response['location'] ?? '',
        'totalCopies': response['total_copies'] ?? 0,
        'availableCopies': response['available_copies'] ?? 0,
        'coverUrl': response['cover_url'],
      });
    } catch (e) {
      throw Exception('获取图书详情失败：$e');
    }
  }

  // ---------------------------------------------------------------------------
  // 预约操作
  // ---------------------------------------------------------------------------

  /// 发起预约：插入记录，返回取书码
  ///
  /// 防重规则：同一用户对同一本书，pending 或 borrowed 状态只能有一条
  Future<String> createReservation(String bookId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('用户未登录，请先登录');

    // 1. 检查是否已有活跃预约（pending 或 borrowed）
    final existing = await _supabase
        .from('borrow_request')
        .select('id, reservation_code, status')
        .eq('user_id', user.id)
        .eq('book_id', bookId)
        .inFilter('status', ['pending', 'borrowed']).maybeSingle();

    if (existing != null) {
      final status = existing['status'] as String;
      final hint = status == 'pending' ? '待取书' : '借阅中';
      throw Exception('您已有此书的预约记录（$hint），无法重复预约');
    }

    // 2. 生成唯一取书码（最多重试 5 次）
    String code = '';
    for (int i = 0; i < 5; i++) {
      code = _generateCode();
      final conflict = await _supabase
          .from('borrow_request')
          .select('id')
          .eq('reservation_code', code)
          .maybeSingle();
      if (conflict == null) break;
      if (i == 4) throw Exception('生成取书码失败，请重试');
    }

    // 3. 插入记录
    try {
      await _supabase.from('borrow_request').insert({
        'user_id': user.id,
        'book_id': bookId,
        'status': 'pending',
        'reservation_code': code,
      });
      return code;
    } catch (e) {
      throw Exception('预约失败：$e');
    }
  }

  /// 用户确认已取书：pending → borrowed，记录 confirmed_at，计算 due_date
  Future<void> confirmPickup(String requestId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('用户未登录');

    final now = DateTime.now();
    final dueDate = now.add(const Duration(days: 30));

    try {
      await _supabase
          .from('borrow_request')
          .update({
            'status': 'borrowed',
            'confirmed_at': now.toIso8601String(),
            'due_date': dueDate.toIso8601String(),
          })
          .eq('id', requestId)
          .eq('user_id', user.id)
          .eq('status', 'pending'); // 只允许 pending 状态操作
    } catch (e) {
      throw Exception('确认取书失败：$e');
    }
  }

  /// 用户确认归还：borrowed → returned，记录 returned_at
  Future<void> confirmReturn(String requestId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('用户未登录');

    final now = DateTime.now();

    try {
      await _supabase
          .from('borrow_request')
          .update({
            'status': 'returned',
            'returned_at': now.toIso8601String(),
          })
          .eq('id', requestId)
          .eq('user_id', user.id)
          .eq('status', 'borrowed'); // 只允许 borrowed 状态操作
    } catch (e) {
      throw Exception('确认归还失败：$e');
    }
  }

  /// 取消预约：pending → cancelled
  Future<void> cancelReservation(String requestId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('用户未登录');

    try {
      await _supabase
          .from('borrow_request')
          .update({'status': 'cancelled'})
          .eq('id', requestId)
          .eq('user_id', user.id)
          .eq('status', 'pending'); // 只允许 pending 状态取消
    } catch (e) {
      throw Exception('取消预约失败：$e');
    }
  }

  /// 查询当前用户所有借阅/预约记录（join books 表获取书名、封面、位置）
  Future<List<BorrowRequest>> fetchMyBorrows() async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('用户未登录');

    try {
      final response = await _supabase
          .from('borrow_request')
          .select('*, books(title, cover_url, location)')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => BorrowRequest.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('获取借阅记录失败：$e');
    }
  }

  /// 检查当前用户对某本书是否有 pending 或 borrowed 状态的活跃记录
  /// 返回活跃记录（null 表示可以发起新预约）
  Future<BorrowRequest?> fetchMyActiveReservation(String bookId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    try {
      final response = await _supabase
          .from('borrow_request')
          .select('*, books(title, cover_url, location)')
          .eq('user_id', user.id)
          .eq('book_id', bookId)
          .inFilter('status', ['pending', 'borrowed']).maybeSingle();

      if (response == null) return null;
      return BorrowRequest.fromJson(response as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// 检查某本书是否有可借副本（available_copies > 0）
  Future<bool> checkAvailability(String bookId) async {
    try {
      final response = await _supabase
          .from('books')
          .select('available_copies')
          .eq('id', bookId)
          .single();
      final copies = response['available_copies'] as int? ?? 0;
      return copies > 0;
    } catch (_) {
      return false;
    }
    }
  /// 获取当前用户借阅统计（借阅中数量 + 即将到期数量）
  Future<BorrowStats> fetchMyStats() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return BorrowStats.empty;

    try {
      final response = await _supabase
          .from('borrow_request')
          .select('status, due_date')
          .eq('user_id', user.id)
          .inFilter('status', ['borrowed']);

      final rows = response as List;
      int borrowedCount = 0;
      int dueSoonCount = 0;
      final now = DateTime.now();

      for (final row in rows) {
        borrowedCount++;
        final dueDateStr = row['due_date'] as String?;
        if (dueDateStr != null) {
          final dueDate = DateTime.tryParse(dueDateStr);
          if (dueDate != null) {
            final diff = dueDate.difference(now).inDays;
            if (diff >= 0 && diff <= 3) dueSoonCount++;
          }
        }
      }

      return BorrowStats(
        borrowedCount: borrowedCount,
        hasDueSoon: dueSoonCount > 0,
        dueSoonCount: dueSoonCount,
      );
    } catch (_) {
      return BorrowStats.empty;
    }
  }

  // ---------------------------------------------------------------------------
  // 内部工具
  // ---------------------------------------------------------------------------

  /// 生成 6 位大写字母 + 数字随机组合，去掉易混淆字符 I/O/1/0
  String _generateCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rng = Random.secure();
    return List.generate(6, (_) => chars[rng.nextInt(chars.length)]).join();
  }
}

// ---------------------------------------------------------------------------
// 借阅统计数据模型
// ---------------------------------------------------------------------------

/// 当前用户借阅统计（供首页功能卡片展示）
class BorrowStats {
  const BorrowStats({
    required this.borrowedCount,
    required this.hasDueSoon,
    required this.dueSoonCount,
  });

  /// status == 'borrowed' 的数量
  final int borrowedCount;

  /// 是否有即将到期（距 due_date ≤ 3天）的记录
  final bool hasDueSoon;

  /// 即将到期的数量
  final int dueSoonCount;

  static const empty = BorrowStats(
    borrowedCount: 0,
    hasDueSoon: false,
    dueSoonCount: 0,
  );
}
