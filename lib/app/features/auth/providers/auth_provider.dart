import 'package:flutter/foundation.dart';
import '../../../core/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService authService;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => authService.isAuthenticated;
  String? get currentUserEmail => authService.currentUserEmail;
  String? get currentUserId => authService.currentUserId;

  AuthProvider({required this.authService});

  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await authService.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      _setLoading(false);
      return success;
    } catch (e) {
      _setError(_formatErrorMessage(e));
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _clearError();

    try {
      final success = await authService.signInWithGoogle();
      _setLoading(false);
      return success;
    } catch (e) {
      _setError(_formatErrorMessage(e));
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signUp(
    String email,
    String password, {
    String? displayName,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await authService.signUpWithEmailAndPassword(
        email: email.trim(),
        password: password,
        displayName: displayName?.trim(),
      );
      _setLoading(false);
      return success;
    } catch (e) {
      _setError(_formatErrorMessage(e));
      _setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    try {
      await authService.signOut();
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _clearError();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  String _formatErrorMessage(dynamic error) {
    final str = error.toString();
    if (str.startsWith('Exception: ')) {
      return str.substring(11);
    }
    return str;
  }
}
