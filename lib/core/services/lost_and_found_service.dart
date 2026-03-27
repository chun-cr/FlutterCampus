import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/community.dart';

class LostAndFoundService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<LostAndFound>> fetchItems({int? limit}) async {
    try {
      var query = _supabase
          .from('lost_and_found')
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
          'location': data['location'] ?? '',
          'type': data['type'] ?? 'found',
          'imageUrl': data['image_url'],
          'publisherId': data['publisher_id']?.toString() ?? '',
          'contactInfo': data['contact_info'],
          'createdAt': data['created_at'] ?? DateTime.now().toIso8601String(),
          'isResolved': data['is_resolved'] ?? false,
          'resolverName': data['resolver_name'],
          'resolverIdNo': data['resolver_id_no'],
          'resolvedAt': data['resolved_at'],
        };
        return LostAndFound.fromJson(mappedJson);
      }).toList();
    } catch (e) {
      print('LostAndFoundService fetch error: $e');
      throw Exception('获取失物招领数据失败');
    }
  }

  Future<void> resolveItem({
    required String id,
    required String name,
    required String idNo,
  }) async {
    try {
      await _supabase.from('lost_and_found').update({
        'is_resolved': true,
        'resolver_name': name,
        'resolver_id_no': idNo,
        'resolved_at': DateTime.now().toIso8601String(),
      }).eq('id', id);
    } catch (e) {
      print('LostAndFoundService resolve error: $e');
      throw Exception('提报寻回状态失败');
    }
  }
  Future<void> addItem({
    required String title,
    String? description,
    required String location,
    required String type,
    String? contactInfo,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('未登录');

      await _supabase.from('lost_and_found').insert({
        'title': title,
        'description': description,
        'location': location,
        'type': type,
        'publisher_id': user.id,
        'contact_info': contactInfo,
        'created_at': DateTime.now().toIso8601String(),
        'is_resolved': false,
      });
    } catch (e) {
      print('LostAndFoundService insert error: $e');
      throw Exception('发布失物招领失败');
    }
  }
}

final lostAndFoundServiceProvider = Provider<LostAndFoundService>((ref) {
  return LostAndFoundService();
});

class LostAndFoundState {
  LostAndFoundState({
    this.items = const [],
    this.isLoading = false,
    this.error,
  });

  final List<LostAndFound> items;
  final bool isLoading;
  final String? error;

  LostAndFoundState copyWith({
    List<LostAndFound>? items,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return LostAndFoundState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class LostAndFoundNotifier extends StateNotifier<LostAndFoundState> {
  LostAndFoundNotifier(this._service, {this.limit})
      : super(LostAndFoundState()) {
    loadItems();
  }

  final LostAndFoundService _service;
  final int? limit;

  Future<void> loadItems() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final items = await _service.fetchItems(limit: limit);
      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: '加载失败：$e', isLoading: false);
    }
  }

  Future<bool> resolveItem(String id, String name, String idNo) async {
    try {
      await _service.resolveItem(id: id, name: name, idNo: idNo);
      // Refresh current list
      await loadItems();
      return true;
    } catch (e) {
      state = state.copyWith(error: '提报失败：$e');
      return false;
    }
  }
  Future<void> addItem(LostAndFound item) async {
    try {
      await _service.addItem(
        title: item.title,
        description: item.description,
        location: item.location,
        type: item.type.name,
        contactInfo: item.contactInfo,
      );
      await loadItems();
    } catch (e) {
      state = state.copyWith(error: '发布失败：$e');
      rethrow;
    }
  }
}

/// 帮助页面的失物招领状态提供者，仅限制显示 2 条最新的
final helpLostAndFoundStateProvider =
    StateNotifierProvider<LostAndFoundNotifier, LostAndFoundState>((ref) {
  return LostAndFoundNotifier(ref.watch(lostAndFoundServiceProvider), limit: 2);
});

/// 全部失物招领列表的状态提供者
final allLostAndFoundStateProvider =
    StateNotifierProvider<LostAndFoundNotifier, LostAndFoundState>((ref) {
  return LostAndFoundNotifier(ref.watch(lostAndFoundServiceProvider));
});
