import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../theme/theme.dart';

Color _defaultSkeletonBaseColor(BuildContext context) {
  if (Theme.of(context).brightness == Brightness.dark) {
    return AppColors.white.withValues(alpha: 0.08);
  }
  return AppColors.greyLight.withValues(alpha: 0.85);
}

Color _defaultSkeletonHighlightColor(BuildContext context) {
  if (Theme.of(context).brightness == Brightness.dark) {
    return AppColors.white.withValues(alpha: 0.16);
  }
  return AppColors.white;
}

// 骨架屏组件
class CampusSkeleton extends StatelessWidget {
  const CampusSkeleton({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = AppSpacing.borderRadius,
    this.baseColor,
    this.highlightColor,
  });

  final double width;
  final double height;
  final double borderRadius;
  final Color? baseColor;
  final Color? highlightColor;

  @override
  Widget build(BuildContext context) {
    final resolvedBaseColor = baseColor ?? _defaultSkeletonBaseColor(context);
    final resolvedHighlightColor =
        highlightColor ?? _defaultSkeletonHighlightColor(context);

    return Shimmer.fromColors(
      baseColor: resolvedBaseColor,
      highlightColor: resolvedHighlightColor,
      period: const Duration(milliseconds: 1400),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: resolvedBaseColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

// 资讯卡片骨架屏
class CampusNewsCardSkeleton extends StatelessWidget {
  const CampusNewsCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final cardColor = Theme.of(context).cardColor;
    final borderColor = Theme.of(context).dividerColor;
    final shadowColor = Theme.of(context).shadowColor;

    return Container(
      margin: const EdgeInsets.all(AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
        border: Border.all(
          color: borderColor.withValues(alpha: 0.35),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withValues(alpha: 0.08),
            offset: const Offset(
              AppSpacing.shadowOffset,
              AppSpacing.shadowOffset,
            ),
            blurRadius: AppSpacing.shadowBlur,
            spreadRadius: 0,
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 图片骨架
          CampusSkeleton(width: double.infinity, height: 160),
          SizedBox(height: AppSpacing.md),
          // 标题骨架
          CampusSkeleton(width: double.infinity, height: 20),
          SizedBox(height: AppSpacing.sm),
          // 内容骨架
          CampusSkeleton(width: double.infinity, height: 16),
          SizedBox(height: AppSpacing.xs),
          CampusSkeleton(width: 300, height: 16),
          SizedBox(height: AppSpacing.sm),
          // 日期骨架
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CampusSkeleton(width: 80, height: 14),
              CampusSkeleton(width: 60, height: 14),
            ],
          ),
        ],
      ),
    );
  }
}

// 课程卡片骨架屏
class CampusCourseCardSkeleton extends StatelessWidget {
  const CampusCourseCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final cardColor = Theme.of(context).cardColor;
    final borderColor = Theme.of(context).dividerColor;
    final shadowColor = Theme.of(context).shadowColor;

    return Container(
      margin: const EdgeInsets.all(AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
        border: Border(left: BorderSide(color: borderColor, width: 4)),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withValues(alpha: 0.08),
            offset: const Offset(
              AppSpacing.shadowOffset,
              AppSpacing.shadowOffset,
            ),
            blurRadius: AppSpacing.shadowBlur,
            spreadRadius: 0,
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CampusSkeleton(width: 200, height: 20),
          SizedBox(height: AppSpacing.xs),
          CampusSkeleton(width: 150, height: 16),
          SizedBox(height: AppSpacing.sm),
          CampusSkeleton(width: double.infinity, height: 16),
        ],
      ),
    );
  }
}

// 列表骨架屏
class CampusListSkeleton extends StatelessWidget {
  const CampusListSkeleton({
    super.key,
    this.itemCount = 5,
    this.withAvatar = true,
  });

  final int itemCount;
  final bool withAvatar;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              if (withAvatar)
                const Column(
                  children: [
                    CampusSkeleton(width: 48, height: 48, borderRadius: 24),
                  ],
                ),
              if (withAvatar) const SizedBox(width: AppSpacing.md),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CampusSkeleton(width: 200, height: 18),
                    SizedBox(height: AppSpacing.xs),
                    CampusSkeleton(width: double.infinity, height: 14),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// 全屏加载组件
class CampusLoading extends StatelessWidget {
  const CampusLoading({super.key, this.message, this.itemCount = 3});

  final String? message;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = Theme.of(context).cardColor;
    final borderColor = Theme.of(context).dividerColor;
    final shadowColor = Theme.of(context).shadowColor;

    return SizedBox.expand(
      child: ColoredBox(
        color: backgroundColor,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _LoadingHeaderSkeleton(),
                          const SizedBox(height: AppSpacing.lg),
                          _LoadingFeatureCardSkeleton(
                            cardColor: cardColor,
                            borderColor: borderColor,
                            shadowColor: shadowColor,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          CampusListSkeleton(
                            itemCount: itemCount,
                            withAvatar: false,
                          ),
                          if (message != null) ...[
                            const SizedBox(height: AppSpacing.lg),
                            Center(
                              child: Text(
                                message!,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _LoadingHeaderSkeleton extends StatelessWidget {
  const _LoadingHeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CampusSkeleton(width: 96, height: 12, borderRadius: 999),
        SizedBox(height: AppSpacing.sm),
        CampusSkeleton(width: 220, height: 28),
        SizedBox(height: AppSpacing.xs),
        CampusSkeleton(width: 160, height: 16),
      ],
    );
  }
}

class _LoadingFeatureCardSkeleton extends StatelessWidget {
  const _LoadingFeatureCardSkeleton({
    required this.cardColor,
    required this.borderColor,
    required this.shadowColor,
  });

  final Color cardColor;
  final Color borderColor;
  final Color shadowColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppSpacing.largeBorderRadius),
        border: Border.all(
          color: borderColor.withValues(alpha: 0.35),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CampusSkeleton(width: 56, height: 56, borderRadius: 18),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CampusSkeleton(width: 180, height: 20),
                    SizedBox(height: AppSpacing.xs),
                    CampusSkeleton(width: 120, height: 14),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          CampusSkeleton(width: double.infinity, height: 160, borderRadius: 24),
          SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: CampusSkeleton(
                  width: double.infinity,
                  height: 12,
                  borderRadius: 999,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: CampusSkeleton(
                  width: double.infinity,
                  height: 12,
                  borderRadius: 999,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: CampusSkeleton(
                  width: double.infinity,
                  height: 12,
                  borderRadius: 999,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// 加载更多组件
class CampusLoadMore extends StatelessWidget {
  const CampusLoadMore({
    super.key,
    required this.isLoading,
    this.noMoreText = '没有更多数据了',
  });

  final bool isLoading;
  final String? noMoreText;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        alignment: Alignment.center,
        child: const CampusSkeleton(width: 96, height: 12, borderRadius: 999),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      alignment: Alignment.center,
      child: Text(noMoreText!, style: AppTextStyles.caption),
    );
  }
}
