import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../components/components.dart';
import '../../theme/theme.dart';

class LibraryHomePage extends ConsumerWidget {
  const LibraryHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CampusAppBar(
        title: '图书馆助手',
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: AppColors.white),
            onPressed: () {
              // TODO: Implement scanner
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            // 1. 搜索框入口
            _buildSearchBar(context),
            const SizedBox(height: AppSpacing.lg),

            // 2. 核心功能入口
            const Row(
              children: [
                Expanded(
                  child: _QuickFeatureCard(
                    icon: Icons.book_rounded,
                    title: '我的借阅',
                    count: '3',
                    badge: '1天后到期',
                    color: Colors.blue,
                    route: '/library/loans',
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _QuickFeatureCard(
                    icon: Icons.chair_rounded,
                    title: '座位预约',
                    count: '余 42',
                    badge: '自习室',
                    color: Colors.green,
                    route: '/library/seats',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const Row(
              children: [
                Expanded(
                  child: _QuickFeatureCard(
                    icon: Icons.event_available,
                    title: '图书预定',
                    count: '0',
                    badge: '暂无待取',
                    color: Colors.orange,
                    route: '/library/reservations',
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _QuickFeatureCard(
                    icon: Icons.analytics_rounded,
                    title: '阅读报告',
                    count: '34本',
                    badge: '击败90%',
                    color: Colors.purple,
                    route: '/library/stats',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // 3. 最新公告
            _buildSectionHeader('馆内公告', () {}),
            const _LibraryAnnouncementCard(
              title: '期末考不打烊：图书馆开放时间调整',
              date: '2025-06-12',
              type: '通知',
            ),
            const _LibraryAnnouncementCard(
              title: '第四届“悦读之星”分享活动报名',
              date: '2025-06-10',
              type: '活动',
            ),

            const SizedBox(height: AppSpacing.lg),
            // 4. 推荐图书
            _buildSectionHeader('图书推荐', () {}),
            SizedBox(
              height: 180,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  _RecommendedBookCard(
                    title: '三体',
                    author: '刘慈欣',
                    cover: 'https://via.placeholder.com/100x140',
                  ),
                  _RecommendedBookCard(
                    title: '解忧杂货店',
                    author: '东野圭吾',
                    cover: 'https://via.placeholder.com/100x140',
                  ),
                  _RecommendedBookCard(
                    title: '百年孤独',
                    author: '马尔克斯',
                    cover: 'https://via.placeholder.com/100x140',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/library/search'),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: AppColors.grey),
            const SizedBox(width: 8),
            Text(
              '书名/作者/ISBN',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey),
            ),
            const Spacer(),
            const VerticalDivider(width: 20),
            Icon(Icons.history, color: AppColors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm, left: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTextStyles.titleSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          TextButton(
            onPressed: onTap,
            child: Text(
              '查看全部',
              style: AppTextStyles.caption.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickFeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String count;
  final String badge;
  final Color color;
  final String route;

  const _QuickFeatureCard({
    required this.icon,
    required this.title,
    required this.count,
    required this.badge,
    required this.color,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(route),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  count,
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: color,
                    fontSize: 18,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.greyLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    badge,
                    style: AppTextStyles.overline.copyWith(fontSize: 8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LibraryAnnouncementCard extends StatelessWidget {
  final String title;
  final String date;
  final String type;

  const _LibraryAnnouncementCard({
    required this.title,
    required this.date,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: type == '通知'
                  ? AppColors.primary.withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              type,
              style: AppTextStyles.overline.copyWith(
                color: type == '通知' ? AppColors.primary : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(date, style: AppTextStyles.caption.copyWith(fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendedBookCard extends StatelessWidget {
  final String title;
  final String author;
  final String cover;

  const _RecommendedBookCard({
    required this.title,
    required this.author,
    required this.cover,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 130,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(cover),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            author,
            style: AppTextStyles.overline,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
