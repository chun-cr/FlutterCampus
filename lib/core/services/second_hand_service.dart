import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/community.dart';

class SecondHandService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<SecondHandItem>> fetchItems({int? limit}) async {
    try {
      var query = _supabase
          .from('second_hand_items')
          .select()
          .order('created_at', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;

      return response.map((data) {
        // extract image url which could be image_url or first of images
        String? imageUrl;
        if (data['image_url'] != null) {
          imageUrl = data['image_url'];
        } else if (data['images'] != null &&
            data['images'] is List &&
            data['images'].isNotEmpty) {
          imageUrl = data['images'][0];
        }

        final mappedJson = {
          'id': data['id']?.toString() ?? '',
          'title': data['title'] ?? '',
          'description': data['description'],
          'price': (data['price'] ?? 0).toDouble(),
          'originalPrice': data['original_price'] != null
              ? (data['original_price'] as num).toDouble()
              : null,
          'imageUrl': imageUrl,
          'sellerId': data['seller_id']?.toString() ?? '',
          'condition': data['condition'] ?? 'good',
          'createdAt': data['created_at'] ?? DateTime.now().toIso8601String(),
          'isSold': data['is_sold'] ?? false,
        };
        return SecondHandItem.fromJson(mappedJson);
      }).toList();
    } catch (e) {
      print('SecondHandService fetch error: $e');
      throw Exception('获取闲置商品失败');
    }
  }
}

final secondHandServiceProvider = Provider<SecondHandService>((ref) {
  return SecondHandService();
});

class SecondHandState {
  SecondHandState({this.items = const [], this.isLoading = false, this.error});

  final List<SecondHandItem> items;
  final bool isLoading;
  final String? error;

  SecondHandState copyWith({
    List<SecondHandItem>? items,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return SecondHandState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class SecondHandNotifier extends StateNotifier<SecondHandState> {
  SecondHandNotifier(this._service, {this.limit}) : super(SecondHandState()) {
    loadItems();
  }

  final SecondHandService _service;
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
}

// Provide only 3 items for the home page widget
final helpSecondHandStateProvider =
    StateNotifierProvider<SecondHandNotifier, SecondHandState>((ref) {
      return SecondHandNotifier(ref.watch(secondHandServiceProvider), limit: 3);
    });

// Provide all items for the full list page
final allSecondHandStateProvider =
    StateNotifierProvider<SecondHandNotifier, SecondHandState>((ref) {
      return SecondHandNotifier(ref.watch(secondHandServiceProvider));
    });
