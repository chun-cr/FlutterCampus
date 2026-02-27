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

  Widget _buildLabel(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: AppTextStyles.bodyMedium,
      cursorColor: AppColors.primary,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textDisabled),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.grey, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.grey, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1),
        ),
      ),
      validator: validator,
    );
  }

  void _register() async {
    if (_formKey.currentState?.validate() ?? false) {
      final username = _usernameController.text.trim();
      final password = _passwordController.text.trim();
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final phone = _phoneController.text.trim();
      final studentId = _userType == UserType.student ? _studentIdController.text.trim() : null;
      final department = _departmentController.text.trim();

      final user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        username: username,
        name: name,
        email: email,
        phone: phone,
        type: _userType,
        studentId: studentId,
        department: department,
      );

      await ref.read(authStateProvider.notifier).register(user, password);

      if (!mounted) return;
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    '创建账号',
                    style: AppTextStyles.headlineMedium.copyWith(
                      fontWeight: FontWeight.w400,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '加入校园通',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    margin: const EdgeInsets.only(bottom: 32),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.greyLight.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(12),
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
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _userType == UserType.student ? AppColors.surface : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: _userType == UserType.student
                                    ? [
                                        BoxShadow(
                                          color: AppColors.black.withOpacity(0.05),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        )
                                      ]
                                    : [],
                              ),
                              child: Center(
                                child: Text(
                                  '学生',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: _userType == UserType.student ? AppColors.textPrimary : AppColors.textSecondary,
                                    fontWeight: _userType == UserType.student ? FontWeight.w500 : FontWeight.w400,
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
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _userType == UserType.teacher ? AppColors.surface : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: _userType == UserType.teacher
                                    ? [
                                        BoxShadow(
                                          color: AppColors.black.withOpacity(0.05),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        )
                                      ]
                                    : [],
                              ),
                              child: Center(
                                child: Text(
                                  '教职工',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: _userType == UserType.teacher ? AppColors.textPrimary : AppColors.textSecondary,
                                    fontWeight: _userType == UserType.teacher ? FontWeight.w500 : FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildLabel('用户名'),
                        _buildTextField(
                          controller: _usernameController,
                          hintText: '输入您的用户名',
                          validator: (value) => (value == null || value.isEmpty) ? '请输入用户名' : null,
                        ),
                        const SizedBox(height: 24),
                        
                        _buildLabel('密码'),
                        _buildTextField(
                          controller: _passwordController,
                          hintText: '设置密码（至少6位）',
                          obscureText: !_isPasswordVisible,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              color: AppColors.grey,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return '请输入密码';
                            if (value.length < 6) return '密码长度至少6位';
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        _buildLabel('确认密码'),
                        _buildTextField(
                          controller: _confirmPasswordController,
                          hintText: '再次输入密码',
                          obscureText: !_isConfirmPasswordVisible,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isConfirmPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              color: AppColors.grey,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                              });
                            },
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return '请确认密码';
                            if (value != _passwordController.text) return '两次输入的密码不一致';
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        _buildLabel('姓名'),
                        _buildTextField(
                          controller: _nameController,
                          hintText: '输入您的真实姓名',
                          validator: (value) => (value == null || value.isEmpty) ? '请输入姓名' : null,
                        ),
                        const SizedBox(height: 24),

                        _buildLabel('邮箱'),
                        _buildTextField(
                          controller: _emailController,
                          hintText: '输入您的邮箱',
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) return '请输入邮箱';
                            if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value)) return '请输入有效的邮箱地址';
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        _buildLabel('手机号'),
                        _buildTextField(
                          controller: _phoneController,
                          hintText: '输入您的手机号',
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) return '请输入手机号';
                            if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(value)) return '请输入有效的手机号';
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        if (_userType == UserType.student) ...[
                          _buildLabel('学号'),
                          _buildTextField(
                            controller: _studentIdController,
                            hintText: '输入您的学号',
                            validator: (value) => (value == null || value.isEmpty) ? '请输入学号' : null,
                          ),
                          const SizedBox(height: 24),
                        ],

                        _buildLabel(_userType == UserType.student ? '院系' : '部门'),
                        _buildTextField(
                          controller: _departmentController,
                          hintText: _userType == UserType.student ? '输入您的院系' : '输入您的部门',
                          validator: (value) => (value == null || value.isEmpty) ? (_userType == UserType.student ? '请输入院系' : '请输入部门') : null,
                        ),
                        
                        const SizedBox(height: 32),

                        if (authState.error != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(
                              authState.error!,
                              style: AppTextStyles.error,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        
                        ElevatedButton(
                          onPressed: authState.isLoading ? null : _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.black,
                            foregroundColor: AppColors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 18),
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
                                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                                  ),
                                )
                              : Text(
                                  '注册',
                                  style: AppTextStyles.button.copyWith(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 48),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '已有账号？',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            TextButton(
                              onPressed: () {
                                context.push('/login');
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                '立即登录',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
