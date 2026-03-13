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

  // Controllers - initialized in initState
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _studentIdController;
  late final TextEditingController _departmentController;

  // FocusNodes for proper keyboard event handling
  late final FocusNode _usernameFocus;
  late final FocusNode _passwordFocus;
  late final FocusNode _confirmPasswordFocus;
  late final FocusNode _nameFocus;
  late final FocusNode _emailFocus;
  late final FocusNode _phoneFocus;
  late final FocusNode _studentIdFocus;
  late final FocusNode _departmentFocus;

  UserType _userType = UserType.student;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _studentIdController = TextEditingController();
    _departmentController = TextEditingController();

    // Initialize focus nodes
    _usernameFocus = FocusNode();
    _passwordFocus = FocusNode();
    _confirmPasswordFocus = FocusNode();
    _nameFocus = FocusNode();
    _emailFocus = FocusNode();
    _phoneFocus = FocusNode();
    _studentIdFocus = FocusNode();
    _departmentFocus = FocusNode();
  }

  @override
  void dispose() {
    // Dispose controllers
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _studentIdController.dispose();
    _departmentController.dispose();

    // Dispose focus nodes
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _studentIdFocus.dispose();
    _departmentFocus.dispose();

    super.dispose();
  }

  Widget _buildLabel(String text) {
    return const SizedBox.shrink();
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required FocusNode focusNode,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    );

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: AppTextStyles.bodyMedium,
      cursorColor: const Color(0xFF1A1A1A),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: const Color(0xFF999999),
        ),
        filled: true,
        fillColor: const Color(0xFFF7F7F7),
        prefixIcon: Icon(
          _prefixIconForHint(hintText),
          color: const Color(0xFF999999),
          size: 20,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        suffixIcon: suffixIcon,
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1A1A1A), width: 1.5),
        ),
      ),
      validator: validator,
    );
  }

  IconData _prefixIconForHint(String hintText) {
    if (hintText.contains('用户名')) return Icons.badge_outlined;
    if (hintText.contains('密码')) return Icons.lock_outline_rounded;
    if (hintText.contains('姓名')) return Icons.person_outline_rounded;
    if (hintText.contains('邮箱')) return Icons.email_outlined;
    if (hintText.contains('手机号')) return Icons.phone_outlined;
    if (hintText.contains('学号')) return Icons.numbers_outlined;
    if (hintText.contains('院系') || hintText.contains('部门')) {
      return Icons.apartment_outlined;
    }
    return Icons.edit_outlined;
  }

  void _register() async {
    if (_formKey.currentState?.validate() ?? false) {
      final username = _usernameController.text.trim();
      final password = _passwordController.text.trim();
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final phone = _phoneController.text.trim();
      final studentId = _userType == UserType.student
          ? _studentIdController.text.trim()
          : null;
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
    final screenHeight = MediaQuery.of(context).size.height;
    final topSectionHeight = screenHeight * 0.3;

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
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.person_add_outlined,
                                  size: 40,
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  '创建账号',
                                  style: AppTextStyles.headlineMedium.copyWith(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
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
                              padding: const EdgeInsets.fromLTRB(32, 32, 32, 32),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 24),
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF7F7F7),
                                      borderRadius: BorderRadius.circular(10),
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
                                              duration: const Duration(
                                                milliseconds: 200,
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                vertical: 12,
                                              ),
                                              decoration: BoxDecoration(
                                                color: _userType ==
                                                        UserType.student
                                                    ? const Color(0xFF1A1A1A)
                                                    : Colors.transparent,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: _userType ==
                                                        UserType.student
                                                    ? null
                                                    : Border.all(
                                                        color: const Color(
                                                          0xFFDDDDDD,
                                                        ),
                                                      ),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  '学生',
                                                  style: AppTextStyles.bodyMedium
                                                      .copyWith(
                                                    color: _userType ==
                                                            UserType.student
                                                        ? Colors.white
                                                        : const Color(
                                                            0xFF999999,
                                                          ),
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _userType = UserType.teacher;
                                              });
                                            },
                                            child: AnimatedContainer(
                                              duration: const Duration(
                                                milliseconds: 200,
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                vertical: 12,
                                              ),
                                              decoration: BoxDecoration(
                                                color: _userType ==
                                                        UserType.teacher
                                                    ? const Color(0xFF1A1A1A)
                                                    : Colors.transparent,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: _userType ==
                                                        UserType.teacher
                                                    ? null
                                                    : Border.all(
                                                        color: const Color(
                                                          0xFFDDDDDD,
                                                        ),
                                                      ),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  '教师',
                                                  style: AppTextStyles.bodyMedium
                                                      .copyWith(
                                                    color: _userType ==
                                                            UserType.teacher
                                                        ? Colors.white
                                                        : const Color(
                                                            0xFF999999,
                                                          ),
                                                    fontWeight: FontWeight.w600,
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        _buildLabel('用户名'),
                                        _buildTextField(
                                          controller: _usernameController,
                                          focusNode: _usernameFocus,
                                          hintText: '输入您的用户名',
                                          validator: (value) =>
                                              (value == null || value.isEmpty)
                                              ? '请输入用户名'
                                              : null,
                                        ),
                                        const SizedBox(height: 16),
                                        _buildLabel('密码'),
                                        _buildTextField(
                                          controller: _passwordController,
                                          focusNode: _passwordFocus,
                                          hintText: '设置密码（至少6位）',
                                          obscureText: !_isPasswordVisible,
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
                                        _buildLabel('确认密码'),
                                        _buildTextField(
                                          controller:
                                              _confirmPasswordController,
                                          focusNode: _confirmPasswordFocus,
                                          hintText: '再次输入密码',
                                          obscureText:
                                              !_isConfirmPasswordVisible,
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _isConfirmPasswordVisible
                                                  ? Icons.visibility_outlined
                                                  : Icons.visibility_off_outlined,
                                              color: const Color(0xFF999999),
                                              size: 20,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _isConfirmPasswordVisible =
                                                    !_isConfirmPasswordVisible;
                                              });
                                            },
                                          ),
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return '请确认密码';
                                            }
                                            if (value !=
                                                _passwordController.text) {
                                              return '两次输入的密码不一致';
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 16),
                                        _buildLabel('姓名'),
                                        _buildTextField(
                                          controller: _nameController,
                                          focusNode: _nameFocus,
                                          hintText: '输入您的真实姓名',
                                          validator: (value) =>
                                              (value == null || value.isEmpty)
                                              ? '请输入姓名'
                                              : null,
                                        ),
                                        const SizedBox(height: 16),
                                        _buildLabel('邮箱'),
                                        _buildTextField(
                                          controller: _emailController,
                                          focusNode: _emailFocus,
                                          hintText: '输入您的邮箱',
                                          keyboardType:
                                              TextInputType.emailAddress,
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
                                        const SizedBox(height: 16),
                                        _buildLabel('手机号'),
                                        _buildTextField(
                                          controller: _phoneController,
                                          focusNode: _phoneFocus,
                                          hintText: '输入您的手机号',
                                          keyboardType: TextInputType.phone,
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return '请输入手机号';
                                            }
                                            if (!RegExp(r'^1[3-9]\d{9}$')
                                                .hasMatch(value)) {
                                              return '请输入有效的手机号';
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 16),
                                        if (_userType == UserType.student) ...[
                                          _buildLabel('学号'),
                                          _buildTextField(
                                            controller: _studentIdController,
                                            focusNode: _studentIdFocus,
                                            hintText: '输入您的学号',
                                            validator: (value) =>
                                                (value == null ||
                                                    value.isEmpty)
                                                ? '请输入学号'
                                                : null,
                                          ),
                                          const SizedBox(height: 16),
                                        ],
                                        _buildLabel(
                                          _userType == UserType.student
                                              ? '院系'
                                              : '部门',
                                        ),
                                        _buildTextField(
                                          controller: _departmentController,
                                          focusNode: _departmentFocus,
                                          hintText: _userType == UserType.student
                                              ? '输入您的院系'
                                              : '输入您的部门',
                                          validator: (value) =>
                                              (value == null || value.isEmpty)
                                              ? (_userType == UserType.student
                                                  ? '请输入院系'
                                                  : '请输入部门')
                                              : null,
                                        ),
                                        const SizedBox(height: 24),
                                        if (authState.error != null)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 16,
                                            ),
                                            child: Text(
                                              authState.error!,
                                              style: AppTextStyles.error,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ElevatedButton(
                                          onPressed: authState.isLoading
                                              ? null
                                              : _register,
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
                                          child: authState.isLoading
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
                                                  '注 册',
                                                  style: AppTextStyles.button
                                                      .copyWith(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w600,
                                                    letterSpacing: 2.0,
                                                  ),
                                                ),
                                        ),
                                        const SizedBox(height: 32),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              '已有账号？',
                                              style: AppTextStyles.bodyMedium
                                                  .copyWith(
                                                color:
                                                    AppColors.textSecondary,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            TextButton(
                                              onPressed: () {
                                                ref
                                                    .read(authStateProvider
                                                        .notifier)
                                                    .clearError();
                                                context.push('/login');
                                              },
                                              style: TextButton.styleFrom(
                                                padding: EdgeInsets.zero,
                                                minimumSize: Size.zero,
                                                tapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                              ),
                                              child: Text(
                                                '立即登录',
                                                style: AppTextStyles.bodyMedium
                                                    .copyWith(
                                                  color:
                                                      const Color(0xFF1A1A1A),
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
