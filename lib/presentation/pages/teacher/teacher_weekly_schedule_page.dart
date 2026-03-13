import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

// ---------------------------------------------------------------------------
// 当前显示教学周
// ---------------------------------------------------------------------------
final _currentWeekProvider = StateProvider<int>((ref) {
  final semesterStart = DateTime(2025, 2, 24);
  final now = DateTime.now();
  final diff = now.difference(semesterStart).inDays;
  final week = (diff ~/ 7) + 1;
  return week.clamp(1, 18);
});

// ---------------------------------------------------------------------------
// 教师教学日历页（兼容入口包装）
// ---------------------------------------------------------------------------
class TeacherWeeklySchedulePage extends StatelessWidget {
  const TeacherWeeklySchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const TeacherCalendarPage();
  }
}

// ---------------------------------------------------------------------------
// 教师教学日历页
// ---------------------------------------------------------------------------
class TeacherCalendarPage extends ConsumerStatefulWidget {
  const TeacherCalendarPage({super.key});

  @override
  ConsumerState<TeacherCalendarPage> createState() => _TeacherCalendarPageState();
}

class _TeacherCalendarPageState extends ConsumerState<TeacherCalendarPage> {
  static const double _hourHeight = 56;
  static const double _timeColumnWidth = 40;
  static const int _startHour = 8;
  static const int _endHour = 21;

