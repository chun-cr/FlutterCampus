import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/community.dart';

class HelpTaskService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<HelpTask>> fetchTasks({int? limit}) async {
    try {
      var query = _supabase
          .from('help_tasks')
          .select()
          .order('created_at', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;

      return (response as List).map((data) {
        final mappedJson = {
          'id': data['id']?.toString() ?? '',
          'title': data['title'] ?? '',
          'description': data['description'] ?? '',
          'type': data['type'] ?? 'errand',
          'publisherId': data['publisher_id']?.toString() ?? '',
          'reward': data['reward'] != null ? (data['reward'] as num).toDouble() : null,
          'requiredCount': data['required_count'],
          'currentCount': data['current_count'] ?? 0,
          'createdAt': data['created_at'] ?? DateTime.now().toIso8601String(),
          'isCompleted': data['is_completed'] ?? false,
        };
        return HelpTask.fromJson(mappedJson);
      }).toList();
    } catch (e) {
      print('HelpTaskService fetch error: $e');
      throw Exception('获取互助任务数据失败');
    }
  }
  Future<void> addTask({
    required String title,
    String? description,
    required String type,
    double? reward,
    int? requiredCount,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('未登录');

      await _supabase.from('help_tasks').insert({
        'title': title,
        'description': description,
        'type': type,
        'publisher_id': user.id,
        'reward': reward,
        'required_count': requiredCount,
        'created_at': DateTime.now().toIso8601String(),
        'is_completed': false,
        'current_count': 0,
      });
    } catch (e) {
      print('HelpTaskService insert error: $e');
      throw Exception('发布互助请求失败');
    }
  }

  Future<void> completeTask(String id) async {
    try {
      await _supabase.from('help_tasks').update({'is_completed': true}).eq('id', id);
    } catch (e) {
      print('HelpTaskService complete error: $e');
      throw Exception('标记完成失败');
    }
  }
}

final helpTaskServiceProvider = Provider<HelpTaskService>((ref) {
  return HelpTaskService();
});

class HelpTaskState {
  HelpTaskState({this.tasks = const [], this.isLoading = false, this.error});

  final List<HelpTask> tasks;
  final bool isLoading;
  final String? error;

  HelpTaskState copyWith({
    List<HelpTask>? tasks,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return HelpTaskState(
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class HelpTaskNotifier extends StateNotifier<HelpTaskState> {
  HelpTaskNotifier(this._service, {this.limit}) : super(HelpTaskState()) {
    loadTasks();
  }

  final HelpTaskService _service;
  final int? limit;

  Future<void> loadTasks() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final tasks = await _service.fetchTasks(limit: limit);
      state = state.copyWith(tasks: tasks, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: '加载失败：$e', isLoading: false);
    }
  }
  Future<void> addTask(HelpTask task) async {
    try {
      await _service.addTask(
        title: task.title,
        description: task.description,
        type: task.type.name,
        reward: task.reward,
      );
      await loadTasks();
    } catch (e) {
      state = state.copyWith(error: '发布失败：$e');
      rethrow;
    }
  }

  Future<void> completeTask(String id) async {
    try {
      await _service.completeTask(id);
      await loadTasks();
    } catch (e) {
      state = state.copyWith(error: '操作失败：$e');
    }
  }
}

final helpTaskStateProvider =
    StateNotifierProvider<HelpTaskNotifier, HelpTaskState>((ref) {
  return HelpTaskNotifier(ref.watch(helpTaskServiceProvider), limit: 3);
});

final allHelpTaskStateProvider =
    StateNotifierProvider<HelpTaskNotifier, HelpTaskState>((ref) {
  return HelpTaskNotifier(ref.watch(helpTaskServiceProvider));
});
