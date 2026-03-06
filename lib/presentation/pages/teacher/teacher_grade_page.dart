import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../theme/theme.dart';
import '../../../core/services/grade_service.dart';
import '../../../domain/models/grade.dart';

// ── Provider：学生列表 ──────────────────────────────────────────────
final studentsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) {
  final service = ref.watch(gradeServiceProvider);
  return service.fetchStudents();
});

// ── Provider：教师端选中学生的成绩列表 ──────────────────────────────
final selectedStudentIdProvider = StateProvider<String?>((ref) => null);

final teacherGradesProvider =
    FutureProvider.autoDispose<List<Grade>>((ref) async {
  final studentId = ref.watch(selectedStudentIdProvider);
  if (studentId == null) return [];
  final service = ref.watch(gradeServiceProvider);
  return service.fetchGradesByStudentId(studentId);
});

// ────────────────────────────────────────────────────────────────────
class TeacherGradePage extends ConsumerStatefulWidget {
  const TeacherGradePage({super.key});

  @override
  ConsumerState<TeacherGradePage> createState() => _TeacherGradePageState();
}

class _TeacherGradePageState extends ConsumerState<TeacherGradePage> {
  // ── 辅助方法：按学期分组 ─────────────────────────────────────────
  Map<String, List<Grade>> _groupBySemester(List<Grade> grades) {
    final map = <String, List<Grade>>{};
    for (final g in grades) {
      map.putIfAbsent(g.semester, () => []).add(g);
    }
    final sorted = map.keys.toList()..sort((a, b) => b.compareTo(a));
    return {for (final k in sorted) k: map[k]!};
  }

  Color _getGradeColor(double score) {
    if (score >= 90) return AppColors.success;
    if (score >= 80) return AppColors.primary;
    if (score >= 70) return AppColors.info;
    if (score >= 60) return AppColors.warning;
    return AppColors.error;
  }

  String _getDefaultSemester() {
    final now = DateTime.now();
    final year = now.month >= 9 ? now.year : now.year - 1;
    final term = now.month >= 2 && now.month < 9 ? '2' : '1';
    return '$year-${year + 1}-$term';
  }

  // ── 刷新教师端成绩列表 ───────────────────────────────────────────
  void _refreshGrades() {
    ref.invalidate(teacherGradesProvider);
  }

