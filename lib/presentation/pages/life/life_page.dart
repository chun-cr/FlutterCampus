import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../components/components.dart';
import '../../theme/theme.dart';

class LifePage extends ConsumerWidget {
  const LifePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 校园资讯动态
          _buildSectionHeader('校园头条'),
          SizedBox(
            height: 160,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              itemBuilder: (context, index) {
                return Container(
                  width: 280,
                  margin: EdgeInsets.only(right: AppSpacing.md),
                  child: CampusCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 100,
                          decoration: BoxDecoration(
                            color: AppColors.greyLight,
                            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                            image: DecorationImage(
                                image: NetworkImage('https://via.placeholder.com/280x100/2196F3/FFFFFF?text=News+$index'), // Placeholder
                                fit: BoxFit.cover
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(AppSpacing.sm),
                          child: Text(
                            index == 0 ? '关于2026年春季学期开学通知' : '校园十大歌手决赛今晚开启！',
                            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // 2. 食堂与后勤
          _buildSectionHeader('今日食谱'),
          CampusCard(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                _buildCanteenItem('一食堂', '红烧肉、麻婆豆腐', 4.5),
                const Divider(),
                _buildCanteenItem('二食堂', '糖醋排骨、清炒时蔬', 4.0),
                const SizedBox(height: AppSpacing.sm),
                CampusButton(
                  text: '去评价 / 查看详情',
                  onPressed: () {},
                  type: CampusButtonType.secondary,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // 3. 校车与地图
          _buildSectionHeader('校园出行'),
          CampusCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                Container(
                  height: 150,
                  width: double.infinity,
                  color: AppColors.greyLight,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.map, size: 40, color: AppColors.textSecondary),
                        Text('地图 SDK 占位区域', style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.directions_bus, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('校车 A 线', style: AppTextStyles.titleSmall),
                              Text('下一班：5分钟后到达', style: AppTextStyles.caption.copyWith(color: AppColors.success)),
                            ],
                          ),
                        ],
                      ),
                      Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.grey),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm, left: 4),
      child: Text(title, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildCanteenItem(String name, String menu, double rating) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: AppColors.campusOrange.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(Icons.restaurant, color: AppColors.campusOrange, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                Text(menu, style: AppTextStyles.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Row(
            children: [
              Icon(Icons.star, size: 14, color: AppColors.campusOrange),
              Text(' $rating', style: AppTextStyles.caption),
            ],
          ),
        ],
      ),
    );
  }
}
