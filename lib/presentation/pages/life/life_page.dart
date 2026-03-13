import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/campus_news_service.dart';
import '../../theme/theme.dart';

class LifePage extends ConsumerStatefulWidget {
  const LifePage({super.key});

  @override
  ConsumerState<LifePage> createState() => _LifePageState();
}

class _LifePageState extends ConsumerState<LifePage> {
  late PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;

  /// 高德静态地图预览 URL（Web服务 Key）
  static const String _staticMapUrl =
      'https://restapi.amap.com/v3/staticmap'
      '?location=113.954625,35.299916'
      '&zoom=17'
      '&size=600*300'
      '&markers=mid,,A:113.954625,35.299916'
      '&key=12c1f063640f6b2b9c2efb205e54c325';

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.88);
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      final newsState = ref.read(campusNewsStateProvider);
      if (newsState.items.length > 1 && _pageController.hasClients) {
        final nextPage = (_currentPage + 1) % newsState.items.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.fastOutSlowIn,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final newsState = ref.watch(campusNewsStateProvider);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. 校园头条 (Premium Feed)
              _buildSectionHeader('校园资讯'),
              SizedBox(height: 240, child: _buildNewsSection(ref, newsState)),
              const SizedBox(height: 48),

              // 2. 食堂与后勤 (Daily Menu - Minimalist)
              _buildSectionHeader('食堂菜单'),
              _buildPremiumCard(
                child: Column(
                  children: [
                    _buildCanteenItem('一食堂', '红烧肉、麻婆豆腐', 4.8),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(
                        height: 1,
                        thickness: 0.5,
                        color: AppColors.greyLight,
                      ),
                    ),
                    _buildCanteenItem('二食堂', '糖醉排骨、时令蔬菜', 4.5),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: Text(
                          '查看全部菜单',
                          style: AppTextStyles.button.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // 3. 校车与地图 (Campus Transit - Sleek)
              _buildSectionHeader('校车与地图'),
              _buildPremiumCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        context.push('/campus-map');
                      },
                      child: SizedBox(
                        height: 160,
                        width: double.infinity,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Image.network(
                                  _staticMapUrl,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, progress) {
                                    if (progress == null) return child;
                                    return Container(
                                      color: AppColors.background,
                                      alignment: Alignment.center,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.textSecondary,
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stack) {
                                    return Container(
                                      color: AppColors.background,
                                      alignment: Alignment.center,
                                      child: const Icon(
                                        Icons.map_outlined,
                                        size: 36,
                                        color: AppColors.textSecondary,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              // 半透明遮罩 + 提示文字
                              Positioned.fill(
                                child: Container(
                                  color: Colors.transparent,
                                  alignment: Alignment.center,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.surface.withValues(
                                        alpha: 0.9,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.location_on_outlined,
                                          size: 16,
                                          color: AppColors.textPrimary,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '查看地图',
                                          style: AppTextStyles.labelMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.08,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.directions_bus_outlined,
                                  color: AppColors.primary,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '校园专车 A线',
                                    style: AppTextStyles.titleMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: AppColors.success,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '5分钟后到达',
                                        style: AppTextStyles.caption,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
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

  Widget _buildNewsSection(WidgetRef ref, CampusNewsState state) {
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
            Text(state.error!, style: AppTextStyles.bodySmall),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () =>
                  ref.read(campusNewsStateProvider.notifier).loadNews(),
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    if (state.items.isEmpty) {
      return Center(
        child: Text(
          '暂无校园资讯',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        PageView.builder(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
          },
          itemCount: state.items.length,
          itemBuilder: (context, index) {
            final item = state.items[index];
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
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
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.greyLight.withValues(alpha: 0.3),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(24),
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
                                Icons.article_outlined,
                                color: AppColors.textSecondary,
                                size: 36,
                              ),
                            )
                          : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.source,
                          style: AppTextStyles.overline.copyWith(
                            letterSpacing: 2,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.title,
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.w500,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        // Dots indicator
        Positioned(
          bottom: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              state.items.length,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == i ? 16 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _currentPage == i
                      ? AppColors.primary
                      : AppColors.greyLight.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ),
      ],
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

  Widget _buildCanteenItem(String name, String menu, double rating) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: AppTextStyles.titleMedium),
              const SizedBox(height: 4),
              Text(
                menu,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.star_rounded,
                size: 14,
                color: AppColors.textPrimary,
              ),
              const SizedBox(width: 4),
              Text(rating.toString(), style: AppTextStyles.labelMedium),
            ],
          ),
        ),
      ],
    );
  }
}
