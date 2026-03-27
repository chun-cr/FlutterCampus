import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/second_hand_service.dart';
import '../../../core/services/lost_and_found_service.dart';
import '../../../core/services/help_task_service.dart';
import '../../../domain/models/community.dart';
import '../../theme/theme.dart';

class HelpPage extends ConsumerWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final secondHandState = ref.watch(helpSecondHandStateProvider);
    final lostAndFoundState = ref.watch(helpLostAndFoundStateProvider);
    final taskState = ref.watch(helpTaskStateProvider);

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
                      '互助请求',
                      () => context.push('/help/post?type=helpTask'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),

              // 2. 失物招领
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionHeader('失物招领'),
                  GestureDetector(
                    onTap: () => context.push('/help/lost_and_found'),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16, right: 4),
                      child: Text(
                        '查看全部',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.primaryBrand,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              _buildPremiumCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    if (lostAndFoundState.isLoading)
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    else if (lostAndFoundState.error != null)
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(child: Text(lostAndFoundState.error!)),
                      )
                    else if (lostAndFoundState.items.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Text(
                            '暂无失物招领',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      )
                    else
                      ...lostAndFoundState.items.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        return Column(
                          children: [
                            _buildListItem(
                              icon: _getLostAndFoundIcon(item),
                              title: item.title,
                              subtitle: item.location,
                              time: item.relativeTime,
                              tag: item.isResolved ? '已解决' : item.type.label,
                              isUrgent:
                                  !item.isResolved &&
                                  item.type == LostFoundType.lost,
                            ),
                            if (index < lostAndFoundState.items.length - 1)
                              const Divider(
                                height: 1,
                                thickness: 0.5,
                                color: AppColors.greyLight,
                              ),
                          ],
                        );
                      }).toList(),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // 3. 闲置流转 (Curated Marketplace)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionHeader('闲置市场'),
                  GestureDetector(
                    onTap: () => context.push('/help/second_hand'),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16, right: 4),
                      child: Text(
                        '查看全部',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (secondHandState.isLoading)
                const SizedBox(
                  height: 200,
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                )
              else if (secondHandState.error != null)
                SizedBox(
                  height: 200,
                  child: Center(
                    child: Text(
                      secondHandState.error!,
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                )
              else if (secondHandState.items.isEmpty)
                SizedBox(
                  height: 200,
                  child: Center(
                    child: Text(
                      '暂无闲置物品',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                )
              else
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    clipBehavior: Clip.none,
                    itemCount: secondHandState.items.length,
                    itemBuilder: (context, index) {
                      final item = secondHandState.items[index];
                      return GestureDetector(
                        onTap: () {}, // Optional details page
                        child: Container(
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
                                    image:
                                        item.imageUrl != null &&
                                            item.imageUrl!.isNotEmpty
                                        ? DecorationImage(
                                            image: NetworkImage(item.imageUrl!),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child:
                                      item.imageUrl == null ||
                                          item.imageUrl!.isEmpty
                                      ? const Center(
                                          child: Icon(
                                            Icons.image_not_supported_outlined,
                                            color: AppColors.textSecondary,
                                            size: 28,
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      style: AppTextStyles.labelMedium.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '¥ ${item.price.toStringAsFixed(0)}',
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
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
              const SizedBox(height: 48),

              // 4. 校园搭子 (Community Requests)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionHeader('互助请求'),
                  GestureDetector(
                    onTap: () => context.push('/help/task_list'),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16, right: 4),
                      child: Text(
                        '查看全部',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              _buildPremiumCard(
                child: Column(
                  children: [
                    if (taskState.isLoading)
                      const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    else if (taskState.error != null)
                      Center(child: Text(taskState.error!))
                    else if (taskState.tasks.isEmpty)
                      Center(
                        child: Text(
                          '暂无互助请求',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                    else
                      ...taskState.tasks.asMap().entries.map((entry) {
                        final index = entry.key;
                        final task = entry.value;
                        return Column(
                          children: [
                            _buildTaskItem(
                              task.title,
                              task.tagDisplay,
                              task.relativeTime,
                            ),
                            if (index < taskState.tasks.length - 1)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Divider(
                                  height: 1,
                                  thickness: 0.5,
                                  color: AppColors.greyLight,
                                ),
                              ),
                          ],
                        );
                      }).toList(),
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

  IconData _getLostAndFoundIcon(LostAndFound item) {
    if (item.type == LostFoundType.lost) {
      return Icons.search_rounded; // 寻物
    } else {
      return Icons.volunteer_activism_outlined; // 招领
    }
  }
}
