import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/theme.dart';

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
    return Shimmer.fromColors(
      baseColor: baseColor ?? AppColors.greyLight,
      highlightColor: highlightColor ?? AppColors.greyLight.withOpacity(0.5),
      period: const Duration(milliseconds: 1500),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.greyLight,
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
    return Container(
      margin: const EdgeInsets.all(AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.1),
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
    return Container(
      margin: const EdgeInsets.all(AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
        border: const Border(
          left: BorderSide(color: AppColors.greyLight, width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.1),
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
  const CampusLoading({super.key, this.message});
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppColors.background,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          if (message != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              child: Text(message!, style: AppTextStyles.bodyMedium),
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
        child: const CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 2,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      alignment: Alignment.center,
      child: Text(noMoreText!, style: AppTextStyles.caption),
    );
  }
}
