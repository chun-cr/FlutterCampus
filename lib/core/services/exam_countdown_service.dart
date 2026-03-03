import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/exam_countdown.dart';

class ExamCountdownService {
  ExamCountdownService(this._supabaseClient);
  final SupabaseClient _supabaseClient;

  Future<List<ExamCountdown>> fetchExams(String userId) async {
    final response = await _supabaseClient
        .from('exam_countdowns')
        .select()
        .eq('user_id', userId)
        .order('exam_date', ascending: true);

    return (response as List)
        .map((json) => ExamCountdown.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<ExamCountdown> addExam(ExamCountdown exam) async {
    final response = await _supabaseClient
        .from('exam_countdowns')
        .insert(exam.toJson())
        .select()
        .single();

    return ExamCountdown.fromJson(response);
  }

  Future<ExamCountdown> updateExam(ExamCountdown exam) async {
    final response = await _supabaseClient
        .from('exam_countdowns')
        .update(exam.toJson())
        .eq('id', exam.id)
        .select()
        .single();

    return ExamCountdown.fromJson(response);
  }

  Future<void> deleteExam(String id) async {
    await _supabaseClient.from('exam_countdowns').delete().eq('id', id);
  }
}

final examCountdownServiceProvider = Provider<ExamCountdownService>((ref) {
  return ExamCountdownService(Supabase.instance.client);
});

class ExamCountdownState {
  ExamCountdownState({
    this.exams = const [],
    this.isLoading = false,
    this.error,
  });
  final List<ExamCountdown> exams;
  final bool isLoading;
  final String? error;

  ExamCountdownState copyWith({
    List<ExamCountdown>? exams,
    bool? isLoading,
    String? error,
  }) {
    return ExamCountdownState(
      exams: exams ?? this.exams,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// 即将到来的考试（按日期排序）
  List<ExamCountdown> get upcomingExams {
    return exams.where((e) => !e.isExpired).toList()
      ..sort((a, b) => a.examDate.compareTo(b.examDate));
  }

  /// 已过期的考试
  List<ExamCountdown> get expiredExams {
    return exams.where((e) => e.isExpired).toList()
      ..sort((a, b) => b.examDate.compareTo(a.examDate));
  }

  /// 紧急考试（7天内）
  List<ExamCountdown> get urgentExams {
    return upcomingExams.where((e) => e.isUrgent).toList();
  }
}

class ExamCountdownNotifier extends StateNotifier<ExamCountdownState> {
  ExamCountdownNotifier(this._examService, this._userId)
    : super(ExamCountdownState()) {
    if (_userId != null) {
      loadExams();
    }
  }
  final ExamCountdownService _examService;
  final String? _userId;

  Future<void> loadExams() async {
    if (_userId == null) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final exams = await _examService.fetchExams(_userId);
      state = state.copyWith(exams: exams, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> addExam(ExamCountdown exam) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final newExam = await _examService.addExam(exam);
      state = state.copyWith(
        exams: [...state.exams, newExam],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> updateExam(ExamCountdown exam) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final updatedExam = await _examService.updateExam(exam);
      final updatedExams = state.exams.map((e) {
        return e.id == updatedExam.id ? updatedExam : e;
      }).toList();
      state = state.copyWith(exams: updatedExams, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> deleteExam(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _examService.deleteExam(id);
      final updatedExams = state.exams.where((e) => e.id != id).toList();
      state = state.copyWith(exams: updatedExams, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final examCountdownStateProvider =
    StateNotifierProvider<ExamCountdownNotifier, ExamCountdownState>((ref) {
      final examService = ref.watch(examCountdownServiceProvider);
      final userId = Supabase.instance.client.auth.currentUser?.id;
      return ExamCountdownNotifier(examService, userId);
    });
