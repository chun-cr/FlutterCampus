import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

// ===========================================================================
// 虚拟数据定义
// ===========================================================================
class ResearchProject {
  const ResearchProject({
    required this.id,
    required this.title,
    required this.source,
    required this.totalBudget,
    required this.usedBudget,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.role,
  });
  final String id;
  final String title;
  final String source;
  final double totalBudget;
  final double usedBudget;
  final String status;
  final String startDate;
  final String endDate;
  final String role;
}

final mockProjects = [
  const ResearchProject(
    id: 'p_001',
    title: '面向智能校园的多模态感知与服务系统研究',
    source: '国家级',
    totalBudget: 80000,
    usedBudget: 35000,
    status: 'active',
    startDate: '2023年9月',
    endDate: '2026年8月',
    role: '主持',
  ),
  const ResearchProject(
    id: 'p_002',
    title: '基于深度学习的图像识别算法优化',
    source: '省级',
    totalBudget: 30000,
    usedBudget: 18000,
    status: 'active',
    startDate: '2024年1月',
    endDate: '2025年12月',
    role: '主持',
  ),
  const ResearchProject(
    id: 'p_003',
    title: '物联网环境下的安全通信协议研究',
    source: '校级',
    totalBudget: 15000,
    usedBudget: 15000,
    status: 'ended',
    startDate: '2022年3月',
    endDate: '2024年3月',
    role: '主持',
  ),
  const ResearchProject(
    id: 'p_004',
    title: '新一代信息技术产业发展战略研究',
    source: '横向',
    totalBudget: 50000,
    usedBudget: 12000,
    status: 'active',
    startDate: '2024年6月',
    endDate: '2025年6月',
    role: '参与',
  ),
];

class BudgetRecord {
  const BudgetRecord({
    required this.projectId,
    required this.category,
    required this.amount,
    required this.date,
    required this.note,
  });
  final String projectId;
  final String category;
  final double amount;
  final String date;
  final String note;
}

final mockBudgetRecords = [
  const BudgetRecord(projectId: 'p_001', category: '设备采购', amount: 12000, date: '2025年2月', note: '采购实验设备GPU服务器'),
  const BudgetRecord(projectId: 'p_001', category: '差旅费', amount: 3200, date: '2025年3月', note: '参加CCF全国学术会议'),
  const BudgetRecord(projectId: 'p_001', category: '劳务费', amount: 8000, date: '2025年1月', note: '研究生助研劳务'),
  const BudgetRecord(projectId: 'p_002', category: '论文版面费', amount: 800, date: '2025年3月', note: 'SCI期刊版面费'),
  const BudgetRecord(projectId: 'p_002', category: '差旅费', amount: 2400, date: '2025年2月', note: '赴北京参加学术交流'),
  const BudgetRecord(projectId: 'p_002', category: '设备采购', amount: 6000, date: '2024年12月', note: '采购实验耗材'),
  const BudgetRecord(projectId: 'p_004', category: '劳务费', amount: 5000, date: '2025年1月', note: '横向项目研究费'),
  const BudgetRecord(projectId: 'p_004', category: '差旅费', amount: 1800, date: '2025年3月', note: '赴企业调研'),
];

class ResearchPaper {
  const ResearchPaper({
    required this.title,
    required this.journal,
    required this.level,
    required this.status,
    required this.date,
    required this.projectId,
  });
  final String title;
  final String journal;
  final String level;
  final String status;
  final String date;
  final String projectId;
}

final mockPapers = [
  const ResearchPaper(
    title: '基于Transformer的多模态融合感知方法研究',
    journal: 'IEEE Transactions on Neural Networks',
    level: 'SCI',
    status: 'published',
    date: '2025年1月',
    projectId: 'p_001',
  ),
  const ResearchPaper(
    title: '轻量化深度学习模型在边缘计算中的应用',
    journal: '计算机学报',
    level: '核心',
    status: 'accepted',
    date: '2025年3月',
    projectId: 'p_002',
  ),
  const ResearchPaper(
    title: 'IoT Security Protocol Based on Blockchain',
    journal: 'ACM CCS 2024',
    level: '会议',
    status: 'published',
    date: '2024年11月',
    projectId: 'p_003',
  ),
  const ResearchPaper(
    title: '智能校园数据治理框架设计与实现',
    journal: '软件学报',
    level: '核心',
    status: 'reviewing',
    date: '2025年2月投稿',
    projectId: 'p_001',
  ),
];

// 本年度1-12月经费使用金额（单位：元）
final monthlySpending = [
  0.0, 0.0, 8000.0, 12000.0, 3200.0, 0.0, 0.0, 6000.0, 2400.0, 800.0, 0.0, 0.0
];

