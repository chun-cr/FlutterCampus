import 'package:flutter/material.dart';
import '../../components/campus_snackbar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../components/campus_empty_state.dart';
import '../../components/campus_loading.dart';
import '../../../ui/components/date_picker_sheet.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

// ---------------------------------------------------------------------------
// 数据模型
// ---------------------------------------------------------------------------
class Venue {
  const Venue({
    required this.id,
    required this.name,
    required this.type,
    required this.capacity,
    required this.facilities,
    required this.building,
  });

  final String id;
  final String name;
  final String type; // 'meeting' / 'hall' / 'lab' / 'classroom'
  final int capacity;
  final List<String> facilities;
  final String building;
}

class VenueApplication {
  const VenueApplication({
    required this.id,
    required this.teacherId,
    required this.teacherName,
    required this.venueName,
    required this.venueType,
    required this.useDate,
    required this.startTime,
    required this.endTime,
    required this.purpose,
    this.attendees,
    required this.status,
    this.adminComment,
    this.reviewedAt,
    required this.createdAt,
  });

  factory VenueApplication.fromJson(Map<String, dynamic> json) {
    return VenueApplication(
      id: json['id'] as String,
      teacherId: json['teacher_id'] as String,
      teacherName: json['teacher_name'] as String? ?? '',
      venueName: json['venue_name'] as String,
      venueType: json['venue_type'] as String? ?? '',
      useDate: DateTime.parse(json['use_date'] as String),
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      purpose: json['purpose'] as String? ?? '',
      attendees: json['attendees'] as int?,
      status: json['status'] as String? ?? 'pending',
      adminComment: json['admin_comment'] as String?,
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.parse(json['reviewed_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  final String id;
  final String teacherId;
  final String teacherName;
  final String venueName;
  final String venueType;
  final DateTime useDate;
  final String startTime;
  final String endTime;
  final String purpose;
  final int? attendees;
  final String status; // 'pending' / 'approved' / 'rejected'
  final String? adminComment;
  final DateTime? reviewedAt;
  final DateTime createdAt;
}

// ---------------------------------------------------------------------------
// 虚拟场地数据
// ---------------------------------------------------------------------------
final mockVenues = [
  Venue(
    id: 'v_001',
    name: '计算机楼会议室A',
    type: 'meeting',
    capacity: 20,
    facilities: ['投影仪', '白板', '视频会议'],
    building: '计算机楼',
  ),
  Venue(
    id: 'v_002',
    name: '计算机楼会议室B',
    type: 'meeting',
    capacity: 10,
    facilities: ['电视', '白板'],
    building: '计算机楼',
  ),
  Venue(
    id: 'v_003',
    name: '图书馆报告厅',
    type: 'hall',
    capacity: 200,
    facilities: ['投影仪', '音响', '话筒', '直播设备'],
    building: '图书馆',
  ),
  Venue(
    id: 'v_004',
    name: '计算机实验室101',
    type: 'lab',
    capacity: 40,
    facilities: ['电脑40台', '投影仪', '服务器'],
    building: '计算机楼',
  ),
  Venue(
    id: 'v_005',
    name: '计算机实验室102',
    type: 'lab',
    capacity: 40,
    facilities: ['电脑40台', '投影仪'],
    building: '计算机楼',
  ),
  Venue(
    id: 'v_006',
    name: '多媒体教室301',
    type: 'classroom',
    capacity: 60,
    facilities: ['投影仪', '音响', '录播系统'],
    building: '教学楼',
  ),
];

// ---------------------------------------------------------------------------
// 状态管理
// ---------------------------------------------------------------------------

// 场地类型筛选
final venueTypeFilterProvider = StateProvider<String>((ref) => 'all');

// 申请记录列表
final venueApplicationsProvider =
    FutureProvider<List<VenueApplication>>((ref) async {
  final supabase = Supabase.instance.client;
  final currentUser = supabase.auth.currentUser;
  if (currentUser == null) return [];
  try {
    final response = await supabase
        .from('venue_applications')
        .select()
        .eq('teacher_id', currentUser.id)
        .order('created_at', ascending: false);
    return (response as List)
        .map((e) => VenueApplication.fromJson(e))
        .toList();
  } catch (e) {
    debugPrint('拉取场地申请记录失败: $e');
    return [];
  }
});

// 申请记录筛选
final applicationStatusFilterProvider =
    StateProvider<String>((ref) => 'all');

// BottomSheet 表单状态
final selectedDateProvider = StateProvider<DateTime?>((ref) => null);
final selectedTimeSlotProvider = StateProvider<String?>((ref) => null);
final purposeTextProvider = StateProvider<String>((ref) => '');
final attendeesProvider = StateProvider<int?>((ref) => null);

// ---------------------------------------------------------------------------
// 类型映射工具
// ---------------------------------------------------------------------------
const _typeLabels = {
  'meeting': '会议室',
  'hall': '报告厅',
  'lab': '实验室',
  'classroom': '教室',
};

Color _typeColor(String type) {
  switch (type) {
    case 'meeting':
      return AppColors.primary;
    case 'hall':
      return AppColors.campusOrange;
    case 'lab':
      return AppColors.success;
    case 'classroom':
      return const Color(0xFF9C27B0);
    default:
      return AppColors.textSecondary;
  }
}

// 预设时间段
const _timeSlots = [
  '08:00-10:00',
  '10:00-12:00',
  '14:00-16:00',
  '16:00-18:00',
  '19:00-21:00',
  '全天(08:00-22:00)',
];

// ---------------------------------------------------------------------------
// 主页面
// ---------------------------------------------------------------------------
class VenuePage extends ConsumerStatefulWidget {
  const VenuePage({super.key});

  @override
  ConsumerState<VenuePage> createState() => _VenuePageState();
}

class _VenuePageState extends ConsumerState<VenuePage>
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
        title: Text('场地借用', style: AppTextStyles.titleMedium),
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
            Tab(text: '申请借用'),
            Tab(text: '我的申请'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _BrowseTab(tabController: _tabController),
          const _MyApplicationsTab(),
        ],
      ),
    );
  }
}

