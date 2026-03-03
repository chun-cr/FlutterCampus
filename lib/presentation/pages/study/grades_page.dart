import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme/theme.dart';
import '../../../core/services/grade_service.dart';
import '../../../domain/models/grade.dart';

class GradesPage extends ConsumerStatefulWidget {
  const GradesPage({super.key});

  @override
  ConsumerState<GradesPage> createState() => _GradesPageState();
}

class _GradesPageState extends ConsumerState<GradesPage> {
  bool _use4PointScale = true;

  @override
  Widget build(BuildContext context) {
    final gradesState = ref.watch(gradeStateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('成绩查询'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: gradesState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : gradesState.error != null
          ? _buildErrorState(gradesState.error!)
          : gradesState.grades.isEmpty
          ? _buildEmptyState()
          : _buildContent(gradesState),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Text('加载失败', style: AppTextStyles.titleMedium),
          const SizedBox(height: 8),
          Text(
            error,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => ref.read(gradeStateProvider.notifier).loadGrades(),
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.school_outlined,
            size: 64,
            color: AppColors.greyLight,
          ),
          const SizedBox(height: 16),
          Text('暂无成绩记录', style: AppTextStyles.titleMedium),
          const SizedBox(height: 8),
          Text(
            '点击右下角按钮添加成绩',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(GradesState gradesState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // GPA 总览卡片
          _buildGpaSummaryCard(gradesState),
          const SizedBox(height: 24),
          // 学期成绩列表
          ...gradesState.semesterSummaries.map(_buildSemesterSection),
        ],
      ),
    );
  }

  Widget _buildGpaSummaryCard(GradesState gradesState) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.greyLight.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '总绩点',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              // 切换按钮
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.greyLight.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildScaleToggle(
                      '4分制',
                      _use4PointScale,
                      () => setState(() => _use4PointScale = true),
                    ),
                    _buildScaleToggle(
                      '百分制',
                      !_use4PointScale,
                      () => setState(() => _use4PointScale = false),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _use4PointScale
                ? gradesState.totalGpa.toStringAsFixed(2)
                : _calculatePercentageGpa(
                    gradesState.grades,
                  ).toStringAsFixed(1),
            style: AppTextStyles.headlineLarge.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w300,
              fontSize: 48,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '总学分: ${gradesState.totalCredits.toStringAsFixed(1)}',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScaleToggle(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  double _calculatePercentageGpa(List<Grade> grades) {
    if (grades.isEmpty) return 0;
    double totalWeightedScore = 0;
    double totalCredits = 0;
    for (final grade in grades) {
      totalWeightedScore += grade.score * grade.credit;
      totalCredits += grade.credit;
    }
    return totalCredits > 0 ? totalWeightedScore / totalCredits : 0;
  }

  Widget _buildSemesterSection(SemesterGradeSummary summary) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.greyLight.withOpacity(0.5)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          title: Row(
            children: [
              Expanded(
                child: Text(summary.semester, style: AppTextStyles.titleMedium),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'GPA ${summary.gpa.toStringAsFixed(2)}',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${summary.totalCredits.toStringAsFixed(1)}学分',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          children: summary.grades.map(_buildGradeItem).toList(),
        ),
      ),
    );
  }

  Widget _buildGradeItem(Grade grade) {
    return Dismissible(
      key: Key(grade.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.error,
        child: const Icon(Icons.delete, color: AppColors.white),
      ),
      confirmDismiss: (direction) async {
        return showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('确认删除'),
            content: Text('确定要删除 ${grade.courseName} 的成绩吗？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  '删除',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        ref.read(gradeStateProvider.notifier).deleteGrade(grade.id);
      },
      child: InkWell(
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
            ],
          ),
        ),
      ),
    );
  }

  Color _getGradeColor(double score) {
    if (score >= 90) return AppColors.success;
    if (score >= 80) return AppColors.primary;
    if (score >= 70) return AppColors.info;
    if (score >= 60) return AppColors.warning;
    return AppColors.error;
  }

  void _showAddEditDialog(BuildContext context, {Grade? grade}) {
    final isEditing = grade != null;
    final courseController = TextEditingController(
      text: grade?.courseName ?? '',
    );
    final creditController = TextEditingController(
      text: grade?.credit.toString() ?? '',
    );
    final scoreController = TextEditingController(
      text: grade?.score.toString() ?? '',
    );
    final semesterController = TextEditingController(
      text: grade?.semester ?? _getDefaultSemester(),
    );
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? '编辑成绩' : '添加成绩'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: courseController,
                  decoration: const InputDecoration(labelText: '课程名称'),
                  validator: (v) => v?.isEmpty ?? true ? '请输入课程名称' : null,
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
                    if (score == null || score < 0 || score > 100)
                      return '请输入0-100的成绩';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: semesterController,
                  decoration: const InputDecoration(
                    labelText: '学期 (如: 2024-2025-1)',
                  ),
                  validator: (v) => v?.isEmpty ?? true ? '请输入学期' : null,
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
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                final score = double.parse(scoreController.text);
                final newGrade = Grade(
                  id: grade?.id ?? const Uuid().v4(),
                  userId: Supabase.instance.client.auth.currentUser!.id,
                  courseName: courseController.text.trim(),
                  credit: double.parse(creditController.text),
                  score: score,
                  gradePoint: Grade.calculateGradePoint(score),
                  semester: semesterController.text.trim(),
                  status: score >= 60 ? GradeStatus.passed : GradeStatus.failed,
                  createdAt: grade?.createdAt ?? DateTime.now(),
                );

                if (isEditing) {
                  ref.read(gradeStateProvider.notifier).updateGrade(newGrade);
                } else {
                  ref.read(gradeStateProvider.notifier).addGrade(newGrade);
                }
                Navigator.pop(context);
              }
            },
            child: Text(isEditing ? '保存' : '添加'),
          ),
        ],
      ),
    );
  }

  String _getDefaultSemester() {
    final now = DateTime.now();
    final year = now.month >= 9 ? now.year : now.year - 1;
    final term = now.month >= 2 && now.month < 9 ? '2' : '1';
    return '$year-${year + 1}-$term';
  }
}
