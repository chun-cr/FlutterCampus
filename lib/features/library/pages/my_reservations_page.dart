import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/library/models/seat_reservation.dart';
import '../../../features/library/providers/seat_provider.dart';
import '../../../presentation/components/components.dart';
import '../../../presentation/theme/theme.dart';

// ---------------------------------------------------------------------------
// 我的座位预约页（Tab 筛选 + 卡片 + 操作按钮 + 二次确认弹窗）
// ---------------------------------------------------------------------------
class MyReservationsPage extends ConsumerStatefulWidget {
  const MyReservationsPage({super.key});

  @override
  ConsumerState<MyReservationsPage> createState() => _MyReservationsPageState();
}

class _MyReservationsPageState extends ConsumerState<MyReservationsPage> {
  /// 当前选中的 tab index：0=全部 1=待签到 2=使用中 3=已完成
  int _selectedTab = 0;

  static const _tabs = ['全部', '待签到', '使用中', '已完成'];

  /// 按 tab 过滤预约列表
  List<SeatReservation> _filtered(List<SeatReservation> all) {
    switch (_selectedTab) {
      case 1:
        return all.where((r) => r.status == 'reserved').toList();
      case 2:
        return all.where((r) => r.status == 'using').toList();
      case 3:
        return all
            .where((r) => r.status == 'completed' || r.status == 'cancelled' || r.status == 'expired')
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
      appBar: const CampusAppBar(title: '我的预约', showBackButton: true),
      body: Column(
        children: [
          // 顶部胶囊 Tab
          _SeatTabBar(
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
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: list.length,
                    itemBuilder: (context, index) => _ReservationCard(
                      reservation: list[index],
                      onActionSuccess: () {
                        ref.invalidate(myReservationsProvider);
                        ref.invalidate(seatAvailableCountProvider);
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
class _SeatTabBar extends StatelessWidget {
  const _SeatTabBar({
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
                    color: selected ? AppColors.white : AppColors.textSecondary,
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
// 预约记录卡片
// ---------------------------------------------------------------------------
class _ReservationCard extends ConsumerWidget {
  const _ReservationCard({
    required this.reservation,
    required this.onActionSuccess,
  });

  final SeatReservation reservation;
  final VoidCallback onActionSuccess;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actionState = ref.watch(seatActionNotifierProvider);
    final isLoading = actionState is AsyncLoading;

    // 左侧竖条颜色（低饱和度语义色）
    final Color barColor = _getBarColor(reservation.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 左侧竖条
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
            // 内容区
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 标题行：座位信息 + 状态标签
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${reservation.floor} ${reservation.zone} ${reservation.seatNumber}号座',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        _StatusBadge(status: reservation.status),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // 时段
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_outlined,
                          size: 13,
                          color: Color(0xFF999999),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${_formatDate(reservation.date)}  ${reservation.timeRange}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // 设施标签
                    Row(
                      children: [
                        if (reservation.hasPower) ...[
                          _FeatureTag(
                            icon: Icons.power_outlined,
                            label: '有插座',
                          ),
                          const SizedBox(width: 6),
                        ],
                        if (reservation.hasWindow)
                          _FeatureTag(
                            icon: Icons.window_outlined,
                            label: '靠窗',
                          ),
                      ],
                    ),
                    // 预约码（待签到状态显示）
                    if (reservation.status == 'reserved') ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            '预约码：',
                            style: AppTextStyles.overline.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            reservation.reservationCode,
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
                      // 超时提示
                      if (reservation.isExpired) ...[
                        const SizedBox(height: 4),
                        Text(
                          '已超过签到时间，预约将自动取消',
                          style: AppTextStyles.overline.copyWith(
                            color: const Color(0xFFC62828),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                    // 使用中：签到时间
                    if (reservation.status == 'using' &&
                        reservation.checkedInAt != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '已于 ${_formatTime(reservation.checkedInAt!)} 签到',
                        style: AppTextStyles.overline.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    // 操作按钮
                    if (_hasActions(reservation.status)) ...[
                      const SizedBox(height: 12),
                      _buildActions(context, ref, isLoading),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _hasActions(String status) =>
      status == 'reserved' || status == 'using';

  Widget _buildActions(
      BuildContext context, WidgetRef ref, bool isLoading) {
    if (reservation.status == 'reserved') {
      return Row(
        children: [
          Expanded(
            child: _ActionButton(
              label: '签到',
              isPrimary: true,
              isLoading: isLoading,
              onTap: () => _confirmCheckIn(context, ref),
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
    if (reservation.status == 'using') {
      return _ActionButton(
        label: '签退',
        isPrimary: true,
        isLoading: isLoading,
        onTap: () => _confirmCheckOut(context, ref),
      );
    }
    return const SizedBox.shrink();
  }

  // --- 二次确认弹窗 ---

  Future<void> _confirmCheckIn(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const _ConfirmDialog(
        title: '签到',
        content: '确认您已到达座位并开始使用？',
        confirmText: '确认签到',
        cancelText: '取消',
      ),
    );
    if (confirmed != true) return;
    final notifier = ref.read(seatActionNotifierProvider.notifier);
    final ok = await notifier.checkIn(reservation.id);
    if (!context.mounted) return;
    if (ok) {
      onActionSuccess();
    } else {
      _showError(context, ref);
    }
  }

  Future<void> _confirmCheckOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const _ConfirmDialog(
        title: '签退',
        content: '确认您已离开座位并完成使用？',
        confirmText: '确认签退',
        cancelText: '取消',
      ),
    );
    if (confirmed != true) return;
    final notifier = ref.read(seatActionNotifierProvider.notifier);
    final ok = await notifier.checkOut(reservation.id);
    if (!context.mounted) return;
    if (ok) {
      onActionSuccess();
    } else {
      _showError(context, ref);
    }
  }

  Future<void> _confirmCancel(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const _ConfirmDialog(
        title: '取消预约',
        content: '确认取消此座位预约？取消后预约码将失效。',
        confirmText: '确认取消',
        cancelText: '返回',
        isDestructive: true,
      ),
    );
    if (confirmed != true) return;
    final notifier = ref.read(seatActionNotifierProvider.notifier);
    final ok = await notifier.cancelReservation(reservation.id);
    if (!context.mounted) return;
    if (ok) {
      onActionSuccess();
    } else {
      _showError(context, ref);
    }
  }

  void _showError(BuildContext context, WidgetRef ref) {
    final errState = ref.read(seatActionNotifierProvider);
    final msg = errState is AsyncError
        ? errState.error.toString().replaceFirst('Exception: ', '')
        : '操作失败，请重试';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF666666),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // --- 工具方法 ---

  Color _getBarColor(String status) {
    switch (status) {
      case 'reserved':
        return const Color(0xFFFFCC80); // 低饱和度橙
      case 'using':
        return const Color(0xFF90CAF9); // 低饱和度蓝
      case 'completed':
        return const Color(0xFFA5D6A7); // 低饱和度绿
      case 'cancelled':
      case 'expired':
      default:
        return const Color(0xFFE0E0E0); // 灰色
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return '今天';
    }
    return '${date.month}月${date.day}日';
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

// ---------------------------------------------------------------------------
// 设施标签
// ---------------------------------------------------------------------------
class _FeatureTag extends StatelessWidget {
  const _FeatureTag({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: const Color(0xFFAAAAAA)),
        const SizedBox(width: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFFAAAAAA),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 状态标签
// ---------------------------------------------------------------------------
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    final String label;

    switch (status) {
      case 'reserved':
        bg = const Color(0xFFFFF3E0);
        fg = const Color(0xFFE65100);
        label = '待签到';
      case 'using':
        bg = const Color(0xFFE3F2FD);
        fg = const Color(0xFF1565C0);
        label = '使用中';
      case 'completed':
        bg = const Color(0xFFF5F5F5);
        fg = const Color(0xFF9E9E9E);
        label = '已完成';
      case 'cancelled':
        bg = const Color(0xFFF5F5F5);
        fg = const Color(0xFF9E9E9E);
        label = '已取消';
      case 'expired':
        bg = const Color(0xFFFFEBEE);
        fg = const Color(0xFFC62828);
        label = '已过期';
      default:
        bg = const Color(0xFFF5F5F5);
        fg = const Color(0xFF9E9E9E);
        label = status;
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
// 操作按钮
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
    final bgColor =
        isPrimary ? const Color(0xFF1A1A1A) : const Color(0xFFF0F0F0);
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
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.textSecondary),
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
            Icons.chair_outlined,
            size: 56,
            color: Color(0xFFCCCCCC),
          ),
          const SizedBox(height: 16),
          Text(
            '暂无预约记录',
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
