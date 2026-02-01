import 'package:riverpod/riverpod.dart';
import 'package:hive/hive.dart';
import '../../domain/models/user.dart';

class AuthService {
  late Box<User> _userBox;

  Future<void> init() async {
    _userBox = await Hive.openBox<User>('users');
  }

  Future<User?> login(String username, String password) async {
    // 模拟登录验证
    for (var i = 0; i < _userBox.length; i++) {
      final user = _userBox.getAt(i);
      if (user != null && user.username == username && user.password == password) {
        final updatedUser = user.copyWith(isLoggedIn: true);
        await _userBox.putAt(i, updatedUser);
        return updatedUser;
      }
    }
    return null;
  }

  Future<void> logout() async {
    for (var i = 0; i < _userBox.length; i++) {
      final user = _userBox.getAt(i);
      if (user != null && user.isLoggedIn) {
        final updatedUser = user.copyWith(isLoggedIn: false);
        await _userBox.putAt(i, updatedUser);
        break;
      }
    }
  }

  Future<User> register(User user) async {
    await _userBox.add(user);
    return user;
  }

  Future<User?> getCurrentUser() async {
    for (var i = 0; i < _userBox.length; i++) {
      final user = _userBox.getAt(i);
      if (user != null && user.isLoggedIn) {
        return user;
      }
    }
    return null;
  }

  Future<void> updateUser(User user) async {
    for (var i = 0; i < _userBox.length; i++) {
      final existingUser = _userBox.getAt(i);
      if (existingUser != null && existingUser.id == user.id) {
        await _userBox.putAt(i, user);
        break;
      }
    }
  }

  Future<void> deleteUser(String userId) async {
    for (var i = 0; i < _userBox.length; i++) {
      final user = _userBox.getAt(i);
      if (user != null && user.id == userId) {
        await _userBox.deleteAt(i);
        break;
      }
    }
  }

  Future<List<User>> getAllUsers() async {
    return _userBox.values.toList();
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authServiceProvider));
});

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    User? user,
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
      await _authService.init();
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

  Future<void> register(User user) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final newUser = await _authService.register(user);
      state = state.copyWith(user: newUser, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> updateUser(User user) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authService.updateUser(user);
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}
