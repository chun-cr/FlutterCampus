import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../domain/models/book.dart';
import '../../../features/library/providers/book_provider.dart';
import '../../components/components.dart';
import '../../../features/library/models/announcement.dart';
import '../../../features/library/providers/announcement_provider.dart';
import '../../../features/library/providers/borrow_provider.dart';
import '../../../features/library/providers/seat_provider.dart';
import '../../theme/theme.dart';

class LibraryHomePage extends ConsumerWidget {
  const LibraryHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: CampusAppBar(
        title: '图书馆助手',
        showBackButton: true,
        actions: [
          IconButton(
            // 线性风格二维码扫描图标
            icon: const Icon(Icons.qr_code_scanner_outlined, color: AppColors.white),
            onPressed: () {
              // TODO: Implement scanner
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 搜索框入口
            _buildSearchBar(context),
            const SizedBox(height: 40),

            // 2. 核心功能入口（2×2 网格）
            Row(
              children: [
                Expanded(
                  child: Consumer(
                    builder: (context, ref, _) {
                      final statsAsync = ref.watch(myBorrowStatsProvider);
                      return statsAsync.when(
                        loading: () => _QuickFeatureCard(
                          icon: Icons.book_outlined,
                          title: '我的借阅',
                          count: '-',
                          badge: '',
                          route: '/library/loans',
                        ),
                        error: (_, __) => _QuickFeatureCard(
                          icon: Icons.book_outlined,
                          title: '我的借阅',
                          count: '-',
                          badge: '',
                          route: '/library/loans',
                        ),
                        data: (stats) => _QuickFeatureCard(
                          icon: Icons.book_outlined,
                          title: '我的借阅',
                          count: '${stats.borrowedCount}',
                          badge: stats.hasDueSoon
                              ? '${stats.dueSoonCount}本即将到期'
                              : '借阅中',
                          badgeColor: stats.hasDueSoon
                              ? const Color(0xFFFFEBEE)
                              : const Color(0xFFF0F0F0),
                          badgeTextColor: stats.hasDueSoon
                              ? const Color(0xFFC62828)
                              : const Color(0xFF666666),
                          route: '/library/loans',
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Consumer(
                    builder: (context, ref, _) {
                      final countAsync = ref.watch(seatAvailableCountProvider);
                      return countAsync.when(
                        loading: () => const _QuickFeatureCard(
                          icon: Icons.chair_outlined,
                          title: '座位预约',
                          count: '-',
                          badge: '自习室',
                          route: '/library/seats',
                        ),
                        error: (_, __) => const _QuickFeatureCard(
                          icon: Icons.chair_outlined,
                          title: '座位预约',
                          count: '-',
                          badge: '自习室',
                          route: '/library/seats',
                        ),
                        data: (n) => _QuickFeatureCard(
                          icon: Icons.chair_outlined,
                          title: '座位预约',
                          count: '余 $n',
                          badge: '自习室',
                          route: '/library/seats',
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Expanded(
                  child: _QuickFeatureCard(
                    icon: Icons.event_available_outlined,
                    title: '图书预定',
                    count: '0',
                    badge: '暂无待取',
                    route: '/library/reservations',
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _QuickFeatureCard(
                    icon: Icons.bar_chart_outlined,
                    title: '阅读报告',
                    count: '34本',
                    badge: '击败90%',
                    route: '/library/stats',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // 3. 馆内公告
            _buildSectionHeader('馆内公告', subtitle: 'ANNOUNCEMENTS', onTap: () {}),
            const _AnnouncementBanner(),
            const SizedBox(height: 40),

            // 4. 推荐图书（接入真实 Supabase 数据）
            _buildSectionHeader(
              '图书推荐',
              subtitle: 'RECOMMENDATIONS',
              onTap: () => context.push('/library/books'),
            ),
            _RecommendedBooksSection(ref: ref),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  /// 搜索框：极简白卡，轻阴影，无彩色元素
  Widget _buildSearchBar(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/library/search'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.06),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.search_outlined, color: AppColors.grey, size: 20),
            const SizedBox(width: 10),
            Text(
              '书名 / 作者 / ISBN',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textDisabled,
              ),
            ),
            const Spacer(),
            Container(
              width: 1,
              height: 16,
              color: AppColors.greyLight,
            ),
            const SizedBox(width: 12),
            const Icon(Icons.history_outlined, color: AppColors.grey, size: 18),
          ],
        ),
      ),
    );
  }

  /// 模块标题：中文粗体 + 英文全大写副标题 + 右侧"查看全部"（灰色）
  /// 与 study_page.dart 的 _buildSectionHeader 风格保持一致
  Widget _buildSectionHeader(String title, {String? subtitle, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textDisabled,
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
          const Spacer(),
          // "查看全部"—灰色，非彩色
          GestureDetector(
            onTap: onTap,
            child: Text(
              '查看全部',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 功能卡片：极简白卡，线性灰色图标，黑色大数字，浅灰小标签
// ---------------------------------------------------------------------------
class _QuickFeatureCard extends StatelessWidget {
  const _QuickFeatureCard({
    required this.icon,
    required this.title,
    required this.count,
    required this.badge,
    required this.route,
    this.badgeColor,
    this.badgeTextColor,
  });

  final IconData icon;
  final String title;
  final String count;
  final String badge;
  final String route;
  /// badge 背景色（默认 0xFFF0F0F0 浅灰）
  final Color? badgeColor;
  /// badge 文字色（默认 0xFF666666 深灰）
  final Color? badgeTextColor;


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(route),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.06),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 线性图标，无彩色背景色块
            Icon(icon, color: const Color(0xFF333333), size: 24),
            const SizedBox(height: 12),
            // 标题
            Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // 数字：大号加粗黑色
                Text(
                  count,
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
                // 角标：浅灰胶囊，深灰文字
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor ?? const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badge,
                    style: AppTextStyles.overline.copyWith(
                      fontSize: 9,
                      color: badgeTextColor ?? const Color(0xFF666666),
                      fontWeight: FontWeight.w500,
                    ),
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

// ---------------------------------------------------------------------------
// 公告卡片：浅灰圆角文字标签，无彩色背景
// ---------------------------------------------------------------------------
class _LibraryAnnouncementCard extends StatelessWidget {
  const _LibraryAnnouncementCard({
    super.key,
    required this.title,
    required this.date,
    required this.type,
  });

  final String title;
  final String date;
  final String type;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.06),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // 浅灰圆角标签，无彩色
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              type,
              style: AppTextStyles.overline.copyWith(
                color: const Color(0xFF666666),
                fontSize: 10,
                fontWeight: FontWeight.w500,
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
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  date,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textDisabled,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          // 右箭头指示器
          const Icon(
            Icons.chevron_right,
            color: AppColors.grey,
            size: 16,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 推荐图书区域：含 loading 骨架、错误状态、真实数据
// ---------------------------------------------------------------------------
class _RecommendedBooksSection extends StatelessWidget {
  const _RecommendedBooksSection({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final booksAsync = ref.watch(recommendedBooksProvider);

    return SizedBox(
      height: 180,
      child: booksAsync.when(
        // 加载中：3 个 shimmer 骨架占位卡片
        loading: () => ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 3,
          itemBuilder: (context, index) => const _SkeletonBookCard(),
        ),
        // 加载失败：灰色提示文字
        error: (error, _) => Center(
          child: Text(
            '推荐图书加载失败',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textDisabled,
            ),
          ),
        ),
        // 加载成功：横向滚动图书卡片列表
        data: (books) {
          if (books.isEmpty) {
            return Center(
              child: Text(
                '暂无推荐图书',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textDisabled,
                ),
              ),
            );
          }
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: books.length,
            itemBuilder: (context, index) =>
                _RecommendedBookCard(book: books[index]),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 推荐图书卡片：与原样式保持一致，接收 Book 对象
// ---------------------------------------------------------------------------
class _RecommendedBookCard extends StatelessWidget {
  const _RecommendedBookCard({required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/library/books/${book.id}'),
      child: Container(
      width: 100,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 封面图：有封面显示网络图片，无封面显示灰色占位
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 130,
              width: 100,
              child: _buildCoverImage(),
            ),
          ),
          const SizedBox(height: 6),
          // 书名
          Text(
            book.title,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          // 作者
          Text(
            book.author,
            style: AppTextStyles.overline.copyWith(
              color: AppColors.textDisabled,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),    // Column closes
    ),      // Container closes (child of GestureDetector)
    );      // GestureDetector closes
  }

  /// 封面图片：有 coverUrl 则加载网络图，否则灰色占位
  Widget _buildCoverImage() {
    if (book.coverUrl == null || book.coverUrl!.isEmpty) {
      return Container(
        color: const Color(0xFFF0F0F0),
        child: const Center(
          child: Icon(
            Icons.book_outlined,
            color: Color(0xFF999999),
            size: 32,
          ),
        ),
      );
    }
    return Image.network(
      book.coverUrl!,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        color: const Color(0xFFF0F0F0),
        child: const Center(
          child: Icon(
            Icons.broken_image_outlined,
            color: Color(0xFF999999),
            size: 32,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 推荐图书骨架屏卡片：shimmer 动画占位
// ---------------------------------------------------------------------------
class _SkeletonBookCard extends StatelessWidget {
  const _SkeletonBookCard();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFEEEEEE),
      highlightColor: const Color(0xFFFAFAFA),
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 封面占位
            Container(
              height: 130,
              width: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 6),
            // 书名占位
            Container(
              height: 12,
              width: 80,
              color: Colors.white,
            ),
            const SizedBox(height: 4),
            // 作者占位
            Container(
              height: 10,
              width: 55,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}


// ---------------------------------------------------------------------------
// 公告轮播 Banner：ListView + ScrollController 逐条上滚，无限循环
// ---------------------------------------------------------------------------
class _AnnouncementBanner extends ConsumerStatefulWidget {
  const _AnnouncementBanner();

  @override
  ConsumerState<_AnnouncementBanner> createState() => _AnnouncementBannerState();
}

class _AnnouncementBannerState extends ConsumerState<_AnnouncementBanner> {
  // 用于测量单张卡片真实渲染高度的 GlobalKey
  final GlobalKey _cardKey = GlobalKey();

  // 动态测量得到的卡片高度（0 = 尚未测量）
  double _itemHeight = 0;

  late final ScrollController _scrollController;
  Timer? _timer;

  // 保存最近一次观察到的公告数量，用于 Timer 回调内引用
  int _announcementCount = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    // Timer 必须在 dispose 中 cancel，防止内存泄漏
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  /// 测量卡片高度：渲染首张隐形卡片后，通过 RenderBox 获取实际高度
  void _measureCardHeight() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final renderBox =
          _cardKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null && renderBox.hasSize) {
        final measuredHeight = renderBox.size.height;
        if (measuredHeight > 0 && _itemHeight != measuredHeight) {
          setState(() {
            _itemHeight = measuredHeight;
          });
          // 高度确定后再启动 Timer
          _startAutoScroll(_announcementCount);
        }
      }
    });
  }

  /// 启动自动滚动定时器（幂等，只启动一次）
  void _startAutoScroll(int originalCount) {
    // 高度未测量完成或条数不足时不启动
    if (_timer != null || originalCount <= 2 || _itemHeight == 0) return;

    final oneThirdOffset = originalCount * _itemHeight;
    // 无缝跳回的界限：将进入第 3 份时跳回
    final jumpBackThreshold = originalCount * 2 * _itemHeight;

    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted || !_scrollController.hasClients) return;

      final nextOffset = _scrollController.offset + _itemHeight;

      // 当即将进入第 3 份时，无缝跳回第 1 份对应位置
      if (nextOffset >= jumpBackThreshold) {
        _scrollController.jumpTo(nextOffset - oneThirdOffset);
        return;
      }

      _scrollController.animateTo(
        nextOffset,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final announcementsAsync = ref.watch(announcementsProvider);

    return announcementsAsync.when(
      // 加载中：2 行 shimmer 骨架占位
      loading: () => Column(
        children: [
          _buildSkeletonRow(),
          const SizedBox(height: 8),
          _buildSkeletonRow(),
        ],
      ),
      // 加载失败：灰色提示
      error: (error, _) => Center(
        child: Text(
          '公告加载失败',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textDisabled,
          ),
        ),
      ),
      data: (announcements) {
        // 空数据：不渲染公告模块
        if (announcements.isEmpty) return const SizedBox.shrink();

        // 更新条数缓存（供 Timer 回调内使用）
        _announcementCount = announcements.length;

        // <= 2 条：静态展示，不启动 Timer
        if (announcements.length <= 2) {
          return Column(
            children: announcements
                .map((a) => _LibraryAnnouncementCard(
                      title: a.title,
                      date: a.date,
                      type: a.type,
                    ))
                .toList(),
          );
        }

        // 三份拼接列表
        final tripleList = [
          ...announcements,
          ...announcements,
          ...announcements,
        ];

        // 高度未测量时：先渲染隐形测量卡片，获取真实高度
        if (_itemHeight == 0) {
          _measureCardHeight();
          // 隐形占位卡片：不展示内容，仅用于测量高度
          return Opacity(
            opacity: 0,
            child: _LibraryAnnouncementCard(
              key: _cardKey,
              title: tripleList[0].title,
              date: tripleList[0].date,
              type: tripleList[0].type,
            ),
          );
        }

        // 高度测量完成：渲染 ListView，高度完全自适应
        return SizedBox(
          // 展示 2 张卡片，高度 = 实际测量值 × 2
          height: _itemHeight * 2,
          // ClipRect 严格裁剪，超出区域完全不可见
          child: ClipRect(
            child: ListView.builder(
              controller: _scrollController,
              // 禁止用户手动滑动
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tripleList.length,
              // 用测量得到的真实高度作为 itemExtent
              itemExtent: _itemHeight,
              itemBuilder: (context, index) {
                final a = tripleList[index];
                return _LibraryAnnouncementCard(
                  title: a.title,
                  date: a.date,
                  type: a.type,
                );
              },
            ),
          ),
        );
      },
    );
  }

  /// 公告骨架行：shimmer 占位
  Widget _buildSkeletonRow() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFEEEEEE),
      highlightColor: const Color(0xFFFAFAFA),
      child: Container(
        height: 56,
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}