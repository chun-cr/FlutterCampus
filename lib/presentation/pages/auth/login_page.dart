import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/theme.dart';
import '../../components/campus_card.dart';
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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 32.0,
                vertical: 48.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 32),
                  CampusCard(
                    padding: const EdgeInsets.all(32.0),
                    margin: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Icon(
                            Icons.school_outlined,
                            size: 48,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          '欢迎回来',
                          style: AppTextStyles.headlineMedium.copyWith(
                            fontWeight: FontWeight.w400,
                            letterSpacing: 1.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '请登录您的账号',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        // 登录表单
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // 手机号/学号输入
                              Text(
                                '手机号 / 学号',
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _identifierController,
                                style: AppTextStyles.bodyMedium,
                                cursorColor: AppColors.primary,
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  hintText: '输入手机号或学号',
                                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textDisabled,
                                  ),
                                  filled: true,
                                  fillColor: AppColors.surface,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: AppColors.grey,
                                      width: 1.0,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: AppColors.grey,
                                      width: 1.0,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: AppColors.primary,
                                      width: 1,
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
                              const SizedBox(height: 24),
                              // 密码输入
                              Text(
                                '密码',
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: !_isPasswordVisible,
                                style: AppTextStyles.bodyMedium,
                                cursorColor: AppColors.primary,
                                decoration: InputDecoration(
                                  hintText: '输入您的密码',
                                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textDisabled,
                                  ),
                                  filled: true,
                                  fillColor: AppColors.surface,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isPasswordVisible
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: AppColors.grey,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isPasswordVisible =
                                            !_isPasswordVisible;
                                      });
                                    },
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: AppColors.greyLight,
                                      width: 0.5,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: AppColors.greyLight,
                                      width: 0.5,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: AppColors.primary,
                                      width: 1,
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
                              // 错误信息
                              if (authState.error != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: Text(
                                    authState.error!,
                                    style: AppTextStyles.error,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              // 忘记密码
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    context.push('/forgot_password');
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.textSecondary,
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    '忘记密码？',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                              ElevatedButton(
                                onPressed: authState.isLoading ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: AppColors.surface,
                                  elevation: 2,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
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
                                                AppColors.white,
                                              ),
                                        ),
                                      )
                                    : Text(
                                        '登录',
                                        style: AppTextStyles.button.copyWith(
                                          color: AppColors.surface,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // 注册链接
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
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                '立即注册',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                      ],
                    ), // closes Column (CampusCard child)
                  ), // closes CampusCard
                ],
              ), // closes Column (SingleChildScrollView child)
            ), // closes SingleChildScrollView
          ), // closes ConstrainedBox
        ), // closes Center
      ), // closes SafeArea
    ); // closes Scaffold
  } // closes build
} // closes _LoginPageState
