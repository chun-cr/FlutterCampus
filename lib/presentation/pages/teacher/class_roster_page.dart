import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../components/campus_empty_state.dart';
import '../../components/campus_loading.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

// ---------------------------------------------------------------------------
// 学生数据模型
// ---------------------------------------------------------------------------
class Student {
  const Student({
    required this.id,
    required this.studentNo,
    required this.name,
    required this.gender,
    required this.classId,
    required this.phone,
    required this.email,
    required this.status,
  });

  final String id;
  final String studentNo;
  final String name;
  final String gender;
  final String classId;
  final String phone;
  final String email;
  final String status;

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id']?.toString() ?? '',
      studentNo: json['student_no']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      classId: json['class_id']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
    );
  }

  String get statusLabel => status == 'active' ? '在读' : '休学';

  Color get statusColor =>
      status == 'active' ? AppColors.success : AppColors.campusOrange;
}

// ---------------------------------------------------------------------------
// 按班级拉取学生列表
// ---------------------------------------------------------------------------
final classStudentsProvider =
    FutureProvider.family<List<Student>, String>((ref, classId) async {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('students')
          .select()
          .eq('class_id', classId)
          .order('student_no');

      return (response as List)
          .map((item) => Student.fromJson(item as Map<String, dynamic>))
          .toList();
    });

// ---------------------------------------------------------------------------
// 页面局部状态
// ---------------------------------------------------------------------------
final _searchKeywordProvider = StateProvider<String>((ref) => '');
final _genderFilterProvider = StateProvider<int>((ref) => 0);
final _searchExpandedProvider = StateProvider<bool>((ref) => false);

