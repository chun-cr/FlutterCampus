import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../components/components.dart';
import '../../theme/theme.dart';

// ---------------------------------------------------------------------------
// 阅读报告页（Mock 数据 + 极简黑白灰视觉）
// ---------------------------------------------------------------------------
class LibraryStatsPage extends StatelessWidget {
  const LibraryStatsPage({super.key});

  static const List<_MonthlyBorrowData> _monthlyBorrowData = [
    _MonthlyBorrowData(month: '9月', count: 2),
    _MonthlyBorrowData(month: '10月', count: 5),
    _MonthlyBorrowData(month: '11月', count: 1),
    _MonthlyBorrowData(month: '12月', count: 3),
    _MonthlyBorrowData(month: '1月', count: 4),
    _MonthlyBorrowData(month: '2月', count: 8),
  ];

  static const List<_CategoryStat> _categoryStats = [
    _CategoryStat(
      label: '计算机类',
      percent: 45,
      color: Color(0xFF1A1A1A),
    ),
    _CategoryStat(
      label: '文学类',
      percent: 25,
      color: Color(0xFF555555),
    ),
    _CategoryStat(
      label: '历史类',
      percent: 20,
      color: Color(0xFF999999),
    ),
    _CategoryStat(
      label: '其他',
      percent: 10,
      color: Color(0xFFCCCCCC),
    ),
  ];

