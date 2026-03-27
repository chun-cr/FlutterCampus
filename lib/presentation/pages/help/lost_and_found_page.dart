import 'package:flutter/material.dart';
import '../../components/campus_snackbar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/lost_and_found_service.dart';
import '../../../domain/models/community.dart';
import '../../theme/theme.dart';

class LostAndFoundPage extends ConsumerStatefulWidget {
  const LostAndFoundPage({super.key});

  @override
  ConsumerState<LostAndFoundPage> createState() => _LostAndFoundPageState();
}

class _LostAndFoundPageState extends ConsumerState<LostAndFoundPage>
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
    final state = ref.watch(allLostAndFoundStateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('失物招领中心', style: AppTextStyles.titleLarge),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelStyle: AppTextStyles.labelLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: AppTextStyles.labelLarge,
          labelColor: AppColors.primaryBrand,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primaryBrand,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: const [
            Tab(text: '寻找中'),
            Tab(text: '已寻回'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildItemList(state, resolved: false),
          _buildItemList(state, resolved: true),
        ],
      ),
    );
  }

  Widget _buildItemList(LostAndFoundState state, {required bool resolved}) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryBrand),
      );
    }

    final filteredItems = state.items
        .where((i) => i.isResolved == resolved)
        .toList();

    if (filteredItems.isEmpty) {
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
            Text(
              resolved ? '暂无已寻回记录' : '暂无待寻回物品',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        final item = filteredItems[index];
        return _buildItemCard(item);
      },
    );
  }

  Widget _buildItemCard(LostAndFound item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showItemDetailsBottomSheet(context, item),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildTypeBadge(item),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title, style: AppTextStyles.titleMedium),
                      const SizedBox(height: 4),
                      Text(
                        '地点: ${item.location}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (item.isResolved && item.resolverName != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '领取人: ${item.resolverName}',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.success,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      item.relativeTime,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (!item.isResolved)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Icon(
                          Icons.chevron_right,
                          size: 16,
                          color: AppColors.greyLight,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeBadge(LostAndFound item) {
    final isLost = item.type == LostFoundType.lost;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isLost
            ? AppColors.error.withOpacity(0.1)
            : AppColors.primaryBrand.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        item.type.label,
        style: AppTextStyles.overline.copyWith(
          color: isLost ? AppColors.error : AppColors.primaryBrand,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showItemDetailsBottomSheet(BuildContext context, LostAndFound item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 16),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.greyLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildTypeBadge(item),
                        const Spacer(),
                        Text(item.relativeTime, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(item.title, style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    if (item.description.isNotEmpty) ...[
                      Text('详情描述', style: AppTextStyles.labelLarge.copyWith(color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      Text(item.description, style: AppTextStyles.bodyMedium),
                      const SizedBox(height: 20),
                    ],
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 20, color: AppColors.primaryBrand),
                        const SizedBox(width: 8),
                        Expanded(child: Text(item.location, style: AppTextStyles.bodyMedium)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (!item.isResolved && item.contactInfo != null && item.contactInfo!.isNotEmpty)
                      Row(
                        children: [
                          const Icon(Icons.phone_outlined, size: 20, color: AppColors.primaryBrand),
                          const SizedBox(width: 8),
                          Expanded(child: Text('联系方式: ${item.contactInfo}', style: AppTextStyles.bodyMedium)),
                        ],
                      ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            if (!item.isResolved)
              Container(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4)),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          CampusSnackBar.show(context, message: '发布者联系方式：${item.contactInfo ?? "暂未提供"}', isError: false);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          side: const BorderSide(color: AppColors.primaryBrand),
                        ),
                        child: Text('去联系', style: AppTextStyles.button.copyWith(color: AppColors.primaryBrand)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _showResolveDialog(item);
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primaryBrand,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          item.type == LostFoundType.lost ? '我捡到了' : '认领物品',
                          style: AppTextStyles.button.copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showResolveDialog(LostAndFound item) {
    final nameController = TextEditingController();
    final idController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('确认寻回/认领', style: AppTextStyles.titleLarge),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('请输入认领人身份信息以完成流程。', style: AppTextStyles.bodyMedium),
              const SizedBox(height: 20),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: '姓名',
                  hintText: '输入您的真实姓名',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                validator: (v) => v?.isEmpty ?? true ? '请输入姓名' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: idController,
                decoration: InputDecoration(
                  labelText: '学号/工号',
                  hintText: '输入您的校园卡号',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.badge_outlined),
                ),
                validator: (v) => v?.isEmpty ?? true ? '请输入学号/工号' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '取消',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBrand,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final success = await ref
                    .read(allLostAndFoundStateProvider.notifier)
                    .resolveItem(
                      item.id,
                      nameController.text,
                      idController.text,
                    );
                if (success && mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('已确认寻回状态，谢谢！')));
                }
              }
            },
            child: const Text('确认提交'),
          ),
        ],
      ),
    );
  }
}
