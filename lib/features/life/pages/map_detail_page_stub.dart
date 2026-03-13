import 'package:flutter/material.dart';

import '../../../presentation/theme/theme.dart';

class MapDetailView extends StatelessWidget {
  const MapDetailView({super.key});

  static const String _staticMapUrl =
      'https://restapi.amap.com/v3/staticmap'
      '?location=113.954625,35.299916'
      '&zoom=17'
      '&size=800*480'
      '&markers=mid,,A:113.954625,35.299916'
      '&key=12c1f063640f6b2b9c2efb205e54c325';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          '校园地图',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: AspectRatio(
                aspectRatio: 5 / 3,
                child: Image.network(
                  _staticMapUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.surface,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.map_outlined,
                        size: 48,
                        color: AppColors.textSecondary,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('河南工学院图书馆', style: AppTextStyles.titleLarge),
            const SizedBox(height: 8),
            Text(
              '已打开校园生活模块地图页。当前平台展示静态地图预览，Web 端可查看完整交互地图。',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
