import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/theme.dart';

// 骨架屏组件
class CampusSkeleton extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final Color? baseColor;
  final Color? highlightColor;

  const CampusSkeleton({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = AppSpacing.borderRadius,
    this.baseColor,
    this.highlightColor,
  });

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
      margin: EdgeInsets.all(AppSpacing.sm),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.1),
            offset: Offset(AppSpacing.shadowOffset, AppSpacing.shadowOffset),
            blurRadius: AppSpacing.shadowBlur,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 图片骨架
          CampusSkeleton(
            width: double.infinity,
            height: 160,
          ),
          const SizedBox(height: AppSpacing.md),
          // 标题骨架
          CampusSkeleton(
            width: double.infinity,
            height: 20,
          ),
          const SizedBox(height: AppSpacing.sm),
          // 内容骨架
          CampusSkeleton(
            width: double.infinity,
            height: 16,
          ),
          const SizedBox(height: AppSpacing.xs),
          CampusSkeleton(
            width: 300,
            height: 16,
          ),
          const SizedBox(height: AppSpacing.sm),
          // 日期骨架
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CampusSkeleton(
                width: 80,
                height: 14,
              ),
              CampusSkeleton(
                width: 60,
                height: 14,
              ),
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
      margin: EdgeInsets.all(AppSpacing.sm),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
        border: Border(left: BorderSide(color: AppColors.greyLight, width: 4)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.1),
            offset: Offset(AppSpacing.shadowOffset, AppSpacing.shadowOffset),
            blurRadius: AppSpacing.shadowBlur,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CampusSkeleton(
            width: 200,
            height: 20,
          ),
          const SizedBox(height: AppSpacing.xs),
          CampusSkeleton(
            width: 150,
            height: 16,
          ),
          const SizedBox(height: AppSpacing.sm),
          CampusSkeleton(
            width: double.infinity,
            height: 16,
          ),
        ],
      ),
    );
  }
}

// 列表骨架屏
class CampusListSkeleton extends StatelessWidget {
  final int itemCount;
  final bool withAvatar;

  const CampusListSkeleton({
    super.key,
    this.itemCount = 5,
    this.withAvatar = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Container(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              if (withAvatar)
                Column(
                  children: [
                    CampusSkeleton(
                      width: 48,
                      height: 48,
                      borderRadius: 24,
                    ),
                  ],
                ),
              if (withAvatar)
                const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CampusSkeleton(
                      width: 200,
                      height: 18,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    CampusSkeleton(
                      width: double.infinity,
                      height: 14,
                    ),
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
  final String? message;

  const CampusLoading({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppColors.background,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.primary,
          ),
          if (message != null)
            Padding(
              padding: EdgeInsets.only(top: AppSpacing.md),
              child: Text(
                message!,
                style: AppTextStyles.bodyMedium,
              ),
            ),
        ],
      ),
    );
  }
}

// 加载更多组件
class CampusLoadMore extends StatelessWidget {
  final bool isLoading;
  final String? noMoreText;

  const CampusLoadMore({
    super.key,
    required this.isLoading,
    this.noMoreText = '没有更多数据了',
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
        alignment: Alignment.center,
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 2,
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
      alignment: Alignment.center,
      child: Text(
        noMoreText!,
        style: AppTextStyles.caption,
      ),
    );
  }
}
