import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/leave_application.dart';

// ── Service ──────────────────────────────────────────────────────────
class LeaveService {
  LeaveService(this._client);
  final SupabaseClient _client;

  static const _table = 'leave_applications';

  /// 查询 pending 状态的请假，按创建时间降序
  Future<List<LeaveApplication>> fetchPendingLeaves() async {
    final response = await _client
        .from(_table)
        .select()
        .eq('status', 'pending')
        .order('created_at', ascending: false);
    return (response as List)
        .map((j) => LeaveApplication.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  /// 查询所有请假记录，按创建时间降序
  Future<List<LeaveApplication>> fetchAllLeaves() async {
    final response = await _client
        .from(_table)
        .select()
        .order('created_at', ascending: false);
    return (response as List)
        .map((j) => LeaveApplication.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  /// 通过审批
  Future<void> approveLeave(
    String id,
    String teacherId, {
    String? comment,
  }) async {
    await _client.from(_table).update({
      'status': 'approved',
      'teacher_id': teacherId,
      if (comment != null && comment.isNotEmpty) 'teacher_comment': comment,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }

  /// 拒绝审批
  Future<void> rejectLeave(
    String id,
    String teacherId, {
    String? comment,
  }) async {
    await _client.from(_table).update({
      'status': 'rejected',
      'teacher_id': teacherId,
      if (comment != null && comment.isNotEmpty) 'teacher_comment': comment,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }

  /// 学生提交请假申请
  Future<LeaveApplication> submitLeave(LeaveApplication leave) async {
    final response = await _client
        .from(_table)
        .insert(leave.toJson())
        .select()
        .single();
    return LeaveApplication.fromJson(response);
  }

  /// 查询当前学生的请假记录
  Future<List<LeaveApplication>> fetchMyLeaves(String studentId) async {
    final response = await _client
        .from(_table)
        .select()
        .eq('student_id', studentId)
        .order('created_at', ascending: false);
    return (response as List)
        .map((j) => LeaveApplication.fromJson(j as Map<String, dynamic>))
        .toList();
  }
  /// 学生撤销请假申请（直接删除记录）
  Future<void> cancelLeave(String id) async {
    await _client.from(_table).delete().eq('id', id);
  }
}

final leaveServiceProvider = Provider<LeaveService>((ref) {
  return LeaveService(Supabase.instance.client);
});

// ── State ─────────────────────────────────────────────────────────────
class LeaveState {
  LeaveState({
    this.leaves = const [],
    this.isLoading = false,
    this.error,
  });

  final List<LeaveApplication> leaves;
  final bool isLoading;
  final String? error;

  LeaveState copyWith({
    List<LeaveApplication>? leaves,
    bool? isLoading,
    String? error,
  }) {
    return LeaveState(
      leaves: leaves ?? this.leaves,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// 待审批列表
  List<LeaveApplication> get pendingLeaves =>
      leaves.where((l) => l.status == 'pending').toList();
}

// ── Notifier ──────────────────────────────────────────────────────────
class LeaveNotifier extends StateNotifier<LeaveState> {
  LeaveNotifier(this._service) : super(LeaveState());

  final LeaveService _service;

  /// 加载待审批列表
  Future<void> loadPendingLeaves() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final leaves = await _service.fetchPendingLeaves();
      state = state.copyWith(leaves: leaves, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  /// 加载全部记录
  Future<void> loadAllLeaves() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final leaves = await _service.fetchAllLeaves();
      state = state.copyWith(leaves: leaves, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  /// 通过审批
  Future<void> approveLeave(
    String id, {
    String? comment,
  }) async {
    final teacherId = Supabase.instance.client.auth.currentUser?.id ?? '';
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _service.approveLeave(id, teacherId, comment: comment);
      // 本地乐观更新
      final updated = state.leaves.map((l) {
        return l.id == id
            ? l.copyWith(
                status: 'approved',
                teacherId: teacherId,
                teacherComment: comment,
              )
            : l;
      }).toList();
      state = state.copyWith(leaves: updated, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  /// 拒绝审批
  Future<void> rejectLeave(
    String id, {
    String? comment,
  }) async {
    final teacherId = Supabase.instance.client.auth.currentUser?.id ?? '';
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _service.rejectLeave(id, teacherId, comment: comment);
      final updated = state.leaves.map((l) {
        return l.id == id
            ? l.copyWith(
                status: 'rejected',
                teacherId: teacherId,
                teacherComment: comment,
              )
            : l;
      }).toList();
      state = state.copyWith(leaves: updated, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
  /// 撤销请假申请，成功后从本地列表移除
  Future<void> cancelLeave(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _service.cancelLeave(id);
      final updated = state.leaves.where((l) => l.id != id).toList();
      state = state.copyWith(leaves: updated, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final leaveStateProvider =
    StateNotifierProvider<LeaveNotifier, LeaveState>((ref) {
  return LeaveNotifier(ref.watch(leaveServiceProvider));
});
