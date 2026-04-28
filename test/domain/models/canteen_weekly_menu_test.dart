import 'package:flutter_test/flutter_test.dart';
import 'package:campus_life_app/domain/models/canteen_weekly_menu.dart';

void main() {
  group('resolveMealPeriodStatus', () {
    test('早餐时段返回早餐供应中', () {
      final status = resolveMealPeriodStatus(DateTime(2026, 3, 30, 8, 0));

      expect(status.period, MealPeriod.breakfast);
      expect(status.label, '早餐供应中');
      expect(status.isServing, isTrue);
    });

    test('午餐前返回午餐预告', () {
      final status = resolveMealPeriodStatus(DateTime(2026, 3, 30, 10, 0));

      expect(status.period, MealPeriod.lunch);
      expect(status.label, '午餐 11:00 起');
      expect(status.isServing, isFalse);
    });

    test('晚间闭餐后返回明日早餐预告', () {
      final status = resolveMealPeriodStatus(DateTime(2026, 3, 30, 21, 0));

      expect(status.period, MealPeriod.breakfast);
      expect(status.label, '明日早餐预告');
      expect(status.isServing, isFalse);
    });
  });

  group('CanteenWeeklyMenu', () {
    const dailyMenu = CanteenDailyMenu(
      weekday: 1,
      breakfastItems: ['豆浆'],
      lunchItems: ['红烧肉'],
      dinnerItems: ['清炒时蔬'],
      featuredNote: '周一推荐',
    );

    const teacherMenu = CanteenWeeklyMenu(
      id: 'teacher-1',
      name: '教工食堂',
      type: 'teacher',
      isOpen: true,
      openTime: '07:00 - 19:00',
      sortOrder: 1,
      dailyMenus: [dailyMenu],
    );

    test('教师菜单仅对教师端可见', () {
      expect(teacherMenu.supportsAudience(CanteenAudience.teacher), isTrue);
      expect(teacherMenu.supportsAudience(CanteenAudience.student), isFalse);
    });

    test('查不到指定星期时回退到第一天菜单', () {
      final menu = teacherMenu.menuForWeekday(4);

      expect(menu, isNotNull);
      expect(menu?.weekday, 1);
      expect(menu?.featuredNote, '周一推荐');
    });
  });
}
