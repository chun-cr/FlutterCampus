import 'package:flutter/material.dart';
import '../../../presentation/components/components.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/leave_service.dart';
import '../../../domain/models/leave_application.dart';
import '../../../presentation/theme/theme.dart';
import '../../../ui/components/date_picker_sheet.dart';

class LeaveApplyPage extends ConsumerStatefulWidget {
  const LeaveApplyPage({super.key});

  @override
  ConsumerState<LeaveApplyPage> createState() => _LeaveApplyPageState();
}

class _LeaveApplyPageState extends ConsumerState<LeaveApplyPage> {
  // 表单状态
  String _selectedType = '事假';
  DateTime? _startDate;
  DateTime? _endDate;
  final _reasonController = TextEditingController();
  bool _submitting = false;

  // 我的记录（独立 provider，不复用教师端的 leaveStateProvider）
  final _myLeavesProvider =
      StateNotifierProvider<_MyLeavesNotifier, _MyLeavesState>((ref) {
    return _MyLeavesNotifier(ref.watch(leaveServiceProvider));
  });

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMyLeaves();
    });
  }

  void _loadMyLeaves() {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      ref.read(_myLeavesProvider.notifier).load(userId);
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  // ── 日期选择 ──────────────────────────────────────────────────────────

  Future<void> _pickStartDate() async {
    final date = await DatePickerSheet.showDateTime(
      context,
      initialDate: _startDate ?? DateTime.now(),
      minDate: DateTime.now().subtract(const Duration(days: 30)),
      maxDate: DateTime.now().add(const Duration(days: 90)),
      title: '选择开始时间',
    );
    if (date != null) {
      setState(() {
        _startDate = date;
        // 结束时间不能早于开始时间
        if (_endDate != null && _endDate!.isBefore(date)) {
          _endDate = date;
        }
      });
    }
  }

  Future<void> _pickEndDate() async {
    final date = await DatePickerSheet.showDateTime(
      context,
      initialDate: _endDate ?? (_startDate ?? DateTime.now()),
      minDate: _startDate ?? DateTime.now(),
      maxDate: DateTime.now().add(const Duration(days: 90)),
      title: '选择结束时间',
    );
    if (date != null) setState(() => _endDate = date);
  }

  // ── 提交逻辑 ──────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先选择开始和结束日期')),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      final client = Supabase.instance.client;
      final userId = client.auth.currentUser!.id;

      // 查询用户姓名和部门
      final userResponse = await client
          .from('users')
          .select('name, department')
          .eq('id', userId)
          .single();

      final studentName = userResponse['name'] as String? ?? '未知学生';
      final className =
          userResponse['department'] as String? ?? '未知班级';

      final leave = LeaveApplication(
        id: '',
        studentId: userId,
        studentName: studentName,
        className: className,
        leaveType: _selectedType,
        startDate: _startDate!,
        endDate: _endDate!,
        reason: _reasonController.text.trim().isEmpty
            ? null
            : _reasonController.text.trim(),
        status: 'pending',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await ref.read(leaveServiceProvider).submitLeave(leave);

      if (mounted) {
        // 重置表单
        setState(() {
          _startDate = null;
          _endDate = null;
          _selectedType = '事假';
          _reasonController.clear();
        });
        // 显示成功弹窗
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            backgroundColor: AppColors.surface,
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 成功图标
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: AppColors.success,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '申请已提交',
                    style: AppTextStyles.titleLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '请假申请已成功提交\n等待老师审批',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('我知道了'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
        // 弹窗关闭后刷新申请记录
        if (mounted) _loadMyLeaves();
      }
    } catch (e) {
      if (mounted) {
        CampusSnackBar.show(context, message: '提交失败：$e', isError: false);
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  // ── 构建 ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final myLeavesState = ref.watch(_myLeavesProvider);
    // 实时计算是否有待审批申请
    final hasPending =
        myLeavesState.leaves.any((l) => l.status == 'pending');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.primary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '请假申请',
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 申请表单 ──────────────────────────────────────────────
            _buildFormCard(hasPending: hasPending),
            const SizedBox(height: 40),

            // ── 我的记录 ──────────────────────────────────────────────
            _buildSectionHeader('申请记录', subtitle: 'MY RECORDS'),
            _buildMyLeavesList(myLeavesState),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  // ── 表单卡片 ──────────────────────────────────────────────────────────

  Widget _buildFormCard({required bool hasPending}) {
    return _buildPremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 请假类型选择
          Text(
            '请假类型',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.greyLight.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: ['事假', '病假', '其他'].map((type) {
                final selected = _selectedType == type;
                return GestureDetector(
                  onTap: () => setState(() => _selectedType = type),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.surface
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color:
                                    AppColors.primary.withValues(alpha: 0.08),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              )
                            ]
                          : null,
                    ),
                    child: Text(
                      type,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: selected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),

          // 开始日期
          Text(
            '开始日期',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          _buildDateButton(
            value: _startDate,
            hint: '选择开始日期',
            onTap: _pickStartDate,
          ),
          const SizedBox(height: 16),

          // 结束日期
          Text(
            '结束日期',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          _buildDateButton(
            value: _endDate,
            hint: '选择结束日期',
            onTap: _pickEndDate,
          ),

          // 天数提示
          if (_startDate != null && _endDate != null) ...[
            const SizedBox(height: 8),
            Text(
              '共 ${_endDate!.difference(_startDate!).inDays + 1} 天',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.primaryBrand,
              ),
            ),
          ],

          const SizedBox(height: 24),

          // 请假原因
          Text(
            '请假原因（选填）',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.greyLight,
                width: 0.5,
              ),
            ),
            child: TextField(
              controller: _reasonController,
              maxLines: 4,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: '请描述请假原因…',
                hintStyle: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textDisabled),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // 提交按钮
          SizedBox(
            width: double.infinity,
            child: _submitting
                ? const Center(child: CircularProgressIndicator())
                : TextButton(
                    // 有待审批申请时禁用按鈕
                    onPressed: hasPending ? null : _submit,
                    style: TextButton.styleFrom(
                      backgroundColor: hasPending
                          ? AppColors.greyLight
                          : AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      hasPending ? '已有待审批的申请' : '提交申请',
                      style: AppTextStyles.button.copyWith(
                        color: hasPending
                            ? AppColors.textSecondary
                            : Colors.white,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateButton({
    required DateTime? value,
    required String hint,
    required VoidCallback onTap,
  }) {
    final formatted = value == null
        ? null
        : '${value.year}年${value.month}月${value.day}日 '
            '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.greyLight,
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 16,
              color: value == null
                  ? AppColors.textDisabled
                  : AppColors.primary,
            ),
            const SizedBox(width: 10),
            Text(
              formatted ?? hint,
              style: AppTextStyles.bodyMedium.copyWith(
                color: value == null
                    ? AppColors.textDisabled
                    : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 记录列表 ──────────────────────────────────────────────────────────

  Widget _buildMyLeavesList(_MyLeavesState state) {
    if (state.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.leaves.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Text(
            '暂无请假记录',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return Column(
      children: state.leaves
          .map((leave) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildLeaveCard(leave),
              ))
          .toList(),
    );
  }

  // 撤销确认弹窗
  Future<void> _confirmCancel(LeaveApplication leave) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('确认撤销', style: AppTextStyles.titleMedium),
        content: Text(
          '撤销后本次请假申请将被删除，确认继续？',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              '取消',
              style: AppTextStyles.button.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              '确认',
              style: AppTextStyles.button.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      try {
        await ref.read(leaveServiceProvider).cancelLeave(leave.id);
        _loadMyLeaves();
      } catch (e) {
        if (mounted) {
          CampusSnackBar.show(context, message: '撤销失败：$e', isError: false);
        }
      }
    }
  }

  Widget _buildLeaveCard(LeaveApplication leave) {
    final isPending = leave.status == 'pending';
    IconData statusIcon;
    Color statusColor;
    switch (leave.status) {
      case 'approved':
        statusIcon = Icons.check_circle_outline_rounded;
        statusColor = AppColors.success;
        break;
      case 'rejected':
        statusIcon = Icons.cancel_outlined;
        statusColor = AppColors.error;
        break;
      default:
        statusIcon = Icons.schedule_rounded;
        statusColor = AppColors.warning;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.greyLight.withValues(alpha: 0.6),
          width: 0.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 状态图标
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(statusIcon, color: statusColor, size: 20),
          ),
          const SizedBox(width: 14),
          // 主体信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${leave.leaveType} · ${leave.dateRange}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        leave.statusLabel,
                        style: AppTextStyles.caption.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '共 ${leave.daysCount} 天',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                if (leave.teacherComment != null &&
                    leave.teacherComment!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    '审批意见：${leave.teacherComment}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // 撤销按钮（仅待审批状态显示）
          if (isPending) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _confirmCancel(leave),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.4),
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '撤销',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── 通用组件 ──────────────────────────────────────────────────────────

  Widget _buildPremiumCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.greyLight.withValues(alpha: 0.6),
          width: 0.5,
        ),
      ),
      child: child,
    );
  }

  Widget _buildSectionHeader(String title, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textDisabled,
                letterSpacing: 0.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── 局部 State/Notifier（仅用于本页面的「我的记录」）────────────────────

class _MyLeavesState {
  const _MyLeavesState({
    this.leaves = const [],
    this.isLoading = false,
    this.error,
  });
  final List<LeaveApplication> leaves;
  final bool isLoading;
  final String? error;

  _MyLeavesState copyWith({
    List<LeaveApplication>? leaves,
    bool? isLoading,
    String? error,
  }) =>
      _MyLeavesState(
        leaves: leaves ?? this.leaves,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class _MyLeavesNotifier extends StateNotifier<_MyLeavesState> {
  _MyLeavesNotifier(this._service) : super(const _MyLeavesState());

  final LeaveService _service;

  Future<void> load(String studentId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final leaves = await _service.fetchMyLeaves(studentId);
      state = state.copyWith(leaves: leaves, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}
