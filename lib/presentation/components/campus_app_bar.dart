import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/theme.dart';

class CampusAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final TextStyle? titleStyle;
  final bool centerTitle;
  final double? elevation;

  const CampusAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.actions,
    this.backgroundColor,
    this.titleStyle,
    this.centerTitle = true,
    this.elevation,
  });

  @override
  Size get preferredSize => Size.fromHeight(AppSpacing.appBarHeight);

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
              icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
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
    );
  }
}

// 带搜索功能的AppBar
class CampusSearchAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final TextEditingController searchController;
  final Function(String)? onSearch;
  final Function()? onSearchSubmitted;
  final bool showBackButton;
  final List<Widget>? actions;

  const CampusSearchAppBar({
    super.key,
    required this.title,
    required this.searchController,
    this.onSearch,
    this.onSearchSubmitted,
    this.showBackButton = true,
    this.actions,
  });

  @override
  Size get preferredSize => Size.fromHeight(AppSpacing.appBarHeight + 56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimary),
      ),
      leading: showBackButton
          ? IconButton(
              icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
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
          padding: EdgeInsets.symmetric(
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
              prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, color: AppColors.textSecondary),
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
              contentPadding: EdgeInsets.symmetric(
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
