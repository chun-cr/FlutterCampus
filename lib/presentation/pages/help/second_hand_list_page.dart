import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/second_hand_service.dart';
import '../../theme/theme.dart';

class SecondHandListPage extends ConsumerWidget {
  const SecondHandListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(allSecondHandStateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '闲置市场',
          style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: _buildBody(state, ref),
    );
  }

  Widget _buildBody(SecondHandState state, WidgetRef ref) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(state.error!, style: AppTextStyles.bodyMedium),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(allSecondHandStateProvider.notifier).loadItems();
              },
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    if (state.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.shopping_bag_outlined,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              '暂时还没有闲置物品',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Simple responsive check for desktop/web
        final crossAxisCount = constraints.maxWidth > 800
            ? 4
            : constraints.maxWidth > 600
            ? 3
            : 2;

        return RefreshIndicator(
          onRefresh: () async {
            await ref.read(allSecondHandStateProvider.notifier).loadItems();
          },
          color: AppColors.primary,
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.75, // Adjust based on content
            ),
            itemCount: state.items.length,
            itemBuilder: (context, index) {
              final item = state.items[index];
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.greyLight.withValues(alpha: 0.6),
                    width: 0.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.greyLight.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          image:
                              item.imageUrl != null && item.imageUrl!.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(item.imageUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: item.imageUrl == null || item.imageUrl!.isEmpty
                            ? const Center(
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  color: AppColors.textSecondary,
                                  size: 32,
                                ),
                              )
                            : null,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: AppTextStyles.labelLarge.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Spacer(),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '¥${item.price.toStringAsFixed(0)}',
                                  style: AppTextStyles.titleMedium.copyWith(
                                    color: AppColors.error,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (item.originalPrice != null &&
                                    item.originalPrice! > item.price) ...[
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      '¥${item.originalPrice!.toStringAsFixed(0)}',
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.textSecondary,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
