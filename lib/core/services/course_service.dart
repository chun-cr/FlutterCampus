import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/course.dart';

class CourseService {
  CourseService(this._supabaseClient);
  final SupabaseClient _supabaseClient;

  Future<List<Course>> fetchCourses() async {
    // 获取当前用户的课程
    // 假设课程表不需要鉴权或者已经添加 user_id。这里先不考虑user_id过滤，仅读取所有课程
    // 如果需要可以加上 .eq('user_id', userId)
    final response = await _supabaseClient
        .from('courses')
        .select()
        .order('weekday', ascending: true);

    return (response as List)
        .map((json) => Course.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}

final courseServiceProvider = Provider<CourseService>((ref) {
  return CourseService(Supabase.instance.client);
});

class CoursesState {
  CoursesState({this.courses = const [], this.isLoading = false, this.error});
  final List<Course> courses;
  final bool isLoading;
  final String? error;

  CoursesState copyWith({
    List<Course>? courses,
    bool? isLoading,
    String? error,
  }) {
    return CoursesState(
      courses: courses ?? this.courses,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class CoursesNotifier extends StateNotifier<CoursesState> {
  CoursesNotifier(this._courseService) : super(CoursesState()) {
    loadCourses();
  }
  final CourseService _courseService;

  Future<void> loadCourses() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final courses = await _courseService.fetchCourses();
      state = state.copyWith(courses: courses, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  void refresh() {
    loadCourses();
  }
}

final coursesStateProvider =
    StateNotifierProvider<CoursesNotifier, CoursesState>((ref) {
      final courseService = ref.watch(courseServiceProvider);
      return CoursesNotifier(courseService);
    });
