import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:score_app/app/core/services/auth_service.dart';
import 'package:score_app/app/features/auth/pages/sign_in_page.dart';
import 'package:score_app/app/features/auth/providers/auth_provider.dart';

class FakeAuthService implements AuthService {
  String? _userId;
  String? _userEmail;
  bool googleSignInCalled = false;
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
    googleSignInCalled = true;
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
    _userId = 'user_123';
    _userEmail = email;
    return true;
  }

  @override
  Future<bool> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    return true;
  }

  @override
  Future<void> signOut() async {
    _userId = null;
    _userEmail = null;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  void dispose() {
    _authStateController.close();
  }
}

void main() {
  group('SignInPage Tests', () {
    late FakeAuthService fakeAuthService;
    late AuthProvider authProvider;

    setUp(() {
      fakeAuthService = FakeAuthService();
      authProvider = AuthProvider(authService: fakeAuthService);
    });

    tearDown(() {
      fakeAuthService.dispose();
      authProvider.dispose();
    });

    Widget createWidgetUnderTest() {
      final router = GoRouter(
        initialLocation: '/signin',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const Scaffold(body: Text('Home Page')),
          ),
          GoRoute(
            path: '/signin',
            builder: (context, state) => const SignInPage(),
          ),
        ],
      );

      return ChangeNotifierProvider<AuthProvider>.value(
        value: authProvider,
        child: MaterialApp.router(
          routerConfig: router,
        ),
      );
    }

    testWidgets('renders Google sign in button and divider', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Sign in with Google'), findsOneWidget);
      expect(find.text('OR'), findsOneWidget);
    });

    testWidgets('tapping Google sign in triggers signInWithGoogle and navigates', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final googleButton = find.text('Sign in with Google');
      expect(googleButton, findsOneWidget);

      await tester.tap(googleButton);
      await tester.pumpAndSettle();

      expect(fakeAuthService.googleSignInCalled, isTrue);
      expect(find.text('Home Page'), findsOneWidget);
    });
  });
}
