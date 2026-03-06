import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/course_service.dart';
import '../../../domain/models/course.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../components/campus_loading.dart';
import '../../components/campus_empty_state.dart';

class SchedulePage extends ConsumerStatefulWidget {
  const SchedulePage({super.key});

  @override
  ConsumerState<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends ConsumerState<SchedulePage> {
  final ScrollController _scrollController = ScrollController();
  final double hourHeight = 60.0;
  final int startHour = 8;
  final int endHour = 22;

  // List of colors to use if course color is not provided
  final List<Color> _courseColors = [
    AppColors.primary,
    AppColors.secondary,
    AppColors.success,
    AppColors.warning,
    AppColors.campusBlue,
    AppColors.campusOrange,
    Color(0xFF9C27B0),
    Color(0xFFE91E63),
    Color(0xFF009688),
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(coursesStateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('完整课表', style: AppTextStyles.titleLarge),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh_rounded,
              color: AppColors.textPrimary,
            ),
            onPressed: () => ref.read(coursesStateProvider.notifier).refresh(),
          ),
        ],
      ),
      body: state.isLoading && state.courses.isEmpty
          ? const Center(child: CampusLoading())
          : state.error != null && state.courses.isEmpty
          ? Center(
              child: CampusEmptyState(
                icon: Icons.error_outline_rounded,
                title: '加载失败',
                subtitle: state.error!,
                buttonText: '重试',
                onButtonTap: () =>
                    ref.read(coursesStateProvider.notifier).refresh(),
              ),
            )
          : state.courses.isEmpty
          ? Center(
              child: CampusEmptyState(
                icon: Icons.calendar_today_outlined,
                title: '暂无课程',
                subtitle: '你的课表似乎是空的，享受你的闲暇时光吧！',
                buttonText: '刷新看看',
                onButtonTap: () =>
                    ref.read(coursesStateProvider.notifier).refresh(),
              ),
            )
          : _buildSchedule(state.courses),
    );
  }

  Widget _buildSchedule(List<Course> courses) {
    return Column(
      children: [
        _buildDaysHeader(),
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTimeColumn(),
                Expanded(child: _buildGridAndCourses(courses)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDaysHeader() {
    final days = ['一', '二', '三', '四', '五', '六', '日'];
    final now = DateTime.now();
    final todayWeekday = now.weekday;

    return Container(
      padding: const EdgeInsets.only(left: 50, top: 12, bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.greyLight.withOpacity(0.5)),
        ),
      ),
      child: Row(
        children: List.generate(7, (index) {
          final isToday = todayWeekday == index + 1;
          return Expanded(
            child: Column(
              children: [
                Text(
                  '周${days[index]}',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isToday
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (isToday)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTimeColumn() {
    final int hoursCount = endHour - startHour + 1;
    return Container(
      width: 50,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          right: BorderSide(color: AppColors.greyLight.withOpacity(0.5)),
        ),
      ),
      child: Column(
        children: List.generate(hoursCount, (index) {
          final hour = startHour + index;
          return SizedBox(
            height: hourHeight,
            child: Align(
              alignment: Alignment.topCenter,
              child: Transform.translate(
                offset: const Offset(0, -8),
                child: Text(
                  hour.toString().padLeft(2, '0') + ':00',
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

  Widget _buildGridAndCourses(List<Course> courses) {
    final int hoursCount = endHour - startHour + 1;
    final double totalHeight = hoursCount * hourHeight;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double dayWidth = constraints.maxWidth / 7;

        return SizedBox(
          height: totalHeight,
          child: Stack(
            children: [
              // Grid background
              ...List.generate(hoursCount + 1, (index) {
                return Positioned(
                  top: index * hourHeight,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 1,
                    color: AppColors.greyLight.withOpacity(0.3),
                  ),
                );
              }),
              ...List.generate(8, (index) {
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

              // Courses
              ...courses.map((course) {
                return _buildCourseBlock(course, dayWidth);
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCourseBlock(Course course, double dayWidth) {
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
    } catch (e) {
      return const SizedBox.shrink(); // Invalid time format
    }

    if (startH < startHour || endH > endHour) {
      return const SizedBox.shrink(); // Out of bounds
    }

    final double topStart =
        ((startH - startHour) * 60 + startM) / 60.0 * hourHeight;
    final double topEnd = ((endH - startHour) * 60 + endM) / 60.0 * hourHeight;
    final double height = max(topEnd - topStart, 20.0); // min height 20

    // Weekday ranges from 1 to 7
    final double left = (course.weekday - 1) * dayWidth;

    Color blockColor;
    if (course.color != null && course.color!.isNotEmpty) {
      try {
        blockColor = Color(int.parse(course.color!.replaceFirst('#', '0xFF')));
      } catch (_) {
        blockColor = _getConsistentColor(course.id);
      }
    } else {
      blockColor = _getConsistentColor(course.id);
    }

    return Positioned(
      top: topStart,
      left: left,
      width: dayWidth,
      height: height,
      child: GestureDetector(
        onTap: () => _showCourseDetails(course, blockColor),
        child: Container(
          margin: const EdgeInsets.only(left: 1, right: 1, bottom: 2),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: blockColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(6),
            border: Border(left: BorderSide(color: blockColor, width: 3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                course.name,
                style: AppTextStyles.labelSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: blockColor.withOpacity(0.9),
                  fontSize: 10,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (height > 40) ...[
                const SizedBox(height: 2),
                Text(
                  course.location,
                  style: AppTextStyles.caption.copyWith(
                    color: blockColor.withOpacity(0.7),
                    fontSize: 9,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getConsistentColor(String id) {
    if (id.isEmpty) return _courseColors.first;
    final sum = id.codeUnits.reduce((a, b) => a + b);
    return _courseColors[sum % _courseColors.length];
  }

  void _showCourseDetails(Course course, Color color) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: AppColors.surface,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      course.name,
                      style: AppTextStyles.titleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildDetailRow(
                Icons.schedule_rounded,
                '${course.timeSlotDisplay} (${course.weekRangeDisplay})',
              ),
              const SizedBox(height: 16),
              _buildDetailRow(Icons.location_on_rounded, course.location),
              const SizedBox(height: 16),
              _buildDetailRow(Icons.person_outline_rounded, course.teacher),
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
                  child: const Text('我知道了'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
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
