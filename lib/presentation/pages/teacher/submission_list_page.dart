import 'package:flutter/material.dart';
import '../../components/campus_snackbar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../components/campus_empty_state.dart';
import '../../components/campus_loading.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'assignment_page.dart'; // import Assignment model

// ---------------------------------------------------------------------------
// 数据模型
// ---------------------------------------------------------------------------
class Submission {
  const Submission({
    required this.id,
    required this.assignmentId,
    required this.studentId,
    required this.studentName,
    required this.studentNo,
    required this.score,
    required this.comment,
    required this.gradedAt,
    required this.submittedAt,
  });

  final String id;
  final String assignmentId;
  final String studentId;
  final String studentName;
  final String studentNo;
  final double? score; // null = 未批改
  final String? comment;
  final DateTime? gradedAt;
  final DateTime submittedAt;

  factory Submission.fromJson(Map<String, dynamic> json) {
    return Submission(
      id: json['id'] as String,
      assignmentId: json['assignment_id'] as String,
      studentId: json['student_id'] as String,
      studentName: json['student_name'] as String,
      studentNo: json['student_no'] as String,
      score: json['score'] != null ? (json['score'] as num).toDouble() : null,
      comment: json['comment'] as String?,
      gradedAt: json['graded_at'] != null
          ? DateTime.parse(json['graded_at'] as String)
          : null,
      submittedAt: DateTime.parse(json['submitted_at'] as String),
    );
  }
}

class StudentBrief {
  const StudentBrief({
    required this.id,
    required this.studentNo,
    required this.name,
  });

  factory StudentBrief.fromJson(Map<String, dynamic> json) {
    return StudentBrief(
      id: json['id'] as String,
      studentNo: json['student_no'] as String,
      name: json['name'] as String,
    );
  }

  final String id;
  final String studentNo;
  final String name;
}

// ---------------------------------------------------------------------------
// 状态管理
// ---------------------------------------------------------------------------

// 某作业的批改记录（按 assignmentId 拉取）
final submissionsProvider = FutureProvider.family<List<Submission>, String>(
  (ref, assignmentId) async {
    final supabase = Supabase.instance.client;
    try {
      final response = await supabase
          .from('assignment_submissions')
          .select()
          .eq('assignment_id', assignmentId);
      return (response as List).map((e) => Submission.fromJson(e)).toList();
    } catch (e) {
      debugPrint('拉取批改记录失败: $e');
      return [];
    }
  },
);

// 学生列表（全局复用）
final studentsProvider = FutureProvider<List<StudentBrief>>((ref) async {
  final supabase = Supabase.instance.client;
  try {
    final response = await supabase
        .from('students')
        .select('id, student_no, name')
        .eq('class_id', '11111111-0001-0000-0000-000000000000')
        .order('student_no');
    return (response as List).map((e) => StudentBrief.fromJson(e)).toList();
  } catch (e) {
    debugPrint('拉取学生列表失败: $e');
    return [];
  }
});

// 提交列表页的筛选状态 0全部/1已批改/2未批改
final submissionFilterProvider = StateProvider<int>((ref) => 0);

// 批改 BottomSheet 内的分数和评语
final gradingScoreProvider = StateProvider<double?>((ref) => null);
final gradingCommentProvider = StateProvider<String>((ref) => '');

// ---------------------------------------------------------------------------
// 主页面
// ---------------------------------------------------------------------------
class SubmissionListPage extends ConsumerWidget {
  const SubmissionListPage({super.key, required this.assignment});

