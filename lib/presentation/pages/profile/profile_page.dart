import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/theme.dart';
import '../../../core/services/auth_service.dart';
import '../../../domain/models/user.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.user;

    Widget body;
    if (user == null) {
      body = _buildUnauthenticatedBody(context);
    } else {
      body = _buildAuthenticatedBody(context, ref, user);
    }

    return Container(
      color: const Color(0xFFF7F7F7), // Neutral background for constraints
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ClipRect(
            child: Scaffold(
              backgroundColor: const Color(0xFFFAFAFA),
              body: body,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUnauthenticatedBody(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_outline_rounded,
            size: 80,
            color: AppColors.grey.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 24),
          Text(
            '欢迎使用',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.w300,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '登录后查看个人资料',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: () => context.go('/login'),
            child: const Text(
              '立即登录',
              style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthenticatedBody(
    BuildContext context,
    WidgetRef ref,
    User user,
  ) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          expandedHeight: 280,
          pinned: true,
          stretch: true,
          elevation: 0,
          backgroundColor: const Color(0xFFFAFAFA),
          foregroundColor: AppColors.textPrimary,
          flexibleSpace: FlexibleSpaceBar(
            stretchModes: const [StretchMode.zoomBackground],
            background: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Hero(
                  tag: 'profile_avatar',
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 56,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 52,
                        backgroundColor: const Color(0xFFF0F0F0),
                        backgroundImage:
                            user.avatar != null && user.avatar!.isNotEmpty
                            ? NetworkImage(user.avatar!)
                            : null,
                        child: user.avatar == null || user.avatar!.isEmpty
                            ? Icon(
                                Icons.person_outline_rounded,
                                size: 48,
                                color: AppColors.grey.withValues(alpha: 0.5),
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  user.name,
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 28,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  user.department ?? '校园成员',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('账号信息'),
                const SizedBox(height: 16),
                _buildProfileGroup([
                  _buildProfileRow(
                    Icons.phone_iphone_rounded,
                    '手机号',
                    user.phone,
                  ),
                  _buildProfileRow(
                    Icons.mail_outline_rounded,
                    '邮箱',
                    user.email,
                  ),
                  _buildProfileRow(Icons.badge_outlined, '账号', user.username),
                  _buildProfileRow(
                    Icons.verified_user_outlined,
                    '角色',
                    user.type == UserType.student
                        ? '学生'
                        : (user.type == UserType.teacher ? '教师' : '工作人员'),
                    isLast: true,
                  ),
                ]),
                const SizedBox(height: 40),
                _buildSectionHeader('偏好设置'),
                const SizedBox(height: 16),
                _buildProfileGroup([
                  _buildActionRow(Icons.tune_rounded, '设置', onTap: () {}),
                  _buildActionRow(
                    Icons.help_outline_rounded,
                    '帮助与反馈',
                    onTap: () {},
                  ),
                  _buildActionRow(
                    Icons.info_outline_rounded,
                    '关于',
                    isLast: true,
                    onTap: () {},
                  ),
                ]),
                const SizedBox(height: 48),
                Center(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () async {
                      await ref.read(authStateProvider.notifier).logout();
                      if (context.mounted) {
                        context.go('/login');
                      }
                    },
                    child: const Text(
                      '退出登录',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 80), // Extra bottom padding
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: Text(
        title,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textSecondary.withValues(alpha: 0.6),
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildProfileGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.white,
          child: Column(children: children),
        ),
      ),
    );
  }

  Widget _buildProfileRow(
    IconData icon,
    String label,
    String value, {
    bool isLast = false,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Row(
            children: [
              Icon(
                icon,
                color: AppColors.grey.withValues(alpha: 0.8),
                size: 22,
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textPrimary.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                value,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 58,
            endIndent: 20,
            color: Colors.black.withValues(alpha: 0.04),
          ),
      ],
    );
  }

  Widget _buildActionRow(
    IconData icon,
    String label, {
    bool isLast = false,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 20.0,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: AppColors.grey.withValues(alpha: 0.8),
                  size: 22,
                ),
                const SizedBox(width: 16),
                Text(
                  label,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textPrimary.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.grey.withValues(alpha: 0.4),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 58,
            endIndent: 20,
            color: Colors.black.withValues(alpha: 0.04),
          ),
      ],
    );
  }
}
