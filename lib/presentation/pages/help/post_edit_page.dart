import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../components/components.dart';
import '../../theme/theme.dart';

enum PostType { lostAndFound, secondHand, helpTask }

class PostEditPage extends StatefulWidget {
  const PostEditPage({super.key, required this.type});
  final PostType type;

  @override
  State<PostEditPage> createState() => _PostEditPageState();
}

class _PostEditPageState extends State<PostEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _priceController = TextEditingController();
  final _contactController = TextEditingController();

  String get _title {
    switch (widget.type) {
      case PostType.lostAndFound:
        return '发布失物招领';
      case PostType.secondHand:
        return '发布闲置交易';
      case PostType.helpTask:
        return '发布互助/找搭子';
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

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: Implement actual submission logic
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('发布成功！')));
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CampusAppBar(title: _title, showBackButton: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 图片上传区域 (Mock)
              _buildImageUploader(),
              const SizedBox(height: AppSpacing.lg),

              // 标题
              _buildLabel('标题'),
              TextFormField(
                controller: _titleController,
                decoration: _buildInputDecoration('输入标题，如“捡到一个钱包”'),
                validator: (v) => v?.isEmpty ?? true ? '请输入标题' : null,
              ),
              const SizedBox(height: AppSpacing.md),

              // 详情描述
              _buildLabel('详情描述'),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: _buildInputDecoration('详细描述一下，提高寻回/交易成功率...'),
                validator: (v) => v?.isEmpty ?? true ? '请输入描述' : null,
              ),
              const SizedBox(height: AppSpacing.md),

              if (widget.type == PostType.secondHand) ...[
                _buildLabel('价格 (元)'),
                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: _buildInputDecoration('0.00'),
                  validator: (v) => v?.isEmpty ?? true ? '请输入价格' : null,
                ),
                const SizedBox(height: AppSpacing.md),
              ],

              _buildLabel(widget.type == PostType.helpTask ? '集合/互助地点' : '地点'),
              TextFormField(
                controller: _locationController,
                decoration: _buildInputDecoration('如“二食堂”、“五教302”'),
                validator: (v) => v?.isEmpty ?? true ? '请输入地点' : null,
              ),
              const SizedBox(height: AppSpacing.md),

              _buildLabel('联系方式'),
              TextFormField(
                controller: _contactController,
                decoration: _buildInputDecoration('如：微信、手机号'),
                validator: (v) => v?.isEmpty ?? true ? '请输入联系方式' : null,
              ),
              const SizedBox(height: 32),

              CampusButton(text: '确认发布', onPressed: _submit),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(label, style: AppTextStyles.titleSmall),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  Widget _buildImageUploader() {
    return GestureDetector(
      onTap: () {
        // TODO: Implement image picking
      },
      child: Container(
        height: 120,
        width: 120,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.greyLight,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_a_photo_outlined,
              color: AppColors.grey,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text('上传图片', style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}
