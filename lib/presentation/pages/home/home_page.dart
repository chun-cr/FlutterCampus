import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../components/components.dart';
import '../../theme/theme.dart';
import '../../../core/services/auth_service.dart';
import '../study/study_page.dart';
import '../life/life_page.dart';
import '../help/help_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    StudyPage(),
    LifePage(),
    HelpPage(),
  ];

  final List<String> _titles = const [
    '学习中心',
    '校园生活',
    '互助社区',
  ];

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final user = authState.user;

    final scaffold = Scaffold(
      backgroundColor: AppColors.background,
      appBar: CampusAppBar(
        title: _titles[_currentIndex],
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: AppColors.white),
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
                  backgroundColor: AppColors.white.withOpacity(0.2),
                  backgroundImage: user?.avatar != null && user!.avatar!.isNotEmpty
                      ? NetworkImage(user.avatar!)
                      : null,
                  child: user?.avatar == null || user!.avatar!.isEmpty
                      ? const Icon(Icons.person_outline_rounded, size: 20, color: AppColors.white)
                      : null,
                ),
              ),
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 32, right: 32, bottom: 24, top: 12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
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
                selectedItemColor: AppColors.primary,
                unselectedItemColor: AppColors.grey,
                items: const [
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
                ],
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
          child: ClipRect(
            child: scaffold,
          ),
        ),
      ),
    );
  }
}
