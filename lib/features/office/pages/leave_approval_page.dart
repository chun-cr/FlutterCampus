import 'package:flutter/material.dart';
import '../../../presentation/components/components.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../../../core/services/leave_service.dart';
import '../../../domain/models/leave_application.dart';
import '../../../presentation/theme/theme.dart';

class LeaveApprovalPage extends ConsumerStatefulWidget {
  const LeaveApprovalPage({super.key});

  @override
  ConsumerState<LeaveApprovalPage> createState() => _LeaveApprovalPageState();
}

class _LeaveApprovalPageState extends ConsumerState<LeaveApprovalPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // 页面打开时加载全部数据（Tab 切换时筛选）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(leaveStateProvider.notifier).loadAllLeaves();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── 审批 BottomSheet ─────────────────────────────────────────────
  void _showApprovalSheet(BuildContext context, LeaveApplication leave) {
    final commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 拖拽条
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: AppColors.greyLight,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // 标题
                  Text('审批详情', style: AppTextStyles.titleMedium),
                  const SizedBox(height: 20),
                  // 详情信息卡
                  _buildDetailCard(leave),
                  const SizedBox(height: 20),
                  // 审批意见输入
                  Text(
                    '审批意见（可选）',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: commentController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: '填写审批意见…',
                      hintStyle: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textDisabled,
                      ),
                      contentPadding: const EdgeInsets.all(16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.greyLight.withValues(alpha: 0.8),
                          width: 0.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.greyLight.withValues(alpha: 0.8),
                          width: 0.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // 操作按钮
                  Row(
                    children: [
                      // 拒绝按钮
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            Navigator.pop(ctx);
                            await ref
                                .read(leaveStateProvider.notifier)
                                .rejectLeave(
                                  leave.id,
                                  comment: commentController.text.trim(),
                                );
                            if (mounted) {
                              _showSnackBar('已拒绝该请假申请');
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(
                              color: AppColors.error,
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            '拒绝',
                            style: AppTextStyles.button
                                .copyWith(color: AppColors.error),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // 通过按钮
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(ctx);
                            await ref
                                .read(leaveStateProvider.notifier)
                                .approveLeave(
                                  leave.id,
                                  comment: commentController.text.trim(),
                                );
                            if (mounted) {
                              _showSnackBar('已通过该请假申请');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            '通过',
                            style: AppTextStyles.button,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showSnackBar(String message) {
    CampusSnackBar.show(context, message: message, isError: false);
  }

  // ── 详情信息卡 ───────────────────────────────────────────────────
  Widget _buildDetailCard(LeaveApplication leave) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.greyLight.withValues(alpha: 0.6),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          _buildDetailRow('学生姓名', leave.studentName),
          _buildDetailDivider(),
          _buildDetailRow('班级', leave.className),
          _buildDetailDivider(),
          _buildDetailRow('请假类型', leave.leaveType),
          _buildDetailDivider(),
          _buildDetailRow('请假日期', leave.dateRange),
          _buildDetailDivider(),
          _buildDetailRow('请假天数', '${leave.daysCount} 天'),
          if (leave.reason != null && leave.reason!.isNotEmpty) ...[
            _buildDetailDivider(),
            _buildDetailRow('请假原因', leave.reason!),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailDivider() {
    return const Divider(height: 1, thickness: 0.5, color: AppColors.greyLight);
  }

  // ── 请假记录卡片 ─────────────────────────────────────────────────
  Widget _buildLeaveCard(LeaveApplication leave) {
    final isPending = leave.status == 'pending';

    IconData statusIcon;
    Color iconColor;
    if (leave.status == 'approved') {
      statusIcon = Icons.check_circle_rounded;
      iconColor = AppColors.success;
    } else if (leave.status == 'rejected') {
      statusIcon = Icons.cancel_rounded;
      iconColor = AppColors.error;
    } else {
      statusIcon = Icons.schedule_rounded;
      iconColor = AppColors.warning;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.greyLight.withValues(alpha: 0.6),
          width: 0.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 左侧状态图标
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(statusIcon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 16),
          // 中间内容
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${leave.studentName}的${leave.leaveType}申请',
                  style: AppTextStyles.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  leave.dateRange,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  leave.className,
                  style: AppTextStyles.caption,
                ),
                if (!isPending && leave.teacherComment != null &&
                    leave.teacherComment!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    '意见：${leave.teacherComment}',
                    style: AppTextStyles.caption.copyWith(
                      color: leave.statusColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          // 右侧操作区
          isPending
              ? GestureDetector(
                  onTap: () => _showApprovalSheet(context, leave),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        width: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      '审批',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                )
              : Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: leave.statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    leave.statusLabel,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: leave.statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  // ── 空状态 ───────────────────────────────────────────────────────
  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.inbox_outlined,
            size: 64,
            color: AppColors.greyLight,
          ),
          const SizedBox(height: 16),
          Text(message, style: AppTextStyles.titleMedium),
          const SizedBox(height: 8),
          Text(
            '暂时没有相关记录',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final leaveState = ref.watch(leaveStateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('请假审批'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: AppTextStyles.labelMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: AppTextStyles.labelMedium,
          indicatorColor: AppColors.primary,
          indicatorWeight: 2,
          indicatorSize: TabBarIndicatorSize.label,
          dividerColor: AppColors.greyLight.withValues(alpha: 0.5),
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('待审批'),
                  if (leaveState.pendingLeaves.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.warning,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${leaveState.pendingLeaves.length}',
                        style: AppTextStyles.overline.copyWith(
                          color: AppColors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Tab(text: '全部'),
          ],
        ),
      ),
      body: leaveState.isLoading && leaveState.leaves.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : leaveState.error != null && leaveState.leaves.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: AppColors.error),
                      const SizedBox(height: 12),
                      Text(
                        '加载失败：${leaveState.error}',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.error),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => ref
                            .read(leaveStateProvider.notifier)
                            .loadAllLeaves(),
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 1: 待审批
                    _buildListTab(leaveState.pendingLeaves, '暂无待审批申请'),
                    // Tab 2: 全部
                    _buildListTab(leaveState.leaves, '暂无请假记录'),
                  ],
                ),
    );
  }

  Widget _buildListTab(List<LeaveApplication> items, String emptyMessage) {
    if (items.isEmpty) return _buildEmptyState(emptyMessage);
    return RefreshIndicator(
      onRefresh: () =>
          ref.read(leaveStateProvider.notifier).loadAllLeaves(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        itemCount: items.length,
        itemBuilder: (_, i) => _buildLeaveCard(items[i]),
      ),
    );
  }
}
