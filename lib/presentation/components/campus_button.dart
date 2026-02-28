import 'package:flutter/material.dart';
import '../theme/theme.dart';

enum CampusButtonType { primary, secondary, outline, text }

class CampusButton extends StatelessWidget {
  final String text;
  final Function() onPressed;
  final bool isLoading;
  final bool isDisabled;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Color? textColor;
  final TextStyle? textStyle;
  final double? elevation;
  final IconData? icon;
  final MainAxisSize mainAxisSize;
  final CampusButtonType type;

  const CampusButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.backgroundColor,
    this.textColor,
    this.textStyle,
    this.elevation,
    this.icon,
    this.mainAxisSize = MainAxisSize.min,
    this.type = CampusButtonType.primary,
  });

  @override
  Widget build(BuildContext context) {
    final buttonContent = Row(
      mainAxisSize: mainAxisSize,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null && !isLoading)
          Icon(icon, color: _getTextColor(), size: 20),
        if (icon != null && !isLoading) const SizedBox(width: 8),
        if (isLoading)
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(_getTextColor()),
            ),
          )
        else
          Text(
            text,
            style:
                textStyle ??
                AppTextStyles.button.copyWith(color: _getTextColor()),
          ),
      ],
    );

    switch (type) {
      case CampusButtonType.primary:
        return ElevatedButton(
          onPressed: (isLoading || isDisabled) ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: isDisabled
                ? AppColors.greyLight
                : backgroundColor ?? AppColors.primary,
            foregroundColor: _getTextColor(),
            minimumSize: Size(width ?? double.infinity, height ?? 48),
            padding:
                padding ??
                EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.buttonPadding,
                ),
            shape: RoundedRectangleBorder(
              borderRadius:
                  borderRadius ??
                  BorderRadius.circular(AppSpacing.borderRadius),
            ),
            elevation: elevation ?? 0,
            disabledBackgroundColor: AppColors.greyLight,
            disabledForegroundColor: AppColors.textDisabled,
          ),
          child: buttonContent,
        );

      case CampusButtonType.secondary:
        return ElevatedButton(
          onPressed: (isLoading || isDisabled) ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: isDisabled
                ? AppColors.greyLight
                : backgroundColor ?? AppColors.secondary,
            foregroundColor: _getTextColor(),
            minimumSize: Size(width ?? double.infinity, height ?? 48),
            padding:
                padding ??
                EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.buttonPadding,
                ),
            shape: RoundedRectangleBorder(
              borderRadius:
                  borderRadius ??
                  BorderRadius.circular(AppSpacing.borderRadius),
            ),
            elevation: elevation ?? 0,
            disabledBackgroundColor: AppColors.greyLight,
            disabledForegroundColor: AppColors.textDisabled,
          ),
          child: buttonContent,
        );

      case CampusButtonType.outline:
        return OutlinedButton(
          onPressed: (isLoading || isDisabled) ? null : onPressed,
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: isDisabled
                  ? AppColors.greyLight
                  : backgroundColor ?? AppColors.primary,
              width: 1,
            ),
            foregroundColor: _getTextColor(),
            minimumSize: Size(width ?? double.infinity, height ?? 48),
            padding:
                padding ??
                EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.buttonPadding,
                ),
            shape: RoundedRectangleBorder(
              borderRadius:
                  borderRadius ??
                  BorderRadius.circular(AppSpacing.borderRadius),
            ),
            disabledForegroundColor: AppColors.textDisabled,
          ),
          child: buttonContent,
        );

      case CampusButtonType.text:
        return TextButton(
          onPressed: (isLoading || isDisabled) ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: _getTextColor(),
            minimumSize: Size(width ?? double.infinity, height ?? 48),
            padding:
                padding ??
                EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.buttonPadding,
                ),
            disabledForegroundColor: AppColors.textDisabled,
          ),
          child: buttonContent,
        );
    }
  }

  Color _getTextColor() {
    switch (type) {
      case CampusButtonType.primary:
      case CampusButtonType.secondary:
        return textColor ?? AppColors.white;
      case CampusButtonType.outline:
      case CampusButtonType.text:
        return textColor ?? AppColors.primary;
    }
  }
}