// ===========================================================================
// 主页面：科研详情页 
// ===========================================================================
class ResearchPage extends ConsumerWidget {
  const ResearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('科研概况', style: AppTextStyles.titleMedium),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _BudgetOverviewCard(),
            SizedBox(height: 32),
            _SectionHeader(title: '科研项目', subtitle: 'RESEARCH PROJECTS'),
            SizedBox(height: 16),
            _ProjectList(),
            SizedBox(height: 32),
            _SectionHeader(title: '论文成果', subtitle: 'PUBLICATIONS'),
            SizedBox(height: 16),
            _PaperCard(),
            SizedBox(height: 32),
            _SectionHeader(title: '支出明细', subtitle: 'EXPENSES'),
            SizedBox(height: 16),
            _ExpenseChart(),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 辅助组件：节标题
// ---------------------------------------------------------------------------
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.titleMedium),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.textDisabled,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 模块一：经费总览卡片
// ---------------------------------------------------------------------------
class _BudgetOverviewCard extends StatelessWidget {
  const _BudgetOverviewCard();

  @override
  Widget build(BuildContext context) {
    // 聚合统计
    double total = 0;
    double used = 0;
    int countNational = 0;
    int countProvincial = 0;
    int countOther = 0;

    for (final p in mockProjects) {
      total += p.totalBudget;
      used += p.usedBudget;
      if (p.source == '国家级') { countNational++; }
      else if (p.source == '省级') { countProvincial++; }
      else { countOther++; }
    }

    final balance = total - used;
    final progress = total > 0 ? used / total : 0.0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.greyLight, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('科研经费', style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('经费结余', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Text(
                    '¥${balance.toStringAsFixed(0)}',
                    style: AppTextStyles.headlineLarge.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('已使用 ¥${used.toStringAsFixed(0)}', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                  Text('总金额 ¥${total.toStringAsFixed(0)}', style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.greyLight,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text('$countNational项', style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary)),
                    const SizedBox(height: 4),
                    Text('国家级', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Container(width: 1, height: 24, color: AppColors.greyLight),
              Expanded(
                child: Column(
                  children: [
                    Text('$countProvincial项', style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary)),
                    const SizedBox(height: 4),
                    Text('省级', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Container(width: 1, height: 24, color: AppColors.greyLight),
              Expanded(
                child: Column(
                  children: [
                    Text('$countOther项', style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary)),
                    const SizedBox(height: 4),
                    Text('校级+横向', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 模块二：科研项目列表
// ---------------------------------------------------------------------------
class _ProjectList extends StatelessWidget {
  const _ProjectList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: mockProjects.map((p) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _ProjectCard(project: p),
      )).toList(),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.project});
  final ResearchProject project;

  Color _getSourceColor(String source) {
    switch (source) {
      case '国家级': return AppColors.primary;
      case '省级': return AppColors.success;
      case '校级': return AppColors.campusOrange;
      default: return Colors.purple;
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = project.totalBudget > 0 ? project.usedBudget / project.totalBudget : 0.0;
    final progressPercent = (progress * 100).toStringAsFixed(1);
    final sourceColor = _getSourceColor(project.source);

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: AppColors.background,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (ctx) => _ProjectDetailSheet(project: project),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.greyLight, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // 来源标签
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: sourceColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    project.source,
                    style: AppTextStyles.labelSmall.copyWith(color: sourceColor),
                  ),
                ),
                const SizedBox(width: 8),
                // 角色标签
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.greyLight.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    project.role,
                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
                  ),
                ),
                const Spacer(),
                // 状态标签
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: project.status == 'active' 
                      ? AppColors.success.withValues(alpha: 0.1)
                      : AppColors.greyLight.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    project.status == 'active' ? '进行中' : '已结题',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: project.status == 'active' ? AppColors.success : AppColors.textDisabled,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              project.title,
              style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '已用 ¥${project.usedBudget.toStringAsFixed(0)} / 总计 ¥${project.totalBudget.toStringAsFixed(0)}',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                ),
                Text(
                  '$progressPercent%',
                  style: AppTextStyles.caption.copyWith(color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor: AppColors.greyLight,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.date_range_outlined, size: 12, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  '${project.startDate} - ${project.endDate}',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectDetailSheet extends StatelessWidget {
  const _ProjectDetailSheet({required this.project});
  final ResearchProject project;

  @override
  Widget build(BuildContext context) {
    // 筛选当前项目的明细
    final records = mockBudgetRecords.where((r) => r.projectId == project.id).toList();

    return SafeArea(
      child: FractionallySizedBox(
        heightFactor: 0.85,
        child: Column(
          children: [
            const SizedBox(height: 16),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.greyLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('项目详情', style: AppTextStyles.titleLarge),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(project.title, style: AppTextStyles.titleMedium),
                    const SizedBox(height: 24),
                    Text('经费使用明细', style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 12),
                    if (records.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: Text('暂无支出记录')),
                      )
                    else
                      ...records.map(_buildRecordRow),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordRow(BudgetRecord record) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              record.category,
              style: AppTextStyles.caption.copyWith(color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      record.note,
                      style: AppTextStyles.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '¥${record.amount.toStringAsFixed(0)}',
                      style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  record.date,
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 模块三：论文成果
// ---------------------------------------------------------------------------
class _PaperCard extends StatelessWidget {
  const _PaperCard();

  @override
  Widget build(BuildContext context) {
    int published = 0;
    int accepted = 0;
    int reviewing = 0;

    for (final p in mockPapers) {
      if (p.status == 'published') { published++; }
      else if (p.status == 'accepted') { accepted++; }
      else { reviewing++; }
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.greyLight, width: 0.5),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text('$published篇', style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary)),
                      const SizedBox(height: 4),
                      Text('已发表', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                Container(width: 1, height: 24, color: AppColors.greyLight),
                Expanded(
                  child: Column(
                    children: [
                      Text('$accepted篇', style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary)),
                      const SizedBox(height: 4),
                      Text('已录用', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                Container(width: 1, height: 24, color: AppColors.greyLight),
                Expanded(
                  child: Column(
                    children: [
                      Text('$reviewing篇', style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary)),
                      const SizedBox(height: 4),
                      Text('审稿中', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 0.5, color: AppColors.greyLight),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: mockPapers.length,
            separatorBuilder: (context, index) => const Divider(height: 1, thickness: 0.5, color: AppColors.greyLight),
            itemBuilder: (context, index) => _buildPaperRow(mockPapers[index]),
          ),
        ],
      ),
    );
  }

  Widget _buildPaperRow(ResearchPaper paper) {
    Color levelColor;
    switch (paper.level) {
      case 'SCI': levelColor = AppColors.primary; break;
      case '核心': levelColor = AppColors.success; break;
      case '会议': levelColor = AppColors.campusOrange; break;
      default: levelColor = Colors.purple;
    }

    String statusLabel;
    Color statusColor;
    if (paper.status == 'published') {
      statusLabel = '已发表';
      statusColor = AppColors.success;
    } else if (paper.status == 'accepted') {
      statusLabel = '已录用';
      statusColor = AppColors.primary;
    } else {
      statusLabel = '审稿中';
      statusColor = AppColors.campusOrange;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(width: 4, color: levelColor),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    paper.title,
                    style: AppTextStyles.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    paper.journal,
                    style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          border: Border.all(color: levelColor),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          paper.level,
                          style: AppTextStyles.caption.copyWith(color: levelColor, fontSize: 10),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        paper.date,
                        style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          statusLabel,
                          style: AppTextStyles.labelSmall.copyWith(color: statusColor),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 模块四：本年度经费支出明细 (环形图)
// ---------------------------------------------------------------------------
class _ExpenseChart extends StatelessWidget {
  const _ExpenseChart();

  @override
  Widget build(BuildContext context) {
    // 汇总虚拟数据：可直接使用指定的写死总计
    final total = 39200.0;
    
    // 自定义数据结构以对应色块
    final items = [
      ('设备采购', 18000.0, AppColors.primary),
      ('差旅费', 7400.0, AppColors.campusOrange),
      ('劳务费', 13000.0, AppColors.success),
      ('论文版面费', 800.0, Colors.purple),
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.greyLight, width: 0.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 左侧环形图
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(120, 120),
                  painter: _DonutChartPainter(
                    items: items,
                    total: total,
                  ),
                ),
                Text(
                  '¥39,200',
                  style: AppTextStyles.labelMedium,
                ),
              ],
            ),
          ),
          const SizedBox(width: 32),
          // 右侧图例列表
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items.map((item) {
                final percent = (item.$2 / total * 100).toStringAsFixed(1);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: item.$3,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.$1,
                          style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                      Text(
                        '$percent%',
                        style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  const _DonutChartPainter({required this.items, required this.total});
  final List<(String, double, Color)> items;
  final double total;

  @override
  void paint(Canvas canvas, Size size) {
    // 环形外半径60，内半径40，线宽20
    final strokeWidth = 20.0;
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width - strokeWidth,
      height: size.height - strokeWidth,
    );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    double startAngle = -pi / 2; // 从顶部开始

    for (final item in items) {
      final sweepAngle = (item.$2 / total) * 2 * pi;
      paint.color = item.$3;
      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
