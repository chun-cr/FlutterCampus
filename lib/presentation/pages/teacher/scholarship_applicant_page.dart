import 'dart:math';
import '../../components/campus_snackbar.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../components/campus_empty_state.dart';
import '../../components/campus_loading.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'scholarship_page.dart'; // Scholarship, mockApplicantNos
import 'submission_list_page.dart'; // StudentBrief, studentsProvider

// ---------------------------------------------------------------------------
// 数据模型
// ---------------------------------------------------------------------------
class ScholarshipReview {
  const ScholarshipReview({
    required this.id,
    required this.scholarshipId,
    required this.studentId,
    required this.studentName,
    required this.studentNo,
    this.applyReason,
    this.teacherResult,
    this.teacherComment,
    this.reviewedAt,
  });

  factory ScholarshipReview.fromJson(Map<String, dynamic> json) {
    return ScholarshipReview(
      id: json['id'] as String,
      scholarshipId: json['scholarship_id'] as String,
      studentId: json['student_id'] as String,
      studentName: json['student_name'] as String,
      studentNo: json['student_no'] as String,
      applyReason: json['apply_reason'] as String?,
      teacherResult: json['teacher_result'] as String?,
      teacherComment: json['teacher_comment'] as String?,
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.parse(json['reviewed_at'] as String)
          : null,
    );
  }

  final String id;
  final String scholarshipId;
  final String studentId;
  final String studentName;
  final String studentNo;
  final String? applyReason;
  final String? teacherResult; // 'recommended' / 'not_recommended'
  final String? teacherComment;
  final DateTime? reviewedAt;
}

// ---------------------------------------------------------------------------
// 模拟申请理由列表（根据学号用固定种子选取）
// ---------------------------------------------------------------------------
const _mockReasons = [
  '综合成绩排名专业第一，积极参与科研项目',
  '家庭经济困难，勤工俭学，成绩优良',
  '担任班长一年，组织多次班级活动',
  '连续两学期综合测评排名前3%',
  '获得全国大学生程序设计竞赛二等奖',
];

/// 根据学号生成固定的申请理由
String _generateReason(String studentNo) {
  final seed = studentNo.hashCode;
  final rng = Random(seed);
  return _mockReasons[rng.nextInt(_mockReasons.length)];
}

// ---------------------------------------------------------------------------
// 状态管理
// ---------------------------------------------------------------------------

// 某项目的审核记录
final scholarshipReviewsProvider =
    FutureProvider.family<List<ScholarshipReview>, String>(
  (ref, scholarshipId) async {
    final supabase = Supabase.instance.client;
    try {
      final response = await supabase
          .from('scholarship_reviews')
          .select()
          .eq('scholarship_id', scholarshipId);
      return (response as List)
          .map((e) => ScholarshipReview.fromJson(e))
          .toList();
    } catch (e) {
      debugPrint('拉取审核记录失败: $e');
      return [];
    }
  },
);

// 申请名单页筛选 0全部 / 1待审核 / 2已推荐 / 3不推荐
final applicantFilterProvider = StateProvider<int>((ref) => 0);

// 审核 BottomSheet 的审核结果：'recommended' / 'not_recommended' / null
final reviewResultProvider = StateProvider<String?>((ref) => null);

// 审核 BottomSheet 的评语
final reviewCommentProvider = StateProvider<String>((ref) => '');

// ---------------------------------------------------------------------------
// 合并后的申请学生数据项
// ---------------------------------------------------------------------------
class _ApplicantItem {
  _ApplicantItem({
    required this.student,
    required this.reason,
    this.review,
  });

  final StudentBrief student;
  final String reason;
  final ScholarshipReview? review;

  /// 是否已审核
  bool get isReviewed => review?.teacherResult != null;

  /// 审核结果
  String? get result => review?.teacherResult;
}

// ---------------------------------------------------------------------------
// 申请名单页面
// ---------------------------------------------------------------------------
class ScholarshipApplicantPage extends ConsumerWidget {
  const ScholarshipApplicantPage({super.key, required this.scholarship});

