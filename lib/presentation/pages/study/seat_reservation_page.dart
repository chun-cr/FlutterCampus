import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../features/library/models/seat.dart';
import '../../../features/library/providers/seat_provider.dart';
import '../../../features/library/repositories/seat_repository.dart';
import '../../components/components.dart';
import '../../theme/theme.dart';

// ---------------------------------------------------------------------------
// 座位预约页（接入真实 Supabase 数据）
// ---------------------------------------------------------------------------
class SeatReservationPage extends ConsumerStatefulWidget {
  const SeatReservationPage({super.key});

  @override
  ConsumerState<SeatReservationPage> createState() =>
      _SeatReservationPageState();
}

class _SeatReservationPageState extends ConsumerState<SeatReservationPage> {
  // --- 筛选状态 ---
  String _selectedFloor = '3楼';
  String _selectedZone = 'A区';
  DateTime _selectedDate = DateTime.now();
  String? _selectedStartTime;
  String? _selectedEndTime;

  // --- 选座状态 ---
  String? _selectedSeatId;
  int? _selectedSeatNumber;

  static const _floors = ['1楼', '2楼', '3楼', '4楼'];
  static const _zones = ['A区', 'B区', 'C区', 'D区'];

  List<Map<String, String>> get _timeSlots => SeatRepository.getTimeSlots();

  SeatQuery get _currentQuery => SeatQuery(
        floor: _selectedFloor,
        zone: _selectedZone,
        date: _selectedDate,
      );

