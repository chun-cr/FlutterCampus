import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/book.dart';
import '../../../presentation/components/components.dart';
import '../../../presentation/theme/theme.dart';
import '../models/borrow_request.dart';
import '../providers/borrow_provider.dart';

/// 图书详情页：展示封面、基本信息、简介，并支持发起预约（到馆自取）
class BookDetailPage extends ConsumerWidget {
  const BookDetailPage({super.key, required this.bookId});

  final String bookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookAsync = ref.watch(bookDetailProvider(bookId));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: CampusAppBar(
        title: '图书详情',
        showBackButton: true,
      ),
      body: bookAsync.when(
        loading: () => const _LoadingBody(),
        error: (error, _) => _ErrorBody(
          onRetry: () => ref.invalidate(bookDetailProvider(bookId)),
        ),
        data: (book) => _BookDetailBody(book: book, bookId: bookId),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 加载中骨架
// ---------------------------------------------------------------------------
class _LoadingBody extends StatelessWidget {
  const _LoadingBody();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: Color(0xFF333333),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 加载失败
// ---------------------------------------------------------------------------
class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Color(0xFF999999), size: 48),
          const SizedBox(height: 16),
          Text(
            '加载失败，请稍后重试',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
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
}

// ---------------------------------------------------------------------------
// 详情主体：滚动内容区 + 底部固定按钮
// ---------------------------------------------------------------------------
class _BookDetailBody extends ConsumerStatefulWidget {
  const _BookDetailBody({required this.book, required this.bookId});

  final Book book;
  final String bookId;

  @override
  ConsumerState<_BookDetailBody> createState() => _BookDetailBodyState();
}

class _BookDetailBodyState extends ConsumerState<_BookDetailBody> {
  @override
  Widget build(BuildContext context) {
    final reservationState = ref.watch(reservationNotifierProvider);
    final activeAsync = ref.watch(myActiveReservationProvider(widget.bookId));
    final isLoading = reservationState is AsyncLoading ||
        activeAsync is AsyncLoading;

    return Column(
      children: [
        // 可滚动内容区
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _CoverCard(book: widget.book),
                const SizedBox(height: 16),
                _InfoCard(book: widget.book),
                const SizedBox(height: 16),
                if (widget.book.summary != null &&
                    widget.book.summary!.isNotEmpty) ...[
                  _SummaryCard(summary: widget.book.summary!),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),
        ),
        // 底部固定借阅按钮
        activeAsync.when(
          loading: () => _BorrowButton(
            buttonState: _ButtonState.loading,
            onTap: null,
          ),
          error: (_, __) => _BorrowButton(
            buttonState: _ButtonState.canBorrow,
            onTap: widget.book.isAvailable ? _handleBorrow : null,
          ),
          data: (active) {
            if (isLoading) {
              return _BorrowButton(
                buttonState: _ButtonState.loading,
                onTap: null,
              );
            }
            if (active?.status == BorrowStatus.pending) {
              return _BorrowButton(
                buttonState: _ButtonState.alreadyReserved,
                onTap: null,
              );
            }
            if (active?.status == BorrowStatus.borrowed) {
              return _BorrowButton(
                buttonState: _ButtonState.currentlyBorrowed,
                onTap: null,
              );
            }
            if (!widget.book.isAvailable) {
              return _BorrowButton(
                buttonState: _ButtonState.unavailable,
                onTap: null,
              );
            }
            return _BorrowButton(
              buttonState: _ButtonState.canBorrow,
              onTap: _handleBorrow,
            );
          },
        ),
      ],
    );
  }

  /// 发起预约，成功后弹出取书码底部弹窗
  Future<void> _handleBorrow() async {
    final notifier = ref.read(reservationNotifierProvider.notifier);
    final code = await notifier.createReservation(widget.bookId);

    if (!mounted) return;

    if (code != null) {
      // 成功：弹出取书码弹窗
      await _showReservationSheet(code);
      // 关闭弹窗后刷新状态
      ref.invalidate(myActiveReservationProvider(widget.bookId));
      ref.invalidate(bookDetailProvider(widget.bookId));
      ref.invalidate(myBorrowsProvider);
      ref.invalidate(myBorrowStatsProvider);
    } else {
      // 失败：提取错误信息显示 SnackBar
      final error = ref.read(reservationNotifierProvider);
      final message = error is AsyncError
          ? error.error.toString().replaceFirst('Exception: ', '')
          : '预约失败，请重试';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF666666),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// 弹出预约成功底部弹窗，展示取书码
  Future<void> _showReservationSheet(String code) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ReservationSuccessSheet(
        code: code,
        location: widget.book.location,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 预约成功底部弹窗
// ---------------------------------------------------------------------------
class _ReservationSuccessSheet extends StatelessWidget {
  const _ReservationSuccessSheet({
    required this.code,
    required this.location,
  });

  final String code;
  final String location;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        28,
        24,
        28 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 顶部拖拽条
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          // 成功图标
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F7F0),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Color(0xFF4CAF50),
              size: 28,
            ),
          ),
          const SizedBox(height: 14),
          // 标题
          Text(
            '预约成功',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '请携带此码前往图书馆前台取书',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          // 取书码展示区
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              code,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                letterSpacing: 6,
                fontFamily: 'monospace',
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 说明文字
          Text(
            '取书码有效期 3 天',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 14,
                color: Color(0xFF999999),
              ),
              const SizedBox(width: 4),
              Text(
                '馆藏位置：$location',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          // 知道了按钮
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: Text(
                  '知道了',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 封面卡片：封面图 + 书名 + 作者 + 分类标签
// ---------------------------------------------------------------------------
class _CoverCard extends StatelessWidget {
  const _CoverCard({required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
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
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 160,
              height: 220,
              child: _buildCoverImage(),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            book.title,
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            book.author,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (book.category != null && book.category!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                book.category!,
                style: AppTextStyles.overline.copyWith(
                  fontSize: 10,
                  color: const Color(0xFF666666),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCoverImage() {
    if (book.coverUrl == null || book.coverUrl!.isEmpty) {
      return Container(
        color: const Color(0xFFF0F0F0),
        child: const Center(
          child: Icon(Icons.book_outlined, color: Color(0xFF999999), size: 48),
        ),
      );
    }
    return Image.network(
      book.coverUrl!,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: const Color(0xFFF0F0F0),
        child: const Center(
          child: Icon(
            Icons.broken_image_outlined,
            color: Color(0xFF999999),
            size: 48,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 信息卡片：ISBN / 馆藏位置 / 借阅状态
// ---------------------------------------------------------------------------
class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
        children: [
          _InfoRow(label: 'ISBN', value: book.isbn),
          const _Divider(),
          _InfoRow(label: '馆藏位置', value: book.location),
          const _Divider(),
          _InfoRow(
            label: '借阅状态',
            valueWidget: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: book.isAvailable
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFBBBBBB),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  book.isAvailable
                      ? '可借阅（${book.availableCopies}/${book.totalCopies}）'
                      : '已借出',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: book.isAvailable
                        ? const Color(0xFF4CAF50)
                        : AppColors.textDisabled,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 信息行：左灰标签 + 右黑值
class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, this.value, this.valueWidget});

  final String label;
  final String? value;
  final Widget? valueWidget;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: valueWidget ??
                Text(
                  value ?? '-',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
          ),
        ],
      ),
    );
  }
}

/// 信息行间的分割线
class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: const Color(0xFFF5F5F5));
  }
}

// ---------------------------------------------------------------------------
// 简介卡片
// ---------------------------------------------------------------------------
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary});

  final String summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Text(
            '内容简介',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            summary,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 底部固定借阅按钮
// ---------------------------------------------------------------------------

/// 按钮状态枚举
enum _ButtonState {
  canBorrow,          // 可借阅，深色按钮
  loading,            // 操作中
  alreadyReserved,    // 已预约待取书（pending）
  currentlyBorrowed,  // 借阅中（borrowed）
  unavailable,        // 暂不可借（他人已借完）
}

class _BorrowButton extends StatelessWidget {
  const _BorrowButton({
    required this.buttonState,
    required this.onTap,
  });

  final _ButtonState buttonState;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color bgColor;
    final String label;

    switch (buttonState) {
      case _ButtonState.canBorrow:
        bgColor = const Color(0xFF1A1A1A);
        label = '申请借阅';
      case _ButtonState.loading:
        bgColor = const Color(0xFFDDDDDD);
        label = '';
      case _ButtonState.alreadyReserved:
        bgColor = const Color(0xFFFFF3E0);
        label = '已预约，待取书';
      case _ButtonState.currentlyBorrowed:
        bgColor = const Color(0xFFE3F2FD);
        label = '借阅中';
      case _ButtonState.unavailable:
        bgColor = const Color(0xFFDDDDDD);
        label = '暂不可借';
    }

    final Color textColor;
    switch (buttonState) {
      case _ButtonState.canBorrow:
        textColor = AppColors.white;
      case _ButtonState.alreadyReserved:
        textColor = const Color(0xFFE65100);
      case _ButtonState.currentlyBorrowed:
        textColor = const Color(0xFF1565C0);
      default:
        textColor = AppColors.textDisabled;
    }

    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFF5F5F5),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: buttonState == _ButtonState.loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF999999),
                    ),
                  )
                : Text(
                    label,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