  // ── 添加 / 编辑成绩 dialog ────────────────────────────────────────
  void _showAddEditDialog(BuildContext context, {Grade? grade}) {
    final selectedStudentId = ref.read(selectedStudentIdProvider);
    if (selectedStudentId == null) return;

    final isEditing = grade != null;
    final courseController =
        TextEditingController(text: grade?.courseName ?? '');
    final creditController =
        TextEditingController(text: grade?.credit.toString() ?? '');
    final scoreController =
        TextEditingController(text: grade?.score.toString() ?? '');
    final semesterController =
        TextEditingController(text: grade?.semester ?? _getDefaultSemester());
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? '编辑成绩' : '录入成绩'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: courseController,
                  decoration: const InputDecoration(labelText: '课程名称'),
                  validator: (v) =>
                      v?.isEmpty ?? true ? '请输入课程名称' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: creditController,
                  decoration: const InputDecoration(labelText: '学分'),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v?.isEmpty ?? true) return '请输入学分';
                    final credit = double.tryParse(v!);
                    if (credit == null || credit <= 0) return '请输入有效学分';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: scoreController,
                  decoration: const InputDecoration(labelText: '成绩 (0-100)'),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v?.isEmpty ?? true) return '请输入成绩';
                    final score = double.tryParse(v!);
                    if (score == null || score < 0 || score > 100) {
                      return '请输入0-100的成绩';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: semesterController,
                  decoration: const InputDecoration(
                    labelText: '学期 (如: 2024-2025-1)',
                  ),
                  validator: (v) =>
                      v?.isEmpty ?? true ? '请输入学期' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!(formKey.currentState?.validate() ?? false)) return;
              final score = double.parse(scoreController.text);
              final teacherId =
                  Supabase.instance.client.auth.currentUser?.id ?? '';
              final newGrade = Grade(
                id: grade?.id ?? const Uuid().v4(),
                userId: selectedStudentId,
                courseName: courseController.text.trim(),
                credit: double.parse(creditController.text),
                score: score,
                gradePoint: Grade.calculateGradePoint(score),
                semester: semesterController.text.trim(),
                status:
                    score >= 60 ? GradeStatus.passed : GradeStatus.failed,
                createdAt: grade?.createdAt ?? DateTime.now(),
                teacherId: teacherId,
              );
              try {
                final service = ref.read(gradeServiceProvider);
                if (isEditing) {
                  await service.updateGrade(newGrade);
                } else {
                  await service.addGrade(newGrade);
                }
                _refreshGrades();
                if (context.mounted) Navigator.pop(context);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('操作失败：$e')),
                  );
                }
              }
            },
            child: Text(isEditing ? '保存' : '录入'),
          ),
        ],
      ),
    );
  }

  // ── 删除确认 dialog ──────────────────────────────────────────────
  Future<void> _confirmDelete(BuildContext context, Grade grade) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除 ${grade.courseName} 的成绩吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              '删除',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await ref.read(gradeServiceProvider).deleteGrade(grade.id);
        _refreshGrades();
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('删除失败：$e')),
          );
        }
      }
    }
  }

  // ── 学期分组区块 ─────────────────────────────────────────────────
  Widget _buildSemesterSection(
      BuildContext context, String semester, List<Grade> grades) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.greyLight.withValues(alpha: 0.5)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          tilePadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          title: Text(semester, style: AppTextStyles.titleMedium),
          children: grades.map((g) => _buildGradeItem(context, g)).toList(),
        ),
      ),
    );
  }

  // ── 单条成绩行 ───────────────────────────────────────────────────
  Widget _buildGradeItem(BuildContext context, Grade grade) {
    return InkWell(
      onTap: () => _showAddEditDialog(context, grade: grade),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(grade.courseName, style: AppTextStyles.bodyMedium),
            ),
            SizedBox(
              width: 50,
              child: Text(
                '${grade.credit}学分',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              width: 50,
              child: Text(
                grade.score.toStringAsFixed(0),
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              width: 40,
              child: Text(
                grade.letterGrade,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: _getGradeColor(grade.score),
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // 删除按钮
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18),
              color: AppColors.error,
              onPressed: () => _confirmDelete(context, grade),
              tooltip: '删除',
            ),
          ],
        ),
      ),
    );
  }

  // ── 弹出 BottomSheet 选择学生 ────────────────────────────────────
  void _showStudentPicker(
      BuildContext context, List<Map<String, dynamic>> students) {
    final currentId = ref.read(selectedStudentIdProvider);
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 拖拽指示条
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.greyLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // 标题
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text('选择学生', style: AppTextStyles.titleMedium),
            ),
            // 学生列表
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: students.length,
                separatorBuilder: (context2, index2) => const Divider(
                  height: 1,
                  thickness: 0.5,
                  indent: 64,
                  endIndent: 16,
                ),
                itemBuilder: (_, i) {
                  final s = students[i];
                  final name = s['name'] as String? ?? '';
                  final studentId = s['student_id'] as String? ?? '';
                  final department = s['department'] as String? ?? '';
                  final id = s['id'] as String;
                  final isSelected = id == currentId;
                  final initial =
                      name.isNotEmpty ? name.characters.first : '?';

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 4),
                    leading: _buildAvatar(initial),
                    title: Text(
                      name,
                      style: AppTextStyles.titleSmall,
                    ),
                    subtitle: [studentId, department]
                            .where((v) => v.isNotEmpty)
                            .isNotEmpty
                        ? Text(
                            [studentId, department]
                                .where((v) => v.isNotEmpty)
                                .join('  ·  '),
                            style: AppTextStyles.caption,
                          )
                        : null,
                    trailing: isSelected
                        ? const Icon(Icons.check_rounded,
                            color: AppColors.primary, size: 20)
                        : null,
                    onTap: () {
                      ref.read(selectedStudentIdProvider.notifier).state = id;
                      Navigator.pop(ctx);
                    },
                  );
                },
              ),
            ),
            // 底部安全距离
            SizedBox(height: MediaQuery.of(ctx).padding.bottom + 16),
          ],
        );
      },
    );
  }

  // ── 圆形首字头像 ─────────────────────────────────────────────────
  Widget _buildAvatar(String initial) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: AppTextStyles.titleSmall.copyWith(
          color: AppColors.primary,
          height: 1,
        ),
      ),
    );
  }

  // ── 学生选择卡片 ─────────────────────────────────────────────────
  Widget _buildStudentSelector(
    BuildContext context,
    AsyncValue<List<Map<String, dynamic>>> studentsAsync,
    String? selectedStudentId,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: studentsAsync.when(
        loading: () => Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.greyLight.withValues(alpha: 0.6),
              width: 0.5,
            ),
          ),
          child: const Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Text('加载学生列表…'),
            ],
          ),
        ),
        error: (e, _) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.greyLight.withValues(alpha: 0.6),
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.error_outline, size: 16, color: AppColors.error),
              const SizedBox(width: 8),
              Text(
                '加载失败：$e',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
              ),
            ],
          ),
        ),
        data: (students) {
          if (students.isEmpty) {
            return Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.greyLight.withValues(alpha: 0.6),
                  width: 0.5,
                ),
              ),
              child: Text(
                '暂无学生数据',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
              ),
            );
          }

          // 查找当前选中学生
          final selected = selectedStudentId != null
              ? students.firstWhere(
                  (s) => s['id'] == selectedStudentId,
                  orElse: () => {},
                )
              : null;

          final name = selected?['name'] as String? ?? '';
          final studentId = selected?['student_id'] as String? ?? '';
          final department = selected?['department'] as String? ?? '';
          final initial = name.isNotEmpty ? name.characters.first : '?';
          final subText = [studentId, department]
              .where((v) => v.isNotEmpty)
              .join('  ·  ');

          return GestureDetector(
            onTap: () => _showStudentPicker(context, students),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.greyLight.withValues(alpha: 0.6),
                  width: 0.5,
                ),
              ),
              child: Row(
                children: [
                  // 左侧头像
                  selected != null && name.isNotEmpty
                      ? _buildAvatar(initial)
                      : Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.06),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.person_search_outlined,
                            size: 18,
                            color: AppColors.primary,
                          ),
                        ),
                  const SizedBox(width: 12),
                  // 中间文字
                  Expanded(
                    child: selected != null && name.isNotEmpty
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(name, style: AppTextStyles.titleSmall),
                              if (subText.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(subText, style: AppTextStyles.caption),
                              ],
                            ],
                          )
                        : Text(
                            '请选择要管理的学生',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                  ),
                  // 右侧图标
                  const Icon(
                    Icons.unfold_more_rounded,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── 学生信息摘要条 ────────────────────────────────────────────────
  Widget _buildStudentSummary(List<Grade> grades) {
    final totalCourses = grades.length;
    final totalCredit =
        grades.fold<double>(0, (sum, g) => sum + g.credit);

    // 计算本学期（最新学期）GPA
    final semesters = grades.map((g) => g.semester).toSet().toList()
      ..sort((a, b) => b.compareTo(a));
    double semesterGpa = 0;
    if (semesters.isNotEmpty) {
      final latestSemester = semesters.first;
      final latestGrades =
          grades.where((g) => g.semester == latestSemester).toList();
      final totalCredit2 =
          latestGrades.fold<double>(0, (sum, g) => sum + g.credit);
      if (totalCredit2 > 0) {
        final weightedSum = latestGrades.fold<double>(
            0, (sum, g) => sum + g.gradePoint * g.credit);
        semesterGpa = weightedSum / totalCredit2;
      }
    }

    final summaryText = '共 $totalCourses 门课  ·  '
        '本学期 GPA ${semesterGpa.toStringAsFixed(2)}  ·  '
        '总学分 ${totalCredit.toStringAsFixed(1)}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          summaryText,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.primary,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final studentsAsync = ref.watch(studentsProvider);
    final selectedStudentId = ref.watch(selectedStudentIdProvider);
    final gradesAsync = ref.watch(teacherGradesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('成绩管理'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Column(
        children: [
          // ── 学生选择卡片 ──────────────────────────────────────────
          _buildStudentSelector(context, studentsAsync, selectedStudentId),
          // ── 成绩摘要条（已选学生 + 有数据时） ───────────────────────
          if (selectedStudentId != null)
            gradesAsync.maybeWhen(
              data: (grades) =>
                  grades.isNotEmpty ? _buildStudentSummary(grades) : const SizedBox.shrink(),
              orElse: () => const SizedBox.shrink(),
            ),
          const SizedBox(height: 8),
          // ── 成绩列表 ───────────────────────────────────────────
          Expanded(
            child: selectedStudentId == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.person_search_outlined,
                          size: 64,
                          color: AppColors.greyLight,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '请先选择学生',
                          style: AppTextStyles.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '点击上方卡片选择要管理成绩的学生',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : gradesAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(
                      child: Text(
                        '加载失败：$e',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                    data: (grades) {
                      if (grades.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.grade_outlined,
                                size: 64,
                                color: AppColors.greyLight,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '该学生暂无成绩',
                                style: AppTextStyles.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '点击右下角按钮录入成绩',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      final grouped = _groupBySemester(grades);
                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: grouped.entries
                              .map((e) => _buildSemesterSection(
                                  context, e.key, e.value))
                              .toList(),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      // ── 录入成绩 FAB ─────────────────────────────────────────────
      floatingActionButton: selectedStudentId != null
          ? FloatingActionButton(
              onPressed: () => _showAddEditDialog(context),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: AppColors.white),
            )
          : null,
    );
  }
}
