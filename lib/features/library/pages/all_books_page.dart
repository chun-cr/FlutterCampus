import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../domain/models/book.dart';
import '../../../presentation/components/components.dart';
import '../../../presentation/theme/theme.dart';
import '../providers/book_provider.dart';

/// 全部图书页：2 列 GridView，含骨架屏、错误重试、空状态
class AllBooksPage extends ConsumerWidget {
  const AllBooksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(allBooksProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: CampusAppBar(
        title: '图书推荐',
        showBackButton: true,
      ),
      body: booksAsync.when(
        // 加载中：显示骨架屏（6 个占位卡片）
        loading: () => _buildSkeletonGrid(),
        // 加载失败：居中显示错误提示 + 重试按钮
        error: (error, _) => _buildErrorState(ref),
        // 加载成功
        data: (books) {
          if (books.isEmpty) {
            return _buildEmptyState();
          }
          return _buildBookGrid(books);
        },
      ),
    );
  }

  /// 书籍列表：Wrap 自适应高度（2 列）
  Widget _buildBookGrid(List<Book> books) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // 卡片宽度：（总宽 - 中间间距）/ 2
          final cardWidth = (constraints.maxWidth - 16) / 2;
          return Wrap(
            spacing: 16,
            runSpacing: 16,
            children: books
                .map((book) => SizedBox(
                      width: cardWidth,
                      child: _BookGridCard(book: book),
                    ))
                .toList(),
          );
        },
      ),
    );
  }

  /// 骨架屏：Wrap 布局，6 个占位卡片
  Widget _buildSkeletonGrid() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cardWidth = (constraints.maxWidth - 16) / 2;
          return Wrap(
            spacing: 16,
            runSpacing: 16,
            children: List.generate(
              6,
              (_) => SizedBox(
                width: cardWidth,
                child: _SkeletonBookCard(),
              ),
            ),
          );
        },
      ),
    );
  }

  /// 错误状态：居中提示 + 灰色胶囊重试按钮
  Widget _buildErrorState(WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Color(0xFF999999),
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            '加载失败，请稍后重试',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          // 灰色胶囊重试按钮
          GestureDetector(
            onTap: () => ref.invalidate(allBooksProvider),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '重新加载',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 空状态：提示暂无图书
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.book_outlined,
            color: Color(0xFF999999),
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            '暂无图书数据',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 图书卡片：封面图 + 书名 + 作者
// ---------------------------------------------------------------------------
class _BookGridCard extends StatelessWidget {
  const _BookGridCard({required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/library/books/${book.id}'),
      child: Container(
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
        mainAxisSize: MainAxisSize.min,
        children: [
          // 封面图：固定高度 130px
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: SizedBox(
              height: 130,
              width: double.infinity,
              child: _buildCoverImage(),
            ),
          ),
          // 信息区：上下 12px、左右 10px padding
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 书名（加粗，1 行截断）
                Text(
                  book.title,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // 作者（浅灰小字）
                Text(
                  book.author,
                  style: AppTextStyles.overline.copyWith(
                    color: AppColors.textDisabled,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                // 分类标签：浅灰胶囊，与公告标签风格一致
                if (book.category != null && book.category!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F0F0),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      book.category!,
                      style: AppTextStyles.overline.copyWith(
                        fontSize: 9,
                        color: const Color(0xFF666666),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                if (book.category != null && book.category!.isNotEmpty)
                  const SizedBox(height: 4),
                // 馆藏位置：图标 + 灰色小字
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 10,
                      color: Color(0xFF999999),
                    ),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        book.location,
                        style: AppTextStyles.overline.copyWith(
                          fontSize: 9,
                          color: AppColors.textDisabled,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                // 简介：灰色小字，最多 1 行
                if (book.summary != null && book.summary!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    book.summary!,
                    style: AppTextStyles.overline.copyWith(
                      fontSize: 9,
                      color: AppColors.textDisabled,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    ),      // Container closes (child of GestureDetector)
    );      // GestureDetector closes
  }

  /// 封面图片：有封面时显示网络图片，无封面时显示灰色占位
  Widget _buildCoverImage() {
    if (book.coverUrl == null || book.coverUrl!.isEmpty) {
      // 无封面：灰色背景 + 居中书本图标
      return Container(
        color: const Color(0xFFF0F0F0),
        child: const Center(
          child: Icon(
            Icons.book_outlined,
            color: Color(0xFF999999),
            size: 40,
          ),
        ),
      );
    }
    // 有封面：加载网络图片，加载失败时降级显示占位
    return Image.network(
      book.coverUrl!,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        color: const Color(0xFFF0F0F0),
        child: const Center(
          child: Icon(
            Icons.broken_image_outlined,
            color: Color(0xFF999999),
            size: 40,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 骨架屏卡片：shimmer 动画占位
// ---------------------------------------------------------------------------
class _SkeletonBookCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFEEEEEE),
      highlightColor: const Color(0xFFFAFAFA),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 封面占位：固定 130px
            Container(
              height: 130,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 书名占位
                  Container(height: 12, width: double.infinity, color: Colors.white),
                  const SizedBox(height: 4),
                  // 作者占位
                  Container(height: 10, width: 60, color: Colors.white),
                  const SizedBox(height: 6),
                  // 分类标签占位
                  Container(height: 14, width: 40, color: Colors.white),
                  const SizedBox(height: 4),
                  // 馆藏位置占位
                  Container(height: 10, width: 70, color: Colors.white),
                  const SizedBox(height: 3),
                  // 简介占位
                  Container(height: 10, width: double.infinity, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
