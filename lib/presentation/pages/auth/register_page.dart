import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/theme.dart';
import '../../../domain/models/user.dart';
import '../../../core/services/auth_service.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _departmentController = TextEditingController();
  
  UserType _userType = UserType.student;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _studentIdController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  void _register() async {
    if (_formKey.currentState?.validate() ?? false) {
      final user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        username: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        type: _userType,
        studentId: _userType == UserType.student ? _studentIdController.text.trim() : null,
        department: _departmentController.text.trim(),
        isLoggedIn: true,
      );

      await ref.read(authStateProvider.notifier).register(user);

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
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 48),
              // 标题
              Text(
                '创建账号',
                style: AppTextStyles.headlineMedium,
              ),
              Text(
                '加入校园通',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              // 用户类型选择
              Container(
                margin: EdgeInsets.only(bottom: AppSpacing.lg),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.greyLight),
                  borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _userType = UserType.student;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: AppSpacing.md,
                          ),
                          decoration: BoxDecoration(
                            color: _userType == UserType.student ? AppColors.primary : AppColors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(AppSpacing.borderRadius),
                              bottomLeft: Radius.circular(AppSpacing.borderRadius),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '学生',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: _userType == UserType.student ? AppColors.white : AppColors.textPrimary,
                                fontWeight: _userType == UserType.student ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _userType = UserType.teacher;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: AppSpacing.md,
                          ),
                          decoration: BoxDecoration(
                            color: _userType == UserType.teacher ? AppColors.primary : AppColors.white,
                          ),
                          child: Center(
                            child: Text(
                              '教职工',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: _userType == UserType.teacher ? AppColors.white : AppColors.textPrimary,
                                fontWeight: _userType == UserType.teacher ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // 注册表单
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // 用户名输入
                    Container(
                      margin: EdgeInsets.only(bottom: AppSpacing.md),
                      child: TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: '用户名',
                          hintText: '请输入用户名',
                          prefixIcon: Icon(Icons.person, color: AppColors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '请输入用户名';
                          }
                          return null;
                        },
                      ),
                    ),
                    // 密码输入
                    Container(
                      margin: EdgeInsets.only(bottom: AppSpacing.md),
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: '密码',
                          hintText: '请输入密码',
                          prefixIcon: Icon(Icons.lock, color: AppColors.grey),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                              color: AppColors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
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
                    ),
                    // 确认密码输入
                    Container(
                      margin: EdgeInsets.only(bottom: AppSpacing.md),
                      child: TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: !_isConfirmPasswordVisible,
                        decoration: InputDecoration(
                          labelText: '确认密码',
                          hintText: '请再次输入密码',
                          prefixIcon: Icon(Icons.lock, color: AppColors.grey),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                              color: AppColors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '请确认密码';
                          }
                          if (value != _passwordController.text) {
                            return '两次输入的密码不一致';
                          }
                          return null;
                        },
                      ),
                    ),
                    // 姓名输入
                    Container(
                      margin: EdgeInsets.only(bottom: AppSpacing.md),
                      child: TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: '姓名',
                          hintText: '请输入姓名',
                          prefixIcon: Icon(Icons.person_outline, color: AppColors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '请输入姓名';
                          }
                          return null;
                        },
                      ),
                    ),
                    // 邮箱输入
                    Container(
                      margin: EdgeInsets.only(bottom: AppSpacing.md),
                      child: TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: '邮箱',
                          hintText: '请输入邮箱',
                          prefixIcon: Icon(Icons.email, color: AppColors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '请输入邮箱';
                          }
                          if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value)) {
                            return '请输入有效的邮箱地址';
                          }
                          return null;
                        },
                      ),
                    ),
                    // 手机号输入
                    Container(
                      margin: EdgeInsets.only(bottom: AppSpacing.md),
                      child: TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: '手机号',
                          hintText: '请输入手机号',
                          prefixIcon: Icon(Icons.phone, color: AppColors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '请输入手机号';
                          }
                          if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(value)) {
                            return '请输入有效的手机号';
                          }
                          return null;
                        },
                      ),
                    ),
                    // 学号输入（仅学生）
                    if (_userType == UserType.student)
                      Container(
                        margin: EdgeInsets.only(bottom: AppSpacing.md),
                        child: TextFormField(
                          controller: _studentIdController,
                          decoration: InputDecoration(
                            labelText: '学号',
                            hintText: '请输入学号',
                            prefixIcon: Icon(Icons.confirmation_number, color: AppColors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '请输入学号';
                            }
                            return null;
                          },
                        ),
                      ),
                    // 院系输入
                    Container(
                      margin: EdgeInsets.only(bottom: AppSpacing.md),
                      child: TextFormField(
                        controller: _departmentController,
                        decoration: InputDecoration(
                          labelText: _userType == UserType.student ? '院系' : '部门',
                          hintText: _userType == UserType.student ? '请输入院系' : '请输入部门',
                          prefixIcon: Icon(Icons.business, color: AppColors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return _userType == UserType.student ? '请输入院系' : '请输入部门';
                          }
                          return null;
                        },
                      ),
                    ),
                    // 错误信息
                    if (authState.error != null)
                      Container(
                        margin: EdgeInsets.only(bottom: AppSpacing.md),
                        child: Text(
                          authState.error!,
                          style: AppTextStyles.error,
                        ),
                      ),
                    // 注册按钮
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(bottom: AppSpacing.md),
                      child: ElevatedButton(
                        onPressed: authState.isLoading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: AppSpacing.buttonPadding,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
                          ),
                        ),
                        child: authState.isLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                                ),
                              )
                            : Text('注册'),
                      ),
                    ),
                    // 登录链接
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '已有账号？',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            context.push('/login');
                          },
                          child: Text(
                            '立即登录',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
