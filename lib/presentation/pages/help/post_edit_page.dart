import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../components/components.dart';
import '../../theme/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/community.dart';
import '../../../core/services/lost_and_found_service.dart';
import '../../../core/services/second_hand_service.dart';
import '../../../core/services/help_task_service.dart';

enum PostType { lostAndFound, secondHand, helpTask }

/// 失物招领子类型
enum LostFoundSubType { found, lost }

// ---------------------------------------------------------------------------
// 文案配置
// ---------------------------------------------------------------------------
class _PostCopy {
  const _PostCopy({
    required this.appBarTitle,
    required this.typeTag,
    required this.typeIcon,
    required this.titleLabel,
    required this.titleHint,
    required this.descLabel,
    required this.descHint,
    required this.locationLabel,
    required this.locationHint,
    required this.contactLabel,
    required this.contactHint,
    required this.submitLabel,
    required this.successText,
  });

  final String appBarTitle;
  final String typeTag;
  final IconData typeIcon;
  final String titleLabel;
  final String titleHint;
  final String descLabel;
  final String descHint;
  final String locationLabel;
  final String locationHint;
  final String contactLabel;
  final String contactHint;
  final String submitLabel;
  final String successText;
}

// 捡到物品
const _copyFound = _PostCopy(
  appBarTitle: '发布失物招领',
  typeTag: '捡到物品',
  typeIcon: Icons.volunteer_activism_outlined,
  titleLabel: '物品名称',
  titleHint: '如"黑色钱包"、"蓝色水杯"',
  descLabel: '物品描述',
  descHint: '描述外观、品牌、特征等，帮失主快速确认',
  locationLabel: '拾取地点',
  locationHint: '如"图书馆一楼"、"三食堂门口"',
  contactLabel: '认领联系方式',
  contactHint: '留下微信或手机号，方便失主联系你',
  submitLabel: '发布招领信息',
  successText: '招领信息已发布！',
);

// 丢失物品
const _copyLost = _PostCopy(
  appBarTitle: '发布寻物启事',
  typeTag: '丢失物品',
  typeIcon: Icons.search_rounded,
  titleLabel: '物品名称',
  titleHint: '如"学生证"、"黑色充电宝"',
  descLabel: '物品描述',
  descHint: '描述外观、品牌、特征等，越详细越容易找回',
  locationLabel: '丢失地点',
  locationHint: '如"五教302"、"体育馆附近"',
  contactLabel: '失主联系方式',
  contactHint: '留下微信或手机号，捡到的同学联系你',
  submitLabel: '发布寻物启事',
  successText: '寻物启事已发布！',
);

const _copyMap = {
  PostType.secondHand: _PostCopy(
    appBarTitle: '发布闲置交换',
    typeTag: '闲置交换',
    typeIcon: Icons.swap_horiz_rounded,
    titleLabel: '物品名称',
    titleHint: '如"九成新高数教材"、"台灯"',
    descLabel: '物品详情',
    descHint: '描述成色、使用情况、是否有划痕等',
    locationLabel: '交易地点',
    locationHint: '如"宿舍楼下"、"南门附近"',
    contactLabel: '卖家联系方式',
    contactHint: '留下微信或手机号，方便买家咨询',
    submitLabel: '发布闲置信息',
    successText: '闲置信息已发布！',
  ),
  PostType.helpTask: _PostCopy(
    appBarTitle: '发布找搭子',
    typeTag: '找搭子',
    typeIcon: Icons.people_outline_rounded,
    titleLabel: '活动主题',
    titleHint: '如"找自习搭子"、"组队打羽毛球"',
    descLabel: '活动说明',
    descHint: '说明时间、人数、要求，让感兴趣的人快速了解',
    locationLabel: '集合地点',
    locationHint: '如"东区自习室"、"操场北门"',
    contactLabel: '招募联系方式',
    contactHint: '留下微信或手机号，感兴趣的人来找你',
    submitLabel: '发布招募帖子',
    successText: '招募帖子已发布！',
  ),
};

// ---------------------------------------------------------------------------
// 页面
// ---------------------------------------------------------------------------
class PostEditPage extends ConsumerStatefulWidget {
  const PostEditPage({super.key, required this.type});
  final PostType type;

  @override
  ConsumerState<PostEditPage> createState() => _PostEditPageState();
}

