import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/theme.dart';

class HelpPage extends ConsumerWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. 快速功能入口
              _buildSectionHeader('快速功能'),
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      Icons.vpn_key_outlined,
                      '失物招领',
                      () => context.push('/help/post?type=lostAndFound'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildActionButton(
                      Icons.shopping_bag_outlined,
                      '闲置交换',
                      () => context.push('/help/post?type=secondHand'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildActionButton(
                      Icons.people_outline,
                      '校园搭子',
                      () => context.push('/help/post?type=helpTask'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),

              // 2. 失物招领
              _buildSectionHeader('最新失物招领'),
              _buildPremiumCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _buildListItem(
                      icon: Icons.directions_car_outlined,
                      title: '宝马车钥匙',
                      subtitle: '在二食堂附近拾到',
                      time: '10分钟前',
                      tag: '已找到',
                      isUrgent: false,
                    ),
                    const Divider(
                      height: 1,
                      thickness: 0.5,
                      color: AppColors.greyLight,
                    ),
                    _buildListItem(
                      icon: Icons.credit_card_outlined,
                      title: '学生证',
                      subtitle: '尾号 01',
                      time: '1小时前',
                      tag: '已丢失',
                      isUrgent: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // 3. 闲置流转 (Curated Marketplace)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionHeader('闲置市场'),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16, right: 4),
                    child: Text(
                      '查看全部',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 160,
                      margin: const EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppColors.greyLight.withValues(alpha: 0.6),
                          width: 0.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(24),
                                ),
                                image: DecorationImage(
                                  image: NetworkImage(
                                    index % 2 == 0
                                        ? 'https://images.unsplash.com/photo-1544947950-fa07a98d237f?auto=format&fit=crop&q=80&w=400'
                                        : 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?auto=format&fit=crop&q=80&w=400',
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  index % 2 == 0 ? '设计类图书' : '无线鼠标',
                                  style: AppTextStyles.labelMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '¥ ${index % 2 == 0 ? '150' : '280'}',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 48),

              // 4. 校园搭子 (Community Requests)
              _buildSectionHeader('互助请求'),
              _buildPremiumCard(
                child: Column(
                  children: [
                    _buildTaskItem('二食堂帮打饭', '跑腿任务 · 奖励20元', '5分钟前'),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(
                        height: 1,
                        thickness: 0.5,
                        color: AppColors.greyLight,
                      ),
                    ),
                    _buildTaskItem('周六打羽毛球搭子', '运动 ·缺2人', '30分钟前'),
                  ],
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumCard({
    required Widget child,
    EdgeInsetsGeometry? padding,
  }) {
    return Container(
      padding: padding ?? const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.greyLight.withValues(alpha: 0.6),
          width: 0.5,
        ),
      ),
      child: child,
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.labelLarge.copyWith(
          letterSpacing: 1.5,
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.greyLight.withValues(alpha: 0.6),
            width: 0.5,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(height: 12),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required String tag,
    required bool isUrgent,
  }) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isUrgent
                  ? AppColors.error.withValues(alpha: 0.05)
                  : AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: isUrgent ? AppColors.error : AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.titleMedium),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                tag,
                style: AppTextStyles.overline.copyWith(
                  letterSpacing: 1.2,
                  color: isUrgent ? AppColors.error : AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                time,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.greyDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(String title, String tag, String time) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.background,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.greyLight.withValues(alpha: 0.6),
              width: 0.5,
            ),
          ),
          child: const Icon(
            Icons.person_outline,
            size: 20,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.titleMedium),
              const SizedBox(height: 4),
              Text(
                tag,
                style: AppTextStyles.caption.copyWith(color: AppColors.primary),
              ),
            ],
          ),
        ),
        Text(
          time,
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
