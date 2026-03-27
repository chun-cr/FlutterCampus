import 'package:flutter/material.dart';
import '../theme/theme.dart';

class CampusSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    bool isError = false,
  }) {
    if (!context.mounted) return;
    
    final icon = isError ? Icons.error_outline_rounded : Icons.check_circle_rounded;
    final bgColor = isError ? AppColors.error : AppColors.success;
    
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.labelMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: bgColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
