import 'package:flutter/material.dart';
import '../theme/theme.dart';

class CampusCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? borderRadius;
  final double? elevation;
  final Color? backgroundColor;
  final BoxShadow? shadow;
  final Function()? onTap;
  final Border? border;

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

  @override
  Widget build(BuildContext context) {
    Widget cardContent = Container(
      margin: margin ?? EdgeInsets.all(AppSpacing.md),
      child: Material(
        color: backgroundColor ?? AppColors.surface,
        elevation: elevation ?? 2.0,
        borderRadius: BorderRadius.circular(borderRadius ?? AppSpacing.borderRadius),
        child: Container(
          padding: padding ?? EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius ?? AppSpacing.borderRadius),
            border: border ?? Border.all(color: AppColors.divider, width: 1),
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
      return GestureDetector(
        onTap: onTap,
        child: cardContent,
      );
    }

    return cardContent;
  }
}

// 带图标和标题的卡片
class CampusFeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? iconColor;
  final Color? backgroundColor;
  final Function()? onTap;

  const CampusFeatureCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.iconColor,
    this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CampusCard(
      onTap: onTap,
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: (backgroundColor ?? AppColors.primary).withOpacity(0.1),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Center(
              child: Icon(
                icon,
                size: 28,
                color: iconColor ?? backgroundColor ?? AppColors.primary,
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
              padding: EdgeInsets.only(top: AppSpacing.sm),
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
  final String title;
  final String? content;
  final String? imageUrl;
  final String? date;
  final String? source;
  final Function()? onTap;

  const CampusNewsCard({
    super.key,
    required this.title,
    this.content,
    this.imageUrl,
    this.date,
    this.source,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CampusCard(
      onTap: onTap,
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imageUrl != null)
            Container(
              width: double.infinity,
              height: 160,
              margin: EdgeInsets.only(bottom: AppSpacing.md),
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
              padding: EdgeInsets.only(top: AppSpacing.sm),
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
              padding: EdgeInsets.only(top: AppSpacing.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (date != null)
                    Text(
                      date!,
                      style: AppTextStyles.caption,
                    ),
                  if (source != null)
                    Text(
                      source!,
                      style: AppTextStyles.caption,
                    ),
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
  final String courseName;
  final String teacher;
  final String time;
  final String location;
  final Color? color;
  final Function()? onTap;

  const CampusCourseCard({
    super.key,
    required this.courseName,
    required this.teacher,
    required this.time,
    required this.location,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CampusCard(
      onTap: onTap,
      padding: EdgeInsets.all(AppSpacing.lg),
      border: Border(
        left: BorderSide(color: color ?? AppColors.primary, width: 4),
        top: BorderSide(color: AppColors.divider),
        right: BorderSide(color: AppColors.divider),
        bottom: BorderSide(color: AppColors.divider),
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
            padding: EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              teacher,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: AppSpacing.sm),
            child: Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: AppColors.grey,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  time,
                  style: AppTextStyles.caption,
                ),
                const SizedBox(width: AppSpacing.md),
                Icon(
                  Icons.location_on,
                  size: 14,
                  color: AppColors.grey,
                ),
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
