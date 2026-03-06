import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/grade.dart';

class GradeService {
  GradeService(this._supabaseClient);
  final SupabaseClient _supabaseClient;

  Future<List<Grade>> fetchGrades(String userId) async {
    final response = await _supabaseClient
        .from('grades')
        .select()
        .eq('user_id', userId);

    return (response as List)
        .map((json) => Grade.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// 教师用：按学生 user_id 查询成绩
  Future<List<Grade>> fetchGradesByStudentId(String studentId) async {
    final response = await _supabaseClient
        .from('grades')
        .select()
        .eq('user_id', studentId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => Grade.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// 教师用：查询所有学生列表
  Future<List<Map<String, dynamic>>> fetchStudents() async {
    final response = await _supabaseClient
        .from('users')
        .select('id, name, student_id, department')
        .eq('type', 'student')
        .order('name');
    return (response as List).cast<Map<String, dynamic>>();
  }

  Future<Grade> addGrade(Grade grade) async {
    final response = await _supabaseClient
        .from('grades')
        .insert(grade.toJson())
        .select()
        .single();

    return Grade.fromJson(response);
  }

  Future<Grade> updateGrade(Grade grade) async {
    final response = await _supabaseClient
        .from('grades')
        .update(grade.toJson())
        .eq('id', grade.id)
        .select()
        .single();

    return Grade.fromJson(response);
  }

  Future<void> deleteGrade(String id) async {
    await _supabaseClient.from('grades').delete().eq('id', id);
  }
}

final gradeServiceProvider = Provider<GradeService>((ref) {
  return GradeService(Supabase.instance.client);
});

class GradesState {
  GradesState({this.grades = const [], this.isLoading = false, this.error});
  final List<Grade> grades;
  final bool isLoading;
  final String? error;

  GradesState copyWith({List<Grade>? grades, bool? isLoading, String? error}) {
    return GradesState(
      grades: grades ?? this.grades,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// 计算总GPA (4分制)
  double get totalGpa {
    if (grades.isEmpty) return 0;
    double totalWeightedPoints = 0;
    double totalCredits = 0;
    for (final grade in grades) {
      totalWeightedPoints += grade.gradePoint * grade.credit;
      totalCredits += grade.credit;
    }
    return totalCredits > 0 ? totalWeightedPoints / totalCredits : 0;
  }

  /// 计算总学分
  double get totalCredits {
    return grades.fold(0, (sum, grade) => sum + grade.credit);
  }

  /// 按学期分组
  Map<String, List<Grade>> get gradesBySemester {
    final map = <String, List<Grade>>{};
    for (final grade in grades) {
      map.putIfAbsent(grade.semester, () => []).add(grade);
    }
    // 按学期排序（降序）
    final sortedKeys = map.keys.toList()..sort((a, b) => b.compareTo(a));
    return {for (var key in sortedKeys) key: map[key]!};
  }

  /// 获取学期汇总列表
  List<SemesterGradeSummary> get semesterSummaries {
    return gradesBySemester.entries
        .map((e) => SemesterGradeSummary.fromGrades(e.key, e.value))
        .toList();
  }
}

class GradesNotifier extends StateNotifier<GradesState> {
  GradesNotifier(this._gradeService, this._userId) : super(GradesState()) {
    if (_userId != null) {
      loadGrades();
    }
  }
  final GradeService _gradeService;
  final String? _userId;

  Future<void> loadGrades() async {
    if (_userId == null) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final grades = await _gradeService.fetchGrades(_userId);
      state = state.copyWith(grades: grades, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> addGrade(Grade grade) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final newGrade = await _gradeService.addGrade(grade);
      state = state.copyWith(
        grades: [newGrade, ...state.grades],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> updateGrade(Grade grade) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final updatedGrade = await _gradeService.updateGrade(grade);
      final updatedGrades = state.grades.map((g) {
        return g.id == updatedGrade.id ? updatedGrade : g;
      }).toList();
      state = state.copyWith(grades: updatedGrades, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> deleteGrade(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _gradeService.deleteGrade(id);
      final updatedGrades = state.grades.where((g) => g.id != id).toList();
      state = state.copyWith(grades: updatedGrades, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final gradeStateProvider = StateNotifierProvider<GradesNotifier, GradesState>((
  ref,
) {
  final gradeService = ref.watch(gradeServiceProvider);
  final userId = Supabase.instance.client.auth.currentUser?.id;
  return GradesNotifier(gradeService, userId);
});
