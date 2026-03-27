import 'dart:async';
import '../../components/campus_snackbar.dart';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../components/campus_empty_state.dart';
import '../../components/campus_loading.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

// ---------------------------------------------------------------------------
// 数据模型
// ---------------------------------------------------------------------------

/// 签到会话
class AttendanceSession {
  const AttendanceSession({
    required this.id,
    required this.teacherId,
    required this.courseName,
    required this.courseCode,
    required this.classNames,
    required this.checkInCode,
    required this.status,
    required this.durationMinutes,
    required this.startedAt,
    this.endedAt,
  });

  factory AttendanceSession.fromJson(Map<String, dynamic> json) {
    return AttendanceSession(
      id: json['id'] as String,
      teacherId: json['teacher_id'] as String,
      courseName: json['course_name'] as String,
      courseCode: json['course_code'] as String? ?? '',
      classNames: json['class_names'] as String? ?? '',
      checkInCode: json['check_in_code'] as String,
      status: json['status'] as String? ?? 'active',
      durationMinutes: json['duration_minutes'] as int? ?? 5,
      startedAt: DateTime.parse(json['started_at'] as String),
      endedAt: json['ended_at'] != null
          ? DateTime.parse(json['ended_at'] as String)
          : null,
    );
  }

  final String id;
  final String teacherId;
  final String courseName;
  final String courseCode;
  final String classNames;
  final String checkInCode;
  final String status; // 'active' / 'ended'
  final int durationMinutes;
  final DateTime startedAt;
  final DateTime? endedAt;
}

/// 签到记录
class AttendanceRecord {
  const AttendanceRecord({
    required this.id,
    required this.sessionId,
    required this.studentName,
    required this.studentNo,
    required this.checkedInAt,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'] as String,
      sessionId: json['session_id'] as String,
      studentName: json['student_name'] as String? ?? '',
      studentNo: json['student_no'] as String? ?? '',
      checkedInAt: DateTime.parse(json['checked_in_at'] as String),
    );
  }

  final String id;
  final String sessionId;
  final String studentName;
  final String studentNo;
  final DateTime checkedInAt;
}

// ---------------------------------------------------------------------------
// 课程数据模型（简化版，复用教学日历数据）
// ---------------------------------------------------------------------------
class _CourseItem {
  const _CourseItem({
    required this.courseName,
    required this.courseCode,
    required this.classNames,
    required this.location,
    required this.weekday,
    required this.period,
    required this.classId,
  });

  final String courseName;
  final String courseCode;
  final String classNames;
  final String location;
  final int weekday;
  final String period;
  final String classId;
}

// 虚拟课程数据（与教学日历7条课程一致）
const _mockCourses = [
  _CourseItem(
    courseName: '数据结构',
    courseCode: 'CS301',
    classNames: '22级计算机1、2班',
    location: '计算机楼101',
    weekday: 1,
    period: '1-2',
    classId: '11111111-0001-0000-0000-000000000000',
  ),
  _CourseItem(
    courseName: '算法设计与分析',
    courseCode: 'CS402',
    classNames: '22级网络工程1班',
    location: '计算机楼203',
    weekday: 1,
    period: '5-6',
    classId: '11111111-0001-0000-0000-000000000000',
  ),
  _CourseItem(
    courseName: '数据库系统原理',
    courseCode: 'CS312',
    classNames: '23级软工1、2班',
    location: '计算机楼101',
    weekday: 2,
    period: '3-4',
    classId: '11111111-0001-0000-0000-000000000000',
  ),
  _CourseItem(
    courseName: '数据结构',
    courseCode: 'CS301',
    classNames: '22级计算机1、2班',
    location: '计算机楼101',
    weekday: 3,
    period: '1-2',
    classId: '11111111-0001-0000-0000-000000000000',
  ),
  _CourseItem(
    courseName: '操作系统',
    courseCode: 'CS305',
    classNames: '22级计算机1班',
    location: '计算机楼305',
    weekday: 3,
    period: '7-8',
    classId: '11111111-0001-0000-0000-000000000000',
  ),
  _CourseItem(
    courseName: '数据库系统原理',
    courseCode: 'CS312',
    classNames: '23级软工1、2班',
    location: '计算机楼101',
    weekday: 4,
    period: '3-4',
    classId: '11111111-0001-0000-0000-000000000000',
  ),
  _CourseItem(
    courseName: '计算机网络',
    courseCode: 'CS308',
    classNames: '23级软工2班',
    location: '计算机楼202',
    weekday: 5,
    period: '5-6',
    classId: '11111111-0001-0000-0000-000000000000',
  ),
];

