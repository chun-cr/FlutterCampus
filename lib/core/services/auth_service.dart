import 'package:riverpod/riverpod.dart';
import '../../domain/models/user.dart' as models;
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:supabase_flutter/supabase_flutter.dart' as sup;

class AuthService {
  AuthService(this._supabaseClient);
  final SupabaseClient _supabaseClient;

  /// Login with email directly
  Future<models.User?> loginWithEmail(String email, String password) async {
    try {
      final AuthResponse response = await _supabaseClient.auth
          .signInWithPassword(email: email, password: password);
      if (response.user != null) {
        return await _getUserFromPublicTable(response.user!);
      }
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
    return null;
  }

  Future<models.User> _getUserFromPublicTable(sup.User supabaseUser) async {
    try {
      final response = await _supabaseClient
          .from('users')
          .select()
          .eq('id', supabaseUser.id)
          .maybeSingle();

      if (response != null) {
        // Merge auth info with public table info
        return models.User(
          id: supabaseUser.id,
          email: supabaseUser.email ?? response['email'] ?? '',
          username:
              response['username'] ??
              supabaseUser.userMetadata?['username'] ??
              '',
          name: response['name'] ?? supabaseUser.userMetadata?['name'] ?? '',
          phone: response['phone'] ?? supabaseUser.phone ?? '',
          type: models.UserType.fromString(
            response['type'] ?? supabaseUser.userMetadata?['type'] ?? 'student',
          ),
          studentId:
              response['student_id'] ??
              supabaseUser.userMetadata?['student_id'],
          department:
              response['department'] ??
              supabaseUser.userMetadata?['department'],
          avatar: response['avatar'] ?? supabaseUser.userMetadata?['avatar'],
        );
      }
    } catch (e) {
      print('Failed to fetch user profile: $e');
    }
    // Fallback if public table record not found (shouldn't happen with trigger)
    return _getUserFromPublicTable(supabaseUser);
  }

  /// Find user email by phone number or student ID
  Future<String?> findEmailByPhoneOrStudentId(String identifier) async {
    try {
      // Try to find by phone first
      final phoneResponse = await _supabaseClient
          .from('users')
          .select('email')
          .eq('phone', identifier)
          .maybeSingle();

      if (phoneResponse != null && phoneResponse['email'] != null) {
        return phoneResponse['email'] as String;
      }

      // Try to find by student_id
      final studentIdResponse = await _supabaseClient
          .from('users')
          .select('email')
          .eq('student_id', identifier)
          .maybeSingle();

      if (studentIdResponse != null && studentIdResponse['email'] != null) {
        return studentIdResponse['email'] as String;
      }
    } catch (e) {
      print('Find email error: $e');
    }
    return null;
  }

  /// Login with phone number or student ID
  Future<models.User?> loginWithPhoneOrStudentId(
    String identifier,
    String password,
  ) async {
    final email = await findEmailByPhoneOrStudentId(identifier);
    if (email != null) {
      return loginWithEmail(email, password);
    }
    return null;
  }

  /// Check if identifier is a valid phone number (11 digits starting with 1)
  static bool isPhoneNumber(String identifier) {
    return RegExp(r'^1[3-9]\d{9}$').hasMatch(identifier);
  }

  /// Check if identifier looks like a student ID (alphanumeric, typically 8-12 chars)
  static bool isStudentId(String identifier) {
    return RegExp(r'^[A-Za-z0-9]{6,20}$').hasMatch(identifier);
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
          'type': user.type
              .toString()
              .split('.')
              .last, // Ensure we just send the string value, like 'student'
          'student_id': user.studentId,
          'department': user.department,
          'phone': user.phone,
        },
      );
      if (response.user != null) {
        return await _getUserFromPublicTable(response.user!);
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
      return _getUserFromPublicTable(supabaseUser);
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
  AuthState({this.user, this.isLoading = false, this.error});
  final models.User? user;
  final bool isLoading;
  final String? error;

  AuthState copyWith({
    models.User? user,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._authService) : super(AuthState()) {
    _loadCurrentUser();
  }
  final AuthService _authService;

  Future<void> _loadCurrentUser() async {
    state = state.copyWith(isLoading: true);
    try {
      final user = await _authService.getCurrentUser();
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> login(String identifier, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      models.User? user;
      // Try login with phone or student ID first
      user = await _authService.loginWithPhoneOrStudentId(identifier, password);

      // If not found, try as email directly
      if (user == null && identifier.contains('@')) {
        user = await _authService.loginWithEmail(identifier, password);
      }

      if (user != null) {
        state = state.copyWith(user: user, isLoading: false);
      } else {
        state = state.copyWith(error: '手机号/学号或密码错误', isLoading: false);
      }
    } catch (e) {
      String errorMsg = '登录失败';
      if (e.toString().contains('Invalid login credentials')) {
        errorMsg = '手机号/学号或密码错误';
      } else {
        errorMsg = e.toString();
      }
      state = state.copyWith(error: errorMsg, isLoading: false);
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _authService.logout();
      state = state.copyWith(clearUser: true, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> register(models.User user, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final newUser = await _authService.register(user, password);
      state = state.copyWith(user: newUser, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> updateUser(models.User user) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _authService.updateUser(user);
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