  final Scholarship scholarship;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          scholarship.name,
          style: AppTextStyles.titleMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                scholarship.amount,
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: ref.watch(studentsProvider).when(
            loading: () => const Center(child: CampusLoading()),
            error: (err, _) => Center(child: Text('加载学生数据失败: $err')),
            data: (allStudents) {
              return ref
                  .watch(scholarshipReviewsProvider(scholarship.id))
                  .when(
                    loading: () => const Center(child: CampusLoading()),
                    error: (err, _) =>
                        Center(child: Text('加载审核记录失败: $err')),
                    data: (reviews) {
                      return _buildBody(
                          context, ref, allStudents, reviews);
                    },
                  );
            },
          ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    List<StudentBrief> allStudents,
    List<ScholarshipReview> reviews,
  ) {
    // 取出该项目的已申请学号列表
    final applicantNos = mockApplicantNos[scholarship.id] ?? [];

    // 从全部学生中筛选出已申请的学生
    final applicantStudents = allStudents
        .where((s) => applicantNos.contains(s.studentNo))
        .toList();

    if (applicantStudents.isEmpty) {
      return const Center(
        child: CampusEmptyState(
          icon: Icons.group_off_rounded,
          title: '暂无申请记录',
          subtitle: '该项目尚无学生提交申请',
        ),
      );
    }

    // 构建合并数据
    final items = <_ApplicantItem>[];
    int reviewedCount = 0;
    int pendingCount = 0;

    for (final student in applicantStudents) {
      final review = reviews
          .where((r) => r.studentId == student.id)
          .firstOrNull;
      final reason = _generateReason(student.studentNo);
      final item = _ApplicantItem(
        student: student,
        reason: reason,
        review: review,
      );
      if (item.isReviewed) {
        reviewedCount++;
      } else {
        pendingCount++;
      }
      items.add(item);
    }

    final totalApplicants = items.length;

    // 筛选
    final filter = ref.watch(applicantFilterProvider);
    final filteredItems = items.where((item) {
      switch (filter) {
        case 1:
          return !item.isReviewed; // 待审核
        case 2:
          return item.result == 'recommended'; // 已推荐
        case 3:
          return item.result == 'not_recommended'; // 不推荐
        default:
          return true; // 全部
      }
    }).toList();

    return Column(
      children: [
        // 顶部统计卡片
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: _StatCard(
            total: totalApplicants,
            reviewed: reviewedCount,
            pending: pendingCount,
          ),
        ),

        // 筛选栏
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _FilterTabBar(
            selectedIndex: filter,
            onChanged: (index) {
              ref.read(applicantFilterProvider.notifier).state = index;
            },
          ),
        ),

        // 学生列表
        Expanded(
          child: filteredItems.isEmpty
              ? const CampusEmptyState(
                  icon: Icons.search_off_rounded,
                  title: '暂无匹配结果',
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  itemCount: filteredItems.length,
                  separatorBuilder: (_, __) => const Divider(
                    height: 1,
                    thickness: 0.5,
                    color: AppColors.greyLight,
                  ),
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    return _ApplicantTile(
                      item: item,
                      onTap: () =>
                          _showReviewSheet(context, ref, item),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showReviewSheet(
    BuildContext context,
    WidgetRef ref,
    _ApplicantItem item,
  ) {
    // 初始化 BottomSheet 状态
    ref.read(reviewResultProvider.notifier).state = item.review?.teacherResult;
    ref.read(reviewCommentProvider.notifier).state =
        item.review?.teacherComment ?? '';

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
        child:
            _ReviewSheet(scholarship: scholarship, item: item),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 统计卡片
// ---------------------------------------------------------------------------
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.total,
    required this.reviewed,
    required this.pending,
  });

  final int total;
  final int reviewed;
  final int pending;

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
          _buildStatGroup(total.toString(), '申请人数', AppColors.primary),
          Container(width: 1, height: 32, color: AppColors.greyLight),
          _buildStatGroup(reviewed.toString(), '已审核', AppColors.success),
          Container(width: 1, height: 32, color: AppColors.greyLight),
          _buildStatGroup(
              pending.toString(), '待审核', AppColors.campusOrange),
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
// 筛选 TabBar（全部 / 待审核 / 已推荐 / 不推荐）
// ---------------------------------------------------------------------------
class _FilterTabBar extends StatelessWidget {
  const _FilterTabBar({required this.selectedIndex, required this.onChanged});

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    const labels = ['全部', '待审核', '已推荐', '不推荐'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: List.generate(labels.length, (index) {
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
                  labels[index],
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isSelected
                        ? AppColors.white
                        : AppColors.textSecondary,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
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
// 申请学生列表 item
// ---------------------------------------------------------------------------
class _ApplicantTile extends StatelessWidget {
  const _ApplicantTile({required this.item, required this.onTap});

  final _ApplicantItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            // 头像
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

            // 姓名、学号、申请理由
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        item.student.name,
                        style: AppTextStyles.titleMedium,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item.student.studentNo,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.reason,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // 状态标签
            _buildResultTag(),
          ],
        ),
      ),
    );
  }

  Widget _buildResultTag() {
    if (!item.isReviewed) {
      // 待审核
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.campusOrange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '待审核',
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.campusOrange,
          ),
        ),
      );
    }

    if (item.result == 'recommended') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '已推荐',
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.success,
          ),
        ),
      );
    }

    // not_recommended
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '不推荐',
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.error,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 审核 BottomSheet
// ---------------------------------------------------------------------------
class _ReviewSheet extends ConsumerStatefulWidget {
  const _ReviewSheet({required this.scholarship, required this.item});
  final Scholarship scholarship;
  final _ApplicantItem item;