class CampusOutlineButton extends StatelessWidget {
  final String text;
  final Function() onPressed;
  final bool isLoading;
  final bool isDisabled;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final Color? borderColor;
  final Color? textColor;
  final TextStyle? textStyle;
  final IconData? icon;
  final MainAxisSize mainAxisSize;

  const CampusOutlineButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.borderColor,
    this.textColor,
    this.textStyle,
    this.icon,
    this.mainAxisSize = MainAxisSize.min,
  });

  @override
  Widget build(BuildContext context) {
    final buttonContent = Row(
      mainAxisSize: mainAxisSize,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null && !isLoading)
          Icon(icon, color: textColor ?? AppColors.primary, size: 20),
        if (icon != null && !isLoading) const SizedBox(width: 8),
        if (isLoading)
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                textColor ?? AppColors.primary,
              ),
            ),
          )
        else
          Text(
            text,
            style:
                textStyle ??
                AppTextStyles.button.copyWith(
                  color: textColor ?? AppColors.primary,
                ),
          ),
      ],
    );

    return OutlinedButton(
      onPressed: (isLoading || isDisabled) ? null : onPressed,
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: isDisabled
              ? AppColors.greyLight
              : borderColor ?? AppColors.primary,
          width: 1,
        ),
        minimumSize: Size(width ?? double.infinity, height ?? 48),
        padding:
            padding ??
            EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.buttonPadding,
            ),
        shape: RoundedRectangleBorder(
          borderRadius:
              borderRadius ?? BorderRadius.circular(AppSpacing.borderRadius),
        ),
        foregroundColor: textColor ?? AppColors.primary,
        disabledForegroundColor: AppColors.textDisabled,
      ),
      child: buttonContent,
    );
  }
}

class CampusTextButton extends StatelessWidget {
  final String text;
  final Function() onPressed;
  final bool isLoading;
  final bool isDisabled;
  final Color? textColor;
  final TextStyle? textStyle;
  final IconData? icon;
  final MainAxisSize mainAxisSize;
  final EdgeInsets? padding;

  const CampusTextButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.textColor,
    this.textStyle,
    this.icon,
    this.mainAxisSize = MainAxisSize.min,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final buttonContent = Row(
      mainAxisSize: mainAxisSize,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null && !isLoading)
          Icon(icon, color: textColor ?? AppColors.primary, size: 16),
        if (icon != null && !isLoading) const SizedBox(width: 4),
        if (isLoading)
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                textColor ?? AppColors.primary,
              ),
            ),
          )
        else
          Text(
            text,
            style:
                textStyle ??
                AppTextStyles.bodyMedium.copyWith(
                  color: textColor ?? AppColors.primary,
                ),
          ),
      ],
    );

    return TextButton(
      onPressed: (isLoading || isDisabled) ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: textColor ?? AppColors.primary,
        padding:
            padding ??
            EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.sm,
            ),
        disabledForegroundColor: AppColors.textDisabled,
      ),
      child: buttonContent,
    );
  }
}

// 图标按钮
class CampusIconButton extends StatelessWidget {
  final IconData icon;
  final Function() onPressed;
  final bool isDisabled;
  final Color? backgroundColor;
  final Color? iconColor;
  final double? size;
  final BorderRadius? borderRadius;
  final double? elevation;

  const CampusIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.isDisabled = false,
    this.backgroundColor,
    this.iconColor,
    this.size,
    this.borderRadius,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: isDisabled ? null : onPressed,
      icon: Icon(icon, color: iconColor ?? AppColors.white, size: size ?? 24),
      label: const SizedBox.shrink(),
      style: ElevatedButton.styleFrom(
        backgroundColor: isDisabled
            ? AppColors.greyLight
            : backgroundColor ?? AppColors.primary,
        minimumSize: Size(size ?? 48, size ?? 48),
        shape: RoundedRectangleBorder(
          borderRadius:
              borderRadius ?? BorderRadius.circular(AppSpacing.borderRadius),
        ),
        elevation: elevation ?? 0,
        shadowColor: AppColors.black.withOpacity(0.1),
        disabledBackgroundColor: AppColors.greyLight,
        disabledForegroundColor: AppColors.textDisabled,
      ),
    );
  }
}