// ===========================================================================
// Tab1：申请借用（浏览场地列表）
// ===========================================================================
class _BrowseTab extends ConsumerWidget {
  const _BrowseTab({required this.tabController});
  final TabController tabController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(venueTypeFilterProvider);
    final filteredVenues = filter == 'all'
        ? mockVenues
        : mockVenues.where((v) => v.type == filter).toList();

    return Column(
      children: [
        const SizedBox(height: 16),
        _TypeFilterBar(
          selected: filter,
          onChanged: (val) {
            ref.read(venueTypeFilterProvider.notifier).state = val;
          },
        ),
        const SizedBox(height: 8),
        Expanded(
          child: filteredVenues.isEmpty
              ? const CampusEmptyState(
                  icon: Icons.meeting_room_outlined,
                  title: '暂无匹配场地',
                )
              : ListView.separated(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  itemCount: filteredVenues.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final venue = filteredVenues[index];
                    return _VenueCard(
                      venue: venue,
                      onTap: () => _showApplySheet(
                          context, ref, venue, tabController),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showApplySheet(BuildContext context, WidgetRef ref, Venue venue,
      TabController tabController) {
    // 重置表单状态
    ref.read(selectedDateProvider.notifier).state = null;
    ref.read(selectedTimeSlotProvider.notifier).state = null;
    ref.read(purposeTextProvider.notifier).state = '';
    ref.read(attendeesProvider.notifier).state = null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: _ApplySheet(venue: venue, tabController: tabController),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 场地类型筛选栏
// ---------------------------------------------------------------------------
class _TypeFilterBar extends StatelessWidget {
  const _TypeFilterBar({required this.selected, required this.onChanged});
  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    const filters = [
      ('all', '全部'),
      ('meeting', '会议室'),
      ('hall', '报告厅'),
      ('lab', '实验室'),
      ('classroom', '教室'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: filters.map((item) {
          final isSelected = selected == item.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onChanged(item.$1),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color:
                      isSelected ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: isSelected
                      ? null
                      : Border.all(color: AppColors.greyLight, width: 1),
                ),
                child: Text(
                  item.$2,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isSelected
                        ? AppColors.white
                        : AppColors.textSecondary,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 场地卡片
// ---------------------------------------------------------------------------
class _VenueCard extends StatelessWidget {
  const _VenueCard({required this.venue, required this.onTap});
  final Venue venue;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = _typeColor(venue.type);
    final label = _typeLabels[venue.type] ?? '其他';

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
            // 顶部行
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    label,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(Icons.people_outline, size: 14,
                    color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  '${venue.capacity}人',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 中部
            Text(
              venue.name,
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 12,
                    color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  venue.building,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // 设施标签
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                ...venue.facilities.take(3).map((f) => _FacilityTag(text: f)),
                if (venue.facilities.length > 3)
                  _FacilityTag(
                      text: '+${venue.facilities.length - 3}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 设施标签
// ---------------------------------------------------------------------------
class _FacilityTag extends StatelessWidget {
  const _FacilityTag({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

// ===========================================================================
// 申请 BottomSheet
// ===========================================================================
class _ApplySheet extends ConsumerStatefulWidget {
  const _ApplySheet({required this.venue, required this.tabController});
  final Venue venue;
  final TabController tabController;

  @override
  ConsumerState<_ApplySheet> createState() => _ApplySheetState();
}

class _ApplySheetState extends ConsumerState<_ApplySheet> {
  late final TextEditingController _purposeController;
  late final TextEditingController _attendeesController;

  @override
  void initState() {
    super.initState();
    _purposeController = TextEditingController();
    _attendeesController = TextEditingController();
  }

  @override
  void dispose() {
    _purposeController.dispose();
    _attendeesController.dispose();
    super.dispose();
  }

  // 格式化日期显示
  String _formatDate(DateTime date) {
    const weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    final wd = weekdays[date.weekday - 1];
    return '${date.year}年${date.month}月${date.day}日（$wd）';
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    final maxDate = now.add(const Duration(days: 30));

    final picked = await DatePickerSheet.show(
      context,
      initialDate: ref.read(selectedDateProvider) ?? tomorrow,
      minDate: tomorrow,
      maxDate: maxDate,
    );
    if (picked != null) {
      ref.read(selectedDateProvider.notifier).state = picked;
    }
  }

  Future<void> _submit() async {
    final date = ref.read(selectedDateProvider);
    final timeSlot = ref.read(selectedTimeSlotProvider);
    final purpose = _purposeController.text.trim();
    final attendeesVal = int.tryParse(_attendeesController.text.trim());

    if (date == null || timeSlot == null || purpose.isEmpty) return;

    // 解析时间段
    String startTime;
    String endTime;
    if (timeSlot.startsWith('全天')) {
      startTime = '08:00';
      endTime = '22:00';
    } else {
      final parts = timeSlot.split('-');
      startTime = parts[0];
      endTime = parts[1];
    }

    final supabase = Supabase.instance.client;
    final currentUser = supabase.auth.currentUser;
    if (currentUser == null) {
      _showSnackBar('请先登录', isError: true);
      return;
    }

    // 获取用户名
    String teacherName = '教师';
    try {
      final userResp = await supabase
          .from('users')
          .select('name')
          .eq('id', currentUser.id)
          .maybeSingle();
      if (userResp != null) {
        teacherName = userResp['name'] as String? ?? '教师';
      }
    } catch (_) {}

    try {
      await supabase.from('venue_applications').insert({
        'teacher_id': currentUser.id,
        'teacher_name': teacherName,
        'venue_name': widget.venue.name,
        'venue_type': widget.venue.type,
        'use_date':
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
        'start_time': startTime,
        'end_time': endTime,
        'purpose': purpose,
        'attendees': attendeesVal,
      });

      if (mounted) {
        Navigator.of(context).pop();
        CampusSnackBar.show(context, message: '申请已提交，等待审核', isError: false);
        // 自动切换到「我的申请」Tab
        widget.tabController.animateTo(1);
      }
      // 刷新申请列表
      ref.invalidate(venueApplicationsProvider);
    } catch (e) {
      _showSnackBar('提交失败: $e', isError: true);
    }
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    if (!mounted) return;
    CampusSnackBar.show(context, message: msg, isError: true);
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedDateProvider);
    final selectedSlot = ref.watch(selectedTimeSlotProvider);
    final purposeText = ref.watch(purposeTextProvider);
    final attendeesVal = ref.watch(attendeesProvider);
    final venue = widget.venue;
    final color = _typeColor(venue.type);
    final typeLabel = _typeLabels[venue.type] ?? '其他';

    // 表单是否完整
    final isFormValid =
        selectedDate != null && selectedSlot != null && purposeText.isNotEmpty;
    // 是否超出容量
    final isOverCapacity =
        attendeesVal != null && attendeesVal > venue.capacity;

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 拖动条
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: AppColors.greyLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // 场地名称 + 类型标签
            Row(
              children: [
                Expanded(
                  child: Text(
                    venue.name,
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    typeLabel,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 1. 借用日期
            Text('借用日期', style: AppTextStyles.labelMedium),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDate,
              child: selectedDate == null
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.greyLight),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined,
                              size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 8),
                          Text(
                            '点击选择日期',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textDisabled,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border(
                          left: BorderSide(
                              color: AppColors.primary, width: 3),
                        ),
                      ),
                      child: Text(
                        _formatDate(selectedDate),
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 16),

            // 2. 时间段选择
            Text('借用时段', style: AppTextStyles.labelMedium),
            const SizedBox(height: 8),
            _TimeSlotSelector(
              selected: selectedSlot,
              onChanged: (slot) {
                ref.read(selectedTimeSlotProvider.notifier).state = slot;
              },
            ),
            const SizedBox(height: 16),

            // 3. 借用用途
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('借用用途', style: AppTextStyles.labelMedium),
                Text(
                  '${purposeText.length}/50',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _purposeController,
              maxLength: 50,
              onChanged: (val) {
                ref.read(purposeTextProvider.notifier).state = val;
              },
              style: AppTextStyles.bodyMedium,
              decoration: InputDecoration(
                hintText: '请描述借用用途，如：课题组周会、学生答辩等',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textDisabled,
                ),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.greyLight),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.greyLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.primary),
                ),
                counterText: '',
              ),
            ),
            const SizedBox(height: 16),

            // 4. 预计人数
            Text('预计人数', style: AppTextStyles.labelMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _attendeesController,
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      ref.read(attendeesProvider.notifier).state =
                          int.tryParse(val);
                    },
                    style: AppTextStyles.bodyMedium,
                    decoration: InputDecoration(
                      hintText: '请输入预计参与人数',
                      hintStyle: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textDisabled,
                      ),
                      filled: true,
                      fillColor: AppColors.surface,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: AppColors.greyLight),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: AppColors.greyLight),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '≤ ${venue.capacity}人',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            if (isOverCapacity) ...[
              const SizedBox(height: 4),
              Text(
                '超出场地容量',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.error,
                ),
              ),
            ],
            const SizedBox(height: 32),

            // 提交按钮
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed:
                    isFormValid && !isOverCapacity ? _submit : null,
                style: FilledButton.styleFrom(
                  backgroundColor:
                      isOverCapacity ? AppColors.error : AppColors.primary,
                  disabledBackgroundColor: AppColors.greyLight,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  isOverCapacity ? '超出场地容量' : '提交申请',
                  style: AppTextStyles.button.copyWith(
                    color: isFormValid && !isOverCapacity
                        ? AppColors.white
                        : AppColors.textDisabled,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 时间段选择器
// ---------------------------------------------------------------------------
class _TimeSlotSelector extends StatelessWidget {
  const _TimeSlotSelector({required this.selected, required this.onChanged});
  final String? selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _timeSlots.map((slot) {
        final isSelected = selected == slot;
        return GestureDetector(
          onTap: () => onChanged(slot),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.greyLight.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              slot,
              style: AppTextStyles.labelSmall.copyWith(
                color:
                    isSelected ? AppColors.white : AppColors.textSecondary,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ===========================================================================
// Tab2：我的申请
// ===========================================================================
class _MyApplicationsTab extends ConsumerWidget {
  const _MyApplicationsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusFilter = ref.watch(applicationStatusFilterProvider);

    return Column(
      children: [
        const SizedBox(height: 16),
        _StatusFilterBar(
          selected: statusFilter,
          onChanged: (val) {
            ref.read(applicationStatusFilterProvider.notifier).state = val;
          },
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ref.watch(venueApplicationsProvider).when(
                loading: () => const Center(child: CampusLoading()),
                error: (err, _) =>
                    Center(child: Text('加载失败: $err')),
                data: (applications) {
                  // 按状态筛选
                  final filtered = statusFilter == 'all'
                      ? applications
                      : applications
                          .where((a) => a.status == statusFilter)
                          .toList();

                  if (filtered.isEmpty) {
                    return const Center(
                      child: CampusEmptyState(
                        icon: Icons.meeting_room_outlined,
                        title: '暂无借用申请',
                        subtitle: '点击「申请借用」提交场地借用需求',
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(venueApplicationsProvider);
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return _ApplicationCard(
                            application: filtered[index]);
                      },
                    ),
                  );
                },
              ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 状态筛选栏
// ---------------------------------------------------------------------------
class _StatusFilterBar extends StatelessWidget {
  const _StatusFilterBar({required this.selected, required this.onChanged});
  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    const filters = [
      ('all', '全部'),
      ('pending', '待审核'),
      ('approved', '已通过'),
      ('rejected', '已拒绝'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: filters.map((item) {
          final isSelected = selected == item.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onChanged(item.$1),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color:
                      isSelected ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: isSelected
                      ? null
                      : Border.all(color: AppColors.greyLight, width: 1),
                ),
                child: Text(
                  item.$2,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isSelected
                        ? AppColors.white
                        : AppColors.textSecondary,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 申请记录卡片
// ---------------------------------------------------------------------------
class _ApplicationCard extends StatelessWidget {
  const _ApplicationCard({required this.application});
  final VenueApplication application;

  /// 格式化日期：yyyy-MM-dd
  String _formatDateSimple(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// 格式化日期时间：MM-dd HH:mm
  String _formatDateTime(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.greyLight, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 顶部行
          Row(
            children: [
              Expanded(
                child: Text(
                  application.venueName,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _buildStatusTag(application.status),
            ],
          ),
          const SizedBox(height: 12),

          // 信息行
          _buildInfoRow(Icons.calendar_today_outlined,
              _formatDateSimple(application.useDate)),
          const SizedBox(height: 6),
          _buildInfoRow(Icons.access_time_outlined,
              '${application.startTime} - ${application.endTime}'),
          const SizedBox(height: 6),
          _buildInfoRow(Icons.description_outlined, application.purpose,
              isCaption: true),
          if (application.attendees != null) ...[
            const SizedBox(height: 6),
            _buildInfoRow(Icons.people_outline,
                '预计${application.attendees}人',
                isCaption: true),
          ],

          // 申请时间（右对齐）
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '申请于 ${_formatDateTime(application.createdAt)}',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),

          // 审核结果展示
          if (application.status == 'approved' ||
              application.status == 'rejected')
            _ReviewResult(application: application),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text,
      {bool isCaption = false}) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: isCaption
                ? AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  )
                : AppTextStyles.labelMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusTag(String status) {
    late final String label;
    late final Color color;

    switch (status) {
      case 'pending':
        label = '待审核';
        color = AppColors.campusOrange;
        break;
      case 'approved':
        label = '已通过';
        color = AppColors.success;
        break;
      case 'rejected':
        label = '已拒绝';
        color = AppColors.error;
        break;
      default:
        label = status;
        color = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(color: color),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 审核结果展示
// ---------------------------------------------------------------------------
class _ReviewResult extends StatelessWidget {
  const _ReviewResult({required this.application});
  final VenueApplication application;

  @override
  Widget build(BuildContext context) {
    final isApproved = application.status == 'approved';
    final color = isApproved ? AppColors.success : AppColors.error;
    final icon = isApproved
        ? Icons.check_circle_outline
        : Icons.cancel_outlined;
    final label = isApproved ? '审核已通过' : '审核未通过';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        const Divider(
            height: 1, thickness: 0.5, color: AppColors.greyLight),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        if (application.adminComment != null &&
            application.adminComment!.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            application.adminComment!,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}
