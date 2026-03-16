import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../components/campus_empty_state.dart';
import '../../components/campus_loading.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

// ---------------------------------------------------------------------------
// 数据模型：调课申请
// ---------------------------------------------------------------------------
class RescheduleApplication {
  const RescheduleApplication({
    required this.id,
    required this.teacherId,
    required this.teacherName,
    required this.courseName,
    required this.courseCode,
    required this.originalWeekday,
    required this.originalPeriod,
    required this.originalTime,
    required this.originalLocation,
    this.originalWeek,
    required this.applyType,
    this.newWeekday,
    this.newPeriod,
    this.newTime,
    this.newLocation,
    this.reason,
    required this.status,
    this.adminComment,
    this.reviewedAt,
    required this.createdAt,
  });

  factory RescheduleApplication.fromJson(Map<String, dynamic> json) {
    return RescheduleApplication(
      id: json['id'] as String,
      teacherId: json['teacher_id'] as String,
      teacherName: json['teacher_name'] as String? ?? '',
      courseName: json['course_name'] as String,
      courseCode: json['course_code'] as String,
      originalWeekday: json['original_weekday'] as int,
      originalPeriod: json['original_period'] as String,
      originalTime: json['original_time'] as String,
      originalLocation: json['original_location'] as String,
      originalWeek: json['original_week'] as int?,
      applyType: json['apply_type'] as String,
      newWeekday: json['new_weekday'] as int?,
      newPeriod: json['new_period'] as String?,
      newTime: json['new_time'] as String?,
      newLocation: json['new_location'] as String?,
      reason: json['reason'] as String?,
      status: json['status'] as String? ?? 'pending',
      adminComment: json['admin_comment'] as String?,
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.parse(json['reviewed_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  final String id;
  final String teacherId;
  final String teacherName;
  final String courseName;
  final String courseCode;
  final int originalWeekday;
  final String originalPeriod;
  final String originalTime;
  final String originalLocation;
  final int? originalWeek;
  final String applyType; // 'time' / 'room'
  final int? newWeekday;
  final String? newPeriod;
  final String? newTime;
  final String? newLocation;
  final String? reason;
  final String status; // 'pending' / 'approved' / 'rejected'
  final String? adminComment;
  final DateTime? reviewedAt;
  final DateTime createdAt;
}

// ---------------------------------------------------------------------------
// 复用教学日历中的课程模型（简化版，仅用于选择器）
// ---------------------------------------------------------------------------
class _CourseItem {
  const _CourseItem({
    required this.courseName,
    required this.courseCode,
    required this.location,
    required this.weekday,
    required this.period,
    required this.time,
  });

  final String courseName;
  final String courseCode;
  final String location;
  final int weekday;
  final String period; // 如 '1-2'
  final String time; // 如 '08:00-09:40'
}

// 虚拟课程数据（与教学日历7条课程一致）
const _mockCourses = [
  _CourseItem(
    courseName: '数据结构',
    courseCode: 'CS301',
    location: '计算机楼101',
    weekday: 1,
    period: '1-2',
    time: '08:00-09:40',
  ),
  _CourseItem(
    courseName: '算法设计与分析',
    courseCode: 'CS402',
    location: '计算机楼203',
    weekday: 1,
    period: '5-6',
    time: '14:00-15:40',
  ),
  _CourseItem(
    courseName: '数据库系统原理',
    courseCode: 'CS312',
    location: '计算机楼101',
    weekday: 2,
    period: '3-4',
    time: '10:00-11:40',
  ),
  _CourseItem(
    courseName: '数据结构',
    courseCode: 'CS301',
    location: '计算机楼101',
    weekday: 3,
    period: '1-2',
    time: '08:00-09:40',
  ),
  _CourseItem(
    courseName: '操作系统',
    courseCode: 'CS305',
    location: '计算机楼305',
    weekday: 3,
    period: '7-8',
    time: '19:00-20:40',
  ),
  _CourseItem(
    courseName: '数据库系统原理',
    courseCode: 'CS312',
    location: '计算机楼101',
    weekday: 4,
    period: '3-4',
    time: '10:00-11:40',
  ),
  _CourseItem(
    courseName: '计算机网络',
    courseCode: 'CS308',
    location: '计算机楼202',
    weekday: 5,
    period: '5-6',
    time: '14:00-15:40',
  ),
];

// ---------------------------------------------------------------------------
// 节次↔时间 映射
// ---------------------------------------------------------------------------
const _periodTimeMap = {
  '1-2': '08:00-09:40',
  '3-4': '10:00-11:40',
  '5-6': '14:00-15:40',
  '7-8': '19:00-20:40',
};

// 星期几中文名
const _weekdayLabels = ['一', '二', '三', '四', '五'];

String _weekdayText(int weekday) {
  if (weekday >= 1 && weekday <= 5) return '周${_weekdayLabels[weekday - 1]}';
  return '周$weekday';
}

// ---------------------------------------------------------------------------
// 状态管理 Providers
// ---------------------------------------------------------------------------

/// 当前选中的课程索引
final _selectedCourseIndexProvider = StateProvider<int?>((ref) => null);

/// 申请类型：'time' 或 'room'
final _applyTypeProvider = StateProvider<String>((ref) => 'time');

/// 换时间 - 目标周次
final _selectedWeekProvider = StateProvider<int?>((ref) => null);

/// 换时间 - 目标周几
final _selectedWeekdayProvider = StateProvider<int?>((ref) => null);

/// 换时间 - 目标节次
final _selectedPeriodProvider = StateProvider<String?>((ref) => null);

/// 记录列表筛选状态
final _recordFilterProvider = StateProvider<String>((ref) => 'all');

/// 调课申请记录列表（从 Supabase 拉取）
final _rescheduleListProvider =
    FutureProvider<List<RescheduleApplication>>((ref) async {
  final supabase = Supabase.instance.client;
  final currentUser = supabase.auth.currentUser;
  if (currentUser == null) return [];

  try {
    final response = await supabase
        .from('reschedule_applications')
        .select()
        .eq('teacher_id', currentUser.id)
        .order('created_at', ascending: false);

    return (response as List)
        .map((item) =>
            RescheduleApplication.fromJson(item as Map<String, dynamic>))
        .toList();
  } catch (e) {
    debugPrint('拉取调课申请列表失败: $e');
    return [];
  }
});

// ---------------------------------------------------------------------------
// 主页面
// ---------------------------------------------------------------------------
class RescheduleApplyPage extends ConsumerStatefulWidget {
  const RescheduleApplyPage({super.key});

  @override
  ConsumerState<RescheduleApplyPage> createState() =>
      _RescheduleApplyPageState();
}

class _RescheduleApplyPageState extends ConsumerState<RescheduleApplyPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('调课申请', style: AppTextStyles.titleLarge),
        backgroundColor: AppColors.surface,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.textPrimary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 2.5,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: AppTextStyles.titleMedium,
          unselectedLabelStyle: AppTextStyles.bodyMedium,
          tabs: const [
            Tab(text: '发起申请'),
            Tab(text: '申请记录'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ApplyFormTab(tabController: _tabController),
          _RecordListTab(),
        ],
      ),
    );
  }
}

// ===========================================================================
// Tab1：发起申请
// ===========================================================================
class _ApplyFormTab extends ConsumerStatefulWidget {
  const _ApplyFormTab({required this.tabController});

