import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../components/campus_empty_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

// ---------------------------------------------------------------------------
// 数据模型
// ---------------------------------------------------------------------------
class Scholarship {
  const Scholarship({
    required this.id,
    required this.name,
    required this.type,
    required this.amount,
    required this.deadline,
    required this.status,
    required this.description,
  });

  final String id; // 'sc_001' 格式
  final String name; // 项目名称
  final String type; // 'award'奖学金 / 'grant'助学金 / 'honor'荣誉
  final String amount; // 金额或描述，如 '¥8000' / '荣誉证书'
  final DateTime deadline; // 申请截止日期
  final String status; // 'active' / 'closed'
  final String description; // 项目说明
}

// ---------------------------------------------------------------------------
// 虚拟写死的5条奖助学金
// ---------------------------------------------------------------------------
final mockScholarships = [
  Scholarship(
    id: 'sc_001',
    name: '国家奖学金',
    type: 'award',
    amount: '¥8000',
    deadline: DateTime(2025, 4, 30),
    status: 'active',
    description: '面向品学兼优的全日制本科生，综合测评排名专业前2%',
  ),
  Scholarship(
    id: 'sc_002',
    name: '国家助学金',
    type: 'grant',
    amount: '¥3000',
    deadline: DateTime(2025, 4, 30),
    status: 'active',
    description: '面向家庭经济困难的全日制本科生，需提交家庭收入证明',
  ),
  Scholarship(
    id: 'sc_003',
    name: '校级一等奖学金',
    type: 'award',
    amount: '¥3000',
    deadline: DateTime(2025, 4, 15),
    status: 'closed',
    description: '综合测评排名专业前5%，上一学年无不及格科目',
  ),
  Scholarship(
    id: 'sc_004',
    name: '优秀学生干部',
    type: 'honor',
    amount: '荣誉证书',
    deadline: DateTime(2025, 5, 10),
    status: 'active',
    description: '面向担任班级或学生组织干部满一学年、表现突出的学生',
  ),
  Scholarship(
    id: 'sc_005',
    name: '励志奖学金',
    type: 'award',
    amount: '¥5000',
    deadline: DateTime(2025, 5, 5),
    status: 'active',
    description: '面向家庭经济困难且品学兼优的全日制本科生',
  ),
];

// ---------------------------------------------------------------------------
// 模拟已申请学生学号列表（写死，不存数据库）
// ---------------------------------------------------------------------------
final mockApplicantNos = <String, List<String>>{
  'sc_001': [
    '2022030101', '2022030103', '2022030106', '2022030109', '2022030112',
  ],
  'sc_002': [
    '2022030102', '2022030105', '2022030108', '2022030115', '2022030118',
    '2022030121',
  ],
  'sc_003': [
    '2022030101', '2022030104', '2022030107',
  ],
  'sc_004': [
    '2022030103', '2022030106', '2022030110', '2022030113',
  ],
  'sc_005': [
    '2022030102', '2022030105', '2022030111', '2022030116', '2022030119',
  ],
};

// ---------------------------------------------------------------------------
// 某项目的已审核数量 Provider（首页卡片用）
// ---------------------------------------------------------------------------
final scholarshipReviewedCountProvider =
    FutureProvider.family<int, String>((ref, scholarshipId) async {
  final supabase = Supabase.instance.client;
  try {
    final response = await supabase
        .from('scholarship_reviews')
        .select('id, teacher_result')
        .eq('scholarship_id', scholarshipId)
        .not('teacher_result', 'is', null);
    return (response as List).length;
  } catch (e) {
    debugPrint('获取审核数异常: $e');
    return 0;
  }
});

// ---------------------------------------------------------------------------
// 主页面入口
// ---------------------------------------------------------------------------
class ScholarshipPage extends ConsumerStatefulWidget {
  const ScholarshipPage({super.key});

  @override
  ConsumerState<ScholarshipPage> createState() => _ScholarshipPageState();
}