class _PostEditPageState extends ConsumerState<PostEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _priceController = TextEditingController();
  final _contactController = TextEditingController();
  HelpTaskType _selectedHelpType = HelpTaskType.errand;

  static const Color _accent = AppColors.textPrimary;

  LostFoundSubType _subType = LostFoundSubType.found;

  _PostCopy get _copy {
    if (widget.type == PostType.lostAndFound) {
      return _subType == LostFoundSubType.found ? _copyFound : _copyLost;
    }
    return _copyMap[widget.type]!;
  }

  final Map<LostFoundSubType, Map<String, String>> _drafts = {};

  Future<void> _switchSubType(LostFoundSubType newType) async {
    if (_subType == newType) return;

    final hasContent =
        _titleController.text.isNotEmpty ||
        _descriptionController.text.isNotEmpty ||
        _locationController.text.isNotEmpty ||
        _contactController.text.isNotEmpty;

    if (hasContent) {
      final shouldSave = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('提示', style: AppTextStyles.titleMedium),
          content: Text('是否保存当前填写的信息为草稿？', style: AppTextStyles.bodyMedium),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                '不保存',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.error,
                ),
              ),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('保存'),
            ),
          ],
        ),
      );

      if (shouldSave == true) {
        _drafts[_subType] = {
          'title': _titleController.text,
          'desc': _descriptionController.text,
          'loc': _locationController.text,
          'contact': _contactController.text,
        };
      } else {
        _drafts.remove(_subType);
      }
    }

    setState(() => _subType = newType);

    final draft = _drafts[_subType];
    if (draft != null) {
      _titleController.text = draft['title'] ?? '';
      _descriptionController.text = draft['desc'] ?? '';
      _locationController.text = draft['loc'] ?? '';
      _contactController.text = draft['contact'] ?? '';
    } else {
      _titleController.clear();
      _descriptionController.clear();
      _locationController.clear();
      _contactController.clear();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  bool _isSubmitting = false;

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSubmitting = true);

      try {
        if (widget.type == PostType.lostAndFound) {
          final item = LostAndFound(
            id: '', // Supabase generates ID
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            location: _locationController.text.trim(),
            type: _subType == LostFoundSubType.found
                ? LostFoundType.found
                : LostFoundType.lost,
            publisherId: '', // Added by service
            contactInfo: _contactController.text.trim(),
            createdAt: DateTime.now(),
          );
          await ref.read(helpLostAndFoundStateProvider.notifier).addItem(item);
        } else if (widget.type == PostType.secondHand) {
          final price = double.tryParse(_priceController.text.trim()) ?? 0;
          final item = SecondHandItem(
            id: '',
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            price: price,
            sellerId: '',
            createdAt: DateTime.now(),
          );
          await ref.read(helpSecondHandStateProvider.notifier).addItem(item);
        } else {
          // HelpTask
          final title = _titleController.text.trim();
          final desc = _descriptionController.text.trim();
          final loc = _locationController.text.trim();
          final contact = _contactController.text.trim();
          final fullDesc = '集合地点: $loc\n联系方式: $contact\n\n活动说明:\n$desc';

          final task = HelpTask(
            id: '',
            title: title,
            description: fullDesc,
            type: _selectedHelpType,
            publisherId: '',
            createdAt: DateTime.now(),
          );
          await ref.read(helpTaskStateProvider.notifier).addTask(task);
        }

        if (mounted) {
          CampusSnackBar.show(
            context,
            message: _copy.successText,
            isError: false,
          );
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          CampusSnackBar.show(context, message: '发布失败: $e', isError: true);
        }
      } finally {
        if (mounted) setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final copy = _copy;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          copy.appBarTitle,
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
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _accent.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(copy.typeIcon, color: _accent, size: 13),
                    const SizedBox(width: 4),
                    Text(
                      copy.typeTag,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: _accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 失物招领专属：捡到 / 丢失 切换
              if (widget.type == PostType.lostAndFound) ...[
                _buildSubTypeToggle(),
                const SizedBox(height: 20),
              ],

              _buildImageSection(),
              const SizedBox(height: 20),
              _buildFormCard(copy),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: _accent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: AppColors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          copy.submitLabel,
                          style: AppTextStyles.button.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 捡到 / 丢失 切换器
  // ---------------------------------------------------------------------------
  Widget _buildSubTypeToggle() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.greyLight, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildToggleOption(
            label: '我捡到了',
            icon: Icons.volunteer_activism_outlined,
            isSelected: _subType == LostFoundSubType.found,
            onTap: () => _switchSubType(LostFoundSubType.found),
          ),
          Container(width: 0.5, height: 24, color: AppColors.greyLight),
          _buildToggleOption(
            label: '我丢失了',
            icon: Icons.search_rounded,
            isSelected: _subType == LostFoundSubType.lost,
            onTap: () => _switchSubType(LostFoundSubType.lost),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleOption({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isSelected ? _accent : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected ? AppColors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: AppTextStyles.labelMedium.copyWith(
                  color: isSelected ? AppColors.white : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 图片上传区
  // ---------------------------------------------------------------------------
  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('上传图片', style: AppTextStyles.labelMedium),
            const SizedBox(width: 6),
            Text(
              '最多9张',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 88,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              GestureDetector(
                onTap: () {
                  // TODO: Implement image picking
                },
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.greyLight, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.add_photo_alternate_outlined,
                        color: _accent,
                        size: 26,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '添加图片',
                        style: AppTextStyles.caption.copyWith(
                          color: _accent,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ...List.generate(
                3,
                (i) => Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.greyLight, width: 1),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 表单卡片
  // ---------------------------------------------------------------------------
  Widget _buildFormCard(_PostCopy copy) {
    return Container(
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
      child: Column(
        children: [
          _buildFormRow(
            icon: Icons.title_rounded,
            label: copy.titleLabel,
            child: TextFormField(
              controller: _titleController,
              decoration: _buildInputDecoration(copy.titleHint),
              validator: (v) =>
                  v?.isEmpty ?? true ? '请输入${copy.titleLabel}' : null,
              style: AppTextStyles.bodyMedium,
            ),
          ),

          _buildRowDivider(),

          _buildFormRow(
            icon: Icons.notes_rounded,
            label: copy.descLabel,
            child: TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: _buildInputDecoration(copy.descHint),
              validator: (v) =>
                  v?.isEmpty ?? true ? '请输入${copy.descLabel}' : null,
              style: AppTextStyles.bodyMedium,
            ),
          ),

          if (widget.type == PostType.helpTask) ...[
            _buildRowDivider(),
            _buildFormRow(
              icon: Icons.category_outlined,
              label: '互助分类',
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: HelpTaskType.values.map((type) {
                  final isSelected = _selectedHelpType == type;
                  return GestureDetector(
                    onTap: () {
                      if (_selectedHelpType != type) {
                        setState(() => _selectedHelpType = type);
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.greyLight.withValues(alpha: 0.8),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        type.label,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],

          if (widget.type == PostType.secondHand) ...[
            _buildRowDivider(),
            _buildFormRow(
              icon: Icons.sell_outlined,
              label: '期望价格 (元)',
              child: TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: _buildInputDecoration('填写金额，免费可填 0'),
                validator: (v) => v?.isEmpty ?? true ? '请输入价格' : null,
                style: AppTextStyles.bodyMedium,
              ),
            ),
          ],

          _buildRowDivider(),

          _buildFormRow(
            icon: Icons.location_on_outlined,
            label: copy.locationLabel,
            child: TextFormField(
              controller: _locationController,
              decoration: _buildInputDecoration(copy.locationHint),
              validator: (v) =>
                  v?.isEmpty ?? true ? '请输入${copy.locationLabel}' : null,
              style: AppTextStyles.bodyMedium,
            ),
          ),

          _buildRowDivider(),

          _buildFormRow(
            icon: Icons.phone_outlined,
            label: copy.contactLabel,
            isLast: true,
            child: TextFormField(
              controller: _contactController,
              decoration: _buildInputDecoration(copy.contactHint),
              validator: (v) =>
                  v?.isEmpty ?? true ? '请输入${copy.contactLabel}' : null,
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormRow({
    required IconData icon,
    required String label,
    required Widget child,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 14, 16, isLast ? 14 : 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.circle, size: 0),
              Icon(icon, size: 15, color: _accent),
              const SizedBox(width: 5),
              Text(
                label,
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _buildRowDivider() {
    return const Divider(
      height: 0.5,
      thickness: 0.5,
      color: AppColors.greyLight,
      indent: 16,
      endIndent: 16,
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textDisabled,
      ),
      filled: true,
      fillColor: AppColors.background,
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
        borderSide: const BorderSide(color: _accent),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      isDense: true,
    );
  }
}