  final TabController tabController;

  @override
  ConsumerState<_ApplyFormTab> createState() => _ApplyFormTabState();
}

class _ApplyFormTabState extends ConsumerState<_ApplyFormTab> {
  final _reasonController = TextEditingController();
  final _newLocationController = TextEditingController();
  final _weekController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reasonController.dispose();
    _newLocationController.dispose();
    _weekController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(_selectedCourseIndexProvider);
    final applyType = ref.watch(_applyTypeProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- 课程选择区 ----
          _CourseSelector(
            selectedIndex: selectedIndex,
            onSelect: (index) {
              ref.read(_selectedCourseIndexProvider.notifier).state = index;
            },
          ),
          const SizedBox(height: 24),

          // ---- 申请类型选择 ----
          _buildSectionLabel('申请类型'),
          const SizedBox(height: 8),
          _ApplyTypeBar(
            selected: applyType,
            onSelect: (type) {
              ref.read(_applyTypeProvider.notifier).state = type;
            },
          ),
          const SizedBox(height: 24),

          // ---- 调整信息填写区 ----
          _buildSectionLabel('调整信息'),
          const SizedBox(height: 8),
          if (applyType == 'time')
            _TimeAdjustForm(weekController: _weekController)
          else
            _RoomAdjustForm(controller: _newLocationController),
          const SizedBox(height: 24),

          // ---- 申请原因 ----
          _buildSectionLabel('申请原因'),
          const SizedBox(height: 8),
          _buildReasonField(),
          const SizedBox(height: 32),

          // ---- 提交按钮 ----
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isSubmitting ? null : _handleSubmit,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.greyLight,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                  : Text(
                      '提交申请',
                      style: AppTextStyles.button.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ---- 区域标题 ----
  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: AppTextStyles.titleMedium.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
      ),
    );
  }

