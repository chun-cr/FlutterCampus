import 'package:flutter/material.dart';
import '../theme/theme.dart';

class CampusCard extends StatelessWidget {
  const CampusCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.elevation,
    this.backgroundColor,
    this.shadow,
    this.onTap,
    this.border,
  });
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? borderRadius;
  final double? elevation;
  final Color? backgroundColor;
  final BoxShadow? shadow;
  final Function()? onTap;
  final Border? border;

  @override
  Widget build(BuildContext context) {
    Widget cardContent = Container(
      margin: margin ?? const EdgeInsets.all(AppSpacing.md),
      child: Material(
        color: backgroundColor ?? AppColors.surface,
        elevation: elevation ?? 0.0,
        borderRadius: BorderRadius.circular(
          borderRadius ?? AppSpacing.borderRadius,
        ),
        child: Container(
          padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              borderRadius ?? AppSpacing.borderRadius,
            ),
            border: border ?? Border.all(color: AppColors.border, width: 1),
            boxShadow: shadow != null
                ? [shadow!]
                : [
                    BoxShadow(
                      color: AppColors.black.withValues(
                        alpha: 0.03,
                      ), // Super subtle shadow
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: child,
        ),
      ),
    );

    // Make the card responsive by restricting max width
    cardContent = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: cardContent,
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: cardContent);
    }

    return cardContent;
  }
}

// 带图标和标题的卡片
class CampusFeatureCard extends StatelessWidget {
  const CampusFeatureCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.iconColor,
    this.backgroundColor,
    this.onTap,
  });
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? iconColor;
  final Color? backgroundColor;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return CampusCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: (backgroundColor ?? AppColors.primary).withValues(
                alpha: 0.1,
              ),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Center(
              child: Icon(
                icon,
                size: 28,
                color: iconColor ?? backgroundColor ?? AppColors.primaryBrand,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: AppTextStyles.titleSmall,
            textAlign: TextAlign.center,
          ),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Text(
                subtitle!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}

// 资讯卡片
class CampusNewsCard extends StatelessWidget {
  const CampusNewsCard({
    super.key,
    required this.title,
    this.content,
    this.imageUrl,
    this.date,
    this.source,
    this.onTap,
  });
  final String title;
  final String? content;
  final String? imageUrl;
  final String? date;
  final String? source;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return CampusCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imageUrl != null)
            Container(
              width: double.infinity,
              height: 160,
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(imageUrl!),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
              ),
            ),
          Text(
            title,
            style: AppTextStyles.titleSmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (content != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Text(
                content!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          if (date != null || source != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (date != null) Text(date!, style: AppTextStyles.caption),
                  if (source != null)
                    Text(source!, style: AppTextStyles.caption),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// 课程卡片
class CampusCourseCard extends StatelessWidget {
  const CampusCourseCard({
    super.key,
    required this.courseName,
    required this.teacher,
    required this.time,
    required this.location,
    this.color,
    this.onTap,
  });
  final String courseName;
  final String teacher;
  final String time;
  final String location;
  final Color? color;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return CampusCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.lg),
      border: Border(
        left: BorderSide(color: color ?? AppColors.primaryBrand, width: 3),
        top: const BorderSide(color: AppColors.divider),
        right: const BorderSide(color: AppColors.divider),
        bottom: const BorderSide(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            courseName,
            style: AppTextStyles.titleSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              teacher,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: Row(
              children: [
                const Icon(Icons.access_time, size: 14, color: AppColors.grey),
                const SizedBox(width: AppSpacing.xs),
                Text(time, style: AppTextStyles.caption),
                const SizedBox(width: AppSpacing.md),
                const Icon(Icons.location_on, size: 14, color: AppColors.grey),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    location,
                    style: AppTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
