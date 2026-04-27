import 'package:flutter/material.dart';
import '../../components/campus_snackbar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../components/components.dart';
import '../../theme/theme.dart';
import '../../../features/library/models/borrow_request.dart';
import '../../../features/library/providers/borrow_provider.dart';

// ---------------------------------------------------------------------------
// 我的借阅页（Tab 筛选 + 四态卡片 + 操作按钮 + 二次确认弹窗）
// ---------------------------------------------------------------------------
class MyLoansPage extends ConsumerStatefulWidget {
  const MyLoansPage({super.key});

  @override
  ConsumerState<MyLoansPage> createState() => _MyLoansPageState();
}

class _MyLoansPageState extends ConsumerState<MyLoansPage> {
  /// 当前选中的 tab index：0=全部 1=待取书 2=借阅中 3=已归还
  int _selectedTab = 0;

  static const _tabs = ['全部', '待取书', '借阅中', '已归还'];

  /// 按 tab 过滤借阅列表
  List<BorrowRequest> _filtered(List<BorrowRequest> all) {
    switch (_selectedTab) {
      case 1:
        return all.where((r) => r.status == BorrowStatus.pending).toList();
      case 2:
        return all.where((r) => r.status == BorrowStatus.borrowed).toList();
      case 3:
        return all.where((r) => r.status == BorrowStatus.returned).toList();
      default:
        return all;
    }
  }

