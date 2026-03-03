import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/campus_news.dart';

const String _defaultApiBaseUrl = 'http://10.0.2.2:3000/api';

class CampusNewsService {
  CampusNewsService(this._dio);

  final Dio _dio;

  Future<List<CampusNews>> fetchNews({NewsCategory? category}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/news',
      queryParameters: {
        if (category != null) 'category': category.name,
        'limit': 20,
        'offset': 0,
      },
    );

    final data = response.data;
    if (data == null || data['items'] is! List) {
      throw Exception('资讯接口返回格式错误');
    }

    final List<dynamic> items = data['items'] as List<dynamic>;
    return items
        .map((item) => CampusNews.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}

final dioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      baseUrl: const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: _defaultApiBaseUrl,
      ),
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 8),
      sendTimeout: const Duration(seconds: 8),
    ),
  );
});

final campusNewsServiceProvider = Provider<CampusNewsService>((ref) {
  return CampusNewsService(ref.watch(dioProvider));
});

class CampusNewsState {
  CampusNewsState({
    this.items = const [],
    this.isLoading = false,
    this.error,
  });

  final List<CampusNews> items;
  final bool isLoading;
  final String? error;

  CampusNewsState copyWith({
    List<CampusNews>? items,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return CampusNewsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class CampusNewsNotifier extends StateNotifier<CampusNewsState> {
  CampusNewsNotifier(this._newsService) : super(CampusNewsState()) {
    loadNews();
  }

  final CampusNewsService _newsService;

  Future<void> loadNews() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final items = await _newsService.fetchNews();
      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: '加载校园资讯失败：$e', isLoading: false);
    }
  }
}

final campusNewsStateProvider =
    StateNotifierProvider<CampusNewsNotifier, CampusNewsState>((ref) {
      return CampusNewsNotifier(ref.watch(campusNewsServiceProvider));
    });