  @override
  ConsumerState<_ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends ConsumerState<_ReviewSheet> {
  late final TextEditingController _commentController;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController(
      text: ref.read(reviewCommentProvider),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    final result = ref.read(reviewResultProvider);
    if (result == null) return;

    final commentValue = _commentController.text.trim();
    final reason = widget.item.reason;

    final supabase = Supabase.instance.client;
    try {
      await supabase.from('scholarship_reviews').upsert({
        'scholarship_id': widget.scholarship.id,
        'student_id': widget.item.student.id,
        'student_name': widget.item.student.name,
        'student_no': widget.item.student.studentNo,
        'apply_reason': reason,
        'teacher_result': result,
        'teacher_comment': commentValue.isEmpty ? null : commentValue,
        'reviewed_at': DateTime.now().toUtc().toIso8601String(),
      }, onConflict: 'scholarship_id,student_id');

      if (mounted) {
        Navigator.of(context).pop();
        CampusSnackBar.show(context, message: '审核已提交', isError: false);
      }
      // 刷新外部列表
      ref.invalidate(
          scholarshipReviewsProvider(widget.scholarship.id));
      // 刷新首页卡片的审核计数
      ref.invalidate(scholarshipReviewedCountProvider);
    } catch (e) {
      if (mounted) {
        CampusSnackBar.show(context, message: '审核提交失败: $e', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentResult = ref.watch(reviewResultProvider);

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

          // 学生信息
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
          const SizedBox(height: 8),
          // 项目名称
          Text(
            widget.scholarship.name,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),

          // 申请理由展示区
          Text('申请理由', style: AppTextStyles.labelMedium),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.item.reason,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 审核意见选择
          Text('审核意见', style: AppTextStyles.labelMedium),
          const SizedBox(height: 12),
          Row(
            children: [
              // 推荐按钮
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    ref.read(reviewResultProvider.notifier).state =
                        'recommended';
                  },
                  child: Container(
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: currentResult == 'recommended'
                          ? AppColors.success
                          : AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '推荐',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: currentResult == 'recommended'
                            ? AppColors.white
                            : AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // 不推荐按钮
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    ref.read(reviewResultProvider.notifier).state =
                        'not_recommended';
                  },
                  child: Container(
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: currentResult == 'not_recommended'
                          ? AppColors.error
                          : AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '不推荐',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: currentResult == 'not_recommended'
                            ? AppColors.white
                            : AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 推荐意见输入
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('推荐意见', style: AppTextStyles.labelMedium),
              Consumer(
                builder: (context, ref, _) {
                  final text = ref.watch(reviewCommentProvider);
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
            maxLines: 3,
            onChanged: (val) {
              ref.read(reviewCommentProvider.notifier).state = val;
            },
            style: AppTextStyles.bodyMedium,
            decoration: InputDecoration(
              hintText: '填写推荐意见（选填）',
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
              onPressed: currentResult == null ? null : _submitReview,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.greyLight,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                '提交审核',
                style: AppTextStyles.button.copyWith(
                  color: currentResult == null
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
