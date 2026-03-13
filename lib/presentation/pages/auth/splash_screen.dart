import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/theme.dart';
import '../../../core/services/auth_service.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // 模拟加载时间
    await Future.delayed(const Duration(seconds: 2));

    final authState = ref.read(authStateProvider);
    if (authState.user != null) {
      // 已登录，跳转到首页
      context.go('/home');
    } else {
      // 未登录，跳转到登录页
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.school_rounded,
              size: 56,
              color: Colors.white,
            ),
            const SizedBox(height: 24),
            Text(
              '校园通',
              style: AppTextStyles.headlineMedium.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '智慧校园一站式服务平台',
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 13,
                color: Colors.white.withOpacity(0.5),
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 64),
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.white.withOpacity(0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
