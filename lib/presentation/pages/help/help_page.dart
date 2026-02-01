import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../components/components.dart';
import '../../theme/theme.dart';

class HelpPage extends ConsumerWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 快捷发布
          Row(
            children: [
              Expanded(child: _buildActionButton(Icons.campaign, '失物招领', AppColors.error)),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: _buildActionButton(Icons.shopping_bag, '闲置交易', AppColors.campusGreen)),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: _buildActionButton(Icons.group_add, '寻找搭子', AppColors.campusPurple)),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // 2. 失物招领
          _buildSectionHeader('最新失物招领'),
          CampusCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _buildListItem(
                  icon: Icons.vpn_key,
                  title: '捡到一把宝马车钥匙',
                  subtitle: '地点：二食堂门口',
                  time: '10分钟前',
                  tag: '招领',
                  tagColor: AppColors.primary,
                ),
                const Divider(height: 1),
                _buildListItem(
                  icon: Icons.credit_card,
                  title: '丢失校园卡',
                  subtitle: '卡号：2023***01',
                  time: '1小时前',
                  tag: '寻物',
                  tagColor: AppColors.error,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // 3. 闲置流转
          _buildSectionHeader('二手好物'),
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              itemBuilder: (context, index) {
                return Container(
                  width: 140,
                  margin: EdgeInsets.only(right: AppSpacing.md),
                  child: CampusCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.greyLight,
                              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                            ),
                            child: Center(child: Icon(Icons.image, color: AppColors.grey)),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(index % 2 == 0 ? '考研英语词汇' : '罗技鼠标', style: AppTextStyles.bodyMedium, maxLines: 1),
                              Text('¥ ${index % 2 == 0 ? '15' : '50'}', style: AppTextStyles.titleSmall.copyWith(color: AppColors.error)),
                            ],
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

          // 4. 校园搭子
          _buildSectionHeader('互助任务 / 找搭子'),
          CampusCard(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                _buildTaskItem('求带二食堂的黄焖鸡', '跑腿 · 悬赏 ¥2', '5分钟前'),
                const SizedBox(height: 12),
                _buildTaskItem('周六下午约羽毛球', '运动 · 缺2人', '30分钟前'),
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

  Widget _buildActionButton(IconData icon, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(label, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildListItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required String tag,
    required Color tagColor,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: AppColors.textPrimary),
      ),
      title: Text(title, style: AppTextStyles.bodyMedium),
      subtitle: Text(subtitle, style: AppTextStyles.caption),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: tagColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
            child: Text(tag, style: AppTextStyles.caption.copyWith(fontSize: 10, color: tagColor)),
          ),
          const SizedBox(height: 4),
          Text(time, style: AppTextStyles.caption.copyWith(fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildTaskItem(String title, String tag, String time) {
    return Row(
      children: [
        CircleAvatar(backgroundColor: AppColors.greyLight, radius: 16, child: Icon(Icons.person, size: 16, color: AppColors.grey)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.bodyMedium),
              Text(tag, style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
            ],
          ),
        ),
        Text(time, style: AppTextStyles.caption),
      ],
    );
  }
}
