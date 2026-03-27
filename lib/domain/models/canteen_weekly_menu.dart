enum CanteenAudience { student, teacher }

enum MealPeriod { breakfast, lunch, dinner }

class MealPeriodStatus {
  const MealPeriodStatus({
    required this.period,
    required this.label,
    required this.timeRange,
    required this.isServing,
  });

  final MealPeriod period;
  final String label;
  final String timeRange;
  final bool isServing;
}

MealPeriodStatus resolveMealPeriodStatus(DateTime now) {
  final totalMinutes = now.hour * 60 + now.minute;

  if (totalMinutes >= 360 && totalMinutes < 540) {
    return const MealPeriodStatus(
      period: MealPeriod.breakfast,
      label: '早餐供应中',
      timeRange: '07:00 - 09:00',
      isServing: true,
    );
  }

  if (totalMinutes >= 540 && totalMinutes < 660) {
    return const MealPeriodStatus(
      period: MealPeriod.lunch,
      label: '午餐 11:00 起',
      timeRange: '11:00 - 13:30',
      isServing: false,
    );
  }

  if (totalMinutes >= 660 && totalMinutes < 810) {
    return const MealPeriodStatus(
      period: MealPeriod.lunch,
      label: '午餐供应中',
      timeRange: '11:00 - 13:30',
      isServing: true,
    );
  }

  if (totalMinutes >= 810 && totalMinutes < 1020) {
    return const MealPeriodStatus(
      period: MealPeriod.dinner,
      label: '晚餐 17:00 起',
      timeRange: '17:00 - 19:00',
      isServing: false,
    );
  }

  if (totalMinutes >= 1020 && totalMinutes < 1140) {
    return const MealPeriodStatus(
      period: MealPeriod.dinner,
      label: '晚餐供应中',
      timeRange: '17:00 - 19:00',
      isServing: true,
    );
  }

  return const MealPeriodStatus(
    period: MealPeriod.breakfast,
    label: '明日早餐预告',
    timeRange: '07:00 - 09:00',
    isServing: false,
  );
}

class CanteenDailyMenu {
  const CanteenDailyMenu({
    required this.weekday,
    required this.breakfastItems,
    required this.lunchItems,
    required this.dinnerItems,
    required this.featuredNote,
  });

  final int weekday;
  final List<String> breakfastItems;
  final List<String> lunchItems;
  final List<String> dinnerItems;
  final String? featuredNote;

  List<String> itemsForPeriod(MealPeriod period) {
    switch (period) {
      case MealPeriod.breakfast:
        return breakfastItems;
      case MealPeriod.lunch:
        return lunchItems;
      case MealPeriod.dinner:
        return dinnerItems;
    }
  }
}

class CanteenWeeklyMenu {
  const CanteenWeeklyMenu({
    required this.id,
    required this.name,
    required this.type,
    required this.isOpen,
    required this.openTime,
    required this.sortOrder,
    required this.dailyMenus,
  });

  final String id;
  final String name;
  final String type;
  final bool isOpen;
  final String? openTime;
  final int sortOrder;
  final List<CanteenDailyMenu> dailyMenus;

  bool supportsAudience(CanteenAudience audience) {
    if (type == 'mixed') {
      return true;
    }

    if (audience == CanteenAudience.teacher) {
      return type == 'teacher';
    }

    return type == 'student';
  }

  CanteenDailyMenu? menuForWeekday(int weekday) {
    for (final menu in dailyMenus) {
      if (menu.weekday == weekday) {
        return menu;
      }
    }

    if (dailyMenus.isEmpty) {
      return null;
    }

    return dailyMenus.first;
  }
}