class _ScholarshipPageState extends ConsumerState<ScholarshipPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('奖助学金审核', style: AppTextStyles.titleMedium),
        backgroundColor: AppColors.surface,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.textPrimary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 2.5,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: AppTextStyles.titleMedium,
          unselectedLabelStyle: AppTextStyles.bodyMedium,
          tabs: const [
            Tab(text: '待审核'),
            Tab(text: '全部项目'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [_PendingTab(), _AllTab()],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tab 1: 待审核（仅展示 active）
// ---------------------------------------------------------------------------
class _PendingTab extends StatelessWidget {
  const _PendingTab();

  @override
  Widget build(BuildContext context) {
    final activeItems =
        mockScholarships.where((s) => s.status == 'active').toList();

    if (activeItems.isEmpty) {
      return const Center(
        child: CampusEmptyState(
          icon: Icons.check_circle_outline_rounded,
          title: '暂无待审核项目',
          subtitle: '所有奖助学金审核任务已完成',
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      itemCount: activeItems.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = activeItems[index];
        return _ScholarshipCard(
          scholarship: item,
          onTap: () {
            context.push('/teacher/scholarship/applicants', extra: item);
          },
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Tab 2: 全部项目（含 closed）
// ---------------------------------------------------------------------------
class _AllTab extends StatelessWidget {
  const _AllTab();

  @override
  Widget build(BuildContext context) {
    if (mockScholarships.isEmpty) {
      return const Center(
        child: CampusEmptyState(
          icon: Icons.school_outlined,
          title: '暂无任何项目',
          subtitle: '还没有发布过任何奖助学金项目',
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      itemCount: mockScholarships.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = mockScholarships[index];
        return _ScholarshipCard(
          scholarship: item,
          showStatus: true,
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// 奖助学金卡片
// ---------------------------------------------------------------------------
class _ScholarshipCard extends ConsumerWidget {
  const _ScholarshipCard({
    required this.scholarship,
    this.showStatus = false,
    this.onTap,
  });

  final Scholarship scholarship;
  final bool showStatus;
  final VoidCallback? onTap;

  String _formatDate(DateTime date) => '${date.month}/${date.day}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final isOverdue = scholarship.deadline.isBefore(now);
    final applicantCount =
        mockApplicantNos[scholarship.id]?.length ?? 0;

    return GestureDetector(
      onTap: onTap,
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
            // --- 顶部行 ---
            Row(
              children: [
                _TypeLabel(type: scholarship.type),
                const Spacer(),
                if (showStatus)
                  _StatusLabel(status: scholarship.status)
                else
                  Text(
                    isOverdue
                        ? '已截止'
                        : '截止 ${_formatDate(scholarship.deadline)}',
                    style: AppTextStyles.caption.copyWith(
                      color: isOverdue
                          ? AppColors.error
                          : AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // --- 中部 ---
            Text(
              scholarship.name,
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              scholarship.amount,
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              scholarship.description,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),

            // --- 底部行 ---
            const Divider(height: 1, thickness: 0.5, color: AppColors.greyLight),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  '已申请 $applicantCount 人',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                // 审核进度
                ref
                    .watch(scholarshipReviewedCountProvider(scholarship.id))
                    .when(
                      data: (reviewedCount) {
                        return RichText(
                          text: TextSpan(
                            text: '已审核 ',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            children: [
                              TextSpan(
                                text: '$reviewedCount',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextSpan(
                                text: ' / $applicantCount',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      loading: () => const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      error: (_, __) => const SizedBox(),
                    ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 类型标签胶囊
// ---------------------------------------------------------------------------
class _TypeLabel extends StatelessWidget {
  const _TypeLabel({required this.type});

  final String type;

  @override
  Widget build(BuildContext context) {
    late final String text;
    late final Color color;

    switch (type) {
      case 'award':
        text = '奖学金';
        color = AppColors.primary;
        break;
      case 'grant':
        text = '助学金';
        color = AppColors.success;
        break;
      case 'honor':
        text = '荣誉';
        color = AppColors.campusOrange;
        break;
      default:
        text = '其他';
        color = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: AppTextStyles.labelMedium.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 状态标签
// ---------------------------------------------------------------------------
class _StatusLabel extends StatelessWidget {
  const _StatusLabel({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    if (status == 'active') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          '进行中',
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.success,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.greyLight.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '已结束',
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