// ---------------------------------------------------------------------------
// 班级学生虚拟数据（22级计算机1班，20名学生）
// 用于签到结果页面计算未签到名单
// ---------------------------------------------------------------------------
class _MockStudent {
  const _MockStudent(this.name, this.studentNo);
  final String name;
  final String studentNo;
}

// ---------------------------------------------------------------------------
// 签到码生成（去除易混淆字符 0OI1）
// ---------------------------------------------------------------------------
String generateCheckInCode() {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  final random = Random();
  return List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
}

// ---------------------------------------------------------------------------
// 签到流程状态
// ---------------------------------------------------------------------------
enum AttendanceFlowState { idle, active, result }

// ---------------------------------------------------------------------------
// 状态管理 Providers
// ---------------------------------------------------------------------------

/// 签到流程状态
final _attendanceFlowProvider =
    StateProvider<AttendanceFlowState>((ref) => AttendanceFlowState.idle);

/// 当前进行中的签到会话
final _activeSessionProvider =
    StateProvider<AttendanceSession?>((ref) => null);

/// 已签到记录列表（实时轮询更新）
final _checkedInRecordsProvider =
    StateProvider<List<AttendanceRecord>>((ref) => []);

/// 选中的课程索引
final _selectedCourseIndexProvider = StateProvider<int?>((ref) => null);

/// 选中的签到时限（分钟）
final _selectedDurationProvider = StateProvider<int>((ref) => 5);

/// 当前进行的签到的全部学生（从数据库拉取）
final _currentSessionStudentsProvider =
    StateProvider<List<_MockStudent>>((ref) => []);

/// 历史签到列表
final _attendanceHistoryProvider =
    FutureProvider<List<AttendanceSession>>((ref) async {
  final supabase = Supabase.instance.client;
  final currentUser = supabase.auth.currentUser;
  if (currentUser == null) return [];

  try {
    final response = await supabase
        .from('attendance_sessions')
        .select()
        .eq('teacher_id', currentUser.id)
        .order('started_at', ascending: false);

    return (response as List)
        .map((item) =>
            AttendanceSession.fromJson(item as Map<String, dynamic>))
        .toList();
  } catch (e) {
    debugPrint('拉取签到历史失败: $e');
    return [];
  }
});

// ---------------------------------------------------------------------------
// 主页面
// ---------------------------------------------------------------------------
class AttendancePage extends ConsumerStatefulWidget {
  const AttendancePage({super.key});

  @override
  ConsumerState<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends ConsumerState<AttendancePage>
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
        title: Text('课堂签到', style: AppTextStyles.titleMedium),
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
            Tab(text: '发起签到'),
            Tab(text: '历史记录'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _CheckInTab(tabController: _tabController),
          const _HistoryTab(),
        ],
      ),
    );
  }
}

// ===========================================================================
// Tab1：发起签到（包含 idle / active / result 三种状态）
// ===========================================================================
class _CheckInTab extends ConsumerStatefulWidget {
  const _CheckInTab({required this.tabController});

  final TabController tabController;

  @override
  ConsumerState<_CheckInTab> createState() => _CheckInTabState();
}

