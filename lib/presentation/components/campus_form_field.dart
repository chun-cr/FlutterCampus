import 'package:flutter/material.dart';
import '../theme/theme.dart';

class CampusFormField extends StatefulWidget {
  const CampusFormField({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.errorText,
    this.isRequired = false,
    this.isObscure = false,
    this.isDisabled = false,
    this.isLoading = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.maxLines = 1,
    this.minLines = 1,
    this.maxLength,
    this.expands = false,
    this.contentPadding,
    this.borderRadius,
    this.borderColor,
    this.backgroundColor,
  });
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final String? errorText;
  final bool isRequired;
  final bool isObscure;
  final bool isDisabled;
  final bool isLoading;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final Function()? onSuffixTap;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final String? Function(String?)? validator;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool expands;
  final EdgeInsets? contentPadding;
  final BorderRadius? borderRadius;
  final Color? borderColor;
  final Color? backgroundColor;

  @override
  _CampusFormFieldState createState() => _CampusFormFieldState();
}

class _CampusFormFieldState extends State<CampusFormField> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final bool showPasswordToggle = widget.isObscure;
    final bool hasError = widget.errorText != null;

    return TextFormField(
      controller: widget.controller,
      decoration: InputDecoration(
        labelText: widget.isRequired
            ? '${widget.labelText} *'
            : widget.labelText,
        hintText: widget.hintText,
        errorText: widget.errorText,
        prefixIcon: widget.prefixIcon != null
            ? Icon(widget.prefixIcon, color: AppColors.grey)
            : null,
        suffixIcon: widget.isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              )
            : showPasswordToggle
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: AppColors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              )
            : widget.suffixIcon != null
            ? IconButton(
                icon: Icon(widget.suffixIcon, color: AppColors.grey),
                onPressed: widget.onSuffixTap,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius:
              widget.borderRadius ??
              BorderRadius.circular(AppSpacing.borderRadius),
          borderSide: BorderSide(
            color: hasError
                ? AppColors.error
                : widget.borderColor ?? AppColors.greyLight.withOpacity(0.8),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius:
              widget.borderRadius ??
              BorderRadius.circular(AppSpacing.borderRadius),
          borderSide: BorderSide(
            color: hasError
                ? AppColors.error
                : widget.borderColor ?? AppColors.greyLight.withOpacity(0.8),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius:
              widget.borderRadius ??
              BorderRadius.circular(AppSpacing.borderRadius),
          borderSide: BorderSide(
            color: hasError ? AppColors.error : AppColors.primary,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius:
              widget.borderRadius ??
              BorderRadius.circular(AppSpacing.borderRadius),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius:
              widget.borderRadius ??
              BorderRadius.circular(AppSpacing.borderRadius),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius:
              widget.borderRadius ??
              BorderRadius.circular(AppSpacing.borderRadius),
          borderSide: const BorderSide(color: AppColors.greyLight, width: 1),
        ),
        filled: true,
        fillColor: widget.isDisabled
            ? AppColors.greyLight.withOpacity(0.5)
            : widget.backgroundColor ?? AppColors.surface,
        contentPadding:
            widget.contentPadding ??
            EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: widget.maxLines == 1 ? AppSpacing.sm : AppSpacing.md,
            ),
        counterText: '',
      ),
      obscureText: widget.isObscure && !_isPasswordVisible,
      enabled: !widget.isDisabled && !widget.isLoading,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      validator: widget.validator,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      expands: widget.expands,
      style: AppTextStyles.bodyMedium,
      cursorColor: AppColors.primary,
    );
  }
}

// 带验证的表单组件
class CampusValidatedFormField extends StatefulWidget {
  const CampusValidatedFormField({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.isRequired = true,
    this.isObscure = false,
    this.keyboardType = TextInputType.text,
    this.customValidator,
    this.maxLength,
    this.prefixIcon,
  });
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final bool isRequired;
  final bool isObscure;
  final TextInputType keyboardType;
  final String? Function(String?)? customValidator;
  final int? maxLength;
  final IconData? prefixIcon;

  @override
  _CampusValidatedFormFieldState createState() =>
      _CampusValidatedFormFieldState();
}

class _CampusValidatedFormFieldState extends State<CampusValidatedFormField> {
  String? _errorText;

  void _validate(String value) {
    if (widget.isRequired && value.isEmpty) {
      setState(() {
        _errorText = '请输入${widget.labelText}';
      });
      return;
    }

    if (widget.customValidator != null) {
      final error = widget.customValidator!(value);
      setState(() {
        _errorText = error;
      });
      return;
    }

    setState(() {
      _errorText = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CampusFormField(
      controller: widget.controller,
      labelText: widget.labelText,
      hintText: widget.hintText,
      errorText: _errorText,
      isRequired: widget.isRequired,
      isObscure: widget.isObscure,
      keyboardType: widget.keyboardType,
      maxLength: widget.maxLength,
      prefixIcon: widget.prefixIcon,
      onChanged: _validate,
    );
  }
}

// 表单验证工具类
class CampusFormValidator {
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '请输入$fieldName';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入邮箱';
    }
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value)) {
      return '请输入有效的邮箱地址';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入手机号';
    }
    if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(value)) {
      return '请输入有效的手机号';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入密码';
    }
    if (value.length < 6) {
      return '密码长度至少6位';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return '请确认密码';
    }
    if (value != password) {
      return '两次输入的密码不一致';
    }
    return null;
  }

  static String? validateStudentId(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入学号';
    }
    if (value.length < 8) {
      return '学号长度不正确';
    }
    return null;
  }
}
