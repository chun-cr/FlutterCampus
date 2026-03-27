import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/canteen_weekly_menu.dart';

class CanteenMenuService {
  CanteenMenuService(this._client);

  final SupabaseClient _client;

  Future<List<CanteenWeeklyMenu>> fetchWeeklyMenus(
    CanteenAudience audience,
  ) async {
    try {
      final canteensResponse = await _client
          .from('canteens')
          .select()
          .order('sort_order', ascending: true);

      final menusResponse = await _client
          .from('canteen_weekly_menus')
          .select()
          .order('weekday', ascending: true);

      final canteenRows = (canteensResponse as List)
          .cast<Map<String, dynamic>>();
      final menuRows = (menusResponse as List).cast<Map<String, dynamic>>();

      final groupedMenus = <String, List<CanteenDailyMenu>>{};
      for (final row in menuRows) {
        final canteenId = row['canteen_id']?.toString();
        if (canteenId == null || canteenId.isEmpty) {
          continue;
        }

        groupedMenus.putIfAbsent(canteenId, () => []).add(
          CanteenDailyMenu(
            weekday: (row['weekday'] as num?)?.toInt() ?? 1,
            breakfastItems: _readTextList(row['breakfast_items']),
            lunchItems: _readTextList(row['lunch_items']),
            dinnerItems: _readTextList(row['dinner_items']),
            featuredNote: row['featured_note']?.toString(),
          ),
        );
      }

      final menus = canteenRows
          .map(
            (row) => CanteenWeeklyMenu(
              id: row['id']?.toString() ?? '',
              name: row['name']?.toString() ?? '',
              type: row['type']?.toString() ?? 'student',
              isOpen: row['is_open'] as bool? ?? true,
              openTime: row['open_time']?.toString(),
              sortOrder: (row['sort_order'] as num?)?.toInt() ?? 0,
              dailyMenus: groupedMenus[row['id']?.toString()] ?? const [],
            ),
          )
          .where((menu) => menu.supportsAudience(audience))
          .where((menu) => menu.dailyMenus.isNotEmpty)
          .toList();

      menus.sort((left, right) => left.sortOrder.compareTo(right.sortOrder));
      return menus;
    } catch (e) {
      throw Exception('获取食堂菜单失败');
    }
  }

  List<String> _readTextList(dynamic value) {
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
    return const [];
  }
}

final canteenMenuServiceProvider = Provider<CanteenMenuService>((ref) {
  return CanteenMenuService(Supabase.instance.client);
});

final canteenWeeklyMenusProvider = FutureProvider.family<
  List<CanteenWeeklyMenu>,
  CanteenAudience
>((ref, audience) async {
  return ref.watch(canteenMenuServiceProvider).fetchWeeklyMenus(audience);
});