  @override
  Widget build(BuildContext context) {
    final seatsAsync = ref.watch(seatsProvider(_currentQuery));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: CampusAppBar(
        title: '座位预约',
        showBackButton: true,
        actions: [
          TextButton(
            onPressed: () => context.push('/library/seat-reservations'),
            child: Text(
              '我的预约',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilters(),
          _buildTimePicker(),
          _buildLegend(),
          Expanded(
            child: seatsAsync.when(
              loading: () => _buildLoadingGrid(),
              error: (error, _) => _ErrorView(
                message: error.toString().replaceFirst('Exception: ', ''),
                onRetry: () => ref.invalidate(seatsProvider(_currentQuery)),
              ),
              data: (seats) => _buildSeatGrid(seats),
            ),
          ),
          _buildBottomPanel(),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 楼层 / 区域 / 日期筛选区
  // ---------------------------------------------------------------------------
  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Column(
        children: [
          _buildFilterRow(
            label: '楼层',
            items: _floors,
            selected: _selectedFloor,
            onSelect: (v) => setState(() {
              _selectedFloor = v;
              _selectedSeatId = null;
            }),
          ),
          const SizedBox(height: 8),
          _buildFilterRow(
            label: '区域',
            items: _zones,
            selected: _selectedZone,
            onSelect: (v) => setState(() {
              _selectedZone = v;
              _selectedSeatId = null;
            }),
          ),
          const SizedBox(height: 8),
          _buildDateRow(),
        ],
      ),
    );
  }

  Widget _buildFilterRow({
    required String label,
    required List<String> items,
    required String selected,
    required ValueChanged<String> onSelect,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 32,
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textDisabled,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: items
                  .map((item) => _buildChip(
                        label: item,
                        isSelected: item == selected,
                        onTap: () => onSelect(item),
                      ))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateRow() {
    final today = DateTime.now();
    final dates = List.generate(7, (i) => today.add(Duration(days: i)));

    return Row(
      children: [
        SizedBox(
          width: 32,
          child: Text(
            '日期',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textDisabled,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: dates.map((date) {
                final isSelected = date.year == _selectedDate.year &&
                    date.month == _selectedDate.month &&
                    date.day == _selectedDate.day;
                final isToday = date.year == today.year &&
                    date.month == today.month &&
                    date.day == today.day;
                final label = isToday
                    ? '今天'
                    : '${date.month}/${date.day}';
                return _buildChip(
                  label: label,
                  isSelected: isSelected,
                  onTap: () => setState(() {
                    _selectedDate = date;
                    _selectedSeatId = null;
                  }),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 时间段选择
  // ---------------------------------------------------------------------------
  Widget _buildTimePicker() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              '时段',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textDisabled,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _timeSlots.map((slot) {
                  final isSelected = slot['start'] == _selectedStartTime;
                  return _buildChip(
                    label: slot['label']!,
                    isSelected: isSelected,
                    onTap: () => setState(() {
                      if (isSelected) {
                        _selectedStartTime = null;
                        _selectedEndTime = null;
                      } else {
                        _selectedStartTime = slot['start'];
                        _selectedEndTime = slot['end'];
                      }
                    }),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 图例
  // ---------------------------------------------------------------------------
  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildLegendItem(
            label: '空闲',
            color: const Color(0xFFE8F5E9),
            borderColor: const Color(0xFFA5D6A7),
          ),
          const SizedBox(width: 12),
          _buildLegendItem(
            label: '占用',
            color: const Color(0xFFFAFAFA),
            borderColor: const Color(0xFFE0E0E0),
          ),
          const SizedBox(width: 12),
          _buildLegendItem(
            label: '我的',
            color: const Color(0xFFE3F2FD),
            borderColor: const Color(0xFF90CAF9),
          ),
          const SizedBox(width: 12),
          _buildLegendItem(
            label: '已选',
            color: const Color(0xFF1A1A1A),
            borderColor: const Color(0xFF1A1A1A),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required String label,
    required Color color,
    required Color borderColor,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: borderColor, width: 1),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF888888)),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 座位网格
  // ---------------------------------------------------------------------------
  Widget _buildSeatGrid(List<Seat> seats) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: seats.length,
      itemBuilder: (context, index) {
        final seat = seats[index];
        final isSelected = _selectedSeatId == seat.id;
        return _buildSeatCell(seat: seat, isSelected: isSelected);
      },
    );
  }

  Widget _buildSeatCell({required Seat seat, required bool isSelected}) {
    final Color bgColor;
    final Color borderColor;
    final Color textColor;
    final bool isInteractive;

    if (isSelected) {
      bgColor = const Color(0xFF1A1A1A);
      borderColor = const Color(0xFF1A1A1A);
      textColor = AppColors.white;
      isInteractive = true;
    } else {
      switch (seat.status) {
        case SeatStatus.available:
          bgColor = const Color(0xFFF0F7F0);
          borderColor = const Color(0xFFC8E6C9);
          textColor = const Color(0xFF388E3C);
          isInteractive = true;
        case SeatStatus.occupied:
          bgColor = const Color(0xFFF5F5F5);
          borderColor = const Color(0xFFE0E0E0);
          textColor = const Color(0xFFBDBDBD);
          isInteractive = false;
        case SeatStatus.myReservation:
          bgColor = const Color(0xFFE3F2FD);
          borderColor = const Color(0xFF90CAF9);
          textColor = const Color(0xFF1565C0);
          isInteractive = false; // 已预约，不可再次选择
      }
    }

    return GestureDetector(
      onTap: !isInteractive
          ? null
          : () {
              setState(() {
                if (isSelected) {
                  _selectedSeatId = null;
                  _selectedSeatNumber = null;
                } else {
                  _selectedSeatId = seat.id;
                  _selectedSeatNumber = seat.seatNumber;
                }
              });
            },
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: 1),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${seat.seatNumber}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            if (seat.hasPower || seat.hasWindow) ...[
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (seat.hasPower)
                    Icon(
                      Icons.power_outlined,
                      size: 8,
                      color: textColor.withValues(alpha: 0.7),
                    ),
                  if (seat.hasWindow)
                    Icon(
                      Icons.window_outlined,
                      size: 8,
                      color: textColor.withValues(alpha: 0.7),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 加载中：骨架格子
  // ---------------------------------------------------------------------------
  Widget _buildLoadingGrid() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: 24,
      itemBuilder: (context, _) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFFEEEEEE),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 底部确认面板
  // ---------------------------------------------------------------------------
  Widget _buildBottomPanel() {
    final hasSelection = _selectedSeatId != null;
    final hasTime = _selectedStartTime != null;
    final canConfirm = hasSelection && hasTime;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasSelection) ...[
            Row(
              children: [
                const Icon(
                  Icons.chair_outlined,
                  color: Color(0xFF333333),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  '$_selectedFloor $_selectedZone ${_selectedSeatNumber ?? ''}号座'
                  '${hasTime ? '  |  $_selectedStartTime-$_selectedEndTime' : '  |  请选择时段'}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ] else if (!hasTime) ...[
            Text(
              '请先选择时段，再点选座位',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textDisabled,
              ),
            ),
            const SizedBox(height: 8),
          ],
          GestureDetector(
            onTap: canConfirm ? () => _showConfirmSheet() : null,
            child: Container(
              height: 50,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: canConfirm
                    ? const Color(0xFF1A1A1A)
                    : const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                canConfirm
                    ? '确认预约'
                    : (hasSelection ? '请选择时段' : '请选择座位与时段'),
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: canConfirm
                      ? AppColors.white
                      : const Color(0xFFBDBDBD),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 确认预约弹窗
  // ---------------------------------------------------------------------------
  Future<void> _showConfirmSheet() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => _ConfirmDialog(
        title: '确认预约',
        content:
            '预约信息：\n$_selectedFloor $_selectedZone ${_selectedSeatNumber}号座\n时段：$_selectedStartTime-$_selectedEndTime\n\n确认后将生成预约码，请在开始时间 30 分钟内完成签到。',
        confirmText: '确认预约',
        cancelText: '返回',
      ),
    );
    if (confirmed != true) return;

    final notifier = ref.read(seatReservationNotifierProvider.notifier);
    final code = await notifier.createReservation(
      seatId: _selectedSeatId!,
      date: _selectedDate,
      startTime: _selectedStartTime!,
      endTime: _selectedEndTime!,
    );

    if (!mounted) return;

    if (code != null) {
      // 刷新座位列表与首页可用数量
      ref.invalidate(seatsProvider(_currentQuery));
      ref.invalidate(seatAvailableCountProvider);
      ref.invalidate(myReservationsProvider);
      setState(() {
        _selectedSeatId = null;
        _selectedSeatNumber = null;
      });
      _showSuccessSheet(code);
    } else {
      final errState = ref.read(seatReservationNotifierProvider);
      final msg = errState is AsyncError
          ? errState.error.toString().replaceFirst('Exception: ', '')
          : '预约失败，请重试';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF666666),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // 预约成功底部弹窗
  // ---------------------------------------------------------------------------
  void _showSuccessSheet(String code) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _SuccessSheet(
        code: code,
        floor: _selectedFloor,
        zone: _selectedZone,
        seatNumber: _selectedSeatNumber ?? 0,
        startTime: _selectedStartTime ?? '',
        endTime: _selectedEndTime ?? '',
        onViewReservations: () {
          Navigator.of(context).pop();
          context.push('/library/seat-reservations');
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 胶囊选择器
  // ---------------------------------------------------------------------------
  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF1A1A1A)
              : const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: isSelected ? AppColors.white : const Color(0xFF666666),
          ),
        ),
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

// ---------------------------------------------------------------------------
// 确认弹窗
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
// 预约成功底部弹窗
// ---------------------------------------------------------------------------
class _SuccessSheet extends StatelessWidget {
  const _SuccessSheet({
    required this.code,
    required this.floor,
    required this.zone,
    required this.seatNumber,
    required this.startTime,
    required this.endTime,
    required this.onViewReservations,
  });

  final String code;
  final String floor;
  final String zone;
  final int seatNumber;
  final String startTime;
  final String endTime;
  final VoidCallback onViewReservations;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 顶部拖拽条
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // 成功图标
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F7F0),
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Icon(
              Icons.check_outlined,
              color: Color(0xFF388E3C),
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '预约成功',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$floor $zone ${seatNumber}号座  |  $startTime-$endTime',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          // 预约码展示区
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  '预约码',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textDisabled,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  code,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 6,
                    fontFamily: 'monospace',
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '请在开始时间 30 分钟内完成签到',
                  style: AppTextStyles.overline.copyWith(
                    color: AppColors.textDisabled,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // 查看我的预约
          GestureDetector(
            onTap: onViewReservations,
            child: Container(
              height: 50,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '查看我的预约',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              height: 44,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '继续选座',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
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
