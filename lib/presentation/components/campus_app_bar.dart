import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/theme.dart';

class CampusAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CampusAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.actions,
    this.backgroundColor,
    this.titleStyle,
    this.centerTitle = true,
    this.elevation,
    this.bottom,
  });
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final TextStyle? titleStyle;
  final bool centerTitle;
  final double? elevation;
  final PreferredSizeWidget? bottom;

  @override
  Size get preferredSize => Size.fromHeight(AppSpacing.appBarHeight + (bottom?.preferredSize.height ?? 0.0));

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style:
            titleStyle ??
            AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimary),
      ),
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () {
                context.pop();
              },
            )
          : null,
      actions: actions,
      backgroundColor: backgroundColor ?? AppColors.background,
      centerTitle: centerTitle,
      elevation: elevation ?? 0,
      shadowColor: AppColors.black.withOpacity(0.03),
      toolbarHeight: AppSpacing.appBarHeight,
      bottom: bottom,
    );
  }
}

// 带搜索功能的AppBar
class CampusSearchAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const CampusSearchAppBar({
    super.key,
    required this.title,
    required this.searchController,
    this.onSearch,
    this.onSearchSubmitted,
    this.showBackButton = true,
    this.actions,
  });
  final String title;
  final TextEditingController searchController;
  final Function(String)? onSearch;
  final Function()? onSearchSubmitted;
  final bool showBackButton;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(AppSpacing.appBarHeight + 56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimary),
      ),
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () {
                context.pop();
              },
            )
          : null,
      actions: actions,
      backgroundColor: AppColors.background,
      centerTitle: true,
      elevation: 0,
      shadowColor: AppColors.black.withOpacity(0.03),
      toolbarHeight: AppSpacing.appBarHeight,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          color: AppColors.background,
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: '搜索...',
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.textSecondary,
              ),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        Icons.clear,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () {
                        searchController.clear();
                        onSearch?.call('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
            ),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
            onChanged: onSearch,
            onSubmitted: (value) {
              onSearchSubmitted?.call();
            },
          ),
        ),
      ), // closes PreferredSize
    ); // closes AppBar
  } // closes build
} // closes CampusSearchAppBar
