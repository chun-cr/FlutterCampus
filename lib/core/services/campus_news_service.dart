import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/campus_news.dart';

class CampusNewsService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<CampusNews>> fetchNews({NewsCategory? category}) async {
    try {
      var query = _supabase.from('campus_news').select();

      if (category != null) {
        query = query.eq('category', category.name);
      }

      // limit to 8 items as requested
      final response = await query
          .order('published_at', ascending: false)
          .limit(8);

      return response.map((json) {
        // Map database fields to the model's expected camelCase format
        final mappedJson = {
          'id': json['id']?.toString() ?? '',
          'title': json['title'] ?? '',
          'summary': json['summary'],
          'imageUrl': json['image_url'] ?? json['imageUrl'],
          'source': json['source'] ?? '学校',
          'category': json['category'] ?? 'notice',
          'publishedAt':
              json['published_at'] ??
              json['publishedAt'] ??
              DateTime.now().toIso8601String(),
          'isTop': json['is_top'] ?? json['isTop'] ?? false,
        };

        return CampusNews.fromJson(mappedJson);
      }).toList();
    } catch (e) {
      print('CampusNewsService fetch error: $e');
      throw Exception('获取资讯失败');
    }
  }
}

final campusNewsServiceProvider = Provider<CampusNewsService>((ref) {
  return CampusNewsService();
});

class CampusNewsState {
  CampusNewsState({this.items = const [], this.isLoading = false, this.error});

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
