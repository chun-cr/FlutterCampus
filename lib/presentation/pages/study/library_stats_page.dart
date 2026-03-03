import 'package:flutter/material.dart';
import '../../components/components.dart';
import '../../theme/theme.dart';

class LibraryStatsPage extends StatelessWidget {
  const LibraryStatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CampusAppBar(title: '阅读报告', showBackButton: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            _buildSummaryCard(),
            const SizedBox(height: AppSpacing.lg),
            _buildChartSection('借阅统计 (近6个月)', const _LibraryBarChart()),
            const SizedBox(height: AppSpacing.lg),
            _buildChartSection('阅读偏好 (分类统计)', const _LibraryPieChart()),
            const SizedBox(height: AppSpacing.lg),
            _buildReadingRank(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return CampusCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('本学期阅读', '12', '本'),
              _buildStatItem('累计借阅', '34', '本'),
              _buildStatItem('超越同学', '92', '%'),
            ],
          ),
          const Divider(height: 32),
          Text(
            '最近读过: 《深入浅出Flutter学习指南》',
            style: AppTextStyles.caption.copyWith(fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, String unit) {
    return Column(
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
              TextSpan(text: ' $unit', style: AppTextStyles.caption),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildChartSection(String title, Widget chart) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: AppTextStyles.titleSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        CampusCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: SizedBox(height: 200, width: double.infinity, child: chart),
        ),
      ],
    );
  }

  Widget _buildReadingRank() {
    return CampusCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events, color: Colors.orange),
              const SizedBox(width: 8),
              Text(
                '本月读书达人榜',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildRankItem(1, '王小明', 15),
          _buildRankItem(2, '李梅', 12),
          _buildRankItem(3, '张伟', 10),
        ],
      ),
    );
  }

  Widget _buildRankItem(int rank, String name, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: rank == 1
                  ? Colors.orange
                  : (rank == 2
                        ? Colors.grey
                        : (rank == 3 ? Colors.brown : AppColors.greyLight)),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(name, style: AppTextStyles.bodyMedium),
          const Spacer(),
          Text(
            '$count 本',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey),
          ),
        ],
      ),
    );
  }
}

class _LibraryBarChart extends StatelessWidget {
  const _LibraryBarChart();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _BarChartPainter());
  }
}

class _LibraryPieChart extends StatelessWidget {
  const _LibraryPieChart();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _PieChartPainter());
  }
}

class _BarChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.primary;
    final data = [4, 6, 3, 8, 5, 7];
    final max = 10.0;
    final barWidth = size.width / (data.length * 2);

    for (var i = 0; i < data.length; i++) {
      final barHeight = (data[i] / max) * size.height;
      final x = barWidth * (i * 2 + 0.5);
      final y = size.height - barHeight;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barWidth, barHeight),
          const Radius.circular(4),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _PieChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.height / 2;
    final paint = Paint()..style = PaintingStyle.fill;

    final data = [0.4, 0.3, 0.2, 0.1];
    final colors = [
      AppColors.primary,
      Colors.orange,
      Colors.green,
      Colors.blue,
    ];

    double startAngle = 0;
    for (var i = 0; i < data.length; i++) {
      paint.color = colors[i];
      final sweepAngle = data[i] * 2 * 3.14159;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
