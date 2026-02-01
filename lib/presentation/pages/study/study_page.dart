import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../components/components.dart';
import '../../theme/theme.dart';

class StudyPage extends ConsumerWidget {
  const StudyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 智能课表模块
          _buildSectionHeader('智能课表'),
          CampusCard(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.access_time_filled, color: AppColors.primary),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('下节课：高等数学', style: AppTextStyles.titleSmall),
                          Text('08:00 - 09:40 @ 第一教学楼301', style: AppTextStyles.caption),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('导航', style: AppTextStyles.caption.copyWith(color: Colors.white)),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildQuickAction(Icons.calendar_month, '完整课表'),
                    _buildQuickAction(Icons.notifications_active, '课程提醒'),
                    _buildQuickAction(Icons.school, '教室查询'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // 2. 图书馆助手
          _buildSectionHeader('图书馆助手'),
          CampusCard(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildLibraryStat('当前借阅', '3', '即将到期: 1'),
                    ),
                    Container(width: 1, height: 40, color: AppColors.greyLight),
                    Expanded(
                      child: _buildLibraryStat('自习室', '余 42', '三楼 A区'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                CampusButton(
                  text: '预约座位 / 检索图书',
                  onPressed: () {},
                  type: CampusButtonType.secondary,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // 3. 学业进度看板 (Mock Chart)
          _buildSectionHeader('学业进度'),
          CampusCard(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('本学期平均绩点: 3.8', style: AppTextStyles.titleSmall.copyWith(color: AppColors.primary)),
                const SizedBox(height: AppSpacing.md),
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomPaint(
                    painter: _MockChartPainter(),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.insights, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text('查看详细成绩分析', style: AppTextStyles.caption),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 80), // Bottom padding for scrolling
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm, left: 4),
      child: Text(title, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildQuickAction(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: AppColors.textSecondary),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }

  Widget _buildLibraryStat(String label, String value, String sub) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.headlineSmall.copyWith(color: AppColors.primary)),
        Text(label, style: AppTextStyles.caption),
        Text(sub, style: AppTextStyles.caption.copyWith(fontSize: 10, color: AppColors.error)),
      ],
    );
  }
}

class _MockChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withOpacity(0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height * 0.7);
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.4, size.width * 0.5, size.height * 0.6);
    path.quadraticBezierTo(size.width * 0.75, size.height * 0.8, size.width, size.height * 0.3);
    
    canvas.drawPath(path, paint);

    // Dots
    final dotPaint = Paint()..color = AppColors.primary;
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.6), 4, dotPaint);
    canvas.drawCircle(Offset(size.width, size.height * 0.3), 4, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
