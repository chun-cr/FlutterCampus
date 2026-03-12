import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/theme.dart';
import '../../components/campus_app_bar.dart';

// ---------------------------------------------------------------------------
// Mock 静态数据
// ---------------------------------------------------------------------------

final _mockRooms = [
  {'id': 'A101', 'building': '教学楼A', 'floor': 1, 'capacity': 80, 'status': 'free', 'freeUntil': '第4节'},
  {'id': 'A203', 'building': '教学楼A', 'floor': 2, 'capacity': 60, 'status': 'free', 'freeUntil': '第6节'},
  {'id': 'B305', 'building': '教学楼B', 'floor': 3, 'capacity': 100, 'status': 'free', 'freeUntil': '第3节'},
  {'id': 'B402', 'building': '教学楼B', 'floor': 4, 'capacity': 50, 'status': 'free', 'freeUntil': '第5节'},
  {'id': 'C201', 'building': '实验楼C', 'floor': 2, 'capacity': 40, 'status': 'free', 'freeUntil': '全天'},
  {'id': 'D108', 'building': '综合楼D', 'floor': 1, 'capacity': 120, 'status': 'free', 'freeUntil': '第2节'},
];

final _mockFavorites = [
  {'id': 'A101', 'building': '教学楼A', 'floor': 1, 'capacity': 80},
  {'id': 'B305', 'building': '教学楼B', 'floor': 3, 'capacity': 100},
  {'id': 'C201', 'building': '实验楼C', 'floor': 2, 'capacity': 40},
];

final _buildings = ['全部', '教学楼A', '教学楼B', '实验楼C', '综合楼D'];

// ---------------------------------------------------------------------------
// FindRoomPage
// ---------------------------------------------------------------------------

class FindRoomPage extends ConsumerStatefulWidget {
  const FindRoomPage({super.key});

  @override
  ConsumerState<FindRoomPage> createState() => _FindRoomPageState();
}

class _FindRoomPageState extends ConsumerState<FindRoomPage> {
  // 楼栋筛选选中状态
  String _selectedBuilding = '全部';
  // 搜索关键词
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // 私有方法：与 study_page.dart 保持完全一致
  // ---------------------------------------------------------------------------

