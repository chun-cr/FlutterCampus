import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import '../pages/auth/splash_screen.dart';
import '../pages/auth/login_page.dart';
import '../pages/auth/register_page.dart';
import '../pages/auth/forgot_password_page.dart';
import '../pages/home/home_page.dart';
import '../pages/profile/profile_page.dart';
import '../pages/study/library_home_page.dart';
import '../pages/study/book_search_page.dart';
import '../pages/study/seat_reservation_page.dart';
import '../pages/study/my_loans_page.dart';
import '../pages/study/library_stats_page.dart';
import '../pages/library/reservations_page.dart';
import '../pages/study/grades_page.dart';
import '../pages/study/exam_countdown_page.dart';
import '../pages/help/post_edit_page.dart';
import '../pages/help/second_hand_list_page.dart';
import '../pages/study/schedule_page.dart';
import '../pages/teacher/teacher_grade_page.dart';
import '../../features/office/pages/leave_approval_page.dart';
import '../../features/study/pages/leave_apply_page.dart';
import '../../features/library/pages/all_books_page.dart';
import '../../features/library/pages/book_detail_page.dart';
import '../../features/library/pages/my_reservations_page.dart';
import '../../features/life/pages/map_detail_page.dart';
import '../pages/study/find_room_page.dart';
import '../pages/teacher/class_roster_page.dart';
import '../pages/teacher/teacher_weekly_schedule_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    // 启动页
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    // 登录页
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    // 注册页
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    // 忘记密码页
    GoRoute(
      path: '/forgot_password',
      builder: (context, state) => const ForgotPasswordPage(),
    ),
    // 首页
    GoRoute(path: '/home', builder: (context, state) => const HomePage()),
    // 个人中心
    GoRoute(path: '/profile', builder: (context, state) => const ProfilePage()),
    // 互助模块 - 编辑发布页
    GoRoute(
      path: '/help/post',
      builder: (context, state) {
        final typeStr = state.uri.queryParameters['type'] ?? 'lostAndFound';
        PostType type;
        switch (typeStr) {
          case 'secondHand':
            type = PostType.secondHand;
            break;
          case 'helpTask':
            type = PostType.helpTask;
            break;
          default:
            type = PostType.lostAndFound;
        }
        return PostEditPage(type: type);
      },
    ),
    // 互助模块 - 闲置市场列表页
    GoRoute(
      path: '/help/second_hand',
      builder: (context, state) => const SecondHandListPage(),
    ),
    // 图书馆模块
    GoRoute(
      path: '/library',
      builder: (context, state) => const LibraryHomePage(),
      routes: [
        GoRoute(
          path: 'search',
          builder: (context, state) => const BookSearchPage(),
        ),
        GoRoute(
          path: 'seats',
          builder: (context, state) => const SeatReservationPage(),
        ),
        GoRoute(
          path: 'loans',
          builder: (context, state) => const MyLoansPage(),
        ),
        GoRoute(
          path: 'reservations',
          builder: (context, state) => const ReservationsPage(),
        ),
        GoRoute(
          path: 'stats',
          builder: (context, state) => const LibraryStatsPage(),
        ),
        GoRoute(
          path: 'books',
          builder: (context, state) => const AllBooksPage(),
        ),
        GoRoute(
          path: 'books/:id',
          builder: (context, state) {
            final bookId = state.pathParameters['id']!;
            return BookDetailPage(bookId: bookId);
          },
        ),
        GoRoute(
          path: 'seat-reservations',
          builder: (context, state) => const MyReservationsPage(),
        ),
      ],
    ),
    // 成绩查询（根据角色跳转不同页面）
    GoRoute(
      path: '/grades',
      builder: (context, state) => const _GradeRouterPage(),
    ),
    // 考试倒计时
    GoRoute(
      path: '/exam-countdown',
      builder: (context, state) => const ExamCountdownPage(),
    ),
    // 完整课表
    GoRoute(
      path: '/schedule',
      builder: (context, state) => const SchedulePage(),
    ),
    // 教师教学日历
    GoRoute(
      path: '/teacher/schedule',
      builder: (context, state) => const TeacherWeeklySchedulePage(),
    ),
    GoRoute(
      path: '/teacher/class-roster',
      builder: (context, state) => const ClassRosterPage(),
    ),
    // 查找教室
    GoRoute(
      path: '/find-room',
      builder: (context, state) => const FindRoomPage(),
    ),
    // 校园地图
    GoRoute(
      path: '/campus-map',
      builder: (context, state) => const MapDetailPage(),
    ),
    // 请假审批
    GoRoute(
      path: '/leave-approval',
      builder: (context, state) => const LeaveApprovalPage(),
    ),
    // 学生请假申请
    GoRoute(
      path: '/leave-apply',
      builder: (context, state) => const LeaveApplyPage(),
    ),
  ],
);

/// 成绩路由分发页：查询当前用户角色后跳转对应页面
class _GradeRouterPage extends StatefulWidget {
  const _GradeRouterPage();

  @override
  State<_GradeRouterPage> createState() => _GradeRouterPageState();
}

class _GradeRouterPageState extends State<_GradeRouterPage> {
  late Future<Widget> _pageFuture;

  @override
  void initState() {
    super.initState();
    _pageFuture = _resolveGradePage();
  }

  Future<Widget> _resolveGradePage() async {
    final currentUserId =
        Supabase.instance.client.auth.currentUser?.id;
    if (currentUserId == null) return const GradesPage();
    try {
      final response = await Supabase.instance.client
          .from('users')
          .select('type')
          .eq('id', currentUserId)
          .single();
      final type = response['type'] as String? ?? 'student';
      if (type == 'teacher') return const TeacherGradePage();
    } catch (_) {}
    return const GradesPage();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _pageFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return snapshot.data ?? const GradesPage();
      },
    );
  }
}
