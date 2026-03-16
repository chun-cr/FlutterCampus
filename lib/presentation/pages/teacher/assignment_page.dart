import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../components/campus_empty_state.dart';
//
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

// ---------------------------------------------------------------------------
// 虚拟作业数据结构
// ---------------------------------------------------------------------------
class Assignment {
  const Assignment({
    required this.id,
    required this.courseName,
    required this.classNames,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.status,
  });

  final String id; // 'assign_001' 格式
  final String courseName;
  final String classNames;
  final String title;
  final String description;
  final DateTime dueDate;
  final String status; // 'active' / 'closed'
}

// ---------------------------------------------------------------------------
// 虚拟写死的5条作业数据
// ---------------------------------------------------------------------------
final mockAssignments = [
  Assignment(
    id: 'assign_001',
    courseName: '数据结构',
    classNames: '22级计算机1、2班',
    title: '第三章课后习题',
    description: '完成教材第三章第1-5题，手写拍照上传',
    dueDate: DateTime(2025, 3, 20),
    status: 'active',
  ),
  Assignment(
    id: 'assign_002',
    courseName: '数据库系统原理',
    classNames: '23级软工1、2班',
    title: 'SQL查询练习',
    description: '完成实验报告第二章SQL查询10道题',
    dueDate: DateTime(2025, 3, 18),
    status: 'active',
  ),
  Assignment(
    id: 'assign_003',
    courseName: '算法设计与分析',
    classNames: '22级网络工程1班',
    title: '排序算法实现',
    description: '用Python实现冒泡、快排、归并三种排序算法并分析复杂度',
    dueDate: DateTime(2025, 3, 15),
    status: 'closed',
  ),
  Assignment(
    id: 'assign_004',
    courseName: '操作系统',
    classNames: '22级计算机1班',
    title: '进程调度模拟实验',
    description: '模拟实现FCFS和RR两种进程调度算法',
    dueDate: DateTime(2025, 3, 25),
    status: 'active',
  ),
  Assignment(
    id: 'assign_005',
    courseName: '计算机网络',
    classNames: '23级软工2班',
    title: 'TCP/IP协议分析报告',
    description: '使用Wireshark抓包分析TCP三次握手过程，撰写实验报告',
    dueDate: DateTime(2025, 3, 28),
    status: 'active',
  ),
];

// ---------------------------------------------------------------------------
// 从 Supabase 拉取每个作业的批改记录数量
// 由于首页只需展示批改进度，我们可以独立用 Provider 来拉取该数量
// 这里我们拉取整表提交或者按 assignment_id 查数量。
// 为了复用及简单，按照需求，首页提供一个 count 的 provider 或在子视图组件使用 FutureBuilder
// ---------------------------------------------------------------------------
final assignmentGradedCountProvider = FutureProvider.family<int, String>((
  ref,
  assignmentId,
) async {
  final supabase = Supabase.instance.client;
  try {
    final response = await supabase
        .from('assignment_submissions')
        .select('id, score')
        .eq('assignment_id', assignmentId)
        .not('score', 'is', null);
    return (response as List).length;
  } catch (e) {
    debugPrint('获取批改数异常: $e');
    return 0;
  }
});

// ---------------------------------------------------------------------------
// 页面主入口
// ---------------------------------------------------------------------------
class AssignmentPage extends ConsumerStatefulWidget {
  const AssignmentPage({super.key});

  @override
  ConsumerState<AssignmentPage> createState() => _AssignmentPageState();
}

class _AssignmentPageState extends ConsumerState<AssignmentPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
        title: Text('作业批改', style: AppTextStyles.titleMedium),
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
            Tab(text: '待批改'),
            Tab(text: '已布置'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [_PendingTab(), _AllTab()],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tab 1: 待批改 (仅展示 active)
// ---------------------------------------------------------------------------
class _PendingTab extends StatelessWidget {
  const _PendingTab();

  @override
  Widget build(BuildContext context) {
    final activeAssignments = mockAssignments
        .where((a) => a.status == 'active')
        .toList();

    if (activeAssignments.isEmpty) {
      return const Center(
        child: CampusEmptyState(
          icon: Icons.checklist_rounded,
          title: '暂无待批改作业',
          subtitle: '所有进行中的作业批改任务已完成',
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      itemCount: activeAssignments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final assignment = activeAssignments[index];
        return _AssignmentCard(
          assignment: assignment,
          onTap: () {
            context.push('/teacher/assignment/submissions', extra: assignment);
          },
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Tab 2: 已布置 (全部)
// ---------------------------------------------------------------------------
class _AllTab extends StatelessWidget {
  const _AllTab();

  @override
  Widget build(BuildContext context) {
    if (mockAssignments.isEmpty) {
      return const Center(
        child: CampusEmptyState(
          icon: Icons.assignment_outlined,
          title: '暂无任何作业',
          subtitle: '您还没有布置过任何作业',
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      itemCount: mockAssignments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final assignment = mockAssignments[index];
        return _AssignmentCard(
          assignment: assignment,
          showStatus: true,
          onTap: () {
            // 已布置页面如果也允许点击批改，也可以加上跳转，需求说"无跳转，仅展示"
          },
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// 作业卡片组件
// ---------------------------------------------------------------------------
class _AssignmentCard extends ConsumerWidget {
  const _AssignmentCard({
    required this.assignment,
    this.showStatus = false,
    this.onTap,
  });

  final Assignment assignment;
  final bool showStatus;
  final VoidCallback? onTap;

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final isOverdue = assignment.dueDate.isBefore(now);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.greyLight, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 顶部
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    assignment.courseName,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                if (showStatus)
                  _StatusLabel(status: assignment.status)
                else
                  Text(
                    isOverdue ? '已截止' : '截止 ${_formatDate(assignment.dueDate)}',
                    style: AppTextStyles.caption.copyWith(
                      color: isOverdue
                          ? AppColors.error
                          : AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // 中部
            Text(
              assignment.title,
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              assignment.description,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),

            // 底部
            Row(
              children: [
                Expanded(
                  child: Text(
                    assignment.classNames,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                // 批改进度
                ref
                    .watch(assignmentGradedCountProvider(assignment.id))
                    .when(
                      data: (gradedCount) {
                        return RichText(
                          text: TextSpan(
                            text: '已批改 ',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            children: [
                              TextSpan(
                                text: '$gradedCount',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextSpan(
                                text: ' / 30',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      loading: () => const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      error: (_, __) => const SizedBox(),
                    ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 状态标签
// ---------------------------------------------------------------------------
class _StatusLabel extends StatelessWidget {
  const _StatusLabel({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    if (status == 'active') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          '进行中',
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.success,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.greyLight.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          '已结束',
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
  }
}
