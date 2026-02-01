import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_spacing.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      // 基础配置
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      primaryColorDark: AppColors.primaryDark,
      primaryColorLight: AppColors.primaryLight,
      secondaryHeaderColor: AppColors.secondary,
      scaffoldBackgroundColor: AppColors.background,
      cardColor: AppColors.surface,
      dividerColor: AppColors.greyLight,
      focusColor: AppColors.primary,
      hoverColor: AppColors.primaryLight,
      highlightColor: AppColors.primaryLight,
      splashColor: AppColors.primaryLight,
      indicatorColor: AppColors.primary,
      // 文本样式
      textTheme: TextTheme(
        displayLarge: AppTextStyles.headlineLarge,
        displayMedium: AppTextStyles.headlineMedium,
        displaySmall: AppTextStyles.headlineSmall,
        headlineLarge: AppTextStyles.headlineLarge,
        headlineMedium: AppTextStyles.headlineMedium,
        headlineSmall: AppTextStyles.headlineSmall,
        titleLarge: AppTextStyles.titleLarge,
        titleMedium: AppTextStyles.titleMedium,
        titleSmall: AppTextStyles.titleSmall,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.labelLarge,
        labelMedium: AppTextStyles.labelMedium,
        labelSmall: AppTextStyles.labelSmall,
      ),
      // 按钮样式
      buttonTheme: ButtonThemeData(
        buttonColor: AppColors.primary,
        textTheme: ButtonTextTheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.buttonPadding,
        ),
      ),
      // ElevatedButton样式
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          textStyle: AppTextStyles.button,
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.buttonPadding,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
          ),
          elevation: 2,
          shadowColor: AppColors.black.withOpacity(0.1),
        ),
      ),
      // OutlinedButton样式
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.primary,
          textStyle: AppTextStyles.button.copyWith(
            color: AppColors.primary,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.buttonPadding,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
          ),
          side: BorderSide(
            color: AppColors.primary,
            width: 1,
          ),
        ),
      ),
      // TextButton样式
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTextStyles.button.copyWith(
            color: AppColors.primary,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm,
          ),
        ),
      ),
      // 卡片样式
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 2,
        margin: EdgeInsets.all(AppSpacing.sm),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
        ),
      ).copyWith(
        shadowColor: AppColors.black.withOpacity(0.1),
      ),
      // 输入框样式
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textPrimary,
        ),
        errorStyle: AppTextStyles.error,
        helperStyle: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textSecondary,
        ),
        prefixStyle: AppTextStyles.bodyMedium,
        suffixStyle: AppTextStyles.bodyMedium,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
          borderSide: BorderSide(
            color: AppColors.greyLight,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
          borderSide: BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
          borderSide: BorderSide(
            color: AppColors.error,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
          borderSide: BorderSide(
            color: AppColors.error,
            width: 2,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
          borderSide: BorderSide(
            color: AppColors.greyLight,
            width: 1,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),
      // 应用栏样式
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 2,
        shadowColor: AppColors.black.withOpacity(0.1),
        centerTitle: true,
        titleTextStyle: AppTextStyles.titleMedium.copyWith(
          color: AppColors.white,
        ),
        toolbarHeight: AppSpacing.appBarHeight,
      ),
      // 底部导航栏样式
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        elevation: 8,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.grey,
        selectedLabelStyle: AppTextStyles.labelSmall,
        unselectedLabelStyle: AppTextStyles.labelSmall,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        showSelectedLabels: true,
        landscapeLayout: BottomNavigationBarLandscapeLayout.spread,
      ),
      // 标签栏样式
      tabBarTheme: TabBarThemeData(
        indicatorColor: AppColors.primary,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.grey,
        labelStyle: AppTextStyles.labelMedium,
        unselectedLabelStyle: AppTextStyles.labelMedium,
        indicatorSize: TabBarIndicatorSize.label,
      ),
      // 弹窗样式
      dialogTheme: DialogThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.largeBorderRadius),
        ),
        titleTextStyle: AppTextStyles.titleMedium,
        contentTextStyle: AppTextStyles.bodyMedium,
      ),
      // 开关样式
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primary;
          }
          return AppColors.greyLight;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primaryLight;
          }
          return AppColors.greyLight;
        }),
      ),
      // 滑块样式
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.greyLight,
        thumbColor: AppColors.primary,
        overlayColor: AppColors.primaryLight.withOpacity(0.2),
        valueIndicatorColor: AppColors.primary,
        valueIndicatorTextStyle: AppTextStyles.labelSmall.copyWith(
          color: AppColors.white,
        ),
      ),
      // 进度条样式
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.primary,
      ),
      // 扩展面板样式
      expansionTileTheme: ExpansionTileThemeData(
        textColor: AppColors.textPrimary,
        iconColor: AppColors.primary,
        collapsedTextColor: AppColors.textPrimary,
        collapsedIconColor: AppColors.grey,
        tilePadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        childrenPadding: EdgeInsets.all(AppSpacing.md),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      primaryColorDark: AppColors.primaryDark,
      primaryColorLight: AppColors.primaryLight,
      secondaryHeaderColor: AppColors.secondary,
      scaffoldBackgroundColor: AppColors.black,
      cardColor: AppColors.greyDark,
      dividerColor: AppColors.grey,
      focusColor: AppColors.primaryLight,
      hoverColor: AppColors.primaryLight,
      highlightColor: AppColors.primaryLight,
      splashColor: AppColors.primaryLight,
      indicatorColor: AppColors.primary,
      textTheme: TextTheme(
        displayLarge: AppTextStyles.headlineLarge.copyWith(
          color: AppColors.white,
        ),
        displayMedium: AppTextStyles.headlineMedium.copyWith(
          color: AppColors.white,
        ),
        displaySmall: AppTextStyles.headlineSmall.copyWith(
          color: AppColors.white,
        ),
        headlineLarge: AppTextStyles.headlineLarge.copyWith(
          color: AppColors.white,
        ),
        headlineMedium: AppTextStyles.headlineMedium.copyWith(
          color: AppColors.white,
        ),
        headlineSmall: AppTextStyles.headlineSmall.copyWith(
          color: AppColors.white,
        ),
        titleLarge: AppTextStyles.titleLarge.copyWith(
          color: AppColors.white,
        ),
        titleMedium: AppTextStyles.titleMedium.copyWith(
          color: AppColors.white,
        ),
        titleSmall: AppTextStyles.titleSmall.copyWith(
          color: AppColors.white,
        ),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(
          color: AppColors.white,
        ),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.white,
        ),
        bodySmall: AppTextStyles.bodySmall.copyWith(
          color: AppColors.white,
        ),
        labelLarge: AppTextStyles.labelLarge.copyWith(
          color: AppColors.white,
        ),
        labelMedium: AppTextStyles.labelMedium.copyWith(
          color: AppColors.white,
        ),
        labelSmall: AppTextStyles.labelSmall.copyWith(
          color: AppColors.white,
        ),
      ),
      // 其他样式配置...
    );
  }
}
