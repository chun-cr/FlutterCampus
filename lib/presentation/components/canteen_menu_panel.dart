import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/canteen_menu_service.dart';
import '../../domain/models/canteen_weekly_menu.dart';
import '../theme/theme.dart';

class CanteenMenuPanel extends ConsumerStatefulWidget {
  const CanteenMenuPanel({
    super.key,
    required this.audience,
    required this.emptyTitle,
  });

  final CanteenAudience audience;
  final String emptyTitle;

  @override
  ConsumerState<CanteenMenuPanel> createState() => _CanteenMenuPanelState();
}

class _CanteenMenuPanelState extends ConsumerState<CanteenMenuPanel> {
  late int _selectedWeekday;
  String? _selectedCanteenId;

  static const _weekdayLabels = <int, String>{
    1: '周一',
    2: '周二',
    3: '周三',
    4: '周四',
    5: '周五',
    6: '周六',
    7: '周日',
  };

  @override
  void initState() {
    super.initState();
    _selectedWeekday = DateTime.now().weekday;
  }

  @override
  Widget build(BuildContext context) {
    final menusAsync = ref.watch(canteenWeeklyMenusProvider(widget.audience));

    return menusAsync.when(
      data: (menus) => _buildLoadedState(context, menus),
      loading: _buildLoadingState,
      error: (error, stackTrace) => _buildErrorState(),
    );
  }

  Widget _buildLoadedState(
    BuildContext context,
    List<CanteenWeeklyMenu> menus,
  ) {
    if (menus.isEmpty) {
      return _buildEmptyState();
    }

    final selectedCanteen = menus.firstWhere(
      (menu) => menu.id == _selectedCanteenId,
      orElse: () => menus.first,
    );
    final selectedDayMenu =
        selectedCanteen.menuForWeekday(_selectedWeekday) ?? menus.first.dailyMenus.first;
    final mealStatus = resolveMealPeriodStatus(DateTime.now());
    final currentItems = selectedDayMenu.itemsForPeriod(mealStatus.period);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.greyLight.withValues(alpha: 0.6),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.greyLight.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryBrand.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.restaurant_menu_rounded,
                  color: AppColors.primaryBrand,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(selectedCanteen.name, style: AppTextStyles.titleLarge),
                    const SizedBox(height: 4),
                    Text(
                      selectedCanteen.openTime ?? '营业时间待更新',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              _buildStatusTag(mealStatus),
            ],
          ),
          const SizedBox(height: 24),
          if (menus.length > 1) ...[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: menus.map((menu) {
                  final isSelected = menu.id == selectedCanteen.id;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCanteenId = menu.id;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryBrand.withValues(alpha: 0.12)
                              : AppColors.background,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primaryBrand.withValues(alpha: 0.3)
                                : AppColors.greyLight,
                          ),
                        ),
                        child: Text(
                          menu.name,
                          style: AppTextStyles.labelMedium.copyWith(
                            color: isSelected
                                ? AppColors.primaryBrand
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
          ],
          Text(
            '本周菜单',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _weekdayLabels.entries.map((entry) {
                final isSelected = entry.key == _selectedWeekday;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedWeekday = entry.key;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 52,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.background,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        entry.value,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: isSelected
                              ? AppColors.white
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _weekdayLabels[_selectedWeekday] ?? '今日',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      mealStatus.period == MealPeriod.breakfast
                          ? '早餐推荐'
                          : mealStatus.period == MealPeriod.lunch
                              ? '午餐推荐'
                              : '晚餐推荐',
                      style: AppTextStyles.titleMedium,
                    ),
                  ],
                ),
                if ((selectedDayMenu.featuredNote ?? '').isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    selectedDayMenu.featuredNote!,
                    style: AppTextStyles.bodySmall,
                  ),
                ],
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: currentItems.map(_buildDishTag).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: AppColors.background,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  builder: (sheetContext) {
                    return _CanteenMenuBottomSheet(
                      canteen: selectedCanteen,
                      dayMenu: selectedDayMenu,
                      weekdayLabel: _weekdayLabels[_selectedWeekday] ?? '今日',
                    );
                  },
                );
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    width: 0.5,
                  ),
                ),
              ),
              child: Text(
                '查看全天菜单',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTag(MealPeriodStatus status) {
    final backgroundColor = status.isServing
        ? AppColors.success.withValues(alpha: 0.12)
        : AppColors.greyLight.withValues(alpha: 0.5);
    final foregroundColor =
        status.isServing ? AppColors.success : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: AppTextStyles.labelSmall.copyWith(color: foregroundColor),
      ),
    );
  }

  Widget _buildDishTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.greyLight),
      ),
      child: Text(
        text,
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.greyLight.withValues(alpha: 0.6)),
      ),
      child: const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: CircularProgressIndicator(color: AppColors.primaryBrand),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.greyLight.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.emptyTitle, style: AppTextStyles.titleMedium),
          const SizedBox(height: 8),
          Text(
            '菜单暂时加载失败，请稍后重试。',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.greyLight.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.emptyTitle, style: AppTextStyles.titleMedium),
          const SizedBox(height: 8),
          Text(
            '当前还没有可展示的菜单数据。',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _CanteenMenuBottomSheet extends StatelessWidget {
  const _CanteenMenuBottomSheet({
    required this.canteen,
    required this.dayMenu,
    required this.weekdayLabel,
  });

  final CanteenWeeklyMenu canteen;
  final CanteenDailyMenu dayMenu;
  final String weekdayLabel;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.greyLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(canteen.name, style: AppTextStyles.titleLarge),
            const SizedBox(height: 4),
            Text(
              '$weekdayLabel · ${canteen.openTime ?? '营业时间待更新'}',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 24),
            _MealSection(
              icon: Icons.free_breakfast_outlined,
              title: '早餐',
              timeRange: '07:00 - 09:00',
              items: dayMenu.breakfastItems,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Divider(height: 1, thickness: 0.5, color: AppColors.greyLight),
            ),
            _MealSection(
              icon: Icons.rice_bowl_outlined,
              title: '午餐',
              timeRange: '11:00 - 13:30',
              items: dayMenu.lunchItems,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Divider(height: 1, thickness: 0.5, color: AppColors.greyLight),
            ),
            _MealSection(
              icon: Icons.dinner_dining_outlined,
              title: '晚餐',
              timeRange: '17:00 - 19:00',
              items: dayMenu.dinnerItems,
            ),
          ],
        ),
      ),
    );
  }
}

class _MealSection extends StatelessWidget {
  const _MealSection({
    required this.icon,
    required this.title,
    required this.timeRange,
    required this.items,
  });

  final IconData icon;
  final String title;
  final String timeRange;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primaryBrand),
            const SizedBox(width: 8),
            Text(title, style: AppTextStyles.titleMedium),
            const SizedBox(width: 12),
            Text(timeRange, style: AppTextStyles.caption),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((item) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.greyLight),
              ),
              child: Text(
                item,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
