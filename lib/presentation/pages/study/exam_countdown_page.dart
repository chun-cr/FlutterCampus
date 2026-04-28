import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../components/campus_loading.dart';
import '../../theme/theme.dart';
import '../../components/date_picker_sheet.dart';
import '../../../core/services/exam_countdown_service.dart';
import '../../../domain/models/exam_countdown.dart';

class ExamCountdownPage extends ConsumerStatefulWidget {
  const ExamCountdownPage({super.key});

  @override
  ConsumerState<ExamCountdownPage> createState() => _ExamCountdownPageState();
}

class _ExamCountdownPageState extends ConsumerState<ExamCountdownPage> {
  bool _showExpired = false;

  @override
  Widget build(BuildContext context) {
    final examState = ref.watch(examCountdownStateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('考试倒计时'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: examState.isLoading
          ? const CampusLoading()
          : examState.error != null
          ? _buildErrorState(examState.error!)
          : examState.exams.isEmpty
          ? _buildEmptyState()
          : _buildContent(examState),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(context),
        backgroundColor: AppColors.campusOrange,
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
            onPressed: () =>
                ref.read(examCountdownStateProvider.notifier).loadExams(),
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
            Icons.timer_outlined,
            size: 64,
            color: AppColors.greyLight,
          ),
          const SizedBox(height: 16),
          Text('暂无考试安排', style: AppTextStyles.titleMedium),
          const SizedBox(height: 8),
          Text(
            '点击右下角按钮添加考试',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ExamCountdownState examState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 即将到来的考试
          if (examState.upcomingExams.isNotEmpty) ...[
            _buildSectionHeader('即将到来', examState.upcomingExams.length),
            const SizedBox(height: 12),
            ...examState.upcomingExams.map(_buildExamCard),
          ],

          // 已结束的考试
          if (examState.expiredExams.isNotEmpty) ...[
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => setState(() => _showExpired = !_showExpired),
              child: Row(
                children: [
                  _buildSectionHeader('已结束', examState.expiredExams.length),
                  const Spacer(),
                  Icon(
                    _showExpired ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
            if (_showExpired) ...[
              const SizedBox(height: 12),
              ...examState.expiredExams.map(
                (exam) => _buildExamCard(exam, isExpired: true),
              ),
            ],
          ],

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Row(
      children: [
        Text(
          title.toUpperCase(),
          style: AppTextStyles.labelLarge.copyWith(
            letterSpacing: 1.5,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.greyLight.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            count.toString(),
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExamCard(ExamCountdown exam, {bool isExpired = false}) {
    final typeColor = _getExamTypeColor(exam.examType);
    final isUrgent = exam.isUrgent;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUrgent
              ? AppColors.warning
              : AppColors.greyLight.withValues(alpha: 0.5),
          width: isUrgent ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showAddEditDialog(context, exam: exam),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // 左侧：考试信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 类型标签
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: typeColor.withValues(
                            alpha: isExpired ? 0.1 : 0.15,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          exam.examType.label,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: isExpired
                                ? AppColors.textSecondary
                                : typeColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // 考试名称
                      Text(
                        exam.examName,
                        style: AppTextStyles.titleMedium.copyWith(
                          color: isExpired
                              ? AppColors.textSecondary
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // 考试日期
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _formatDate(exam.examDate),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      // 备注
                      if (exam.note != null && exam.note!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          exam.note!,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textDisabled,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                // 右侧：倒计时
                Container(
                  width: 80,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: [
                      Text(
                        isExpired
                            ? '${-exam.daysRemaining}'
                            : '${exam.daysRemaining}',
                        style: AppTextStyles.headlineLarge.copyWith(
                          color: isExpired
                              ? AppColors.textSecondary
                              : (isUrgent
                                    ? AppColors.warning
                                    : AppColors.primary),
                          fontWeight: FontWeight.w300,
                          fontSize: 36,
                        ),
                      ),
                      Text(
                        isExpired ? '天前' : '天',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: isExpired
                              ? AppColors.textSecondary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // 删除按钮
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  onPressed: () => _confirmDelete(exam),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getExamTypeColor(ExamType type) {
    switch (type) {
      case ExamType.midterm:
        return AppColors.info;
      case ExamType.final_:
        return AppColors.primary;
      case ExamType.cet4:
        return AppColors.success;
      case ExamType.cet6:
        return AppColors.campusGreen;
      case ExamType.postgraduate:
        return AppColors.campusPurple;
      case ExamType.custom:
        return AppColors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }

  void _confirmDelete(ExamCountdown exam) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除 ${exam.examName} 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              ref.read(examCountdownStateProvider.notifier).deleteExam(exam.id);
              Navigator.pop(context);
            },
            child: const Text('删除', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showAddEditDialog(BuildContext context, {ExamCountdown? exam}) {
    final isEditing = exam != null;
    final nameController = TextEditingController(text: exam?.examName ?? '');
    final noteController = TextEditingController(text: exam?.note ?? '');
    ExamType selectedType = exam?.examType ?? ExamType.midterm;
    DateTime selectedDate =
        exam?.examDate ?? DateTime.now().add(const Duration(days: 7));
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? '编辑考试' : '添加考试'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: '考试名称'),
                    validator: (v) => v?.isEmpty ?? true ? '请输入考试名称' : null,
                  ),
                  const SizedBox(height: 16),
                  // 考试类型
                  Text(
                    '考试类型',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ExamType.values.map((type) {
                      final isSelected = type == selectedType;
                      return GestureDetector(
                        onTap: () => setDialogState(() => selectedType = type),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? _getExamTypeColor(
                                    type,
                                  ).withValues(alpha: 0.15)
                                : AppColors.greyLight.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(8),
                            border: isSelected
                                ? Border.all(
                                    color: _getExamTypeColor(type),
                                    width: 1,
                                  )
                                : null,
                          ),
                          child: Text(
                            type.label,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: isSelected
                                  ? _getExamTypeColor(type)
                                  : AppColors.textSecondary,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  // 考试日期
                  Text(
                    '考试日期',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final picked = await DatePickerSheet.showDateTime(
                        context,
                        initialDate: selectedDate,
                        minDate: DateTime.now().subtract(
                          const Duration(days: 365),
                        ),
                        maxDate: DateTime.now().add(
                          const Duration(days: 365 * 2),
                        ),
                        title: '选择考试日期',
                      );
                      if (picked != null) {
                        setDialogState(() => selectedDate = picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.greyLight),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _formatDate(selectedDate),
                            style: AppTextStyles.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: noteController,
                    decoration: const InputDecoration(labelText: '备注 (可选)'),
                    maxLines: 2,
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
                  final newExam = ExamCountdown(
                    id: exam?.id ?? const Uuid().v4(),
                    userId: Supabase.instance.client.auth.currentUser!.id,
                    examName: nameController.text.trim(),
                    examDate: selectedDate,
                    examType: selectedType,
                    note: noteController.text.trim().isEmpty
                        ? null
                        : noteController.text.trim(),
                    createdAt: exam?.createdAt ?? DateTime.now(),
                  );

                  if (isEditing) {
                    ref
                        .read(examCountdownStateProvider.notifier)
                        .updateExam(newExam);
                  } else {
                    ref
                        .read(examCountdownStateProvider.notifier)
                        .addExam(newExam);
                  }
                  Navigator.pop(context);
                }
              },
              child: Text(isEditing ? '保存' : '添加'),
            ),
          ],
        ),
      ),
    );
  }
}
