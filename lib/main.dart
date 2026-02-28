import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import 'package:hive_flutter/hive_flutter.dart';
import 'presentation/routes/app_router.dart';
import 'presentation/theme/app_theme.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/services/data_migration_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 初始化Hive
  await Hive.initFlutter();



  
  // 初始化Supabase
  await Supabase.initialize(
    url: 'https://ddqwnntaycxfdsnvdiab.supabase.co',
    anonKey: 'sb_publishable_l3zEsZ0KChBVaDk2bahRLQ_Z8BJLJL8',
  );
  // Temporarily trigger migration
  // For a real app, this migration should be triggered carefully,
  // usually once on a specific version update, not every app start.
  // Example of triggering it (ensure Auth and Supabase are initialized):
  // final authServiceForMigration = AuthService(supabase);
  // final dataMigrationService = DataMigrationService(supabase, authServiceForMigration);
  // await dataMigrationService.migrateHiveUsersToSupabase();

  
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '校园通',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}

final supabase = Supabase.instance.client;
final dataMigrationServiceProvider = Provider<DataMigrationService>((ref) {
  final supabaseClient = Supabase.instance.client;
  return DataMigrationService(supabaseClient);
});
