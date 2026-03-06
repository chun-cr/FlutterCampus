import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/theme.dart';
import '../../../../core/services/course_service.dart';
import '../../../../core/services/grade_service.dart';
import '../../../../domain/models/grade.dart';
import '../../../../domain/models/course.dart';

class StudyPage extends ConsumerWidget {
  const StudyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gradeState = ref.watch(gradeStateProvider);
    final currentSemester = gradeState.semesterSummaries.isNotEmpty
        ? gradeState.semesterSummaries.first
        : null;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. 智能课表模块
              _buildSectionHeader('智能课表', subtitle: 'SCHEDULE'),
              _buildScheduleCard(context, ref),
              const SizedBox(height: 40),

              // 2. 图书馆助手
              _buildSectionHeader('图书馆服务', subtitle: 'LIBRARY SERVICES'),
              _buildPremiumCard(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildLibraryStat(
                            '在借图书',
                            '3',
                            '1本即将到期',
                            AppColors.textPrimary,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 48,
                          color: AppColors.greyLight.withValues(alpha: 0.5),
                        ),
                        Expanded(
                          child: _buildLibraryStat(
                            '自习座位',
                            '42',
                            'A区有空位',
                            AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => context.push('/library'),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: AppColors.primary.withValues(
                            alpha: 0.05,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          '预约座位 / 搜索图书',
                          style: AppTextStyles.button.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // 3. 学业进度看板 (Mock Chart)
              _buildSectionHeader('学业进度', subtitle: 'ACADEMIC PROGRESS'),
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
                              currentSemester != null ? '本学期绩点' : '暂无成绩数据',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              currentSemester?.gpa.toStringAsFixed(2) ?? '--',
                              style: AppTextStyles.headlineLarge.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '共 ${currentSemester?.courseCount ?? 0} 门课 · ${currentSemester?.totalCredits.toStringAsFixed(1) ?? '0'} 学分',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Container(
                      height: 140,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.background.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: gradeState.grades.isEmpty
                          ? Center(
                              child: Text(
                                '暂无成绩数据',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            )
                          : _GpaChartWidget(
                              summaries: gradeState.semesterSummaries)
                    ),
                    const SizedBox(height: 24),
                    Center(
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
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // 4. 学习工具
              _buildSectionHeader('学习工具', subtitle: 'STUDY TOOLS'),
              Row(
                children: [
                  Expanded(
                    child: _buildToolCard(
                      context,
                      icon: Icons.school_outlined,
                      title: '成绩查询',
                      subtitle: 'GPA计算器',
                      color: AppColors.primary,
                      onTap: () => context.push('/grades'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildToolCard(
                      context,
                      icon: Icons.timer_outlined,
                      title: '考试倒计时',
                      subtitle: '备考提醒',
                      color: AppColors.campusOrange,
                      onTap: () => context.push('/exam-countdown'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 80), // Bottom padding for scrolling
            ],
          ),
        ),
      ),
    );
  }

  /// 智能课表卡片：显示今天最近一节课
  Widget _buildScheduleCard(BuildContext context, WidgetRef ref) {
    final courseState = ref.watch(coursesStateProvider);
    final today = DateTime.now().weekday; // 1=周一...7=周日
    final now = TimeOfDay.now();

    // 过滤出今天的课程，按 start_time 升序排列
    Course? nextCourse;
    if (!courseState.isLoading && courseState.error == null) {
      final todayCourses = courseState.courses
          .where((c) => c.weekday == today)
          .toList()
        ..sort((a, b) => a.startTime.compareTo(b.startTime));

      // 取最近未结束的一节
      nextCourse = todayCourses.firstWhere(
        (c) {
          final parts = c.endTime.split(':');
          if (parts.length < 2) return false;
          final end = TimeOfDay(
            hour: int.tryParse(parts[0]) ?? 0,
            minute: int.tryParse(parts[1]) ?? 0,
          );
          // 结束时间大于现在即为未结束
          return end.hour * 60 + end.minute > now.hour * 60 + now.minute;
        },
        orElse: () => todayCourses.isNotEmpty ? todayCourses.last : Course(
          id: '',
          name: '',
          teacher: '',
          location: '',
          weekday: today,
          startTime: '',
          endTime: '',
          startWeek: 1,
          endWeek: 16,
        ),
      );
      // 如果 todayCourses 为空，设为 null
      if (todayCourses.isEmpty) nextCourse = null;
    }

    return _buildPremiumCard(
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.schedule_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: courseState.isLoading
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('加载中……', style: AppTextStyles.titleMedium),
                          const SizedBox(height: 4),
                          Text(
                            '请稍候',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      )
                    : nextCourse == null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('今日暂无课程', style: AppTextStyles.titleMedium),
                              const SizedBox(height: 4),
                              Text(
                                '好好休息吧',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(nextCourse.name, style: AppTextStyles.titleMedium),
                              const SizedBox(height: 4),
                              Text(
                                nextCourse.timeSlotDisplay,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                nextCourse.location,
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
              ),
              GestureDetector(
                onTap: null, // 导航功能暂不实现
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      width: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    '导航',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
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
                '完整课表',
                onTap: () => context.push('/schedule'),
              ),
              _buildQuickAction(
                context,
                Icons.edit_calendar_outlined,
                '请假申请',
                onTap: () => context.push('/leave-apply'),
              ),
              _buildQuickAction(
                context,
                Icons.meeting_room_outlined,
                '查找教室',
              ),
            ],
          ),
        ],
      ),
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

  Widget _buildLibraryStat(
    String label,
    String value,
    String sub,
    Color valueColor,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.headlineMedium.copyWith(
            color: valueColor,
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.labelMedium),
        const SizedBox(height: 6),
        Text(
          sub,
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
        ),
      ],
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

class _RealGpaChartPainter extends CustomPainter {
  _RealGpaChartPainter({
    required this.summaries,
    required this.count,
    required this.barWidth,
    required this.left0,
    required this.chartBottom,
  });
  final List<SemesterGradeSummary> summaries;
  final int count;
  final double barWidth;
  final double left0;
  final double chartBottom;

  @override
  void paint(Canvas canvas, Size size) {
    if (summaries.isEmpty) return;

    final data = summaries.take(4).toList().reversed.toList();

    // 背景网格线（GPA 1.0 / 2.0 / 3.0 / 4.0）
    final gridPaint = Paint()
      ..color = AppColors.greyLight.withValues(alpha: 0.4)
      ..strokeWidth = 0.5;
    for (final level in [1.0, 2.0, 3.0, 4.0]) {
      final y = chartBottom - (level / 4.0) * chartBottom;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 渐变色柱子
    for (int i = 0; i < count; i++) {
      final gpa = data[i].gpa.clamp(0.0, 4.0);
      final rawHeight = (gpa / 4.0) * chartBottom;
      final barHeight = max(rawHeight, 8.0);
      final left = count == 1 ? left0 : left0 + i * (barWidth / 1.4 * 2);
      final top = chartBottom - barHeight;

      final rect = RRect.fromRectAndCorners(
        Rect.fromLTWH(left, top, barWidth, barHeight),
        topLeft: const Radius.circular(6),
        topRight: const Radius.circular(6),
      );
      canvas.drawRRect(
        rect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary,
              AppColors.primary.withValues(alpha: 0.3),
            ],
          ).createShader(Rect.fromLTWH(left, top, barWidth, barHeight))
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(_RealGpaChartPainter old) =>
      old.summaries != summaries;
}

/// 柱状图 Widget：用 Stack + Positioned 叠加文字，避免 Web 上 TextPainter 报错
class _GpaChartWidget extends StatelessWidget {
  const _GpaChartWidget({required this.summaries});
  final List<SemesterGradeSummary> summaries;

  @override
  Widget build(BuildContext context) {
    final data = summaries.take(4).toList().reversed.toList();
    final count = data.length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        const chartBottomPad = 24.0; // 底部学期标注预留空间
        final chartBottom = h - chartBottomPad;

        late double barWidth;
        late double left0;
        if (count == 1) {
          barWidth = w * 0.3;
          left0 = (w - barWidth) / 2;
        } else {
          barWidth = w / (count * 2 + 1) * 1.4;
          left0 = barWidth / 1.4;
        }

        // 预先计算每个柱子的布局信息
        final bars = List.generate(count, (i) {
          final gpa = data[i].gpa.clamp(0.0, 4.0);
          final rawHeight = (gpa / 4.0) * chartBottom;
          final barHeight = max(rawHeight, 8.0);
          final left = count == 1 ? left0 : left0 + i * (barWidth / 1.4 * 2);
          final top = chartBottom - barHeight;
          final semester = data[i].semester;
          final semLabel =
              semester.length >= 9 ? semester.substring(7) : semester;
          return (
            gpa: gpa,
            left: left,
            top: top,
            barWidth: barWidth,
            semLabel: semLabel,
          );
        });

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // 底层：只画网格线 + 柱子
            Positioned.fill(
              child: CustomPaint(
                painter: _RealGpaChartPainter(
                  summaries: data,
                  count: count,
                  barWidth: barWidth,
                  left0: left0,
                  chartBottom: chartBottom,
                ),
              ),
            ),
            // 上层：每个柱子的 GPA 数字 + 学期标注
            for (final bar in bars) ...[
              // GPA 数字（柱子上方）
              Positioned(
                left: bar.left,
                top: bar.top - 16,
                width: bar.barWidth,
                child: Text(
                  bar.gpa.toStringAsFixed(1),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
              ),
              // 学期标注（底部）
              Positioned(
                left: bar.left,
                top: h - 14,
                width: bar.barWidth,
                child: Text(
                  bar.semLabel,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 9,
                    height: 1,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