  @override
  Widget build(BuildContext context) {
    final borrowsAsync = ref.watch(myBorrowsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: const CampusAppBar(title: '我的借阅', showBackButton: true),
      body: Column(
        children: [
          // 顶部胶囊 Tab 横向滚动
          _TabBar(
            tabs: _tabs,
            selectedIndex: _selectedTab,
            onTabChanged: (i) => setState(() => _selectedTab = i),
          ),
          Expanded(
            child: borrowsAsync.when(
              loading: () => const CampusLoading(),
              error: (error, _) => _ErrorView(
                message: error.toString().replaceFirst('Exception: ', ''),
                onRetry: () => ref.invalidate(myBorrowsProvider),
              ),
              data: (borrows) {
                final list = _filtered(borrows);
                if (list.isEmpty) {
                  return const _EmptyView();
                }
                return RefreshIndicator(
                  color: const Color(0xFF333333),
                  onRefresh: () async {
                    ref.invalidate(myBorrowsProvider);
                    ref.invalidate(myBorrowStatsProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: list.length,
                    itemBuilder: (context, index) => _LoanCard(
                      request: list[index],
                      onActionSuccess: () {
                        ref.invalidate(myBorrowsProvider);
                        ref.invalidate(myBorrowStatsProvider);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 顶部胶囊 Tab 栏
// ---------------------------------------------------------------------------
class _TabBar extends StatelessWidget {
  const _TabBar({
    required this.tabs,
    required this.selectedIndex,
    required this.onTabChanged,
  });

  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F5F5),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(tabs.length, (i) {
            final selected = i == selectedIndex;
            return GestureDetector(
              onTap: () => onTabChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFF1A1A1A)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected
                        ? const Color(0xFF1A1A1A)
                        : const Color(0xFFDDDDDD),
                    width: 1,
                  ),
                ),
                child: Text(
                  tabs[i],
                  style: AppTextStyles.bodySmall.copyWith(
                    color: selected ? AppColors.white : AppColors.textSecondary,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 单条借阅记录卡片（左封面 + 右内容）
// ---------------------------------------------------------------------------
class _LoanCard extends ConsumerWidget {
  const _LoanCard({required this.request, required this.onActionSuccess});

  final BorrowRequest request;
  final VoidCallback onActionSuccess;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actionState = ref.watch(borrowActionNotifierProvider);
    final isLoading = actionState is AsyncLoading;

    return Opacity(
      opacity: request.status == BorrowStatus.cancelled ? 0.5 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 左：书封面 60×80px
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                width: 60,
                height: 80,
                child: _buildCover(request.bookCoverUrl),
              ),
            ),
            const SizedBox(width: 14),
            // 右：书名 + 状态 + 操作
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 书名
                  Text(
                    request.bookTitle.isNotEmpty ? request.bookTitle : '未知书目',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // 状态标签
                  _StatusBadge(request: request),
                  const SizedBox(height: 6),
                  // 状态相关信息行
                  _buildInfoLines(context),
                  // 操作按钮区
                  if (_hasActions) ...[
                    const SizedBox(height: 12),
                    _buildActions(context, ref, isLoading),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCover(String? url) {
    if (url == null || url.isEmpty) {
      return Container(
        color: const Color(0xFFF0F0F0),
        child: const Center(
          child: Icon(Icons.book_outlined, color: Color(0xFF999999), size: 24),
        ),
      );
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: const Color(0xFFF0F0F0),
        child: const Center(
          child: Icon(
            Icons.broken_image_outlined,
            color: Color(0xFF999999),
            size: 24,
          ),
        ),
      ),
    );
  }

  bool get _hasActions =>
      request.status == BorrowStatus.pending ||
      request.status == BorrowStatus.borrowed;

  /// 状态相关信息行
  Widget _buildInfoLines(BuildContext context) {
    switch (request.status) {
      case BorrowStatus.pending:
        // 取书码大字 + 馆藏位置
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '取书码：',
                  style: AppTextStyles.overline.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  request.reservationCode,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 3,
                    fontFamily: 'monospace',
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 12,
                  color: Color(0xFF999999),
                ),
                const SizedBox(width: 3),
                Expanded(
                  child: Text(
                    request.bookLocation,
                    style: AppTextStyles.overline.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        );
      case BorrowStatus.borrowed:
        if (request.dueDate == null) return const SizedBox.shrink();
        final days = request.daysUntilDue ?? 0;
        if (request.isDueSoon) {
          // 即将到期：红色警示
          return Text(
            days >= 0 ? '还有 $days 天到期，请尽快归还' : '已逾期 ${(-days)} 天',
            style: AppTextStyles.overline.copyWith(
              color: const Color(0xFFC62828),
              fontWeight: FontWeight.w500,
            ),
          );
        }
        return Text(
          '请于 ${_formatMonthDay(request.dueDate!)} 前归还',
          style: AppTextStyles.overline.copyWith(
            color: AppColors.textSecondary,
          ),
        );
      case BorrowStatus.returned:
        if (request.returnedAt == null) return const SizedBox.shrink();
        return Text(
          '已于 ${_formatMonthDay(request.returnedAt!)} 归还',
          style: AppTextStyles.overline.copyWith(
            color: AppColors.textSecondary,
          ),
        );
      case BorrowStatus.cancelled:
        return const SizedBox.shrink();
    }
  }

  /// 操作按钮区
  Widget _buildActions(BuildContext context, WidgetRef ref, bool isLoading) {
    if (request.status == BorrowStatus.pending) {
      return Row(
        children: [
          Expanded(
            child: _ActionButton(
              label: '确认已取书',
              isPrimary: true,
              isLoading: isLoading,
              onTap: () => _confirmPickup(context, ref),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _ActionButton(
              label: '取消预约',
              isPrimary: false,
              isLoading: isLoading,
              onTap: () => _confirmCancel(context, ref),
            ),
          ),
        ],
      );
    }
    if (request.status == BorrowStatus.borrowed) {
      return _ActionButton(
        label: '确认已归还',
        isPrimary: true,
        isLoading: isLoading,
        onTap: () => _confirmReturn(context, ref),
      );
    }
    return const SizedBox.shrink();
  }

  // --- 二次确认弹窗 ---

  Future<void> _confirmPickup(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => _ConfirmDialog(
        title: '确认取书',
        content: '确认已在图书馆取到此书？\n取书后开始计算借阅期限（30天）。',
        confirmText: '确认',
        cancelText: '取消',
      ),
    );
    if (confirmed != true) return;
    final notifier = ref.read(borrowActionNotifierProvider.notifier);
    final ok = await notifier.confirmPickup(request.id);
    if (!context.mounted) return;
    if (ok) {
      onActionSuccess();
    } else {
      final err = ref.read(borrowActionNotifierProvider);
      final msg = err is AsyncError
          ? err.error.toString().replaceFirst('Exception: ', '')
          : '操作失败，请重试';
      CampusSnackBar.show(context, message: msg, isError: false);
    }
  }

  Future<void> _confirmCancel(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const _ConfirmDialog(
        title: '取消预约',
        content: '确认取消预约？取消后取书码将失效。',
        confirmText: '确认取消',
        cancelText: '返回',
        isDestructive: true,
      ),
    );
    if (confirmed != true) return;
    final notifier = ref.read(borrowActionNotifierProvider.notifier);
    final ok = await notifier.cancelReservation(request.id);
    if (!context.mounted) return;
    if (ok) {
      onActionSuccess();
    } else {
      final err = ref.read(borrowActionNotifierProvider);
      final msg = err is AsyncError
          ? err.error.toString().replaceFirst('Exception: ', '')
          : '操作失败，请重试';
      CampusSnackBar.show(context, message: msg, isError: false);
    }
  }

  Future<void> _confirmReturn(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const _ConfirmDialog(
        title: '确认归还',
        content: '确认已将图书归还至图书馆？',
        confirmText: '确认归还',
        cancelText: '取消',
      ),
    );
    if (confirmed != true) return;
    final notifier = ref.read(borrowActionNotifierProvider.notifier);
    final ok = await notifier.confirmReturn(request.id);
    if (!context.mounted) return;
    if (ok) {
      onActionSuccess();
    } else {
      final err = ref.read(borrowActionNotifierProvider);
      final msg = err is AsyncError
          ? err.error.toString().replaceFirst('Exception: ', '')
          : '操作失败，请重试';
      CampusSnackBar.show(context, message: msg, isError: false);
    }
  }

  String _formatMonthDay(DateTime date) {
    return '${date.month}月${date.day}日';
  }
}

// ---------------------------------------------------------------------------
// 状态标签徽章
// ---------------------------------------------------------------------------
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.request});

  final BorrowRequest request;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    final String label = request.statusLabel;

    // 即将到期：红色
    if (request.status == BorrowStatus.borrowed && request.isDueSoon) {
      bg = const Color(0xFFFFEBEE);
      fg = const Color(0xFFC62828);
    } else {
      switch (request.status) {
        case BorrowStatus.pending:
          bg = const Color(0xFFFFF3E0);
          fg = const Color(0xFFE65100);
        case BorrowStatus.borrowed:
          bg = const Color(0xFFE3F2FD);
          fg = const Color(0xFF1565C0);
        case BorrowStatus.returned:
        case BorrowStatus.cancelled:
          bg = const Color(0xFFF5F5F5);
          fg = const Color(0xFF9E9E9E);
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: AppTextStyles.overline.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 操作按钮（主色 / 次色）
// ---------------------------------------------------------------------------
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.isPrimary,
    required this.isLoading,
    required this.onTap,
  });

  final String label;
  final bool isPrimary;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bgColor = isPrimary
        ? const Color(0xFF1A1A1A)
        : const Color(0xFFF0F0F0);
    final textColor = isPrimary ? AppColors.white : AppColors.textSecondary;

    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: isLoading ? const Color(0xFFDDDDDD) : bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF999999),
                  ),
                )
              : Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 二次确认弹窗
// ---------------------------------------------------------------------------
class _ConfirmDialog extends StatelessWidget {
  const _ConfirmDialog({
    required this.title,
    required this.content,
    required this.confirmText,
    required this.cancelText,
    this.isDestructive = false,
  });

  final String title;
  final String content;
  final String confirmText;
  final String cancelText;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        title,
        style: AppTextStyles.titleMedium.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: Text(
        content,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textSecondary,
          height: 1.6,
        ),
      ),
      actions: [
        // 取消按钮
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            cancelText,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        // 确认按钮
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            confirmText,
            style: AppTextStyles.bodySmall.copyWith(
              color: isDestructive
                  ? const Color(0xFFD32F2F)
                  : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 空状态
// ---------------------------------------------------------------------------
class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.library_books_outlined,
            size: 56,
            color: Color(0xFFCCCCCC),
          ),
          const SizedBox(height: 16),
          Text(
            '暂无借阅记录',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textDisabled,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 错误视图
// ---------------------------------------------------------------------------
class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Color(0xFF999999)),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: onRetry,
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
}
