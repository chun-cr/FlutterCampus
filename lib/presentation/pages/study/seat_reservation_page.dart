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
  String _selectedFloor = '三楼';
  String _selectedZone = 'A区';
  DateTime _selectedDate = DateTime.now();
  String? _selectedStartTime;
  String? _selectedEndTime;

  // --- 选座状态 ---
  String? _selectedSeatId;
  int? _selectedSeatNumber;

  // --- 预约成功本地缓存（即时反馈）---
  String? _reservedSeatId; // 本次会话中已预约的座位id
  bool _isLoading = false;  // 防重复提交

  static const _floors = ['一楼', '二楼', '三楼', '四楼'];
  static const _zones = ['A区', 'B区', 'C区', 'D区'];

  // 三个固定时段
  static const List<Map<String, String>> _fixedTimeSlots = [
    {'start': '07:00', 'end': '12:00', 'label': '上午 07:00-12:00'},
    {'start': '13:00', 'end': '18:00', 'label': '下午 13:00-18:00'},
    {'start': '18:30', 'end': '22:00', 'label': '晚上 18:30-22:00'},
  ];

  SeatQuery get _currentQuery => SeatQuery(
        floor: _selectedFloor,
        zone: _selectedZone,
        date: _selectedDate,
      );

  /// 判断时段是否已过期（仅对今天生效）
  bool _isSlotExpired(Map<String, String> slot) {
    final today = DateTime.now();
    final isToday = _selectedDate.year == today.year &&
        _selectedDate.month == today.month &&
        _selectedDate.day == today.day;
    if (!isToday) return false;

    final endParts = slot['end']!.split(':');
    final slotEnd = DateTime(
      today.year,
      today.month,
      today.day,
      int.parse(endParts[0]),
      int.parse(endParts[1]),
    );
    return DateTime.now().isAfter(slotEnd);
  }

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
            style: TextButton.styleFrom(
              backgroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              '我的预约',
              style: AppTextStyles.bodySmall.copyWith(
                color: const Color(0xFF333333),
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
              loading: _buildLoadingGrid,
              error: (error, _) => _ErrorView(
                message: error.toString().replaceFirst('Exception: ', ''),
                onRetry: () => ref.invalidate(seatsProvider(_currentQuery)),
              ),
              data: _buildSeatGrid,
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
                children: _fixedTimeSlots.map((slot) {
                  final isSelected = slot['start'] == _selectedStartTime;
                  final expired = _isSlotExpired(slot);
                  if (expired) {
                    // 过期样式：灰色，不可点击
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${slot['label']!} (已过期)',
                        style: AppTextStyles.caption.copyWith(
                          color: const Color(0xFFBDBDBD),
                        ),
                      ),
                    );
                  }
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
        return _buildSeatCell(seat: seat);
      },
    );
  }

  Widget _buildSeatCell({required Seat seat}) {
    // 优先级：myReservation > reservedSeatId > selected > occupied > available
    final bool isMyReservation =
        seat.status == SeatStatus.myReservation || seat.id == _reservedSeatId;
    final bool isSelected = !isMyReservation && seat.id == _selectedSeatId;
    final bool isOccupied =
        !isMyReservation && !isSelected && seat.status == SeatStatus.occupied;

    final Color bgColor;
    final Color borderColor;
    final Color textColor;
    final bool isInteractive;
    final String cellLabel;

    if (isMyReservation) {
      bgColor = const Color(0xFFE3F2FD);
      borderColor = const Color(0xFF90CAF9);
      textColor = const Color(0xFF1565C0);
      isInteractive = false;
      cellLabel = '我的';
    } else if (isSelected) {
      bgColor = const Color(0xFF1A1A1A);
      borderColor = const Color(0xFF1A1A1A);
      textColor = AppColors.white;
      isInteractive = true;
      cellLabel = '${seat.seatNumber}';
    } else if (isOccupied) {
      bgColor = const Color(0xFFF5F5F5);
      borderColor = const Color(0xFFE0E0E0);
      textColor = const Color(0xFFBDBDBD);
      isInteractive = false;
      cellLabel = '${seat.seatNumber}';
    } else {
      // available
      bgColor = const Color(0xFFF0F7F0);
      borderColor = const Color(0xFFC8E6C9);
      textColor = const Color(0xFF388E3C);
      isInteractive = true;
      cellLabel = '${seat.seatNumber}';
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
              cellLabel,
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
          // 选座提示行（仅在未预约时显示）
          if (_reservedSeatId == null) ...[
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
          ],

          // 按钮区
          if (_reservedSeatId != null)
            // 已预约：灰色禁用按钮
            Container(
              height: 50,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '已预约',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: const Color(0xFFBDBDBD),
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            GestureDetector(
              onTap: canConfirm && !_isLoading ? _handleReservation : null,
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
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
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
  // 确认弹窗 + 预约执行
  // ---------------------------------------------------------------------------
  Future<void> _handleReservation() async {
    if (_selectedSeatId == null || _selectedStartTime == null) return;
    if (_isLoading) return;

    // 第一步：弹出确认弹窗，等待用户操作
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => _ConfirmDialog(
        title: '确认预约',
        content: '预约信息：\n'
            '$_selectedFloor $_selectedZone ${_selectedSeatNumber}号座\n'
            '时段：$_selectedStartTime-$_selectedEndTime\n\n'
            '确认后将生成预约码，请在开始时间 30 分钟内完成签到。',
        confirmText: '确认预约',
        cancelText: '返回',
      ),
    );

    // 用户点击“返回”或关闭弹窗
    if (confirmed != true) return;
    if (!mounted) return;

    // 第二步：执行预约
    setState(() => _isLoading = true);

    // 预先保存座位信息（成功后 setState 会清空）
    final seatId = _selectedSeatId!;
    final seatNumber = _selectedSeatNumber!;
    final savedFloor = _selectedFloor;
    final savedZone = _selectedZone;
    final savedStartTime = _selectedStartTime!;
    final savedEndTime = _selectedEndTime!;

    try {
      final code = await SeatRepository().createReservation(
        seatId: seatId,
        date: _selectedDate,
        startTime: savedStartTime,
        endTime: savedEndTime,
      );

      if (!mounted) return;

      // 第三步：更新本地状态，按钮变灰，座位变蓝
      setState(() {
        _reservedSeatId = seatId;
        _selectedSeatId = null;
        _selectedSeatNumber = null;
        _isLoading = false;
      });

      // 刷新座位图及相关 provider
      ref.invalidate(seatsProvider(_currentQuery));
      ref.invalidate(seatAvailableCountProvider);
      ref.invalidate(myReservationsProvider);
      ref.invalidate(myTodayReservationProvider);

      // 第四步：显示成功弹窗
      if (!mounted) return;
      _showSuccessSheet(
        code: code,
        floor: savedFloor,
        zone: savedZone,
        seatNumber: seatNumber,
        startTime: savedStartTime,
        endTime: savedEndTime,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      // 冲突错误时刷新座位图
      final msg = e.toString().replaceFirst('Exception: ', '');
      if (msg.contains('已被预约') || msg.contains('冲突')) {
        ref.invalidate(seatsProvider(_currentQuery));
      }
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
  void _showSuccessSheet({
    required String code,
    required String floor,
    required String zone,
    required int seatNumber,
    required String startTime,
    required String endTime,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _SuccessSheet(
        code: code,
        floor: floor,
        zone: zone,
        seatNumber: seatNumber,
        startTime: startTime,
        endTime: endTime,
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
  });

  final String title;
  final String content;
  final String confirmText;
  final String cancelText;

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
              color: AppColors.textPrimary,
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
