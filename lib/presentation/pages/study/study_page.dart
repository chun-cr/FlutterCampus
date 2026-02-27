import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../components/components.dart';
import '../../theme/theme.dart';

class StudyPage extends ConsumerWidget {
  const StudyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. 智能课表模块
              _buildSectionHeader('Smart Schedule'),
              _buildPremiumCard(
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.schedule_rounded, color: AppColors.primary, size: 24),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Advanced Mathematics', style: AppTextStyles.titleMedium),
                              const SizedBox(height: 4),
                              Text('08:00 - 09:40', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                              const SizedBox(height: 2),
                              Text('Building 1 · Room 301', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 0.5),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Text('Navigate', style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary)),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Divider(height: 1, thickness: 0.5, color: AppColors.greyLight),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildQuickAction(Icons.calendar_today_outlined, 'Full Schedule'),
                        _buildQuickAction(Icons.notifications_none_outlined, 'Reminders'),
                        _buildQuickAction(Icons.meeting_room_outlined, 'Find Room'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // 2. 图书馆助手
              _buildSectionHeader('Library Services'),
              _buildPremiumCard(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildLibraryStat('Active Loans', '3', '1 returning soon', AppColors.textPrimary),
                        ),
                        Container(width: 1, height: 48, color: AppColors.greyLight.withOpacity(0.5)),
                        Expanded(
                          child: _buildLibraryStat('Study Rooms', '42', 'Zone A available', AppColors.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => context.push('/library'),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: AppColors.primary.withOpacity(0.05),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text(
                          'Reserve Seat / Search Books',
                          style: AppTextStyles.button.copyWith(color: AppColors.primary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // 3. 学业进度看板 (Mock Chart)
              _buildSectionHeader('Academic Progress'),
              _buildPremiumCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Term GPA', style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary)),
                            const SizedBox(height: 4),
                            Text('3.8', style: AppTextStyles.headlineLarge.copyWith(color: AppColors.primary, fontWeight: FontWeight.w300)),
                          ],
                        ),
                        Text('+0.2 from last term', style: AppTextStyles.caption.copyWith(color: AppColors.success)),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.background.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: CustomPaint(
                        painter: _MockChartPainter(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_graph_rounded, size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 8),
                          Text('View Detailed Analysis', style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 80), // Bottom padding for scrolling
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.greyLight.withOpacity(0.6), width: 0.5),
      ),
      child: child,
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.labelLarge.copyWith(
          letterSpacing: 1.5,
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.textPrimary.withOpacity(0.7), size: 28),
        const SizedBox(height: 12),
        Text(label, style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildLibraryStat(String label, String value, String sub, Color valueColor) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.headlineMedium.copyWith(color: valueColor, fontWeight: FontWeight.w300)),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.labelMedium),
        const SizedBox(height: 6),
        Text(sub, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
      ],
    );
  }
}
class _MockChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withOpacity(0.6)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height * 0.85);
    path.quadraticBezierTo(size.width * 0.3, size.height * 0.6, size.width * 0.5, size.height * 0.7);
    path.quadraticBezierTo(size.width * 0.8, size.height * 0.9, size.width, size.height * 0.2);
    
    canvas.drawPath(path, paint);

    // Gradient fill under the line
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.primary.withOpacity(0.15),
          AppColors.primary.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTRB(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(fillPath, fillPaint);

    // Subtle Dots
    final dotPaint = Paint()..color = AppColors.surface;
    final dotBorderPaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final points = [
      Offset(size.width * 0.5, size.height * 0.7),
      Offset(size.width, size.height * 0.2),
    ];

    for (var point in points) {
      canvas.drawCircle(point, 4, dotPaint);
      canvas.drawCircle(point, 4, dotBorderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
