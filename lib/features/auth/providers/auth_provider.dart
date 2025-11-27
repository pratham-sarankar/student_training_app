import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

enum AuthStatus { initial, authenticated, unauthenticated, loading }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  AuthProvider(this._authService) {
    // Listen to auth state changes
    _authService.authStateChanges.listen((User? user) {
      _user = user;
      _authStatus =
          user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
      notifyListeners();
    });
  }

  // State variables
  User? _user;
  AuthStatus _authStatus = AuthStatus.initial;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isEmailVerificationSent = false;
  bool _isPasswordResetSent = false;

  // Getters
  User? get user => _user;
  AuthStatus get authStatus => _authStatus;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _authStatus == AuthStatus.authenticated;
  bool get isEmailVerificationSent => _isEmailVerificationSent;
  bool get isPasswordResetSent => _isPasswordResetSent;

  // Get current user from auth service
  User? get currentUser => _authService.currentUser;

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Clear email verification sent flag
  void clearEmailVerificationSent() {
    _isEmailVerificationSent = false;
    notifyListeners();
  }

  // Clear password reset sent flag
  void clearPasswordResetSent() {
    _isPasswordResetSent = false;
    notifyListeners();
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set error
  void _setError(String error) {
    _errorMessage = error;
    _isLoading = false;
    notifyListeners();
  }

  // Sign in with email and password
  Future<bool> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      clearError();

      await _authService.signInWithEmailAndPassword(email, password);

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Create user with email and password (Sign up)
  Future<bool> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      clearError();

      await _authService.createUserWithEmailAndPassword(email, password);

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      _setLoading(true);
      clearError();

      print('🔵 AuthProvider: Starting Google Sign-In...');
      await _authService.signInWithGoogle();
      print('✅ AuthProvider: Google Sign-In successful');

      _setLoading(false);
      return true;
    } catch (e) {
      print('❌ AuthProvider: Google Sign-In failed - $e');
      _setError(e.toString());
      return false;
    }
  }

  // Sign in with Apple
  Future<bool> signInWithApple() async {
    try {
      _setLoading(true);
      clearError();

      print('🔵 AuthProvider: Starting Apple Sign-In...');
      await _authService.signInWithApple();
      print('✅ AuthProvider: Apple Sign-In successful');

      _setLoading(false);
      return true;
    } catch (e) {
      print('❌ AuthProvider: Apple Sign-In failed - $e');
      _setError(e.toString());
      return false;
    }
  }

  // Send email verification
  Future<bool> sendEmailVerification() async {
    try {
      _setLoading(true);
      clearError();

      await _authService.sendEmailVerification();

      _isEmailVerificationSent = true;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Send password reset email
  Future<bool> resetPassword({required String email}) async {
    try {
      _setLoading(true);
      clearError();

      await _authService.resetPassword(email);

      _isPasswordResetSent = true;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Sign out
  Future<bool> signOut() async {
    try {
      _setLoading(true);
      clearError();

      await _authService.signOut();

      _user = null;
      _authStatus = AuthStatus.unauthenticated;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }
}
