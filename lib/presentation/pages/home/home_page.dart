import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../components/components.dart';
import '../../theme/theme.dart';
import '../../../core/services/auth_service.dart';
import '../study/study_page.dart';
import '../life/life_page.dart';
import '../help/help_page.dart';
import '../teacher/teacher_teaching_page.dart';
import '../teacher/teacher_office_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _currentIndex = 0;

  List<Widget> _getPages(bool isTeacher) {
    if (isTeacher) {
      return const [TeacherTeachingPage(), TeacherOfficePage(), HelpPage()];
    }
    return const [StudyPage(), LifePage(), HelpPage()];
  }

  List<String> _getTitles(bool isTeacher) {
    if (isTeacher) {
      return const ['教学工作台', '教务办公', '校园社区'];
    }
    return const ['学习中心', '校园生活', '互助社区'];
  }
  
  List<BottomNavigationBarItem> _getNavItems(bool isTeacher) {
    if (isTeacher) {
      return const [
        BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Icon(Icons.co_present_outlined, size: 26),
          ),
          activeIcon: Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Icon(Icons.co_present_rounded, size: 26),
          ),
          label: '教学',
        ),
        BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Icon(Icons.domain_verification_outlined, size: 26),
          ),
          activeIcon: Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Icon(Icons.domain_verification_rounded, size: 26),
          ),
          label: '办公',
        ),
        BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Icon(Icons.forum_outlined, size: 26),
          ),
          activeIcon: Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Icon(Icons.forum_rounded, size: 26),
          ),
          label: '社区',
        ),
      ];
    }
    return const [
      BottomNavigationBarItem(
        icon: Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Icon(Icons.school_outlined, size: 26),
        ),
        activeIcon: Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Icon(Icons.school_rounded, size: 26),
        ),
        label: '学习',
      ),
      BottomNavigationBarItem(
        icon: Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Icon(Icons.local_cafe_outlined, size: 26),
        ),
        activeIcon: Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Icon(Icons.local_cafe_rounded, size: 26),
        ),
        label: '生活',
      ),
      BottomNavigationBarItem(
        icon: Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Icon(Icons.volunteer_activism_outlined, size: 26),
        ),
        activeIcon: Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Icon(Icons.volunteer_activism_rounded, size: 26),
        ),
        label: '互助',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final user = authState.user;
    final isTeacher = user?.type.toString().toLowerCase().contains('teacher') ?? false;

    final scaffold = Scaffold(
      backgroundColor: AppColors.background,
      appBar: CampusAppBar(
        title: _getTitles(isTeacher)[_currentIndex],
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: AppColors.white,
            ),
            onPressed: () {},
          ),
          GestureDetector(
            onTap: () => context.push('/profile'),
            child: Padding(
              padding: const EdgeInsets.only(right: 20, left: 8),
              child: Hero(
                tag: 'profile_avatar',
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.white.withValues(alpha: 0.2),
                  backgroundImage:
                      user?.avatar != null && user!.avatar!.isNotEmpty
                      ? NetworkImage(user.avatar!)
                      : null,
                  child: user?.avatar == null || user!.avatar!.isEmpty
                      ? const Icon(
                          Icons.person_outline_rounded,
                          size: 20,
                          color: AppColors.white,
                        )
                      : null,
                ),
              ),
            ),
          ),
        ],
      ),
      body: IndexedStack(index: _currentIndex, children: _getPages(isTeacher)),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 32,
            right: 32,
            bottom: 24,
            top: 12,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: BottomNavigationBar(
                elevation: 0,
                currentIndex: _currentIndex,
                onTap: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                showSelectedLabels: false,
                showUnselectedLabels: false,
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.white,
                selectedItemColor: AppColors.primaryBrand,
                unselectedItemColor: AppColors.grey,
                items: _getNavItems(isTeacher),
              ),
            ),
          ),
        ),
      ),
    );

    return Container(
      color: const Color(0xFFDDDDDD), // 加深桌面背景
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ClipRect(child: scaffold),
        ),
      ),
    );
  }
}
