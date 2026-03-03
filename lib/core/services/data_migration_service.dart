import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';

import '../../domain/models/user.dart' as app_user;

class DataMigrationService {
  DataMigrationService(this._supabaseClient);
  final SupabaseClient _supabaseClient;

  Future<void> migrateHiveUsersToSupabase() async {
    print('开始从 Hive 迁移用户到 Supabase...');
    try {
      if (!Hive.isBoxOpen('users')) {
        await Hive.openBox('users');
      }

      final userBox = Hive.box('users');
      final List<dynamic> hiveData = userBox.values.toList();

      if (hiveData.isEmpty) {
        print('Hive "users" Box 中没有发现用户数据，跳过迁移。');
        return;
      }

      for (final dynamic data in hiveData) {
        app_user.User user;
        if (data is Map) {
          user = app_user.User.fromJson(Map<String, dynamic>.from(data));
        } else if (data is app_user.User) {
          user = data;
        } else {
          print('跳过未知数据格式: $data');
          continue;
        }

        if (user.email.isEmpty) {
          print('用户 ${user.username} (ID: ${user.id}) 没有有效的邮箱地址，跳过注册。');
          continue;
        }

        final temporaryPassword = const Uuid().v4();

        try {
          final AuthResponse response = await _supabaseClient.auth.signUp(
            email: user.email,
            password: temporaryPassword,
            data: {
              'username': user.username,
              'name': user.name,
              'phone': user.phone,
              'type': user.type.name,
              'student_id': user.studentId,
              'department': user.department,
              'avatar': user.avatar,
            },
          );

          if (response.user != null) {
            print('成功迁移用户：${user.email}，临时密码已生成。');
          } else {
            print('迁移用户 ${user.email} 失败：Supabase 未返回用户。');
          }
        } on AuthException catch (e) {
          if (e.message.contains('already registered') ||
              e.message.contains('unique constraint')) {
            print('用户 ${user.email} 已存在于 Supabase 中，跳过注册。');
          } else {
            print('迁移用户 ${user.email} 时发生认证错误：${e.message}');
          }
        } catch (e) {
          print('迁移用户 ${user.email} 时发生未知错误：$e');
        }
      }
      print('Hive 用户迁移到 Supabase 完成。');
    } catch (e) {
      print('执行 Hive 用户迁移时发生错误：$e');
    }
  }
}
