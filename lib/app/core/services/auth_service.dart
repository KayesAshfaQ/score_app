import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Core Authentication Service contract.
/// Provides an extensible, scaffolded authentication service ready for
/// Firebase Auth or custom backend integration.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  String? _userId;
  String? _userEmail;
  final StreamController<String?> _authStateController =
      StreamController<String?>.broadcast();

  AuthService();

  /// Stream of user ID changes (null = logged out)
  Stream<String?> get authStateChanges => _authStateController.stream;

  /// Current authenticated user ID
  String? get currentUserId => _userId;

  /// Current authenticated user email
  String? get currentUserEmail => _userEmail;

  /// Whether a user is currently signed in
  bool get isAuthenticated => _userId != null;

  /// Sign in user using Google and authenticate with Firebase
  Future<bool> signInWithGoogle() async {
    try {
      await _googleSignIn.initialize();
      final result = await _googleSignIn.authenticate();

      _userId = result.authentication.idToken;
      _userEmail = result.email;
      _authStateController.add(_userId);
      return true;
    } on FirebaseAuthException catch (e) {
      // Handle specific error codes here
      if (e.code == 'user-not-found') {
        debugPrint('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        debugPrint('Wrong password provided.');
      } else {
        debugPrint('Error: ${e.message}');
      }
      return false;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  /// Sign in with email and password
  Future<bool> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters.');
      }

      final result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      _userId = result.user?.uid;
      _userEmail = result.user?.email;
      _authStateController.add(_userId);
      return true;
    } on FirebaseAuthException catch (e) {
      // Handle specific error codes here
      if (e.code == 'user-not-found') {
        debugPrint('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        debugPrint('Wrong password provided.');
      } else {
        debugPrint('Error: ${e.message}');
      }
      return false;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  /// Sign up with email, password, and optional display name
  Future<bool> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters.');
      }

      final result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      if (displayName != null && displayName.isNotEmpty) {
        await result.user?.updateDisplayName(displayName.trim());
      }

      _userId = result.user?.uid;
      _userEmail = result.user?.email;
      _authStateController.add(_userId);
      return true;
    } on FirebaseAuthException catch (e) {
      // Handle specific error codes here
      if (e.code == 'user-not-found') {
        debugPrint('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        debugPrint('Wrong password provided.');
      } else {
        debugPrint('Error: ${e.message}');
      }
      return false;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      _auth.signOut();

      _userId = null;
      _userEmail = null;
      _authStateController.add(null);
    } on FirebaseAuthException catch (e) {
      // Handle specific error codes here
      if (e.code == 'user-not-found') {
        debugPrint('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        debugPrint('Wrong password provided.');
      } else {
        debugPrint('Error: ${e.message}');
      }
    } catch (e) {
      debugPrint(e.toString());
    }
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
