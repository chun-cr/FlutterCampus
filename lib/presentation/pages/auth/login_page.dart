import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/theme.dart';
import '../../../core/services/auth_service.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      await ref
          .read(authStateProvider.notifier)
          .login(
            _identifierController.text.trim(),
            _passwordController.text.trim(),
          );

      final authState = ref.read(authStateProvider);
      if (authState.user != null) {
        context.go('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final screenHeight = MediaQuery.of(context).size.height;
    final topSectionHeight = screenHeight * 0.45;

    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(
                height: topSectionHeight,
                width: double.infinity,
                child: Container(color: const Color(0xFF1A1A1A)),
              ),
              Expanded(
                child: Container(color: AppColors.white),
              ),
            ],
          ),
          SafeArea(
            bottom: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  children: [
                    SizedBox(
                      height: topSectionHeight,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.school_rounded,
                              size: 56,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 20),
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
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(32),
                          ),
                        ),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(32, 40, 32, 32),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  '欢迎回来',
                                  style: AppTextStyles.headlineMedium.copyWith(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1A1A1A),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '请登录您的账号继续使用',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    fontSize: 13,
                                    color: const Color(0xFF999999),
                                  ),
                                ),
                                const SizedBox(height: 32),
                                TextFormField(
                                  controller: _identifierController,
                                  style: AppTextStyles.bodyMedium,
                                  cursorColor: const Color(0xFF1A1A1A),
                                  keyboardType: TextInputType.text,
                                  onChanged: (_) {
                                    if (authState.error != null) {
                                      ref
                                          .read(authStateProvider.notifier)
                                          .clearError();
                                    }
                                  },
                                  decoration: InputDecoration(
                                    hintText: '输入手机号或学号',
                                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                                      color: const Color(0xFF999999),
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFFF7F7F7),
                                    prefixIcon: const Icon(
                                      Icons.person_outline_rounded,
                                      color: Color(0xFF999999),
                                      size: 20,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 18,
                                      vertical: 18,
                                    ),
                                    border: inputBorder,
                                    enabledBorder: inputBorder,
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Color(0xFF1A1A1A),
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return '请输入手机号或学号';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: !_isPasswordVisible,
                                  style: AppTextStyles.bodyMedium,
                                  cursorColor: const Color(0xFF1A1A1A),
                                  onChanged: (_) {
                                    if (authState.error != null) {
                                      ref
                                          .read(authStateProvider.notifier)
                                          .clearError();
                                    }
                                  },
                                  decoration: InputDecoration(
                                    hintText: '输入您的密码',
                                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                                      color: const Color(0xFF999999),
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFFF7F7F7),
                                    prefixIcon: const Icon(
                                      Icons.lock_outline_rounded,
                                      color: Color(0xFF999999),
                                      size: 20,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _isPasswordVisible
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        color: const Color(0xFF999999),
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _isPasswordVisible =
                                              !_isPasswordVisible;
                                        });
                                      },
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 18,
                                      vertical: 18,
                                    ),
                                    border: inputBorder,
                                    enabledBorder: inputBorder,
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Color(0xFF1A1A1A),
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return '请输入密码';
                                    }
                                    if (value.length < 6) {
                                      return '密码长度至少6位';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                if (authState.error != null)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: Text(
                                      authState.error!,
                                      style: AppTextStyles.error,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {
                                      ref
                                          .read(authStateProvider.notifier)
                                          .clearError();
                                      context.push('/forgot_password');
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor: const Color(0xFF1A1A1A),
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      '忘记密码？',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: const Color(0xFF1A1A1A),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 28),
                                ElevatedButton(
                                  onPressed: authState.isLoading ? null : _login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1A1A1A),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 18,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: authState.isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 1.5,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          ),
                                        )
                                      : Text(
                                          '登录',
                                          style: AppTextStyles.button.copyWith(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 2.0,
                                          ),
                                        ),
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '还没有账号？',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    TextButton(
                                      onPressed: () {
                                        ref
                                            .read(authStateProvider.notifier)
                                            .clearError();
                                        context.push('/register');
                                      },
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: Size.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: Text(
                                        '立即注册',
                                        style: AppTextStyles.bodyMedium.copyWith(
                                          color: const Color(0xFF1A1A1A),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ); // closes Scaffold
  } // closes build
} // closes _LoginPageState
