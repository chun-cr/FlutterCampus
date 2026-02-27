import 'package:riverpod/riverpod.dart';
import '../../domain/models/user.dart' as models;
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

class AuthService {
  final SupabaseClient _supabaseClient;
  AuthService(this._supabaseClient);

  Future<models.User?> login(String email, String password) async {
    try {
      final AuthResponse response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user != null) {
        return models.User.fromSupabase(response.user!);
      }
    } catch (e) {
      print('Login error: $e');
    }
    return null;
  }

  Future<void> logout() async {
    await _supabaseClient.auth.signOut();
  }

  Future<models.User?> register(models.User user, String password) async {
    try {
      final AuthResponse response = await _supabaseClient.auth.signUp(
        email: user.email,
        password: password,
        data: {
          'username': user.username,
          'name': user.name,
          'type': user.type.toString(),
          'student_id': user.studentId,
          'department': user.department,
          'phone': user.phone,
        },
      );
      if (response.user != null) {
        return models.User.fromSupabase(response.user!);
      }
    } catch (e) {
      print('Register error: $e');
      rethrow;
    }
    return null;
  }

  Future<models.User?> getCurrentUser() async {
    final supabaseUser = _supabaseClient.auth.currentUser;
    if (supabaseUser != null) {
      return models.User.fromSupabase(supabaseUser);
    }
    return null;
  }

  Future<void> updateUser(models.User user) async {
    try {
      await _supabaseClient.auth.updateUser(
        UserAttributes(
          data: {
            'username': user.username,
            'name': user.name,
            'type': user.type.toString(),
            'student_id': user.studentId,
            'department': user.department,
            'phone': user.phone,
          },
        ),
      );
    } catch (e) {
      print('Update user error: $e');
      rethrow;
    }
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(Supabase.instance.client);
});

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authServiceProvider));
});

class AuthState {
  final models.User? user;
  final bool isLoading;
  final String? error;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    models.User? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(AuthState()) {
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    state = state.copyWith(isLoading: true);
    try {
      final user = await _authService.getCurrentUser();
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> login(String username, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _authService.login(username, password);
      if (user != null) {
        state = state.copyWith(user: user, isLoading: false);
      } else {
        state = state.copyWith(
          error: '用户名或密码错误',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    try {
      await _authService.logout();
      state = state.copyWith(user: null, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> register(models.User user, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final newUser = await _authService.register(user, password);
      state = state.copyWith(user: newUser, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> updateUser(models.User user) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authService.updateUser(user);
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}
