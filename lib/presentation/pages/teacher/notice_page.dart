import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../components/campus_empty_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

// ---------------------------------------------------------------------------
// 虚拟数据定义
// ---------------------------------------------------------------------------
class NoticeCategory {
  static const String academic = 'academic';   // 教务处
  static const String research = 'research';   // 科研处
}

class Notice {
  const Notice({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    required this.category,
    required this.publisher,
    required this.date,
    required this.isTop,
    required this.isNew,
  });

  final String id;
  final String title;
  final String summary;
  final String content;
  final String category;
  final String publisher;
  final String date;
  final bool isTop;
  final bool isNew;
}

final mockNotices = [
  // ── 教务处通知 ──
  const Notice(
    id: 'n_001',
    title: '关于开展2025年春季学期期中教学检查的通知',
    summary: '学校将于第10-11教学周开展期中教学检查，请各教师做好准备。',
    content: '''各教学单位、全体教师：

为全面了解本学期教学工作开展情况，保障教学质量，学校决定于2025年4月14日至4月25日（第10-11教学周）开展期中教学检查工作。现将有关事项通知如下：

一、检查内容
1. 教学计划执行情况：各课程是否按教学大纲要求进行授课；
2. 课堂教学质量：教师备课情况、教学方法、课堂管理等；
3. 作业布置与批改情况：作业量是否合理，批改是否及时；
4. 学生出勤情况：各班级学生到课率统计分析。

二、检查方式
采取随堂听课、查阅教学资料、学生座谈等多种方式进行。

三、注意事项
请各位教师认真准备教学材料，保持教案、点名册等资料完整规范。

教务处
2025年3月12日''',
    category: NoticeCategory.academic,
    publisher: '教务处',
    date: '2025年3月12日',
    isTop: true,
    isNew: true,
  ),
  const Notice(
    id: 'n_002',
    title: '关于2025届本科生毕业论文答辩安排的通知',
    summary: '毕业论文答辩将于5月下旬进行，请指导教师提前安排答辩时间。',
    content: '''各教学单位、毕业论文指导教师：

2025届本科毕业生毕业论文（设计）答辩工作即将开始，现将相关安排通知如下：

一、答辩时间
2025年5月19日至5月23日（第15教学周）

二、答辩形式
采用线下答辩方式，各系自行组织答辩委员会。

三、提交材料
1. 毕业论文终稿（纸质版2份+电子版）；
2. 指导教师评阅意见表；
3. 查重报告（相似度须低于20%）。

四、成绩评定
答辩成绩由答辩委员会评定，结合指导教师评分综合计算最终成绩。

请各位指导教师提前与学生沟通，确保论文质量。

教务处
2025年3月5日''',
    category: NoticeCategory.academic,
    publisher: '教务处',
    date: '2025年3月5日',
    isTop: false,
    isNew: true,
  ),
  const Notice(
    id: 'n_003',
    title: '关于2025-2026学年课程申报工作的通知',
    summary: '请各教师于4月30日前完成下学年课程申报，逾期视为放弃。',
    content: '''全体教师：

为做好2025-2026学年教学计划安排工作，现启动课程申报工作，请各位教师认真填写课程申报表。

一、申报时间
2025年4月1日至4月30日

二、申报内容
1. 拟开设课程名称、课程编号；
2. 授课对象（年级、专业、班级）；
3. 计划授课周次及课时数；
4. 教材及参考书目。

三、申报方式
登录教务管理系统，在「课程申报」模块在线填写提交。

四、注意事项
逾期未申报的，视为放弃本学年授课资格，相关课程将另行安排其他教师承担。

教务处
2025年2月28日''',
    category: NoticeCategory.academic,
    publisher: '教务处',
    date: '2025年2月28日',
    isTop: false,
    isNew: false,
  ),
  const Notice(
    id: 'n_004',
    title: '关于开展青年教师教学能力提升培训的通知',
    summary: '学校将举办青年教师教学能力培训，工作年限5年以内教师须参加。',
    content: '''各教学单位：

为提升青年教师教学能力和课堂教学水平，学校决定举办2025年青年教师教学能力提升专项培训，现将有关事项通知如下：

一、培训对象
入职5年以内（含5年）的青年教师，共计约80人。

二、培训时间
2025年3月22日至3月23日（周六、周日）全天

三、培训地点
图书馆报告厅

四、培训内容
1. 课程思政融入教学设计；
2. 现代教育技术应用；
3. 案例教学与互动式教学方法；
4. 优秀教师示范课观摩。

五、参训要求
请符合条件的教师务必参加，无故缺席将影响年度考核。

教务处
2025年2月20日''',
    category: NoticeCategory.academic,
    publisher: '教务处',
    date: '2025年2月20日',
    isTop: false,
    isNew: false,
  ),

  // ── 科研处通知 ──
  const Notice(
    id: 'n_005',
    title: '关于申报2025年国家自然科学基金项目的通知',
    summary: '2025年国家自然科学基金申报工作启动，校内截止日期为3月25日。',
    content: '''全体教师：

国家自然科学基金委员会已发布2025年度项目指南，现将申报工作有关事项通知如下：

一、申报类别
面上项目、青年科学基金项目、地区科学基金项目等。

二、校内截止时间
2025年3月25日17:00前将申报材料提交至科研处（行政楼305室）

三、申报要求
1. 申请人须具有高级职称或博士学位；
2. 在研国家基金项目不超过2项；
3. 申请书须经单位审核盖章后方可提交。

四、材料清单
1. 国家自然科学基金申请书（系统导出PDF版）；
2. 申请人承诺书；
3. 合作单位证明（如有）。

如有疑问请联系科研处，联系电话：0XXX-XXXXXXXX

科研处
2025年3月10日''',
    category: NoticeCategory.research,
    publisher: '科研处',
    date: '2025年3月10日',
    isTop: true,
    isNew: true,
  ),
  const Notice(
    id: 'n_006',
    title: '关于开展2024年度科研项目结题验收工作的通知',
    summary: '2024年度到期科研项目须于4月15日前完成结题材料提交。',
    content: '''各教学单位、项目负责人：

2024年度学校科研项目执行期已届满，现开展结题验收工作，请相关项目负责人按要求提交结题材料。

一、结题范围
2024年12月31日前执行期满的校级及以上科研项目。

二、结题材料
1. 科研项目结题报告（一式三份）；
2. 经费使用明细表及票据；
3. 研究成果清单（论文、专利、软著等）；
4. 项目组成员签字确认表。

三、提交时间
2025年4月15日前提交至科研处。

四、注意事项
未按时结题的项目负责人，两年内不得申报新的校级科研项目。

科研处
2025年3月8日''',
    category: NoticeCategory.research,
    publisher: '科研处',
    date: '2025年3月8日',
    isTop: false,
    isNew: true,
  ),
  const Notice(
    id: 'n_007',
    title: '关于推荐申报省级科技进步奖的通知',
    summary: '省科技厅启动2025年度科技进步奖评选，请有意向教师尽快申报。',
    content: '''全体教师：

省科学技术厅已启动2025年度省科学技术进步奖评选工作，现将推荐申报工作通知如下：

一、奖励类别
一等奖、二等奖、三等奖

二、申报条件
1. 成果须已在省内转化应用，并产生显著经济或社会效益；
2. 申请人须为第一完成人或主要完成人；
3. 近5年内无学术不端记录。

三、校内推荐截止时间
2025年4月20日

四、申报材料
请登录省科技厅官网下载申报模板，填写完成后连同附件材料提交科研处。

科研处
2025年3月1日''',
    category: NoticeCategory.research,
    publisher: '科研处',
    date: '2025年3月1日',
    isTop: false,
    isNew: false,
  ),
  const Notice(
    id: 'n_008',
    title: '关于组织申报横向科研合作项目的通知',
    summary: '鼓励教师积极开展产学研合作，横向项目经费提成比例上调至20%。',
    content: '''全体教师：

为深化产学研合作，鼓励教师积极承接企业横向科研项目，学校对横向科研合作政策进行了调整，现通知如下：

一、政策调整
横向项目到账经费中，项目负责人可提取的劳务费比例由原15%上调至20%。

二、立项流程
1. 与合作企业签订合作协议（须经学校法务审核）；
2. 填写横向项目立项申请表；
3. 提交科研处审批备案；
4. 开设项目经费账户。

三、鼓励方向
优先支持人工智能、大数据、物联网等新兴技术领域的产学研合作。

四、联系方式
科研处横向项目负责人：XXX，电话：0XXX-XXXXXXXX

科研处
2025年2月25日''',
    category: NoticeCategory.research,
    publisher: '科研处',
    date: '2025年2月25日',
    isTop: false,
    isNew: false,
  ),
];