class _CheckInTabState extends ConsumerState<_CheckInTab> {
  Timer? _countdownTimer;
  Timer? _pollTimer;
  int _remainingSeconds = 0;

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _pollTimer?.cancel();
    super.dispose();
  }

  // ---- 开始倒计时 ----
  void _startCountdown(int durationMinutes) {
    _remainingSeconds = durationMinutes * 60;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 0) {
        timer.cancel();
        _endSession();
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  // ---- 开始轮询签到人数 ----
  void _startPolling(String sessionId) {
    // 立即拉取一次
    _fetchRecords(sessionId);
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _fetchRecords(sessionId);
    });
  }

  // ---- 从 Supabase 拉取签到记录 ----
  Future<void> _fetchRecords(String sessionId) async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('attendance_records')
          .select()
          .eq('session_id', sessionId)
          .order('checked_in_at', ascending: true);

      final records = (response as List)
          .map((item) =>
              AttendanceRecord.fromJson(item as Map<String, dynamic>))
          .toList();

      if (mounted) {
        ref.read(_checkedInRecordsProvider.notifier).state = records;
      }
    } catch (e) {
      debugPrint('轮询签到记录失败: $e');
    }
  }

  // ---- 发起签到 ----
  Future<void> _startSession() async {
    final courseIndex = ref.read(_selectedCourseIndexProvider);
    if (courseIndex == null) return;

    final course = _mockCourses[courseIndex];
    final duration = ref.read(_selectedDurationProvider);
    final code = generateCheckInCode();

    try {
      final supabase = Supabase.instance.client;
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        _showSnackBar('请先登录');
        return;
      }

      final response = await supabase.from('attendance_sessions').insert({
        'teacher_id': currentUser.id,
        'course_name': course.courseName,
        'course_code': course.courseCode,
        'class_names': course.classNames,
        'check_in_code': code,
        'status': 'active',
        'duration_minutes': duration,
        'started_at': DateTime.now().toUtc().toIso8601String(),
      }).select().single();

      final session =
          AttendanceSession.fromJson(response);

      // 更新状态
      ref.read(_activeSessionProvider.notifier).state = session;
      ref.read(_checkedInRecordsProvider.notifier).state = [];
      ref.read(_attendanceFlowProvider.notifier).state =
          AttendanceFlowState.active;

      // 获取这门课的全部学生数据（班级名册）
      try {
        final res = await supabase
            .from('students')
            .select()
            .eq('class_id', course.classId)
            .order('student_no');
        
        final studentList = (res as List)
            .map((item) => _MockStudent(
                  item['name']?.toString() ?? '未知',
                  item['student_no']?.toString() ?? '未知',
                ))
            .toList();
        
        ref.read(_currentSessionStudentsProvider.notifier).state = studentList;
      } catch (e) {
        debugPrint('获取班级名册数据失败: $e');
        // 遇到异常设为空数组，不阻碍签到流程
        ref.read(_currentSessionStudentsProvider.notifier).state = [];
      }

      // 启动倒计时和轮询
      _startCountdown(duration);
      _startPolling(session.id);
    } catch (e) {
      debugPrint('发起签到失败: $e');
      _showSnackBar('发起签到失败：${e.toString()}');
    }
  }

  // ---- 结束签到 ----
  Future<void> _endSession() async {
    _countdownTimer?.cancel();
    _pollTimer?.cancel();

    final session = ref.read(_activeSessionProvider);
    if (session == null) return;

    try {
      final supabase = Supabase.instance.client;
      await supabase.from('attendance_sessions').update({
        'status': 'ended',
        'ended_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', session.id);

      // 最后拉取一次签到记录确保数据最新
      await _fetchRecords(session.id);

      if (mounted) {
        ref.read(_attendanceFlowProvider.notifier).state =
            AttendanceFlowState.result;
      }
    } catch (e) {
      debugPrint('结束签到失败: $e');
      if (mounted) _showSnackBar('结束签到失败');
    }
  }

  // ---- 完成并回到 idle ----
  void _finishAndReset() {
    ref.read(_attendanceFlowProvider.notifier).state =
        AttendanceFlowState.idle;
    ref.read(_activeSessionProvider.notifier).state = null;
    ref.read(_checkedInRecordsProvider.notifier).state = [];
    ref.read(_selectedCourseIndexProvider.notifier).state = null;
    ref.read(_currentSessionStudentsProvider.notifier).state = [];
    // 刷新历史记录
    ref.invalidate(_attendanceHistoryProvider);
  }

  void _showSnackBar(String message, {bool isSuccess = false}) {
    if (!mounted) return;
    CampusSnackBar.show(context, message: message, isError: true);
  }

  @override
  Widget build(BuildContext context) {
    final flowState = ref.watch(_attendanceFlowProvider);

    switch (flowState) {
      case AttendanceFlowState.idle:
        return _buildIdleView();
      case AttendanceFlowState.active:
        return _buildActiveView();
      case AttendanceFlowState.result:
        return _buildResultView();
    }
  }

  // ====================
  // 状态A: idle - 发起签到
  // ====================
  Widget _buildIdleView() {
    final courseIndex = ref.watch(_selectedCourseIndexProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 课程选择区
          _CourseSelector(
            selectedIndex: courseIndex,
            onSelect: (index) {
              ref.read(_selectedCourseIndexProvider.notifier).state = index;
            },
          ),
          const SizedBox(height: 24),

          // 签到时限选择
          _buildSectionLabel('签到时限'),
          const SizedBox(height: 8),
          _DurationSelector(
            selected: ref.watch(_selectedDurationProvider),
            onSelect: (value) {
              ref.read(_selectedDurationProvider.notifier).state = value;
            },
          ),
          const SizedBox(height: 32),

          // 发起按钮
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: courseIndex != null ? _startSession : null,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.greyLight,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                '发起签到',
                style: AppTextStyles.button.copyWith(
                  color: courseIndex != null
                      ? AppColors.white
                      : AppColors.textDisabled,
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

  // ==========================
  // 状态B: active - 签到进行中
  // ==========================
  Widget _buildActiveView() {
    final session = ref.watch(_activeSessionProvider);
    final records = ref.watch(_checkedInRecordsProvider);
    final allStudents = ref.watch(_currentSessionStudentsProvider);
    if (session == null) return const SizedBox.shrink();

    final totalStudents = allStudents.length;
    final checkedCount = records.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        children: [
          // ---- 课程信息 ----
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.courseName,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      session.classNames,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '进行中',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // ---- 签到码展示 ----
          _CheckInCodeDisplay(code: session.checkInCode),
          const SizedBox(height: 32),

          // ---- 倒计时环形进度 ----
          _CountdownRing(
            remainingSeconds: _remainingSeconds,
            totalSeconds: session.durationMinutes * 60,
          ),
          const SizedBox(height: 32),

          // ---- 实时签到人数 ----
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.greyLight, width: 0.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '已签到 ',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '$checkedCount',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  ' / 总人数 $totalStudents',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // ---- 结束签到按钮 ----
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _endSession,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error, width: 1),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                '结束签到',
                style: AppTextStyles.button.copyWith(
                  color: AppColors.error,
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

  // ==========================
  // 状态C: result - 签到结果
  // ==========================
  Widget _buildResultView() {
    final records = ref.watch(_checkedInRecordsProvider);
    final allStudents = ref.watch(_currentSessionStudentsProvider);
    final checkedNos =
        records.map((r) => r.studentNo).toSet();
    final totalStudents = allStudents.length;
    final checkedCount = records.length;
    final uncheckedCount = totalStudents - checkedCount;
    final rate = totalStudents > 0
        ? (checkedCount / totalStudents * 100).toStringAsFixed(1)
        : '0.0';

    // 分组：已签到和未签到
    final uncheckedStudents = allStudents
        .where((s) => !checkedNos.contains(s.studentNo))
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- 结果概览卡片 ----
          _AttendanceResultCard(
            checkedCount: checkedCount,
            uncheckedCount: uncheckedCount,
            rate: rate,
          ),
          const SizedBox(height: 24),

          // ---- 已签到学生列表 ----
          if (records.isNotEmpty) ...[
            _buildSectionLabel('已签到（${records.length}人）'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.greyLight, width: 0.5),
              ),
              child: Column(
                children: [
                  for (int i = 0; i < records.length; i++) ...[
                    _buildStudentRow(
                      name: records[i].studentName,
                      studentNo: records[i].studentNo,
                      trailing: Text(
                        _formatTime(records[i].checkedInAt),
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    if (i < records.length - 1)
                      const Divider(
                        height: 1,
                        thickness: 0.5,
                        color: AppColors.greyLight,
                        indent: 56,
                      ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // ---- 未签到学生列表 ----
          if (uncheckedStudents.isNotEmpty) ...[
            _buildSectionLabel('未签到（${uncheckedStudents.length}人）'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.greyLight, width: 0.5),
              ),
              child: Column(
                children: [
                  for (int i = 0; i < uncheckedStudents.length; i++) ...[
                    _buildStudentRow(
                      name: uncheckedStudents[i].name,
                      studentNo: uncheckedStudents[i].studentNo,
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '缺席',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    if (i < uncheckedStudents.length - 1)
                      const Divider(
                        height: 1,
                        thickness: 0.5,
                        color: AppColors.greyLight,
                        indent: 56,
                      ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // ---- 完成按钮 ----
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _finishAndReset,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                '完成',
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

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: AppTextStyles.titleMedium.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildStudentRow({
    required String name,
    required String studentNo,
    required Widget trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Text(
              name.isNotEmpty ? name.characters.first : '?',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  studentNo,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final d = dt.toLocal();
    return '${d.hour.toString().padLeft(2, '0')}:'
        '${d.minute.toString().padLeft(2, '0')}:'
        '${d.second.toString().padLeft(2, '0')}';
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
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          // 横向滚动课程 Chip
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

          // 选中课程后展示课程信息
          if (selected != null) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(
                height: 1,
                thickness: 0.5,
                color: AppColors.greyLight,
              ),
            ),
            _buildInfoRow(Icons.book_outlined, selected.courseName),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.people_outline_rounded, selected.classNames),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.location_on_outlined, selected.location),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
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

// ===========================================================================
// 签到时限选择器
// ===========================================================================
class _DurationSelector extends StatelessWidget {
  const _DurationSelector({
    required this.selected,
    required this.onSelect,
  });

  final int selected;
  final ValueChanged<int> onSelect;

  static const _options = [3, 5, 10, 20];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _options.map((minutes) {
        final isActive = selected == minutes;
        return Padding(
          padding: EdgeInsets.only(
            right: minutes == _options.last ? 0 : 8,
          ),
          child: GestureDetector(
            onTap: () => onSelect(minutes),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : AppColors.greyLight,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$minutes分钟',
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
      }).toList(),
    );
  }
}

// ===========================================================================
// 签到码展示区
// ===========================================================================
class _CheckInCodeDisplay extends StatelessWidget {
  const _CheckInCodeDisplay({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.greyLight, width: 0.5),
      ),
      child: Column(
        children: [
          Text(
            '签到码',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            code,
            style: AppTextStyles.titleLarge.copyWith(
              fontSize: 56,
              fontWeight: FontWeight.w300,
              color: AppColors.primary,
              letterSpacing: 12,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '请让学生输入此签到码完成签到',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// 倒计时环形进度条
// ===========================================================================
class _CountdownRing extends StatelessWidget {
  const _CountdownRing({
    required this.remainingSeconds,
    required this.totalSeconds,
  });

  final int remainingSeconds;
  final int totalSeconds;

  @override
  Widget build(BuildContext context) {
    final progress = totalSeconds > 0 ? remainingSeconds / totalSeconds : 0.0;

    // 根据剩余时间选择颜色
    Color ringColor;
    if (remainingSeconds > 60) {
      ringColor = AppColors.success;
    } else if (remainingSeconds > 30) {
      ringColor = AppColors.campusOrange;
    } else {
      ringColor = AppColors.error;
    }

    // 格式化分:秒
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    final timeStr = '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';

    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 背景环
          SizedBox(
            width: 100,
            height: 100,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: 6,
              strokeCap: StrokeCap.round,
              backgroundColor: AppColors.greyLight.withValues(alpha: 0.5),
              color: AppColors.greyLight.withValues(alpha: 0.5),
            ),
          ),
          // 进度环
          SizedBox(
            width: 100,
            height: 100,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 6,
              strokeCap: StrokeCap.round,
              backgroundColor: Colors.transparent,
              color: ringColor,
            ),
          ),
          // 中间文字
          Text(
            timeStr,
            style: AppTextStyles.titleLarge.copyWith(
              color: ringColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// 签到结果概览卡片
// ===========================================================================
class _AttendanceResultCard extends StatelessWidget {
  const _AttendanceResultCard({
    required this.checkedCount,
    required this.uncheckedCount,
    required this.rate,
  });

  final int checkedCount;
  final int uncheckedCount;
  final String rate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.greyLight, width: 0.5),
      ),
      child: Row(
        children: [
          // 已签到
          Expanded(
            child: Column(
              children: [
                Text(
                  '$checkedCount',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '已签到',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // 分割线
          Container(
            width: 1,
            height: 48,
            color: AppColors.greyLight.withValues(alpha: 0.5),
          ),
          // 未签到
          Expanded(
            child: Column(
              children: [
                Text(
                  '$uncheckedCount',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.campusOrange,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '未签到',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // 分割线
          Container(
            width: 1,
            height: 48,
            color: AppColors.greyLight.withValues(alpha: 0.5),
          ),
          // 签到率
          Expanded(
            child: Column(
              children: [
                Text(
                  '$rate%',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '签到率',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// Tab2：历史记录
// ===========================================================================
class _HistoryTab extends ConsumerWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncList = ref.watch(_attendanceHistoryProvider);

    return asyncList.when(
      loading: () => const Center(child: CampusLoading()),
      error: (error, _) => Center(
        child: CampusEmptyState(
          icon: Icons.error_outline_rounded,
          title: '加载失败',
          subtitle: error.toString(),
          buttonText: '重试',
          onButtonTap: () => ref.invalidate(_attendanceHistoryProvider),
        ),
      ),
      data: (sessions) {
        if (sessions.isEmpty) {
          return const Center(
            child: CampusEmptyState(
              icon: Icons.how_to_reg_outlined,
              title: '暂无签到记录',
              subtitle: '发起签到后，记录将显示在这里',
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(_attendanceHistoryProvider);
            await ref.read(_attendanceHistoryProvider.future);
          },
          color: AppColors.primary,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            itemCount: sessions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _HistoryCard(session: sessions[index]);
            },
          ),
        );
      },
    );
  }
}

// ===========================================================================
// 历史记录卡片（可展开）
// ===========================================================================
class _HistoryCard extends ConsumerStatefulWidget {
  const _HistoryCard({required this.session});

  final AttendanceSession session;

  @override
  ConsumerState<_HistoryCard> createState() => _HistoryCardState();
}

class _HistoryCardState extends ConsumerState<_HistoryCard> {
  bool _expanded = false;
  List<AttendanceRecord>? _records;
  bool _loading = false;

  // 点击展开时拉取该会话的签到记录
  Future<void> _toggleExpand() async {
    if (_expanded) {
      setState(() => _expanded = false);
      return;
    }

    if (_records == null) {
      setState(() => _loading = true);
      try {
        final supabase = Supabase.instance.client;
        final response = await supabase
            .from('attendance_records')
            .select()
            .eq('session_id', widget.session.id)
            .order('checked_in_at', ascending: true);

        _records = (response as List)
            .map((item) =>
                AttendanceRecord.fromJson(item as Map<String, dynamic>))
            .toList();
      } catch (e) {
        debugPrint('拉取签到记录详情失败: $e');
        _records = [];
      } finally {
        if (mounted) setState(() => _loading = false);
      }
    }

    setState(() => _expanded = true);
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    final isActive = session.status == 'active';

    return GestureDetector(
      onTap: _toggleExpand,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.greyLight, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---- 顶部：课程名 + 状态标签 ----
            Row(
              children: [
                Expanded(
                  child: Text(
                    session.courseName,
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : AppColors.greyLight,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    isActive ? '进行中' : '已结束',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: isActive
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ---- 卡片信息 ----
            _buildDetailRow('班级', session.classNames),
            const SizedBox(height: 6),
            _buildDetailRow('签到码', session.checkInCode),
            const SizedBox(height: 6),
            _buildDetailRow('时限', '${session.durationMinutes}分钟'),
            const SizedBox(height: 6),
            _buildDetailRow('发起时间', _formatDateTime(session.startedAt)),
            const SizedBox(height: 8),

            // ---- 展开提示 ----
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: AppColors.textDisabled,
                ),
                const SizedBox(width: 4),
                Text(
                  _expanded ? '收起详情' : '查看签到名单',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textDisabled,
                  ),
                ),
              ],
            ),

            // ---- 展开区域：签到名单 ----
            if (_expanded) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(
                  height: 1,
                  thickness: 0.5,
                  color: AppColors.greyLight,
                ),
              ),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              else if (_records != null && _records!.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: Text(
                      '暂无签到记录',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textDisabled,
                      ),
                    ),
                  ),
                )
              else if (_records != null)
                ..._records!.map((record) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor:
                              AppColors.primary.withValues(alpha: 0.1),
                          child: Text(
                            record.studentName.isNotEmpty
                                ? record.studentName.characters.first
                                : '?',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '${record.studentName}（${record.studentNo}）',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          _formatTime(record.checkedInAt),
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 56,
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
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

  String _formatDateTime(DateTime dt) {
    final d = dt.toLocal();
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')} '
        '${d.hour.toString().padLeft(2, '0')}:'
        '${d.minute.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime dt) {
    final d = dt.toLocal();
    return '${d.hour.toString().padLeft(2, '0')}:'
        '${d.minute.toString().padLeft(2, '0')}:'
        '${d.second.toString().padLeft(2, '0')}';
  }
}