  // ---- 申请原因输入框 ----
  Widget _buildReasonField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.greyLight, width: 0.5),
      ),
      child: TextField(
        controller: _reasonController,
        maxLines: 4,
        maxLength: 150,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: '请简要说明调课原因（选填）',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textDisabled,
          ),
          contentPadding: const EdgeInsets.all(16),
          border: InputBorder.none,
          counterStyle: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  // ---- 提交逻辑 ----
  Future<void> _handleSubmit() async {
    final selectedIndex = ref.read(_selectedCourseIndexProvider);
    final applyType = ref.read(_applyTypeProvider);

    // 校验：必须选择课程
    if (selectedIndex == null) {
      _showSnackBar('请先选择一门课程');
      return;
    }

    final course = _mockCourses[selectedIndex];

    // 校验：换时间时必须填写完整的调整信息
    if (applyType == 'time') {
      final weekText = _weekController.text.trim();
      final weekday = ref.read(_selectedWeekdayProvider);
      final period = ref.read(_selectedPeriodProvider);

      if (weekText.isEmpty) {
        _showSnackBar('请输入调整目标周次');
        return;
      }
      final week = int.tryParse(weekText);
      if (week == null || week < 1 || week > 18) {
        _showSnackBar('周次必须在 1-18 之间');
        return;
      }
      if (weekday == null) {
        _showSnackBar('请选择调整到周几');
        return;
      }
      if (period == null) {
        _showSnackBar('请选择调整到第几节');
        return;
      }
    }

    // 校验：换教室时必须填写新教室
    if (applyType == 'room') {
      if (_newLocationController.text.trim().isEmpty) {
        _showSnackBar('请输入新教室');
        return;
      }
    }

    setState(() => _isSubmitting = true);

    try {
      final supabase = Supabase.instance.client;
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        _showSnackBar('请先登录');
        return;
      }

      // 获取教师姓名
      String teacherName = '';
      try {
        final userRes = await supabase
            .from('users')
            .select('name')
            .eq('id', currentUser.id)
            .maybeSingle();
        teacherName = userRes?['name']?.toString() ?? '';
      } catch (_) {}

      // 构建新调整信息
      int? newWeekday;
      String? newPeriod;
      String? newTime;
      String? newLocation;
      int? targetWeek;

      if (applyType == 'time') {
        newWeekday = ref.read(_selectedWeekdayProvider);
        newPeriod = ref.read(_selectedPeriodProvider);
        newTime = _periodTimeMap[newPeriod];
        targetWeek = int.tryParse(_weekController.text.trim());
      } else {
        newLocation = _newLocationController.text.trim();
      }

      final data = {
        'teacher_id': currentUser.id,
        'teacher_name': teacherName,
        'course_name': course.courseName,
        'course_code': course.courseCode,
        'original_weekday': course.weekday,
        'original_period': course.period,
        'original_time': course.time,
        'original_location': course.location,
        'original_week': targetWeek,
        'apply_type': applyType,
        'new_weekday': newWeekday,
        'new_period': newPeriod,
        'new_time': newTime,
        'new_location': newLocation,
        'reason': _reasonController.text.trim().isEmpty
            ? null
            : _reasonController.text.trim(),
        'status': 'pending',
      };

      await supabase.from('reschedule_applications').insert(data);

      if (!mounted) return;
      _showSnackBar('申请已提交，等待审核', isSuccess: true);

      // 重置表单状态
      _resetForm();

      // 刷新申请记录列表并切换到 Tab2
      ref.invalidate(_rescheduleListProvider);
      widget.tabController.animateTo(1);
    } catch (e) {
      debugPrint('提交调课申请失败: $e');
      if (mounted) {
        _showSnackBar('提交失败：${e.toString()}');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  /// 重置表单
  void _resetForm() {
    ref.read(_selectedCourseIndexProvider.notifier).state = null;
    ref.read(_applyTypeProvider.notifier).state = 'time';
    ref.read(_selectedWeekProvider.notifier).state = null;
    ref.read(_selectedWeekdayProvider.notifier).state = null;
    ref.read(_selectedPeriodProvider.notifier).state = null;
    _reasonController.clear();
    _newLocationController.clear();
    _weekController.clear();
  }

  void _showSnackBar(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}

// ===========================================================================
// 课程选择器
// ===========================================================================
class _CourseSelector extends StatelessWidget {
  const _CourseSelector({
    required this.selectedIndex,
    required this.onSelect,
  });

  final int? selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final selected =
        selectedIndex != null ? _mockCourses[selectedIndex!] : null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.greyLight, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '选择课程',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          // 横向滚动的课程 Chip 列表
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_mockCourses.length, (index) {
                final course = _mockCourses[index];
                final isSelected = selectedIndex == index;
                return Padding(
                  padding: EdgeInsets.only(
                    right: index == _mockCourses.length - 1 ? 0 : 8,
                  ),
                  child: GestureDetector(
                    onTap: () => onSelect(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.greyLight,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${course.courseName} ${course.period}节',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: isSelected
                              ? AppColors.white
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          // 选中课程后展示原课程信息
          if (selected != null) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(
                height: 1,
                thickness: 0.5,
                color: AppColors.greyLight,
              ),
            ),
            _buildInfoRow(
              Icons.book_outlined,
              '课程名称',
              '${selected.courseName}（${selected.courseCode}）',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.location_on_outlined,
              '教室',
              selected.location,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.access_time_rounded,
              '时间',
              '${_weekdayText(selected.weekday)} 第${selected.period}节 '
                  '${selected.time}',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          '$label：',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

// ===========================================================================
// 申请类型选择栏
// ===========================================================================
class _ApplyTypeBar extends StatelessWidget {
  const _ApplyTypeBar({
    required this.selected,
    required this.onSelect,
  });

  final String selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildChip('time', '换时间', Icons.schedule_rounded),
        const SizedBox(width: 12),
        _buildChip('room', '换教室', Icons.meeting_room_outlined),
      ],
    );
  }

  Widget _buildChip(String type, String label, IconData icon) {
    final isActive = selected == type;
    return GestureDetector(
      onTap: () => onSelect(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.greyLight,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? AppColors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: isActive ? AppColors.white : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// 换时间表单
// ===========================================================================
class _TimeAdjustForm extends ConsumerWidget {
  const _TimeAdjustForm({required this.weekController});

  final TextEditingController weekController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedWeekday = ref.watch(_selectedWeekdayProvider);
    final selectedPeriod = ref.watch(_selectedPeriodProvider);

    // 自动推算时间
    final autoTime = selectedPeriod != null ? _periodTimeMap[selectedPeriod] : null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.greyLight, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- 目标周次 ----
          Text(
            '调整到第几周',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: weekController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: '请输入周次（1-18）',
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textDisabled,
              ),
              filled: true,
              fillColor: AppColors.background,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ---- 目标周几 ----
          Text(
            '调整到周几',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (index) {
              final day = index + 1;
              final isActive = selectedWeekday == day;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    ref.read(_selectedWeekdayProvider.notifier).state = day;
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: EdgeInsets.only(right: index < 4 ? 8 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primary
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _weekdayLabels[index],
                      style: AppTextStyles.labelMedium.copyWith(
                        color: isActive
                            ? AppColors.white
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),

          // ---- 目标节次 ----
          Text(
            '调整到第几节',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _periodTimeMap.keys.map((period) {
              final isActive = selectedPeriod == period;
              return GestureDetector(
                onTap: () {
                  ref.read(_selectedPeriodProvider.notifier).state = period;
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primary
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$period节',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: isActive
                          ? AppColors.white
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          // ---- 自动推算时间（只读展示） ----
          if (autoTime != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: AppColors.primary.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '对应时间：$autoTime',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ===========================================================================
// 换教室表单
// ===========================================================================
class _RoomAdjustForm extends StatelessWidget {
  const _RoomAdjustForm({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.greyLight, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '新教室',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: '请输入新教室，如计算机楼 202',
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textDisabled,
              ),
              prefixIcon: const Icon(
                Icons.meeting_room_outlined,
                size: 20,
                color: AppColors.textSecondary,
              ),
              filled: true,
              fillColor: AppColors.background,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// Tab2：申请记录
// ===========================================================================
class _RecordListTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncList = ref.watch(_rescheduleListProvider);
    final filter = ref.watch(_recordFilterProvider);

    return Column(
      children: [
        // ---- 状态筛选栏 ----
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(
            children: [
              _buildFilterChip(ref, 'all', '全部', filter),
              const SizedBox(width: 8),
              _buildFilterChip(ref, 'pending', '待审核', filter),
              const SizedBox(width: 8),
              _buildFilterChip(ref, 'done', '已处理', filter),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ---- 列表内容 ----
        Expanded(
          child: asyncList.when(
            loading: () => const Center(child: CampusLoading()),
            error: (error, _) => Center(
              child: CampusEmptyState(
                icon: Icons.error_outline_rounded,
                title: '加载失败',
                subtitle: error.toString(),
                buttonText: '重试',
                onButtonTap: () => ref.invalidate(_rescheduleListProvider),
              ),
            ),
            data: (allRecords) {
              // 根据筛选条件过滤
              final records = allRecords.where((r) {
                if (filter == 'pending') return r.status == 'pending';
                if (filter == 'done') {
                  return r.status == 'approved' || r.status == 'rejected';
                }
                return true; // 'all'
              }).toList();

              if (records.isEmpty) {
                return const Center(
                  child: CampusEmptyState(
                    icon: Icons.assignment_outlined,
                    title: '暂无申请记录',
                    subtitle: '点击「发起申请」提交调课需求',
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(_rescheduleListProvider);
                  // 等待新数据加载
                  await ref.read(_rescheduleListProvider.future);
                },
                color: AppColors.primary,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                  itemCount: records.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _RecordCard(record: records[index]);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(
    WidgetRef ref,
    String value,
    String label,
    String current,
  ) {
    final isActive = current == value;
    return GestureDetector(
      onTap: () => ref.read(_recordFilterProvider.notifier).state = value,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.greyLight,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: isActive ? AppColors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// 申请记录卡片
// ===========================================================================
class _RecordCard extends StatelessWidget {
  const _RecordCard({required this.record});

  final RescheduleApplication record;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.greyLight, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- 顶部一行：课程名 + 状态标签 ----
          Row(
            children: [
              Expanded(
                child: Text(
                  record.courseName,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _StatusChip(status: record.status),
            ],
          ),
          const SizedBox(height: 12),

          // ---- 申请类型标签 ----
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: record.applyType == 'time'
                  ? AppColors.campusOrange.withValues(alpha: 0.1)
                  : AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              record.applyType == 'time' ? '换时间' : '换教室',
              style: AppTextStyles.labelSmall.copyWith(
                color: record.applyType == 'time'
                    ? AppColors.campusOrange
                    : AppColors.info,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ---- 原 → 新 信息对比 ----
          Row(
            children: [
              // 原信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '原课程',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textDisabled,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      record.applyType == 'time'
                          ? '${_weekdayText(record.originalWeekday)} 第${record.originalPeriod}节'
                          : record.originalLocation,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              // 箭头
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 18,
                  color: AppColors.textDisabled,
                ),
              ),
              // 新信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '调整后',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textDisabled,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      record.applyType == 'time'
                          ? '${record.newWeekday != null ? _weekdayText(record.newWeekday!) : '-'} '
                              '第${record.newPeriod ?? '-'}节'
                          : record.newLocation ?? '-',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ---- 申请时间 ----
          Text(
            '申请于 ${_formatDate(record.createdAt)}',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),

          // ---- 审核信息（仅已审核时展示） ----
          if (record.status == 'approved' || record.status == 'rejected') ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(
                height: 1,
                thickness: 0.5,
                color: AppColors.greyLight,
              ),
            ),
            if (record.adminComment != null &&
                record.adminComment!.isNotEmpty) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.comment_outlined,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '审核意见：${record.adminComment}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
            ],
            if (record.reviewedAt != null)
              Text(
                '审核于 ${_formatDate(record.reviewedAt!)}',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textDisabled,
                ),
              ),
          ],
        ],
      ),
    );
  }

  /// 格式化日期：yyyy-MM-dd HH:mm
  String _formatDate(DateTime dt) {
    final d = dt.toLocal();
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')} '
        '${d.hour.toString().padLeft(2, '0')}:'
        '${d.minute.toString().padLeft(2, '0')}';
  }
}

// ===========================================================================
// 状态标签
// ===========================================================================
class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case 'approved':
        bgColor = AppColors.success.withValues(alpha: 0.1);
        textColor = AppColors.success;
        label = '已通过';
        break;
      case 'rejected':
        bgColor = AppColors.error.withValues(alpha: 0.1);
        textColor = AppColors.error;
        label = '已拒绝';
        break;
      case 'pending':
      default:
        bgColor = AppColors.campusOrange.withValues(alpha: 0.1);
        textColor = AppColors.campusOrange;
        label = '待审核';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
