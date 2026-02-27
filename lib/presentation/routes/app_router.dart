import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
import '../pages/help/post_edit_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    // 启动页
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    // 登录页
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
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
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomePage(),
    ),
    // 个人中心
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfilePage(),
    ),
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
          path: 'stats',
          builder: (context, state) => const LibraryStatsPage(),
        ),
      ],
    ),
  ],
);
