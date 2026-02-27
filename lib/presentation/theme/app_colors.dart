import 'package:flutter/material.dart';

class AppColors {
  // 主色调 (Primary Blue) - 加深
  static const primary = Color(0xFF1155AA);
  static const primaryDark = Color(0xFF0D3F80);
  static const primaryLight = Color(0xFF3A7FD5);
  
  // 辅助色
  static const secondary = Color(0xFF2E3F9E);
  static const secondaryDark = Color(0xFF1E2E7A);
  static const secondaryLight = Color(0xFF5C6BC0);
  
  // 功能色
  static const success = Color(0xFF2E7D32);
  static const warning = Color(0xFFE65100);
  static const error = Color(0xFFC62828);
  static const info = Color(0xFF0277BD);
  
  // 中性色 - 加深以提升对比度
  // No pure white except for card surfaces
  // No pure black
  static const background = Color(0xFFE8E8E8);       // 加深背景色
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF121212);       // 更深的正文色
  static const textSecondary = Color(0xFF424242);     // 加深次要文字
  static const textDisabled = Color(0xFF757575);      // 加深禁用文字
  static const divider = Color(0xFFBDBDBD);           // 加深分割线
  
  // Deprecated/Compatibility aliases
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF121212);
  static const grey = Color(0xFF616161);
  static const greyLight = Color(0xFFBDBDBD);         // 加深浅灰
  static const greyDark = Color(0xFF424242);          // 加深深灰
  
  // 校园特色色
  static const campusGreen = Color(0xFF2E7D32);
  static const campusBlue = Color(0xFF1155AA);
  static const campusRed = Color(0xFFC62828);
  static const campusPurple = Color(0xFF6A1B9A);
  static const campusOrange = Color(0xFFE65100);
}
