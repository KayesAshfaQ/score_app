import 'dart:async';

/// Core Authentication Service contract.
/// Provides an extensible, scaffolded authentication service ready for
/// Firebase Auth or custom backend integration.
class AuthService {
  String? _mockUserId;
  String? _mockUserEmail;
  final StreamController<String?> _authStateController =
      StreamController<String?>.broadcast();

  AuthService();

  /// Stream of user ID changes (null = logged out)
  Stream<String?> get authStateChanges => _authStateController.stream;

  /// Current authenticated user ID
  String? get currentUserId => _mockUserId;

  /// Current authenticated user email
  String? get currentUserEmail => _mockUserEmail;

  /// Whether a user is currently signed in
  bool get isAuthenticated => _mockUserId != null;

  /// Sign in with email and password
  Future<bool> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    // Scaffold implementation: simulate brief network latency
    await Future.delayed(const Duration(milliseconds: 300));

    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters.');
    }

    _mockUserId = 'user_${email.hashCode.abs()}';
    _mockUserEmail = email;
    _authStateController.add(_mockUserId);
    return true;
  }

  /// Sign up with email, password, and optional display name
  Future<bool> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters.');
    }

    _mockUserId = 'user_${email.hashCode.abs()}';
    _mockUserEmail = email;
    _authStateController.add(_mockUserId);
    return true;
  }

  /// Sign out current user
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 150));
    _mockUserId = null;
    _mockUserEmail = null;
    _authStateController.add(null);
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  /// Dispose internal stream controller
  void dispose() {
    _authStateController.close();
  }
}