  static const List<_ReadingRankData> _rankingData = [
    _ReadingRankData(name: '陈红', count: 8),
    _ReadingRankData(name: '李圣', count: 6),
    _ReadingRankData(name: '赵小青', count: 5),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: const CampusAppBar(title: '阅读报告', showBackButton: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SummaryCard(),
            const SizedBox(height: 24),
            const _SectionHeader(
              title: '借阅趋势',
              subtitle: 'BORROWING TREND',
            ),
            const SizedBox(height: 12),
            _CardContainer(
              child: _BorrowBarChart(data: _monthlyBorrowData),
            ),
            const SizedBox(height: 24),
            const _SectionHeader(
              title: '阅读偏好',
              subtitle: 'CATEGORY BREAKDOWN',
            ),
            const SizedBox(height: 12),
            _CardContainer(
              child: _CategoryPieSection(data: _categoryStats),
            ),
            const SizedBox(height: 24),
            const _SectionHeader(
              title: '本月读书达人榜',
              subtitle: 'MONTHLY TOP READERS',
            ),
            const SizedBox(height: 12),
            _CardContainer(
              child: Column(
                children: List.generate(
                  _rankingData.length,
                  (index) => Padding(
                    padding: EdgeInsets.only(
                      bottom: index == _rankingData.length - 1 ? 0 : 12,
                    ),
                    child: _RankItem(
                      rank: index + 1,
                      data: _rankingData[index],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 通用卡片容器
// ---------------------------------------------------------------------------
class _CardContainer extends StatelessWidget {
  const _CardContainer({required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.06),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ---------------------------------------------------------------------------
// 模块标题
// ---------------------------------------------------------------------------
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
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
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 顶部摘要卡片
// ---------------------------------------------------------------------------
class _SummaryCard extends StatelessWidget {
  const _SummaryCard();

  @override
  Widget build(BuildContext context) {
    return _CardContainer(
      child: Column(
        children: [
          Row(
            children: const [
              Expanded(
                child: _SummaryStatItem(
                  value: '7',
                  unit: '本',
                  label: '本学期阅读',
                ),
              ),
              _SummaryDivider(),
              Expanded(
                child: _SummaryStatItem(
                  value: '23',
                  unit: '本',
                  label: '累计借阅',
                ),
              ),
              _SummaryDivider(),
              Expanded(
                child: _SummaryStatItem(
                  value: '78',
                  unit: '%',
                  label: '超越同学',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.menu_book_outlined,
                  size: 18,
                  color: Color(0xFF666666),
                ),
                const SizedBox(width: 8),
                Text(
                  '最近读过',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '《深入理解计算机系统》',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryStatItem extends StatelessWidget {
  const _SummaryStatItem({
    required this.value,
    required this.unit,
    required this.label,
  });

  final String value;
  final String unit;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextSpan(
                text: unit,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: AppTextStyles.overline.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _SummaryDivider extends StatelessWidget {
  const _SummaryDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 52,
      color: const Color(0xFFE5E5E5),
    );
  }
}

// ---------------------------------------------------------------------------
// 借阅柱状图
// ---------------------------------------------------------------------------
class _BorrowBarChart extends StatelessWidget {
  const _BorrowBarChart({required this.data});

  final List<_MonthlyBorrowData> data;

  @override
  Widget build(BuildContext context) {
    final maxValue = data
        .map((item) => item.count)
        .reduce((current, next) => current > next ? current : next);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '近 6 个月借阅走势',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 220,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(data.length, (index) {
              final item = data[index];
              final isPeak = item.count == maxValue;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: index == data.length - 1 ? 0 : 10),
                  child: _BarColumn(
                    month: item.month,
                    count: item.count,
                    maxValue: maxValue,
                    color: isPeak
                        ? const Color(0xFF1A1A1A)
                        : const Color(0xFFCCCCCC),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _BarColumn extends StatelessWidget {
  const _BarColumn({
    required this.month,
    required this.count,
    required this.maxValue,
    required this.color,
  });

  final String month;
  final int count;
  final int maxValue;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final heightFactor = maxValue == 0 ? 0.0 : count / maxValue;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '$count',
          style: AppTextStyles.overline.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: heightFactor.clamp(0.0, 1.0),
              widthFactor: 0.78,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          month,
          style: AppTextStyles.overline.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 饼图 + 图例
// ---------------------------------------------------------------------------
class _CategoryPieSection extends StatelessWidget {
  const _CategoryPieSection({required this.data});

  final List<_CategoryStat> data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '分类借阅分布',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              flex: 4,
              child: AspectRatio(
                aspectRatio: 1,
                child: CustomPaint(
                  painter: _PieChartPainter(data: data),
                  child: Center(
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '23本',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 5,
              child: Column(
                children: data
                    .map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _LegendItem(item: item),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.item});

  final _CategoryStat item;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: item.color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            item.label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          '${item.percent}%',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _PieChartPainter extends CustomPainter {
  const _PieChartPainter({required this.data});

  final List<_CategoryStat> data;

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.width * 0.18;
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    double startAngle = -math.pi / 2;
    for (final item in data) {
      final sweepAngle = (item.percent / 100) * math.pi * 2;
      paint.color = item.color;
      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) {
    return oldDelegate.data != data;
  }
}

// ---------------------------------------------------------------------------
// 达人榜
// ---------------------------------------------------------------------------
class _RankItem extends StatelessWidget {
  const _RankItem({required this.rank, required this.data});

  final int rank;
  final _ReadingRankData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(10),
        border: const Border(
          left: BorderSide(color: Color(0xFFFFD700), width: 3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: _rankColor(rank),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$rank',
              style: AppTextStyles.bodySmall.copyWith(
                color: rank == 1 ? const Color(0xFF5D4037) : AppColors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              data.name,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            '${data.count}本',
            textAlign: TextAlign.right,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _rankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700);
      case 2:
        return const Color(0xFFB0BEC5);
      case 3:
        return const Color(0xFFBCAAA4);
      default:
        return const Color(0xFFDDDDDD);
    }
  }
}

// ---------------------------------------------------------------------------
// Mock 数据模型
// ---------------------------------------------------------------------------
class _MonthlyBorrowData {
  const _MonthlyBorrowData({required this.month, required this.count});

  final String month;
  final int count;
}

class _CategoryStat {
  const _CategoryStat({
    required this.label,
    required this.percent,
    required this.color,
  });

  final String label;
  final int percent;
  final Color color;
}

class _ReadingRankData {
  const _ReadingRankData({required this.name, required this.count});

  final String name;
  final int count;
}