  Widget _buildSectionHeader(String title, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4),
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
          if (subtitle != null) ...[
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
        ],
      ),
    );
  }

  Widget _buildPremiumCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.greyLight.withValues(alpha: 0.6),
          width: 0.5,
        ),
      ),
      child: child,
    );
  }

  Widget _buildToolCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.greyLight.withValues(alpha: 0.6),
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 16),
            Text(title, style: AppTextStyles.titleMedium),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 过滤逻辑
  // ---------------------------------------------------------------------------

  List<Map<String, dynamic>> get _filteredRooms {
    return _mockRooms.where((room) {
      final matchBuilding =
          _selectedBuilding == '全部' || room['building'] == _selectedBuilding;
      final matchSearch = _searchQuery.isEmpty ||
          room['id'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          room['building'].toString().contains(_searchQuery);
      return matchBuilding && matchSearch;
    }).toList();
  }

  // ---------------------------------------------------------------------------
  // 模块构建方法
  // ---------------------------------------------------------------------------

  /// 模块1：搜索框
  Widget _buildSearchSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('快速查找', subtitle: 'FIND ROOM'),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.greyLight.withValues(alpha: 0.6),
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 16, right: 8),
                child: Icon(
                  Icons.search_rounded,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style: AppTextStyles.bodyMedium,
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: '搜索楼栋或教室号',
                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
              if (_searchQuery.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(right: 16, left: 8),
                    child: Icon(
                      Icons.close_rounded,
                      color: AppColors.textSecondary,
                      size: 18,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// 模块2：当前空闲教室
  Widget _buildFreeRoomsSection() {
    final rooms = _filteredRooms;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('当前空闲', subtitle: 'NOW FREE'),
        _buildPremiumCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // a. 数量 + 当前时段
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${rooms.length}',
                    style: AppTextStyles.headlineLarge.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '间现在可用',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '第 1–2 节 · 08:00–09:40',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // c. 楼栋筛选 Chip
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _buildings.map((building) {
                    final isSelected = _selectedBuilding == building;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedBuilding = building),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.greyLight.withValues(alpha: 0.8),
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            building,
                            style: AppTextStyles.labelMedium.copyWith(
                              color: isSelected
                                  ? AppColors.white
                                  : AppColors.textSecondary,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              // e. 教室网格
              rooms.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Column(
                          children: [
                            Icon(
                              Icons.meeting_room_outlined,
                              size: 40,
                              color: AppColors.textDisabled,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '暂无符合条件的空闲教室',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.15,
                      ),
                      itemCount: rooms.length,
                      itemBuilder: (context, index) =>
                          _buildRoomCard(rooms[index]),
                    ),
            ],
          ),
        ),
      ],
    );
  }

  /// 教室卡片（GridView 单元）
  Widget _buildRoomCard(Map<String, dynamic> room) {
    return GestureDetector(
      onTap: () => debugPrint('点击教室：${room['id']}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.greyLight.withValues(alpha: 0.6),
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 教室号
            Text(
              room['id'] as String,
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            // 楼层信息
            Text(
              '${room['building']} · ${room['floor']}楼',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const Spacer(),
            // 容量图标行
            Row(
              children: [
                const Icon(
                  Icons.people_outline_rounded,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${room['capacity']}人',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // 状态标签
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '空闲至${room['freeUntil']}',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 模块3：按时间查询
  Widget _buildByScheduleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('按时间查询', subtitle: 'BY SCHEDULE'),
        Row(
          children: [
            Expanded(
              child: _buildToolCard(
                context,
                icon: Icons.calendar_today_outlined,
                title: '选择日期',
                subtitle: '查指定日期',
                color: AppColors.primary,
                onTap: () => debugPrint('点击：选择日期'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildToolCard(
                context,
                icon: Icons.access_time_rounded,
                title: '选择时段',
                subtitle: '第1-2节 / 下午…',
                color: AppColors.campusOrange,
                onTap: () => debugPrint('点击：选择时段'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 模块4：我的收藏
  Widget _buildFavoritesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('我的收藏', subtitle: 'FAVORITES'),
        _buildPremiumCard(
          child: _mockFavorites.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      children: [
                        Icon(
                          Icons.bookmark_border_rounded,
                          size: 40,
                          color: AppColors.textDisabled,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '暂无收藏的教室',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    for (int i = 0; i < _mockFavorites.length; i++) ...[
                      _buildFavoriteRow(_mockFavorites[i]),
                      if (i < _mockFavorites.length - 1)
                        Divider(
                          height: 1,
                          thickness: 0.5,
                          color: AppColors.greyLight.withValues(alpha: 0.5),
                        ),
                    ],
                  ],
                ),
        ),
      ],
    );
  }

  /// 收藏列表行
  Widget _buildFavoriteRow(Map<String, dynamic> room) {
    return GestureDetector(
      onTap: () => debugPrint('点击收藏教室：${room['id']}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            // 教室号
            Text(
              room['id'] as String,
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 12),
            // 楼栋标签
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.greyLight.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                room['building'] as String,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const Spacer(),
            // 容量
            Row(
              children: [
                const Icon(
                  Icons.people_outline_rounded,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${room['capacity']}人',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            // 右箭头
            const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: AppColors.textDisabled,
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CampusAppBar(
        title: '查找教室',
        showBackButton: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 模块1：搜索框
                _buildSearchSection(),
                const SizedBox(height: 40),

                // 模块2：当前空闲教室
                _buildFreeRoomsSection(),
                const SizedBox(height: 40),

                // 模块3：按时间查询
                _buildByScheduleSection(),
                const SizedBox(height: 40),

                // 模块4：我的收藏
                _buildFavoritesSection(),

                // 底部留白
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
