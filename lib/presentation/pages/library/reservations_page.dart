import 'package:flutter/material.dart';
import '../../components/campus_snackbar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../components/components.dart';
import '../../theme/theme.dart';
import '../../../features/library/models/book_reservation.dart';
import '../../../features/library/providers/reservation_provider.dart';

// ---------------------------------------------------------------------------
// 图书预定页（Tab 筛选 + 状态卡片 + 操作按钮 + 二次确认弹窗）
// ---------------------------------------------------------------------------
class ReservationsPage extends ConsumerStatefulWidget {
  const ReservationsPage({super.key});

  @override
  ConsumerState<ReservationsPage> createState() => _ReservationsPageState();
}

class _ReservationsPageState extends ConsumerState<ReservationsPage> {
  /// 当前选中的 tab index：0=全部 1=预约中 2=可借阅 3=已失效
  int _selectedTab = 0;

  static const _tabs = ['全部', '预约中', '可借阅', '已失效'];

  /// 按 tab 过滤预约列表
  List<BookReservation> _filtered(List<BookReservation> all) {
    switch (_selectedTab) {
      case 1:
        return all.where((r) => r.status == ReservationStatus.queuing).toList();
      case 2:
        return all.where((r) => r.status == ReservationStatus.available).toList();
      case 3:
        return all
            .where(
              (r) =>
                  r.status == ReservationStatus.expired ||
                  r.status == ReservationStatus.cancelled,
            )
            .toList();
      default:
        return all;
    }
  }

  @override
  Widget build(BuildContext context) {
    final reservationsAsync = ref.watch(myReservationsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: const CampusAppBar(title: '图书预定', showBackButton: true),
      body: Column(
        children: [
          _TabBar(
            tabs: _tabs,
            selectedIndex: _selectedTab,
            onTabChanged: (i) => setState(() => _selectedTab = i),
          ),
          Expanded(
            child: reservationsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF333333),
                ),
              ),
              error: (error, _) => _ErrorView(
                message: error.toString().replaceFirst('Exception: ', ''),
                onRetry: () => ref.invalidate(myReservationsProvider),
              ),
              data: (reservations) {
                final list = _filtered(reservations);
                if (list.isEmpty) {
                  return const _EmptyView();
                }
                return RefreshIndicator(
                  color: const Color(0xFF333333),
                  onRefresh: () async {
                    ref.invalidate(myReservationsProvider);
                    ref.invalidate(myReservationStatsProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: list.length,
                    itemBuilder: (context, index) => _ReservationCard(
                      reservation: list[index],
                      onActionSuccess: () {
                        ref.invalidate(myReservationsProvider);
                        ref.invalidate(myReservationStatsProvider);
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
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
                    color: selected
                        ? AppColors.white
                        : AppColors.textSecondary,
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.w400,
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
// 单条预约记录卡片（左封面 + 右内容）
// ---------------------------------------------------------------------------
class _ReservationCard extends ConsumerWidget {
  const _ReservationCard({
    required this.reservation,
    required this.onActionSuccess,
  });

  final BookReservation reservation;
  final VoidCallback onActionSuccess;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actionState = ref.watch(reservationActionNotifierProvider);
    final isLoading = actionState is AsyncLoading;

    return Opacity(
      opacity: reservation.status == ReservationStatus.cancelled ? 0.5 : 1.0,
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
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                width: 60,
                height: 80,
                child: _buildCover(reservation.bookCoverUrl),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reservation.bookTitle.isNotEmpty
                        ? reservation.bookTitle
                        : '未知书目',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  _StatusBadge(reservation: reservation),
                  const SizedBox(height: 6),
                  _buildInfoLines(),
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
      reservation.status == ReservationStatus.queuing ||
      reservation.status == ReservationStatus.available;

  Widget _buildInfoLines() {
    switch (reservation.status) {
      case ReservationStatus.queuing:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '排队中：第 ${reservation.queuePosition} 位 / 共 ${reservation.queueTotal} 人',
              style: AppTextStyles.overline.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            if (reservation.estimatedReturnDate != null) ...[
              const SizedBox(height: 4),
              Text(
                '预计归还：${_formatMonthDay(reservation.estimatedReturnDate!)}',
                style: AppTextStyles.overline.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        );
      case ReservationStatus.available:
        final deadline = reservation.availableDeadline;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🔔 书已到位，请尽快取书',
              style: AppTextStyles.overline.copyWith(
                color: const Color(0xFF2E7D32),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              deadline != null
                  ? '有效期至：${_formatMonthDay(deadline)}（剩余 ${reservation.deadlineRemainingDays} 天）'
                  : '有效期至：--',
              style: AppTextStyles.overline.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        );
      case ReservationStatus.expired:
        return Text(
          '预约已失效',
          style: AppTextStyles.overline.copyWith(
            color: AppColors.textSecondary,
          ),
        );
      case ReservationStatus.cancelled:
        return Text(
          '预约已取消',
          style: AppTextStyles.overline.copyWith(
            color: AppColors.textSecondary,
          ),
        );
    }
  }

  Widget _buildActions(BuildContext context, WidgetRef ref, bool isLoading) {
    if (reservation.status == ReservationStatus.queuing) {
      return _ActionButton(
        label: '取消预约',
        isPrimary: false,
        isLoading: isLoading,
        onTap: () => _confirmCancel(context, ref),
      );
    }
    if (reservation.status == ReservationStatus.available) {
      return _ActionButton(
        label: '查看书架位置',
        isPrimary: true,
        isLoading: isLoading,
        onTap: () {
          CampusSnackBar.show(context, message: '请前往 ${reservation.bookLocation} 取书，有效期剩余 ${reservation.deadlineRemainingDays} 天', isError: false);
        },
      );
    }
    return const SizedBox.shrink();
  }

  Future<void> _confirmCancel(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const _ConfirmDialog(
        title: '取消预约',
        content: '确定要取消这本书的预约吗？取消后排队位次将释放。',
        confirmText: '确认取消',
        cancelText: '再想想',
        isDestructive: true,
      ),
    );
    if (confirmed != true) return;

    final notifier = ref.read(reservationActionNotifierProvider.notifier);
    final ok = await notifier.cancelReservation(reservation.id);
    if (!context.mounted) return;

    if (ok) {
      onActionSuccess();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('已取消预约'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Color(0xFF666666),
          duration: Duration(seconds: 3),
        ),
      );
    } else {
      final err = ref.read(reservationActionNotifierProvider);
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
  const _StatusBadge({required this.reservation});

  final BookReservation reservation;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    final String label;

    switch (reservation.status) {
      case ReservationStatus.queuing:
        bg = const Color(0xFFFFF3E0);
        fg = const Color(0xFFE65100);
        label = '预约中';
      case ReservationStatus.available:
        bg = const Color(0xFFE8F5E9);
        fg = const Color(0xFF2E7D32);
        label = '可借阅';
      case ReservationStatus.expired:
      case ReservationStatus.cancelled:
        bg = const Color(0xFFF5F5F5);
        fg = const Color(0xFF9E9E9E);
        label = '已失效';
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
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            cancelText,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
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
            Icons.bookmark_border_outlined,
            size: 56,
            color: Color(0xFFCCCCCC),
          ),
          const SizedBox(height: 16),
          Text(
            '暂无图书预约',
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