  final Assignment assignment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              assignment.title,
              style: AppTextStyles.titleMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              assignment.classNames,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        centerTitle: true,
      ),
      body: ref.watch(studentsProvider).when(
            loading: () => const Center(child: CampusLoading()),
            error: (err, _) => Center(child: Text('加载学生数据失败: $err')),
            data: (studentList) {
              return ref.watch(submissionsProvider(assignment.id)).when(
                    loading: () => const Center(child: CampusLoading()),
                    error: (err, _) => Center(child: Text('加载数据失败: $err')),
                    data: (subList) {
                      return _buildBody(context, ref, studentList, subList);
                    },
                  );
            },
          ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref,
      List<StudentBrief> students, List<Submission> submissions) {
    if (students.isEmpty) {
      return const Center(
        child: CampusEmptyState(
          icon: Icons.group_off_rounded,
          title: '班级暂无学生数据',
          subtitle: '无法展示作业批改名单',
        ),
      );
    }

    final totalStudents = students.length;
    int gradedCount = 0;
    int ungradedCount = 0;

    // 构建合并后的列表项目
    final uiItems = <_StudentSubmissionItem>[];

    for (final student in students) {
      // 查找提交记录
      final sub = submissions.where((s) => s.studentId == student.id).firstOrNull;
      final isGraded = sub != null && sub.score != null;
      if (isGraded) {
        gradedCount++;
      } else {
        ungradedCount++;
      }
      uiItems.add(_StudentSubmissionItem(student: student, submission: sub));
    }

    // 计算批改率
    final String rateStr = totalStudents > 0
        ? ((gradedCount / totalStudents) * 100).toStringAsFixed(1)
        : '0.0';

    // 过滤
    final filter = ref.watch(submissionFilterProvider);
    final filteredItems = uiItems.where((item) {
      if (filter == 1) return item.isGraded;
      if (filter == 2) return !item.isGraded;
      return true;
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: _ProgressCard(
            graded: gradedCount,
            ungraded: ungradedCount,
            rate: rateStr,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _FilterTabBar(
            selectedIndex: filter,
            onChanged: (index) {
              ref.read(submissionFilterProvider.notifier).state = index;
            },
          ),
        ),
        Expanded(
          child: filteredItems.isEmpty
              ? const CampusEmptyState(
                  icon: Icons.fact_check_outlined,
                  title: '没有符合条件的记录',
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  itemCount: filteredItems.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    return _StudentSubmissionTile(
                      item: item,
                      onTap: () => _showGradingSheet(context, ref, item),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showGradingSheet(
    BuildContext context,
    WidgetRef ref,
    _StudentSubmissionItem item,
  ) {
    // 每次打开先清空/还原上次的状态
    ref.read(gradingScoreProvider.notifier).state = item.submission?.score;
    ref.read(gradingCommentProvider.notifier).state =
        item.submission?.comment ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: _GradingSheet(assignment: assignment, item: item),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 内部合并数据结构
// ---------------------------------------------------------------------------
class _StudentSubmissionItem {
  _StudentSubmissionItem({required this.student, this.submission});
  final StudentBrief student;
  final Submission? submission;
  bool get isGraded => submission != null && submission!.score != null;
}

// ---------------------------------------------------------------------------
// 进度卡片组件
// ---------------------------------------------------------------------------
class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.graded,
    required this.ungraded,
    required this.rate,
  });

  final int graded;
  final int ungraded;
  final String rate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.greyLight, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatGroup(graded.toString(), '已批改', AppColors.primary),
          Container(width: 1, height: 32, color: AppColors.greyLight),
          _buildStatGroup(ungraded.toString(), '未批改', AppColors.campusOrange),
          Container(width: 1, height: 32, color: AppColors.greyLight),
          _buildStatGroup('$rate%', '批改率', AppColors.success),
        ],
      ),
    );
  }

  Widget _buildStatGroup(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.titleLarge.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 过滤 TabBar
// ---------------------------------------------------------------------------
class _FilterTabBar extends StatelessWidget {
  const _FilterTabBar({required this.selectedIndex, required this.onChanged});

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    const filters = ['全部分配', '已批改', '待批改'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: List.generate(filters.length, (index) {
          final isSelected = selectedIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onChanged(index),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color:
                      isSelected ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: isSelected
                      ? null
                      : Border.all(color: AppColors.greyLight, width: 1),
                ),
                child: Text(
                  filters[index],
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isSelected ? AppColors.white : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 提交列表项
// ---------------------------------------------------------------------------
class _StudentSubmissionTile extends StatelessWidget {
  const _StudentSubmissionTile({required this.item, required this.onTap});

  final _StudentSubmissionItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.greyLight, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: Text(
                item.student.name.isNotEmpty
                    ? item.student.name.substring(0, 1)
                    : '?',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.student.name,
                    style: AppTextStyles.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.student.studentNo,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            _buildStatusTag(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTag() {
    if (item.isGraded) {
      final scoreStr =
          item.submission!.score!.truncateToDouble() == item.submission!.score!
              ? item.submission!.score!.toInt().toString()
              : item.submission!.score!.toStringAsFixed(1);
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '$scoreStr分', // 满足需求「已批改：success浅底绿字 + 分数」
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.success,
          ),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.campusOrange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '待批改',
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.campusOrange,
          ),
        ),
      );
    }
  }
}

// ---------------------------------------------------------------------------
// 批改表单 BottomSheet
// ---------------------------------------------------------------------------
class _GradingSheet extends ConsumerStatefulWidget {
  const _GradingSheet({required this.assignment, required this.item});
  final Assignment assignment;
  final _StudentSubmissionItem item;

  @override
  ConsumerState<_GradingSheet> createState() => _GradingSheetState();
}

class _GradingSheetState extends ConsumerState<_GradingSheet> {
  late final TextEditingController _scoreController;
  late final TextEditingController _commentController;

  @override
  void initState() {
    super.initState();
    final initialScore = ref.read(gradingScoreProvider);
    _scoreController = TextEditingController(
      text: initialScore != null
          ? (initialScore.truncateToDouble() == initialScore
              ? initialScore.toInt().toString()
              : initialScore.toStringAsFixed(1))
          : '',
    );
    _commentController = TextEditingController(
      text: ref.read(gradingCommentProvider),
    );
  }

  @override
  void dispose() {
    _scoreController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitGrading() async {
    final scoreValue = double.tryParse(_scoreController.text.trim());
    if (scoreValue == null) return;
    final commentValue = _commentController.text.trim();

    final supabase = Supabase.instance.client;
    try {
      await supabase.from('assignment_submissions').upsert({
        'assignment_id': widget.assignment.id,
        'student_id': widget.item.student.id,
        'student_name': widget.item.student.name,
        'student_no': widget.item.student.studentNo,
        'score': scoreValue,
        'comment': commentValue.isEmpty ? null : commentValue,
        'graded_at': DateTime.now().toUtc().toIso8601String(),
        'submitted_at': widget.item.submission?.submittedAt.toUtc().toIso8601String() ??
            DateTime.now().toUtc().toIso8601String(),
      }, onConflict: 'assignment_id,student_id');

      if (mounted) {
        // 关闭 BottomSheet
        Navigator.of(context).pop();
        // 弹出成功提示
        CampusSnackBar.show(context, message: '批改成功', isError: false);
      }
      // 刷新外部列表页
      ref.invalidate(submissionsProvider(widget.assignment.id));
      // 也刷新一下作业列表首页进度条缓存
      ref.invalidate(assignmentGradedCountProvider);

    } catch (e) {
      if (mounted) {
        CampusSnackBar.show(context, message: '批改失败: $e', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentScore = ref.watch(gradingScoreProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 顶部拖动条
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
          // 标题与学号
          Text(
            widget.item.student.name,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.item.student.studentNo,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),

          // 分数输入区
          Text('评分', style: AppTextStyles.labelMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [60, 70, 80, 85, 90, 95, 100].map((val) {
              final isSelected = currentScore == val.toDouble();
              return GestureDetector(
                onTap: () {
                  ref.read(gradingScoreProvider.notifier).state =
                      val.toDouble();
                  _scoreController.text = val.toString();
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.greyLight.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    val.toString(),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color:
                          isSelected ? AppColors.white : AppColors.textPrimary,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _scoreController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (val) {
              final valDouble = double.tryParse(val);
              ref.read(gradingScoreProvider.notifier).state = valDouble;
            },
            style: AppTextStyles.bodyMedium,
            decoration: InputDecoration(
              hintText: '手动输入分数 (0-100)',
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textDisabled,
              ),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.greyLight),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.greyLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 评语输入区
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('评语', style: AppTextStyles.labelMedium),
              Consumer(
                builder: (context, ref, _) {
                  final text = ref.watch(gradingCommentProvider);
                  return Text(
                    '${text.length}/100',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _commentController,
            maxLength: 100,
            maxLines: 4,
            onChanged: (val) {
              ref.read(gradingCommentProvider.notifier).state = val;
            },
            style: AppTextStyles.bodyMedium,
            decoration: InputDecoration(
              hintText: '写下对这份作业的评价（选填）',
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textDisabled,
              ),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.greyLight),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.greyLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
              counterText: '',
            ),
          ),
          const SizedBox(height: 32),

          // 提交按钮
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: currentScore == null ? null : _submitGrading,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.greyLight,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                '提交批改',
                style: AppTextStyles.button.copyWith(
                  color: currentScore == null
                      ? AppColors.textDisabled
                      : AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