// ---------------------------------------------------------------------------
// 状态管理
// ---------------------------------------------------------------------------
// 搜索关键词
final noticeSearchProvider = StateProvider.autoDispose<String>((ref) => '');

// 搜索框展开状态
final noticeSearchExpandedProvider = StateProvider.autoDispose<bool>((ref) => false);

// ---------------------------------------------------------------------------
// 页面一：通知列表页
// ---------------------------------------------------------------------------
class NoticePage extends ConsumerWidget {
  const NoticePage({super.key, required this.category});

  final String category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titleLabel = category == NoticeCategory.academic ? '教务处通知' : '科研处通知';
    final isSearchExpanded = ref.watch(noticeSearchExpandedProvider);
    final keyword = ref.watch(noticeSearchProvider);

    // 计算过滤后的列表
    final filtered = mockNotices
        .where((n) => n.category == category)
        .where((n) =>
            keyword.isEmpty ||
            n.title.contains(keyword) ||
            n.summary.contains(keyword))
        .toList();

    final topped = filtered.where((n) => n.isTop).toList();
    final normal = filtered.where((n) => !n.isTop).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: isSearchExpanded
            ? TextField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: '搜索通知标题或摘要...',
                  border: InputBorder.none,
                  hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textDisabled),
                ),
                style: AppTextStyles.bodyMedium,
                onChanged: (value) =>
                    ref.read(noticeSearchProvider.notifier).state = value,
              )
            : Text(titleLabel, style: AppTextStyles.titleMedium),
        centerTitle: !isSearchExpanded,
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        actions: [
          IconButton(
            icon: Icon(isSearchExpanded ? Icons.close_rounded : Icons.search_rounded),
            onPressed: () {
              if (isSearchExpanded) {
                // 关闭时清空搜索
                ref.read(noticeSearchProvider.notifier).state = '';
              }
              ref.read(noticeSearchExpandedProvider.notifier).state = !isSearchExpanded;
            },
          ),
        ],
      ),
      body: filtered.isEmpty
          ? const CampusEmptyState(
              icon: Icons.notifications_none_outlined,
              title: '暂无通知',
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (topped.isNotEmpty) ...[
                    ...topped.map((n) => _TopNoticeCard(notice: n)),
                    const SizedBox(height: 16),
                  ],
                  if (normal.isNotEmpty)
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: normal.length,
                        separatorBuilder: (context, index) => const Divider(
                          height: 1,
                          thickness: 0.5,
                          color: AppColors.greyLight,
                          indent: 72, // 分隔线不包括日期列
                        ),
                        itemBuilder: (context, index) => _NoticeItem(notice: normal[index]),
                      ),
                    ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}

