import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/help_task_service.dart';
import '../../../domain/models/community.dart';
import '../../components/components.dart';
import '../../theme/theme.dart';

class HelpTaskListPage extends ConsumerStatefulWidget {
  const HelpTaskListPage({super.key});

  @override
  ConsumerState<HelpTaskListPage> createState() => _HelpTaskListPageState();
}

class _HelpTaskListPageState extends ConsumerState<HelpTaskListPage>
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
    final state = ref.watch(allHelpTaskStateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CampusAppBar(
        title: '互助请求',
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          labelStyle: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: '火热寻搭'),
            Tab(text: '已找到/完成'),
          ],
        ),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : state.error != null
              ? Center(child: Text(state.error!))
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildList(state.tasks.where((t) => !t.isCompleted).toList()),
                    _buildList(state.tasks.where((t) => t.isCompleted).toList(), isCompletedTab: true),
                  ],
                ),
    );
  }

  Widget _buildList(List<HelpTask> tasks, {bool isCompletedTab = false}) {
    if (tasks.isEmpty) {
      return Center(
        child: Text(
          '暂无请求',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(allHelpTaskStateProvider.notifier).loadTasks(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return _buildTaskCard(task);
        },
      ),
    );
  }

  Widget _buildTaskCard(HelpTask task) {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    final isMe = task.publisherId == currentUserId;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.greyLight.withValues(alpha: 0.6),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_outline,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      task.relativeTime,
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: task.isCompleted
                      ? AppColors.greyLight.withValues(alpha: 0.3)
                      : AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  task.isCompleted ? '已解决' : task.type.label,
                  style: AppTextStyles.caption.copyWith(
                    color: task.isCompleted ? AppColors.textSecondary : AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (task.description != null && task.description!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              task.description!,
              style: AppTextStyles.bodyMedium.copyWith(
                height: 1.5,
                color: AppColors.textPrimary,
              ),
            ),
          ],
          if (task.reward != null && task.reward! > 0) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.monetization_on_outlined, size: 16, color: AppColors.warning),
                const SizedBox(width: 4),
                Text(
                  '悬赏: ¥${task.reward!.toStringAsFixed(0)}',
                  style: AppTextStyles.labelMedium.copyWith(color: AppColors.warning),
                ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          const Divider(height: 1, thickness: 0.5, color: AppColors.greyLight),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (!task.isCompleted && !isMe)
                _buildActionBtn('去咨询', AppColors.primary, () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('已复制发布者联系方式')),
                  );
                }),
              if (!task.isCompleted && isMe)
                _buildActionBtn('已找到搭子/跑腿', AppColors.success, () async {
                  await ref.read(allHelpTaskStateProvider.notifier).completeTask(task.id);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('操作成功，已标记完成')),
                    );
                  }
                }),
              if (task.isCompleted)
                Text('此互助已完成', style: AppTextStyles.caption.copyWith(color: AppColors.textDisabled)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
