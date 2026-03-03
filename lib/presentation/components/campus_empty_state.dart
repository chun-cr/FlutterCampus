import 'package:flutter/material.dart';
import '../theme/theme.dart';

class CampusEmptyState extends StatelessWidget {
  const CampusEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.buttonText,
    this.onButtonTap,
    this.iconColor,
    this.backgroundColor,
  });
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? buttonText;
  final Function()? onButtonTap;
  final Color? iconColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: backgroundColor ?? AppColors.background,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 图标
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: (iconColor ?? AppColors.primary).withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Center(
              child: Icon(
                icon,
                size: 60,
                color: iconColor ?? AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // 标题
          Text(
            title,
            style: AppTextStyles.titleMedium,
            textAlign: TextAlign.center,
          ),
          // 副标题
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.md,
              ),
              child: Text(
                subtitle!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          // 按钮
          if (buttonText != null && onButtonTap != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              child: ElevatedButton(
                onPressed: onButtonTap,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.buttonPadding,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppSpacing.borderRadius,
                    ),
                  ),
                ),
                child: Text(buttonText!),
              ),
            ),
        ],
      ),
    );
  }
}

// 无网络状态
class CampusNoNetworkState extends StatelessWidget {
  const CampusNoNetworkState({super.key, this.onRetry});
  final Function()? onRetry;

  @override
  Widget build(BuildContext context) {
    return CampusEmptyState(
      icon: Icons.wifi_off,
      title: '网络连接失败',
      subtitle: '请检查您的网络连接后重试',
      buttonText: '重新连接',
      onButtonTap: onRetry,
      iconColor: AppColors.error,
    );
  }
}

// 无搜索结果状态
class CampusNoSearchResultState extends StatelessWidget {
  const CampusNoSearchResultState({
    super.key,
    this.keyword,
    this.onClearSearch,
  });
  final String? keyword;
  final Function()? onClearSearch;

  @override
  Widget build(BuildContext context) {
    return CampusEmptyState(
      icon: Icons.search_off,
      title: '未找到相关内容',
      subtitle: keyword != null ? '没有找到与"$keyword"相关的内容' : '没有找到相关内容',
      buttonText: '清除搜索',
      onButtonTap: onClearSearch,
      iconColor: AppColors.warning,
    );
  }
}

// 无数据状态
class CampusNoDataState extends StatelessWidget {
  const CampusNoDataState({
    super.key,
    this.title = '暂无数据',
    this.subtitle,
    this.onAction,
    this.actionText,
  });
  final String title;
  final String? subtitle;
  final Function()? onAction;
  final String? actionText;

  @override
  Widget build(BuildContext context) {
    return CampusEmptyState(
      icon: Icons.inbox,
      title: title,
      subtitle: subtitle,
      buttonText: actionText,
      onButtonTap: onAction,
      iconColor: AppColors.grey,
    );
  }
}

// 错误状态
class CampusErrorState extends StatelessWidget {
  const CampusErrorState({super.key, this.message, this.onRetry});
  final String? message;
  final Function()? onRetry;

  @override
  Widget build(BuildContext context) {
    return CampusEmptyState(
      icon: Icons.error_outline,
      title: '出错了',
      subtitle: message ?? '操作失败，请重试',
      buttonText: '重试',
      onButtonTap: onRetry,
      iconColor: AppColors.error,
    );
  }
}
