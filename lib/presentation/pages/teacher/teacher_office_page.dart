import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/models/canteen_weekly_menu.dart';
import '../../theme/theme.dart';
import '../../components/canteen_menu_panel.dart';
import '../../../core/services/leave_service.dart';

class TeacherOfficePage extends ConsumerStatefulWidget {
  const TeacherOfficePage({super.key});

  @override
  ConsumerState<TeacherOfficePage> createState() => _TeacherOfficePageState();
}

class _TeacherOfficePageState extends ConsumerState<TeacherOfficePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(leaveStateProvider.notifier).loadPendingLeaves();
    });
  }

  @override
  Widget build(BuildContext context) {
    final leaveState = ref.watch(leaveStateProvider);
    final pendingLeaves = leaveState.pendingLeaves;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. 教务通知
              _buildSectionHeader('教务通知', subtitle: 'OFFICIAL NOTICES'),
              Row(
                children: [
                  Expanded(
                    child: _buildToolCard(
                      context,
                      icon: Icons.school_outlined,
                      title: '教务处通知',
                      subtitle: '关于期中教学检查的通知',
                      color: AppColors.primary,
                      onTap: () => context.push('/teacher/notice', extra: 'academic'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildToolCard(
                      context,
                      icon: Icons.timer_outlined,
                      title: '科研处通知',
                      subtitle: '国家自然科学基金申报指南',
                      color: AppColors.campusOrange,
                      onTap: () => context.push('/teacher/notice', extra: 'research'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // 2. 办公审批模块
              _buildSectionHeader('办公审批', subtitle: 'APPROVALS'),
              _buildPremiumCard(
                child: Column(
                  children: [
                    // ── 待审批卡片（真实数据）────────────────────────
                    if (leaveState.isLoading && pendingLeaves.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 12),
                            Text('加载中…'),
                          ],
                        ),
                      )
                    else if (pendingLeaves.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.check_circle_outline_rounded,
                                color: AppColors.success,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '暂无待审批申请',
                                    style: AppTextStyles.titleMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '所有申请已处理完毕',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      // 显示最新一条待审批
                      _buildPendingItem(context, pendingLeaves.first),

                    // 有多条时显示剩余数量提示
                    if (pendingLeaves.length > 1)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: GestureDetector(
                          onTap: () => context.push('/leave-approval'),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '还有 ${pendingLeaves.length - 1} 条待审批',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.primaryBrand,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.chevron_right_rounded,
                                size: 14,
                                color: AppColors.primaryBrand,
                              ),
                            ],
                          ),
                        ),
                      ),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Divider(
                        height: 1,
                        thickness: 0.5,
                        color: AppColors.greyLight,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildQuickAction(
                          context,
                          Icons.calendar_today_outlined,
                          '请假审批',
                          onTap: () => context.push('/leave-approval'),
                        ),
                        _buildQuickAction(
                          context,
                          Icons.notifications_none_outlined,
                          '奖助学金',
                          onTap: () => context.push('/teacher/scholarship'),
                        ),
                        _buildQuickAction(
                          context,
                          Icons.meeting_room_outlined,
                          '场地借用',
                          onTap: () => context.push('/teacher/venue'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // 3. 生活服务
              _buildSectionHeader('生活服务', subtitle: 'LIFE SERVICES'),
              const _CanteenCard(),
              const SizedBox(height: 16),
              const _BusCard(),
              const SizedBox(height: 16),
              const _ReimbursementCard(),
              const SizedBox(height: 40),

              // 4. 科研概况
              _buildSectionHeader('科研概况', subtitle: 'RESEARCH PROGRESS'),
              _buildPremiumCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '本年度科研经费结余',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '¥ 45,000',
                              style: AppTextStyles.headlineLarge.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '正常使用中',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.success,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '4个项目',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: CustomPaint(painter: _MockSpendingChartPainter()),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('1月', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textDisabled)),
                        Text('3月', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textDisabled)),
                        Text('6月', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textDisabled)),
                        Text('9月', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textDisabled)),
                        Text('12月', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textDisabled)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Text('3个', style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary)),
                              const SizedBox(height: 4),
                              Text('进行中项目', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        Container(width: 1, height: 24, color: AppColors.greyLight),
                        Expanded(
                          child: Column(
                            children: [
                              Text('3篇', style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary)),
                              const SizedBox(height: 4),
                              Text('已发表论文', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        Container(width: 1, height: 24, color: AppColors.greyLight),
                        Expanded(
                          child: Column(
                            children: [
                              Text('¥32,200', style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary)),
                              const SizedBox(height: 4),
                              Text('本年支出', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: GestureDetector(
                        onTap: () => context.push('/teacher/research'),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.auto_graph_rounded,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '查看详细分析',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
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

  // ── 待审批条目 ───────────────────────────────────────────────────
  Widget _buildPendingItem(BuildContext context, leave) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.schedule_rounded,
            color: AppColors.warning,
            size: 24,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${leave.studentName}的${leave.leaveType}申请',
                style: AppTextStyles.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                '${leave.leaveType}: ${leave.dateRange}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                leave.className,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => context.push('/leave-approval'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 0.5,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              '审批',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
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

  Widget _buildSectionHeader(String title, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4),
      child: Column(
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
    );
  }

  Widget _buildQuickAction(
    BuildContext context,
    IconData icon,
    String label, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: AppColors.textPrimary.withValues(alpha: 0.7),
            size: 28,
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildToolCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.greyLight.withValues(alpha: 0.6),
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 16),
            Text(title, style: AppTextStyles.titleMedium),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MockSpendingChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 虚拟本年12个月经费支出，基于 monthlySpending: [0, 0, 8000, 12000, 3200, 0, 0, 6000, 2400, 800, 0, 0]
    final data = [0.0, 0.0, 8000.0, 12000.0, 3200.0, 0.0, 0.0, 6000.0, 2400.0, 800.0, 0.0, 0.0];
    final maxVal = 12000.0;
    
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.6)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    
    // 生成折线点
    final points = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final x = size.width * (i / (data.length - 1));
      // 0为底部，由于最大高度预留点空间，最高占80%高度
      final y = size.height - (data[i] / maxVal) * (size.height * 0.8);
      points.add(Offset(x, y));
    }

    if (points.isNotEmpty) {
      path.moveTo(points.first.dx, points.first.dy);
      // 使用平滑贝塞尔曲线
      for (var i = 0; i < points.length - 1; i++) {
        var p0 = points[i];
        var p1 = points[i + 1];
        var ctrl1 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p0.dy);
        var ctrl2 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p1.dy);
        path.cubicTo(ctrl1.dx, ctrl1.dy, ctrl2.dx, ctrl2.dy, p1.dx, p1.dy);
      }
    }

    canvas.drawPath(path, paint);

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.primary.withValues(alpha: 0.15),
          AppColors.primary.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTRB(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(fillPath, fillPaint);

    final dotPaint = Paint()..color = AppColors.surface;
    final dotBorderPaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // 绘制有支出的数据点
    for (int i = 0; i < points.length; i++) {
      if (data[i] > 0) {
        final point = points[i];
        canvas.drawCircle(point, 3, dotPaint);
        canvas.drawCircle(point, 3, dotBorderPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ===========================================================================
// 生活服务模块 - 数据与组件
// ===========================================================================

class BusSchedule {
  const BusSchedule({
    required this.route,
    required this.from,
    required this.to,
    required this.times,
  });
  final String route;
  final String from;
  final String to;
  final List<String> times;
}

final busSchedules = [
  const BusSchedule(
    route: '1路',
    from: '学校正门',
    to: '市中心广场',
    times: ['07:15', '08:30', '12:00', '17:30', '18:45', '21:00'],
  ),
  const BusSchedule(
    route: '1路',
    from: '市中心广场',
    to: '学校正门',
    times: ['07:45', '09:00', '13:00', '18:00', '19:15', '21:30'],
  ),
  const BusSchedule(
    route: '2路',
    from: '学校正门',
    to: '火车站',
    times: ['08:00', '12:30', '17:00', '20:30'],
  ),
  const BusSchedule(
    route: '2路',
    from: '火车站',
    to: '学校正门',
    times: ['08:45', '13:15', '17:45', '21:15'],
  ),
];

class ReimbursementRecord {
  const ReimbursementRecord({
    required this.id,
    required this.title,
    required this.amount,
    required this.status,
    required this.date,
  });
  final String id;
  final String title;
  final double amount;
  final String status;
  final String date;
}

final mockReimbursements = [
  const ReimbursementRecord(
    id: '2025-012',
    title: '差旅费报销',
    amount: 1200,
    status: 'processing',
    date: '3月10日',
  ),
  const ReimbursementRecord(
    id: '2025-008',
    title: '科研耗材采购',
    amount: 3400,
    status: 'approved',
    date: '2月28日',
  ),
  const ReimbursementRecord(
    id: '2025-003',
    title: '会议注册费',
    amount: 800,
    status: 'approved',
    date: '2月15日',
  ),
];

// ---------------------------------------------------------------------------
// 卡片一：今日食堂
// ---------------------------------------------------------------------------
class _CanteenCard extends StatelessWidget {
  const _CanteenCard();

  @override
  Widget build(BuildContext context) {
    return const CanteenMenuPanel(
      audience: CanteenAudience.teacher,
      emptyTitle: '教工食堂菜单暂未开放',
    );
  }
}

// ---------------------------------------------------------------------------
// 卡片二：通勤班车
// ---------------------------------------------------------------------------

class _NextBusInfo {
  _NextBusInfo({
    required this.route,
    required this.from,
    required this.to,
    required this.time,
    required this.minutesLeft,
  });
  final String route;
  final String from;
  final String to;
  final String time;
  final int minutesLeft;
}

class _BusCard extends StatelessWidget {
  const _BusCard();

  /// 遍历所有班车数据，找到今天时间上最接近的下一班车
  _NextBusInfo? _findNextBus() {
    final now = DateTime.now();
    final currentTimeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    _NextBusInfo? nextBus;
    int minMinutesDiff = 999999;

    for (final schedule in busSchedules) {
      for (final time in schedule.times) {
        if (time.compareTo(currentTimeStr) >= 0) {
          // 这个班次在未来
          final parts = time.split(':');
          final h = int.parse(parts[0]);
          final m = int.parse(parts[1]);
          final diff = (h * 60 + m) - (now.hour * 60 + now.minute);
          
          if (diff >= 0 && diff < minMinutesDiff) {
            minMinutesDiff = diff;
            nextBus = _NextBusInfo(
              route: schedule.route,
              from: schedule.from,
              to: schedule.to,
              time: time,
              minutesLeft: diff,
            );
          }
        }
      }
    }

    return nextBus;
  }

  @override
  Widget build(BuildContext context) {
    final nextBus = _findNextBus();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.greyLight.withValues(alpha: 0.6),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.directions_bus_outlined,
                  color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text('通勤班车', style: AppTextStyles.titleMedium),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: AppColors.background,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    builder: (ctx) => const _BusSheet(),
                  );
                },
                child: Row(
                  children: [
                    Text(
                      '查看全部',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const Icon(Icons.chevron_right,
                        size: 16, color: AppColors.primary),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (nextBus != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                nextBus.route,
                style: AppTextStyles.caption.copyWith(color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${nextBus.from} → ${nextBus.to}',
              style: AppTextStyles.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  nextBus.time,
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 12),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '距现在 ${nextBus.minutesLeft} 分钟',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            Text(
              '今日班次已全部发车',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.textDisabled,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BusSheet extends StatelessWidget {
  const _BusSheet();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final currentTimeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: AppColors.greyLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text('通勤班车时刻表', style: AppTextStyles.titleLarge),
            const SizedBox(height: 24),
            // 将相同路线名分组展示
            ..._buildGroupedSchedules(currentTimeStr),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildGroupedSchedules(String currentTimeStr) {
    final groups = <String, List<BusSchedule>>{};
    for (final s in busSchedules) {
      groups.putIfAbsent(s.route, () => []).add(s);
    }

    final children = <Widget>[];
    groups.forEach((route, schedules) {
      children.add(Text(route, style: AppTextStyles.titleMedium));
      children.add(const SizedBox(height: 12));
      for (final s in schedules) {
        children.add(Text('${s.from} → ${s.to}', style: AppTextStyles.labelMedium));
        children.add(const SizedBox(height: 8));

        // 找最近未发出的一班标记为最近
        int closestIndex = -1;
        for (int i = 0; i < s.times.length; i++) {
          if (s.times[i].compareTo(currentTimeStr) >= 0) {
            closestIndex = i;
            break;
          }
        }

        children.add(
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(s.times.length, (i) {
                final time = s.times[i];
                final isPast = time.compareTo(currentTimeStr) < 0;
                final isClosest = i == closestIndex;

                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isPast
                              ? AppColors.greyLight.withValues(alpha: 0.5)
                              : AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          time,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: isPast
                                ? AppColors.textDisabled
                                : AppColors.primary,
                          ),
                        ),
                      ),
                      if (isClosest)
                        Positioned(
                          right: -4,
                          top: -6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              '最近',
                              style: TextStyle(
                                  fontSize: 8, color: Colors.white),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),
          ),
        );
        children.add(const SizedBox(height: 16));
      }
      children.add(const Divider(height: 24, thickness: 0.5, color: AppColors.greyLight));
    });

    if (children.isNotEmpty) {
      children.removeLast(); // 移除最后的分隔线
    }
    return children;
  }
}

// ---------------------------------------------------------------------------
// 卡片三：财务报销
// ---------------------------------------------------------------------------
class _ReimbursementCard extends StatelessWidget {
  const _ReimbursementCard();

  @override
  Widget build(BuildContext context) {
    // 处理中数量
    final processingCount = mockReimbursements
        .where((e) => e.status == 'processing')
        .length;

    // 前几条记录
    final recentRecords = mockReimbursements.take(2).toList();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.greyLight.withValues(alpha: 0.6),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_long_outlined,
                  color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text('财务报销', style: AppTextStyles.titleMedium),
              const Spacer(),
              if (processingCount > 0)
                Text(
                  '$processingCount笔审批中',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.campusOrange,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          for (int i = 0; i < recentRecords.length; i++) ...[
            _buildRecordRow(recentRecords[i]),
            if (i < recentRecords.length - 1)
              const Divider(height: 24, thickness: 0.5, color: AppColors.greyLight),
          ],
          if (mockReimbursements.length > recentRecords.length) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: AppColors.background,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    builder: (ctx) => const _ReimbursementSheet(),
                  );
                },
                child: Text(
                  '查看全部记录',
                  style: AppTextStyles.button.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildRecordRow(ReimbursementRecord record) {
    String statusLabel;
    Color statusColor;

    if (record.status == 'processing') {
      statusLabel = '审批中';
      statusColor = AppColors.campusOrange;
    } else if (record.status == 'approved') {
      statusLabel = '已到账';
      statusColor = AppColors.success;
    } else {
      statusLabel = '已驳回';
      statusColor = AppColors.error;
    }

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(record.title, style: AppTextStyles.labelMedium),
              const SizedBox(height: 4),
              Text(
                record.date,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '¥${record.amount.toStringAsFixed(0)}',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                statusLabel,
                style: AppTextStyles.caption.copyWith(
                  color: statusColor,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ReimbursementSheet extends StatelessWidget {
  const _ReimbursementSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: AppColors.greyLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text('报销记录', style: AppTextStyles.titleLarge),
            ),
            const SizedBox(height: 16),
            ...mockReimbursements.map(_buildListTile),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(ReimbursementRecord record) {
    IconData icon;
    Color color;
    String label;

    if (record.status == 'processing') {
      icon = Icons.pending_outlined;
      color = AppColors.campusOrange;
      label = '审批中';
    } else if (record.status == 'approved') {
      icon = Icons.check_circle_outline;
      color = AppColors.success;
      label = '已到账';
    } else {
      icon = Icons.cancel_outlined;
      color = AppColors.error;
      label = '已驳回';
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(record.title, style: AppTextStyles.titleMedium),
      subtitle: Text(
        '#${record.id} · ${record.date}',
        style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '¥${record.amount.toStringAsFixed(0)}',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