// ---------------------------------------------------------------------------
// 班级名册页
// ---------------------------------------------------------------------------
class ClassRosterPage extends ConsumerWidget {
  const ClassRosterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final extra = GoRouterState.of(context).extra;
    if (extra is! Map) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CampusEmptyState(
            icon: Icons.error_outline_rounded,
            title: '页面参数错误',
            subtitle: '缺少班级信息，无法打开班级名册',
          ),
        ),
      );
    }

    final classId = extra['classId']?.toString() ?? '';
    final className = extra['className']?.toString() ?? '班级名册';

    final isSearchExpanded = ref.watch(_searchExpandedProvider);
    final keyword = ref.watch(_searchKeywordProvider).trim().toLowerCase();
    final genderFilter = ref.watch(_genderFilterProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        title: isSearchExpanded
            ? TextField(
                autofocus: true,
                onChanged: (value) {
                  ref.read(_searchKeywordProvider.notifier).state = value;
                },
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: '搜索姓名或学号',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textDisabled,
                  ),
                  border: InputBorder.none,
                ),
              )
            : Text(className, style: AppTextStyles.titleLarge),
        actions: [
          IconButton(
            onPressed: () {
              final next = !isSearchExpanded;
              ref.read(_searchExpandedProvider.notifier).state = next;
              if (!next) {
                ref.read(_searchKeywordProvider.notifier).state = '';
              }
            },
            icon: Icon(
              isSearchExpanded ? Icons.close_rounded : Icons.search_rounded,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
      body: classId.isEmpty
          ? const Center(
              child: CampusEmptyState(
                icon: Icons.groups_2_outlined,
                title: '缺少班级 ID',
                subtitle: '当前入口未传入有效的班级标识，暂时无法加载名册',
              ),
            )
          : ref.watch(classStudentsProvider(classId)).when(
              loading: () => const Center(child: CampusLoading()),
              error: (error, _) => Center(
                child: CampusEmptyState(
                  icon: Icons.error_outline_rounded,
                  title: '加载失败',
                  subtitle: error.toString(),
                  buttonText: '重试',
                  onButtonTap: () => ref.invalidate(classStudentsProvider(classId)),
                ),
              ),
              data: (students) {
                if (students.isEmpty) {
                  return const Center(
                    child: CampusEmptyState(
                      icon: Icons.groups_2_outlined,
                      title: '暂无学生数据',
                      subtitle: '当前班级还没有可展示的学生信息',
                    ),
                  );
                }

                // 轻量过滤逻辑直接放在 build 内，避免额外 provider 复杂化。
                final filteredStudents = students.where((student) {
                  final matchKeyword = keyword.isEmpty ||
                      student.name.toLowerCase().contains(keyword) ||
                      student.studentNo.toLowerCase().contains(keyword);

                  final matchGender = genderFilter == 0 ||
                      (genderFilter == 1 && student.gender == '男') ||
                      (genderFilter == 2 && student.gender == '女');

                  return matchKeyword && matchGender;
                }).toList();

                return Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                        itemCount: filteredStudents.isEmpty
                            ? 3
                            : filteredStudents.length + 2,
                        separatorBuilder: (_, index) {
                          if (index == 0 || index == 1) {
                            return const SizedBox(height: 16);
                          }
                          return const Divider(
                            height: 1,
                            thickness: 0.5,
                            color: AppColors.greyLight,
                          );
                        },
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return _OverviewCard(students: filteredStudents);
                          }

                          if (index == 1) {
                            return _GenderTabBar(
                              selectedIndex: genderFilter,
                              onChanged: (value) {
                                ref.read(_genderFilterProvider.notifier).state =
                                    value;
                              },
                            );
                          }

                          if (filteredStudents.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.only(top: 48),
                              child: CampusEmptyState(
                                icon: Icons.search_off_rounded,
                                title: '暂无匹配结果',
                                subtitle: '请尝试调整搜索关键词或筛选条件',
                              ),
                            );
                          }

                          final student = filteredStudents[index - 2];
                          return _StudentTile(
                            key: ValueKey(student.id),
                            student: student,
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}

// ---------------------------------------------------------------------------
// 班级概况卡片
// ---------------------------------------------------------------------------
class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.students});

  final List<Student> students;

  @override
  Widget build(BuildContext context) {
    final total = students.length;
    final activeCount = students.where((e) => e.status == 'active').length;
    final maleCount = students.where((e) => e.gender == '男').length;
    final femaleCount = students.where((e) => e.gender == '女').length;

    Widget buildItem(String value, String label) {
      return Expanded(
        child: Column(
          children: [
            Text(
              value,
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    Widget divider() {
      return Container(width: 1, height: 44, color: AppColors.greyLight);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.greyLight, width: 0.5),
      ),
      child: Row(
        children: [
          buildItem('$total', '总人数'),
          divider(),
          buildItem('$activeCount', '在读人数'),
          divider(),
          buildItem('$maleCount/$femaleCount', '男女比例'),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 性别筛选胶囊栏
// ---------------------------------------------------------------------------
class _GenderTabBar extends StatelessWidget {
  const _GenderTabBar({
    required this.selectedIndex,
    required this.onChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    const labels = ['全部', '男', '女'];

    return Row(
      children: List.generate(labels.length, (index) {
        final selected = selectedIndex == index;
        return Padding(
          padding: EdgeInsets.only(right: index == labels.length - 1 ? 0 : 8),
          child: GestureDetector(
            onTap: () => onChanged(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.greyLight,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                labels[index],
                style: AppTextStyles.labelMedium.copyWith(
                  color: selected ? AppColors.white : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// 学生列表项
// ---------------------------------------------------------------------------
class _StudentTile extends StatelessWidget {
  const _StudentTile({super.key, required this.student});

  final Student student;

  @override
  Widget build(BuildContext context) {
    final isMale = student.gender == '男';
    final genderColor = isMale ? Colors.blue : Colors.pink;

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
        childrenPadding: const EdgeInsets.only(left: 56, right: 8, bottom: 12),
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Text(
            student.name.isNotEmpty ? student.name.characters.first : '?',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        title: Row(
          children: [
            Flexible(
              child: Text(
                student.name,
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              isMale ? Icons.male_rounded : Icons.female_rounded,
              size: 16,
              color: genderColor,
            ),
          ],
        ),
        subtitle: Text(
          student.studentNo,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: student.statusColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            student.statusLabel,
            style: AppTextStyles.labelSmall.copyWith(
              color: student.statusColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        children: [
          Row(
            children: [
              const Icon(
                Icons.phone_outlined,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  student.phone.isEmpty ? '未填写手机号' : student.phone,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.email_outlined,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  student.email.isEmpty ? '未填写邮箱' : student.email,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
