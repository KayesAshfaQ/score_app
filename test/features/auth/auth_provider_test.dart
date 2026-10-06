import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:score_app/app/core/services/auth_service.dart';
import 'package:score_app/app/features/auth/providers/auth_provider.dart';

class FakeAuthService implements AuthService {
  String? _userId;
  String? _userEmail;
  final StreamController<String?> _authStateController =
      StreamController<String?>.broadcast();

  @override
  Stream<String?> get authStateChanges => _authStateController.stream;

  @override
  String? get currentUserId => _userId;

  @override
  String? get currentUserEmail => _userEmail;

  @override
  bool get isAuthenticated => _userId != null;

  @override
  Future<bool> signInWithGoogle() async {
    _userId = 'google_user_123';
    _userEmail = 'google@scora.com';
    _authStateController.add(_userId);
    return true;
  }

  @override
  Future<bool> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters.');
    }
    _userId = 'user_123';
    _userEmail = email;
    _authStateController.add(_userId);
    return true;
  }

  @override
  Future<bool> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters.');
    }
    _userId = 'user_123';
    _userEmail = email;
    _authStateController.add(_userId);
    return true;
  }

  @override
  Future<void> signOut() async {
    _userId = null;
    _userEmail = null;
    _authStateController.add(null);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  void dispose() {
    _authStateController.close();
  }
}

void main() {
  group('AuthProvider Tests', () {
    late FakeAuthService authService;
    late AuthProvider authProvider;

    setUp(() {
      authService = FakeAuthService();
      authProvider = AuthProvider(authService: authService);
    });

    tearDown(() {
      authService.dispose();
      authProvider.dispose();
    });

    test('initial state is unauthenticated and not loading', () {
      expect(authProvider.isLoading, isFalse);
      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.errorMessage, isNull);
      expect(authProvider.currentUserEmail, isNull);
    });

    test('signIn succeeds with valid credentials', () async {
      final success = await authProvider.signIn('test@scora.com', 'password123');

      expect(success, isTrue);
      expect(authProvider.isLoading, isFalse);
      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.currentUserEmail, equals('test@scora.com'));
      expect(authProvider.errorMessage, isNull);
    });

    test('signIn fails with short password and sets errorMessage', () async {
      final success = await authProvider.signIn('test@scora.com', '123');

      expect(success, isFalse);
      expect(authProvider.isLoading, isFalse);
      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.errorMessage, isNotNull);
      expect(authProvider.errorMessage, contains('at least 6 characters'));
    });

    test('signInWithGoogle succeeds and authenticates user', () async {
      final success = await authProvider.signInWithGoogle();

      expect(success, isTrue);
      expect(authProvider.isLoading, isFalse);
      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.currentUserEmail, equals('google@scora.com'));
      expect(authProvider.errorMessage, isNull);
    });

    test('clearError resets errorMessage', () async {
      await authProvider.signIn('test@scora.com', '123');
      expect(authProvider.errorMessage, isNotNull);

      authProvider.clearError();
      expect(authProvider.errorMessage, isNull);
    });

    test('signUp succeeds and authenticates user', () async {
      final success = await authProvider.signUp(
        'newuser@scora.com',
        'securePass123',
        displayName: 'John Doe',
      );

      expect(success, isTrue);
      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.currentUserEmail, equals('newuser@scora.com'));
    });

    test('signOut clears authenticated state', () async {
      await authProvider.signIn('test@scora.com', 'password123');
      expect(authProvider.isAuthenticated, isTrue);

      await authProvider.signOut();
      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.currentUserEmail, isNull);
    });
  });
}
