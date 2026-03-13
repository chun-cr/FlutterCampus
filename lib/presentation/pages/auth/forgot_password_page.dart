import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/theme.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _isSubmitted = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      // 模拟发送重置邮件
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _isLoading = false;
          _isSubmitted = true;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final topSectionHeight = screenHeight * 0.35;
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
              Expanded(child: Container(color: AppColors.white)),
            ],
          ),
          SafeArea(
            bottom: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Stack(
                  children: [
                    Column(
                      children: [
                        SizedBox(
                          height: topSectionHeight,
                          child: const Center(
                            child: Icon(
                              Icons.lock_outline_rounded,
                              size: 40,
                              color: Colors.white,
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    '忘记密码',
                                    style: AppTextStyles.headlineMedium.copyWith(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF1A1A1A),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '输入邮箱，我们将发送重置链接',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      fontSize: 13,
                                      color: const Color(0xFF999999),
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  if (!_isSubmitted)
                                    Form(
                                      key: _formKey,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          TextFormField(
                                            controller: _emailController,
                                            keyboardType:
                                                TextInputType.emailAddress,
                                            style: AppTextStyles.bodyMedium,
                                            cursorColor:
                                                const Color(0xFF1A1A1A),
                                            decoration: InputDecoration(
                                              hintText: '输入您的邮箱',
                                              hintStyle:
                                                  AppTextStyles.bodyMedium.copyWith(
                                                color: const Color(0xFF999999),
                                              ),
                                              filled: true,
                                              fillColor: const Color(0xFFF7F7F7),
                                              prefixIcon: const Icon(
                                                Icons.email_outlined,
                                                color: Color(0xFF999999),
                                                size: 20,
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 18,
                                                vertical: 18,
                                              ),
                                              border: inputBorder,
                                              enabledBorder: inputBorder,
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: const BorderSide(
                                                  color: Color(0xFF1A1A1A),
                                                  width: 1.5,
                                                ),
                                              ),
                                            ),
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return '请输入邮箱';
                                              }
                                              if (!RegExp(
                                                r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                                              ).hasMatch(value)) {
                                                return '请输入有效的邮箱地址';
                                              }
                                              return null;
                                            },
                                          ),
                                          const SizedBox(height: 32),
                                          ElevatedButton(
                                            onPressed:
                                                _isLoading ? null : _submit,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color(0xFF1A1A1A),
                                              foregroundColor: Colors.white,
                                              elevation: 0,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                vertical: 18,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: _isLoading
                                                ? const SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child:
                                                        CircularProgressIndicator(
                                                      strokeWidth: 1.5,
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                              Color>(
                                                        Colors.white,
                                                      ),
                                                    ),
                                                  )
                                                : Text(
                                                    '发送重置链接',
                                                    style:
                                                        AppTextStyles.button.copyWith(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      letterSpacing: 1.0,
                                                    ),
                                                  ),
                                          ),
                                        ],
                                      ),
                                    )
                                  else
                                    Column(
                                      children: [
                                        const Icon(
                                          Icons.check_circle_outline_rounded,
                                          size: 56,
                                          color: Color(0xFF1A1A1A),
                                        ),
                                        const SizedBox(height: 20),
                                        Text(
                                          '邮件已发送',
                                          style:
                                              AppTextStyles.titleMedium.copyWith(
                                            color: const Color(0xFF1A1A1A),
                                            fontWeight: FontWeight.w700,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '请检查您的邮箱获取重置链接',
                                          style: AppTextStyles.bodyMedium.copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 32),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              context.go('/login');
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color(0xFF1A1A1A),
                                              foregroundColor: Colors.white,
                                              elevation: 0,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                vertical: 18,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: Text(
                                              '返回登录',
                                              style:
                                                  AppTextStyles.button.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                                letterSpacing: 1.0,
                                              ),
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
                      ],
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () => context.pop(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
