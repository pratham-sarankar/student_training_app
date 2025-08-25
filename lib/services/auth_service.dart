import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart' as firebase_ui;
import 'dart:async';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Phone authentication state
  String? _verificationId;
  int? _resendToken;
  bool _isPhoneAuthInProgress = false;
  Timer? _phoneAuthTimeoutTimer;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Phone authentication state getters
  String? get verificationId => _verificationId;
  int? get resendToken => _resendToken;
  bool get isPhoneAuthInProgress => _isPhoneAuthInProgress;

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Enhanced phone number sign-in with proper state management
  Future<void> signInWithPhoneNumber(
    String phoneNumber, {
    Duration timeout = const Duration(seconds: 60),
    bool forceResendingToken = false,
  }) async {
    try {
      // Check if phone auth is already in progress
      if (_isPhoneAuthInProgress && !forceResendingToken) {
        throw 'Phone authentication is already in progress. Please wait for the current request to complete.';
      }

      print('🔐 Attempting to sign in with phone number: $phoneNumber');
      print('🔐 Firebase Auth instance: ${_auth.toString()}');
      print('🔐 Force resending token: $forceResendingToken');
      
      // Set phone auth state
      _isPhoneAuthInProgress = true;
      
      // Start phone auth verification using Flutter Firebase Auth
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: timeout,
        verificationCompleted: (PhoneAuthCredential credential) {
          print('✅ Phone verification completed automatically');
          _isPhoneAuthInProgress = false;
          _phoneAuthTimeoutTimer?.cancel();
          
          // Sign in with the credential
          signInWithPhoneAuthCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          print('❌ Phone verification failed: $e');
          print('❌ Error code: ${e.code}');
          print('❌ Error message: ${e.message}');
          _isPhoneAuthInProgress = false;
          _phoneAuthTimeoutTimer?.cancel();
          
          if (e.code == 'invalid-phone-number') {
            print('❌ Invalid phone number format');
          } else if (e.code == 'too-many-requests') {
            print('❌ SMS quota exceeded');
          } else if (e.code == 'app-not-authorized') {
            print('❌ App not authorized for Firebase Authentication');
          } else if (e.code == 'quota-exceeded') {
            print('❌ SMS quota exceeded for this project');
          } else if (e.code == 'network-error') {
            print('❌ Network error occurred');
          } else if (e.message?.contains('BILLING_NOT_ENABLED') == true) {
            print('❌ Firebase billing not enabled - Phone Auth requires Blaze plan');
          }
          
          // You can handle specific error cases here
          throw _handleAuthError(e);
        },
        codeSent: (String verificationId, int? resendToken) {
          print('✅ SMS verification code sent. Verification ID: $verificationId');
          print('✅ Resend token: $resendToken');
          
          // Save verification ID and resending token
          _verificationId = verificationId;
          // Note: Flutter Firebase Auth doesn't provide ForceResendingToken
          // We'll handle resending differently
          
          // Phone auth is still in progress, waiting for user to enter code
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print('⏰ SMS auto-retrieval timeout for verification ID: $verificationId');
          // User needs to manually enter the code
        },
      );
      
      // Set timeout timer
      _phoneAuthTimeoutTimer = Timer(timeout, () {
        if (_isPhoneAuthInProgress) {
          _isPhoneAuthInProgress = false;
          _phoneAuthTimeoutTimer?.cancel();
        }
      });

      print('✅ SMS verification code sent successfully to: $phoneNumber');
    } catch (e) {
      print('❌ Error sending SMS verification code: $e');
      print('❌ Error type: ${e.runtimeType}');
      if (e is FirebaseAuthException) {
        print('❌ Firebase Auth Error Code: ${e.code}');
        print('❌ Firebase Auth Error Message: ${e.message}');
      }
      
      // Reset phone auth state on error
      _isPhoneAuthInProgress = false;
      _phoneAuthTimeoutTimer?.cancel();
      
      throw _handleAuthError(e);
    }
  }

  // Verify phone number with SMS code
  Future<UserCredential> verifyPhoneNumberWithCode(String smsCode) async {
    try {
      if (_verificationId == null) {
        throw 'No verification ID available. Please request a new verification code.';
      }

      print('🔐 Attempting to verify SMS code: $smsCode');
      
      // Create credential with verification ID and SMS code
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );
      
      // Sign in with the credential
      final result = await signInWithPhoneAuthCredential(credential);
      
      // Clear phone auth state on successful verification
      _clearPhoneAuthState();
      
      print('✅ Phone number verified successfully');
      return result;
    } catch (e) {
      print('❌ Error verifying SMS code: $e');
      print('❌ Error type: ${e.runtimeType}');
      if (e is FirebaseAuthException) {
        print('❌ Firebase Auth Error Code: ${e.code}');
        print('❌ Firebase Auth Error Message: ${e.message}');
      }
      throw _handleAuthError(e);
    }
  }

  // Sign in with phone auth credential
  Future<UserCredential> signInWithPhoneAuthCredential(PhoneAuthCredential credential) async {
    try {
      final result = await _auth.signInWithCredential(credential);
      print('✅ Successfully signed in with phone credential');
      return result;
    } catch (e) {
      print('❌ Error signing in with phone credential: $e');
      throw _handleAuthError(e);
    }
  }

  // Resend verification code
  Future<void> resendVerificationCode(String phoneNumber) async {
    try {
      // Clear the current verification state to allow resending
      _clearPhoneAuthState();
      
      // Start a new verification process
      await signInWithPhoneNumber(phoneNumber, forceResendingToken: true);
      print('✅ Verification code resent successfully');
    } catch (e) {
      print('❌ Error resending verification code: $e');
      throw _handleAuthError(e);
    }
  }

  // Clear phone authentication state
  void _clearPhoneAuthState() {
    _verificationId = null;
    _resendToken = null;
    _isPhoneAuthInProgress = false;
    _phoneAuthTimeoutTimer?.cancel();
  }

  // Cancel phone authentication
  void cancelPhoneAuth() {
    _clearPhoneAuthState();
    print('🛑 Phone authentication cancelled');
  }

  // Create user with email and password
  Future<UserCredential> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Send email verification
  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      // Clear phone auth state before signing out
      _clearPhoneAuthState();
      await _auth.signOut();
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      await _auth.currentUser?.updateDisplayName(displayName);
      if (photoURL != null) {
        await _auth.currentUser?.updatePhotoURL(photoURL);
      }
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Check if email is verified
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  // Check if phone number is verified
  bool get isPhoneVerified => _auth.currentUser?.phoneNumber != null;

  // Get user's phone number
  String? get userPhoneNumber => _auth.currentUser?.phoneNumber;

  // Handle Firebase Auth errors
  String _handleAuthError(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No user found with this email address.';
        case 'wrong-password':
          return 'Wrong password provided.';
        case 'email-already-in-use':
          return 'An account already exists with this email address.';
        case 'weak-password':
          return 'The password provided is too weak.';
        case 'invalid-email':
          return 'The email address is not valid.';
        case 'user-disabled':
          return 'This user account has been disabled.';
        case 'too-many-requests':
          return 'Too many requests. Please try again later.';
        case 'operation-not-allowed':
          return 'Email/password accounts are not enabled.';
        case 'invalid-phone-number':
          return 'The phone number is not valid. Please check the format and try again.';
        case 'invalid-verification-code':
          return 'The verification code is invalid. Please check and try again.';
        case 'invalid-verification-id':
          return 'The verification ID is invalid. Please request a new code.';
        case 'quota-exceeded':
          return 'SMS quota exceeded. Please try again later.';
        case 'session-expired':
          return 'The verification session has expired. Please request a new code.';
        case 'credential-already-in-use':
          return 'This phone number is already associated with another account.';
        case 'phone-number-already-exists':
          return 'This phone number is already registered. Please sign in instead.';
        case 'app-not-authorized':
          return 'This app is not authorized to use Firebase Authentication.';
        case 'network-request-failed':
          return 'Network request failed. Please check your internet connection.';
        case 'internal-error':
          return 'An internal error occurred. Please try again.';
        default:
          return 'Authentication failed: ${error.message}';
      }
    }
    return 'An unexpected error occurred: $error';
  }

  // Dispose method to clean up resources
  void dispose() {
    _clearPhoneAuthState();
  }
}
