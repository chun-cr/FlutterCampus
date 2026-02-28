import 'package:flutter/material.dart';

class AppColors {
  // Shadcn UI Primary Blue (Used for CTA buttons)
  static const primary = Color(
    0xFF0F172A,
  ); // Almost black for standard primary buttons
  static const primaryBrand = Color(
    0xFF2563EB,
  ); // The actual blue (Blue 600) for CTA
  static const primaryDark = Color(0xFF1D4ED8); // Blue 700
  static const primaryLight = Color(0xFF60A5FA); // Blue 400

  // 辅助色
  static const secondary = Color(0xFFF1F5F9); // Slate 100
  static const secondaryDark = Color(0xFFE2E8F0); // Slate 200
  static const secondaryLight = Color(0xFFF8FAFC); // Slate 50

  // 功能色
  static const success = Color(0xFF10B981); // Emerald 500
  static const warning = Color(0xFFF59E0B); // Amber 500
  static const error = Color(0xFFEF4444); // Red 500
  static const info = Color(0xFF3B82F6); // Blue 500

  // 中性色 (Zinc/Slate Palette for minimalistic look)
  static const background = Color(0xFFFAFAFA); // Zinc 50
  static const surface = Color(0xFFFFFFFF); // Pure White
  static const textPrimary = Color(0xFF09090B); // Zinc 950 (Almost black)
  static const textSecondary = Color(0xFF71717A); // Zinc 500 (Subtle gray)
  static const textDisabled = Color(0xFFA1A1AA); // Zinc 400
  static const divider = Color(0xFFE4E4E7); // Zinc 200 (Very subtle borders)

  // 阴影与边框颜色
  static const border = Color(0xFFE4E4E7); // Zinc 200
  static const input = Color(0xFFE4E4E7); // Zinc 200
  static const ring = Color(0xFF2563EB); // CTA Blue ring focus

  // Compatibility aliases
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF09090B);
  static const grey = Color(0xFF71717A);
  static const greyLight = Color(0xFFE4E4E7);
  static const greyDark = Color(0xFF27272A); // Zinc 800

  // 校园特色色 (保留供后续可能用到，转为柔和色调)
  static const campusGreen = Color(0xFF10B981);
  static const campusBlue = Color(0xFF2563EB);
  static const campusRed = Color(0xFFEF4444);
  static const campusPurple = Color(0xFF8B5CF6);
  static const campusOrange = Color(0xFFF97316);
}