// ---------------------------------------------------------------------------
// 辅助组件：置顶通知卡片
// ---------------------------------------------------------------------------
class _TopNoticeCard extends StatelessWidget {
  const _TopNoticeCard({required this.notice});

  final Notice notice;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/teacher/notice/detail', extra: notice),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.2),
            width: 0.5,
          ),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 左侧竖色条
              Container(
                width: 4,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              notice.title,
                              style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '置顶',
                              style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary, fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        notice.summary,
                        style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(notice.publisher, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                          Text(notice.date, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 辅助组件：普通通知列表项
// ---------------------------------------------------------------------------
class _NoticeItem extends StatelessWidget {
  const _NoticeItem({required this.notice});

  final Notice notice;

  @override
  Widget build(BuildContext context) {
    // 简单解析出日和月（假设格式如 '2025年3月12日'）
    String day = '--';
    String month = '--月';
    try {
      final splits = notice.date.split('月');
      if (splits.length > 1) {
        month = '${splits[0].split('年').last}月';
        day = splits[1].replaceAll('日', '');
      }
    } catch (_) {}

    return InkWell(
      onTap: () => context.push('/teacher/notice/detail', extra: notice),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 左侧日期
            SizedBox(
              width: 44,
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            day,
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            month,
                            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Container(width: 1, color: AppColors.greyLight, margin: const EdgeInsets.only(left: 4)),
                  ],
                ),
              ),
            ),
            // 右侧内容
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 标题和NEW标签
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            notice.title,
                            style: AppTextStyles.labelMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (notice.isNew) ...[
                          const SizedBox(width: 8),
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.error, // 红色底
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'NEW',
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    // 底部部门
                    Text(
                      notice.publisher,
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