  final List<TeacherCourse> _courses = const [
    TeacherCourse(
      id: 't1',
      courseName: '数据结构',
      courseCode: 'CS301',
      classNames: '22级计算机1、2班',
      location: '计算机楼101',
      weekday: 1,
      periodStart: 1,
      periodEnd: 2,
      startTime: '08:00',
      endTime: '09:40',
      startWeek: 1,
      endWeek: 18,
      weekType: 'all',
      color: '#5B8DEF',
    ),
    TeacherCourse(
      id: 't2',
      courseName: '算法设计与分析',
      courseCode: 'CS402',
      classNames: '22级网络工程1班',
      location: '计算机楼203',
      weekday: 1,
      periodStart: 5,
      periodEnd: 6,
      startTime: '14:00',
      endTime: '15:40',
      startWeek: 1,
      endWeek: 18,
      weekType: 'all',
      color: '#F5A623',
    ),
    TeacherCourse(
      id: 't3',
      courseName: '数据库系统原理',
      courseCode: 'CS312',
      classNames: '23级软工1、2班',
      location: '计算机楼101',
      weekday: 2,
      periodStart: 3,
      periodEnd: 4,
      startTime: '10:00',
      endTime: '11:40',
      startWeek: 1,
      endWeek: 18,
      weekType: 'all',
      color: '#7ED321',
    ),
    TeacherCourse(
      id: 't4',
      courseName: '数据结构',
      courseCode: 'CS301',
      classNames: '22级计算机1、2班',
      location: '计算机楼101',
      weekday: 3,
      periodStart: 1,
      periodEnd: 2,
      startTime: '08:00',
      endTime: '09:40',
      startWeek: 1,
      endWeek: 18,
      weekType: 'all',
      color: '#5B8DEF',
    ),
    TeacherCourse(
      id: 't5',
      courseName: '操作系统',
      courseCode: 'CS305',
      classNames: '22级计算机1班',
      location: '计算机楼305',
      weekday: 3,
      periodStart: 7,
      periodEnd: 8,
      startTime: '19:00',
      endTime: '20:40',
      startWeek: 1,
      endWeek: 18,
      weekType: 'odd',
      color: '#BD10E0',
    ),
    TeacherCourse(
      id: 't6',
      courseName: '数据库系统原理',
      courseCode: 'CS312',
      classNames: '23级软工1、2班',
      location: '计算机楼101',
      weekday: 4,
      periodStart: 3,
      periodEnd: 4,
      startTime: '10:00',
      endTime: '11:40',
      startWeek: 1,
      endWeek: 18,
      weekType: 'all',
      color: '#7ED321',
    ),
    TeacherCourse(
      id: 't7',
      courseName: '计算机网络',
      courseCode: 'CS308',
      classNames: '23级软工2班',
      location: '计算机楼202',
      weekday: 5,
      periodStart: 5,
      periodEnd: 6,
      startTime: '14:00',
      endTime: '15:40',
      startWeek: 1,
      endWeek: 18,
      weekType: 'even',
      color: '#E84B4B',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final currentWeek = ref.watch(_currentWeekProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('教学日历', style: AppTextStyles.titleLarge),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: Column(
        children: [
          _WeekSwitcher(
            currentWeek: currentWeek,
            onPrevious: currentWeek <= 1
                ? null
                : () {
                    ref.read(_currentWeekProvider.notifier).state = currentWeek - 1;
                  },
            onNext: currentWeek >= 18
                ? null
                : () {
                    ref.read(_currentWeekProvider.notifier).state = currentWeek + 1;
                  },
          ),
          _DateHeader(currentWeek: currentWeek),
          Expanded(
            child: SingleChildScrollView(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTimeColumn(),
                  Expanded(
                    child: _buildGridAndCourses(currentWeek),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeColumn() {
    final hoursCount = _endHour - _startHour + 1;

    return Container(
      width: _timeColumnWidth,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          right: BorderSide(color: AppColors.greyLight.withOpacity(0.5)),
        ),
      ),
      child: Column(
        children: List.generate(hoursCount, (index) {
          final hour = _startHour + index;
          return SizedBox(
            height: _hourHeight,
            child: Align(
              alignment: Alignment.topCenter,
              child: Transform.translate(
                offset: const Offset(0, -8),
                child: Text(
                  '${hour.toString().padLeft(2, '0')}:00',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary.withOpacity(0.7),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildGridAndCourses(int currentWeek) {
    final hoursCount = _endHour - _startHour + 1;
    final totalHeight = hoursCount * _hourHeight;
    final weekCourses = _courses.where((course) => course.weekday >= 1 && course.weekday <= 5).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final dayWidth = constraints.maxWidth / 5;

        return SizedBox(
          height: totalHeight,
          child: Stack(
            children: [
              ...List.generate(hoursCount + 1, (index) {
                return Positioned(
                  top: index * _hourHeight,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 1,
                    color: AppColors.greyLight.withOpacity(0.3),
                  ),
                );
              }),
              ...List.generate(6, (index) {
                return Positioned(
                  top: 0,
                  bottom: 0,
                  left: index * dayWidth,
                  child: Container(
                    width: 1,
                    color: AppColors.greyLight.withOpacity(0.3),
                  ),
                );
              }),
              ...List.generate(5, (index) {
                final weekday = index + 1;
                final date = weekdayToDate(currentWeek, weekday);
                final isToday = _isSameDay(date, DateTime.now());
                if (!isToday) {
                  return const SizedBox.shrink();
                }

                return Positioned(
                  top: 0,
                  bottom: 0,
                  left: index * dayWidth,
                  width: dayWidth,
                  child: IgnorePointer(
                    child: Container(
                      color: AppColors.primary.withOpacity(0.04),
                    ),
                  ),
                );
              }),
              ...weekCourses.map((course) {
                return _buildCourseBlock(course, dayWidth, currentWeek);
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCourseBlock(
    TeacherCourse course,
    double dayWidth,
    int currentWeek,
  ) {
    int startH = 0;
    int startM = 0;
    int endH = 0;
    int endM = 0;

    try {
      final startParts = course.startTime.split(':');
      startH = int.parse(startParts[0]);
      startM = int.parse(startParts[1]);

      final endParts = course.endTime.split(':');
      endH = int.parse(endParts[0]);
      endM = int.parse(endParts[1]);
    } catch (_) {
      return const SizedBox.shrink();
    }

    if (startH < _startHour || endH > _endHour) {
      return const SizedBox.shrink();
    }

    final topStart =
        ((startH - _startHour) * 60 + startM) / 60.0 * _hourHeight;
    final topEnd = ((endH - _startHour) * 60 + endM) / 60.0 * _hourHeight;
    final height = max(topEnd - topStart, 20.0);
    final left = (course.weekday - 1) * dayWidth;
    final isActive = isCourseActiveInWeek(course, currentWeek);
    final courseColor = _parseCourseColor(course.color);

    return Positioned(
      top: topStart,
      left: left,
      width: dayWidth,
      height: height,
      child: _TeacherCourseBlock(
        course: course,
        color: courseColor,
        isActive: isActive,
        height: height,
        onTap: () => _showCourseDetails(course, courseColor, isActive),
      ),
    );
  }

  void _showCourseDetails(TeacherCourse course, Color color, bool isActive) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: AppColors.surface,
      builder: (context) {
        return _CourseDetailSheet(
          course: course,
          color: color,
          isActive: isActive,
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// 周次切换栏
// ---------------------------------------------------------------------------
class _WeekSwitcher extends StatelessWidget {
  const _WeekSwitcher({
    required this.currentWeek,
    required this.onPrevious,
    required this.onNext,
  });

  final int currentWeek;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.greyLight.withOpacity(0.5), width: 0.5),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onPrevious,
            icon: Icon(
              Icons.chevron_left_rounded,
              color: onPrevious == null
                  ? AppColors.textDisabled
                  : AppColors.textPrimary,
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                '第$currentWeek教学周',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: onNext,
            icon: Icon(
              Icons.chevron_right_rounded,
              color: onNext == null
                  ? AppColors.textDisabled
                  : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 日期列头
// ---------------------------------------------------------------------------
class _DateHeader extends StatelessWidget {
  const _DateHeader({required this.currentWeek});

  final int currentWeek;

  @override
  Widget build(BuildContext context) {
    const weekLabels = ['周一', '周二', '周三', '周四', '周五'];

    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.greyLight.withOpacity(0.5), width: 0.5),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 40),
          ...List.generate(5, (index) {
            final weekday = index + 1;
            final date = weekdayToDate(currentWeek, weekday);
            final isToday = _isSameDay(date, DateTime.now());

            return Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    weekLabels[index],
                    style: AppTextStyles.labelSmall.copyWith(
                      color: isToday ? AppColors.primary : AppColors.textSecondary,
                      fontWeight: isToday ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (isToday)
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${date.month}/${date.day}',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.white,
                          fontSize: 10,
                          height: 1,
                        ),
                      ),
                    )
                  else
                    Text(
                      '${date.month}/${date.day}',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 教师课程块
// ---------------------------------------------------------------------------
class _TeacherCourseBlock extends StatelessWidget {
  const _TeacherCourseBlock({
    required this.course,
    required this.color,
    required this.isActive,
    required this.height,
    required this.onTap,
  });

  final TeacherCourse course;
  final Color color;
  final bool isActive;
  final double height;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final sideColor = isActive ? color : AppColors.textDisabled;
    final backgroundColor = isActive
        ? color.withOpacity(0.15)
        : AppColors.greyLight.withOpacity(0.8);
    final titleColor = isActive
        ? color.withOpacity(0.9)
        : AppColors.textDisabled;
    final subColor = isActive
        ? color.withOpacity(0.7)
        : AppColors.textDisabled;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(left: 1, right: 1, bottom: 2),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border(left: BorderSide(color: sideColor, width: 3)),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.courseName,
                    style: AppTextStyles.labelSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                      fontSize: 10,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    course.location,
                    style: AppTextStyles.caption.copyWith(
                      color: subColor,
                      fontSize: 9,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (height > 58) ...[
                    const SizedBox(height: 2),
                    Text(
                      course.classNames,
                      style: AppTextStyles.caption.copyWith(
                        color: subColor,
                        fontSize: 9,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Text(
                _badgeLabel(),
                style: AppTextStyles.caption.copyWith(
                  fontSize: 8,
                  color: _badgeColor(),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _badgeLabel() {
    if (!isActive && course.weekType != 'all') {
      return '休';
    }
    if (course.weekType == 'odd') return '单';
    if (course.weekType == 'even') return '双';
    return '';
  }

  Color _badgeColor() {
    if (!isActive && course.weekType != 'all') {
      return AppColors.error;
    }
    return color;
  }
}

// ---------------------------------------------------------------------------
// 课程详情 BottomSheet
// ---------------------------------------------------------------------------
class _CourseDetailSheet extends StatelessWidget {
  const _CourseDetailSheet({
    required this.course,
    required this.color,
    required this.isActive,
  });

  final TeacherCourse course;
  final Color color;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.greyLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: isActive ? color : AppColors.textDisabled,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.courseName,
                      style: AppTextStyles.titleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      course.courseCode,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _DetailTile(
            icon: Icons.location_on_rounded,
            text: course.location,
          ),
          const SizedBox(height: 14),
          _DetailTile(
            icon: Icons.people_outline_rounded,
            text: course.classNames,
          ),
          const SizedBox(height: 14),
          _DetailTile(
            icon: Icons.access_time_rounded,
            text: '${course.startTime} - ${course.endTime}',
          ),
          const SizedBox(height: 14),
          _DetailTile(
            icon: Icons.view_week_rounded,
            text: '第${course.periodStart}-${course.periodEnd}节',
          ),
          const SizedBox(height: 14),
          _DetailTile(
            icon: Icons.date_range_rounded,
            text: '第${course.startWeek}-${course.endWeek}周',
          ),
          const SizedBox(height: 14),
          _DetailTile(
            icon: Icons.repeat_rounded,
            text: _weekTypeLabel(course.weekType, isActive),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(context),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                '我知道了',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  String _weekTypeLabel(String type, bool active) {
    switch (type) {
      case 'odd':
        return active ? '单周' : '单周（本周休）';
      case 'even':
        return active ? '双周' : '双周（本周休）';
      default:
        return '全周';
    }
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 教师课程模型
// ---------------------------------------------------------------------------
class TeacherCourse {
  const TeacherCourse({
    required this.id,
    required this.courseName,
    required this.courseCode,
    required this.classNames,
    required this.location,
    required this.weekday,
    required this.periodStart,
    required this.periodEnd,
    required this.startTime,
    required this.endTime,
    required this.startWeek,
    required this.endWeek,
    required this.weekType,
    required this.color,
  });

  final String id;
  final String courseName;
  final String courseCode;
  final String classNames;
  final String location;
  final int weekday;
  final int periodStart;
  final int periodEnd;
  final String startTime;
  final String endTime;
  final int startWeek;
  final int endWeek;
  final String weekType;
  final String color;
}

// ---------------------------------------------------------------------------
// 工具函数
// ---------------------------------------------------------------------------
DateTime weekdayToDate(int weekNo, int weekday) {
  return DateTime(2025, 2, 24).add(
    Duration(days: (weekNo - 1) * 7 + (weekday - 1)),
  );
}

bool isCourseActiveInWeek(TeacherCourse c, int weekNo) {
  if (weekNo < c.startWeek || weekNo > c.endWeek) return false;
  if (c.weekType == 'odd') return weekNo % 2 == 1;
  if (c.weekType == 'even') return weekNo % 2 == 0;
  return true;
}

Color _parseCourseColor(String color) {
  try {
    return Color(int.parse(color.replaceFirst('#', '0xFF')));
  } catch (_) {
    return AppColors.primary;
  }
}

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
