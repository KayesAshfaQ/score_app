import 'package:flutter_test/flutter_test.dart';
import 'package:score_app/app/core/services/auth_service.dart';
import 'package:score_app/app/features/auth/providers/auth_provider.dart';

void main() {
  group('AuthProvider Tests', () {
    late AuthService authService;
    late AuthProvider authProvider;

    setUp(() {
      authService = AuthService();
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
