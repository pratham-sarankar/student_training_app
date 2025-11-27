import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:learn_work/services/user_service.dart';
import 'package:learn_work/models/user.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:io' show Platform;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();

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
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update user verification status in Firestore
      if (result.user != null) {
        await _userService.updateVerificationStatus(
          isEmailVerified: result.user!.emailVerified,
        );
      }

      return result;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Sign in with Google
  Future<UserCredential> signInWithGoogle() async {
    try {
      print('🔵 Starting Google Sign-In process...');

      // Sign out from any previous Google account to allow account selection
      final googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

      // Sign out first to ensure clean state
      await googleSignIn.signOut();
      print('🔵 Cleared previous Google Sign-In state');

      // Trigger the Google Sign In flow
      print('🔵 Triggering Google Sign-In UI...');
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        print('⚠️ Google sign-in was cancelled by user');
        throw 'Google sign in was cancelled';
      }

      print('✅ Google account selected: ${googleUser.email}');

      // Obtain the auth details from the request
      print('🔵 Getting Google authentication credentials...');
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        print('❌ Failed to get Google auth tokens');
        throw 'Failed to get Google authentication tokens';
      }

      print('✅ Google auth tokens obtained');

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('🔵 Signing in to Firebase with Google credential...');
      // Sign in to Firebase with the Google credential
      final result = await _auth.signInWithCredential(credential);

      print('✅ Firebase authentication successful');

      // Create or update user document in Firestore
      if (result.user != null) {
        print('🔵 Creating/updating user in Firestore...');
        final userModel = UserModel(
          uid: result.user!.uid,
          firstName: result.user!.displayName?.split(' ').first ?? '',
          lastName:
              result.user!.displayName?.split(' ').skip(1).join(' ') ?? '',
          email: result.user!.email ?? '',
          photoUrl: result.user!.photoURL,
          isEmailVerified: result.user!.emailVerified,
          createdAt: result.user!.metadata.creationTime ?? DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _userService.createOrUpdateUser(userModel);
        print('✅ User document created/updated in Firestore');
      }

      print('✅ Google Sign-In completed successfully');
      return result;
    } catch (e) {
      print('❌ Google Sign-In Error: $e');
      print('❌ Error type: ${e.runtimeType}');
      throw _handleAuthError(e);
    }
  }

  // Sign in with Apple
  Future<UserCredential> signInWithApple() async {
    try {
      // Check if Apple Sign In is available
      if (!Platform.isIOS && !Platform.isMacOS) {
        throw 'Apple Sign In is only available on iOS and macOS devices';
      }

      // Request credential for the currently signed in Apple account
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Create an OAuthCredential from the credential returned by Apple
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in to Firebase with the Apple credential
      final result = await _auth.signInWithCredential(oauthCredential);

      // Create or update user document in Firestore
      if (result.user != null) {
        // For Apple Sign-In, use the name from appleCredential if available
        String firstName = result.user!.displayName?.split(' ').first ?? '';
        String lastName =
            result.user!.displayName?.split(' ').skip(1).join(' ') ?? '';

        // Apple provides name only on first sign-in
        if (appleCredential.givenName != null) {
          firstName = appleCredential.givenName!;
        }
        if (appleCredential.familyName != null) {
          lastName = appleCredential.familyName!;
        }

        final userModel = UserModel(
          uid: result.user!.uid,
          firstName: firstName,
          lastName: lastName,
          email: result.user!.email ?? '',
          photoUrl: result.user!.photoURL,
          isEmailVerified: result.user!.emailVerified,
          createdAt: result.user!.metadata.creationTime ?? DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _userService.createOrUpdateUser(userModel);
      }

      return result;
    } catch (e) {
      print('❌ Apple Sign-In Error: $e');
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
            print(
              '❌ Firebase billing not enabled - Phone Auth requires Blaze plan',
            );
          }

          // You can handle specific error cases here
          throw _handleAuthError(e);
        },
        codeSent: (String verificationId, int? resendToken) {
          print(
            '✅ SMS verification code sent. Verification ID: $verificationId',
          );
          print('✅ Resend token: $resendToken');

          // Save verification ID and resending token
          _verificationId = verificationId;
          // Note: Flutter Firebase Auth doesn't provide ForceResendingToken
          // We'll handle resending differently

          // Phone auth is still in progress, waiting for user to enter code
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print(
            '⏰ SMS auto-retrieval timeout for verification ID: $verificationId',
          );
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
  Future<UserCredential> signInWithPhoneAuthCredential(
    PhoneAuthCredential credential,
  ) async {
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
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document in Firestore
      if (result.user != null) {
        final userModel = UserModel(
          uid: result.user!.uid,
          firstName: result.user!.displayName?.split(' ').first ?? '',
          lastName:
              result.user!.displayName?.split(' ').skip(1).join(' ') ?? '',
          email: result.user!.email ?? '',
          photoUrl: result.user!.photoURL,
          isEmailVerified: result.user!.emailVerified,
          createdAt: result.user!.metadata.creationTime ?? DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _userService.createOrUpdateUser(userModel);
      }

      return result;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Send email verification
  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();

      // Update verification status in Firestore
      await _userService.updateVerificationStatus(isEmailVerified: true);
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

      // Update user document in Firestore
      if (displayName != null) {
        final nameParts = displayName.split(' ');
        final firstName = nameParts.isNotEmpty ? nameParts[0] : '';
        final lastName =
            nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

        await _userService.updateUserProfile(
          firstName: firstName,
          lastName: lastName,
          photoUrl: photoURL,
        );
      }
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Update user profile with comprehensive data
  Future<void> updateUserProfileComprehensive({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? photoUrl,
    String? bio,
    String? gender,
    DateTime? dateOfBirth,
    bool? emailNotifications,
    bool? pushNotifications,
    bool? jobAlerts,
    List<String>? jobCategories,
    List<String>? preferredLocations,
  }) async {
    try {
      // Update Firebase Auth display name if name changed
      if (firstName != null || lastName != null) {
        final newDisplayName = '${firstName ?? ''} ${lastName ?? ''}'.trim();
        if (newDisplayName.isNotEmpty) {
          await _auth.currentUser?.updateDisplayName(newDisplayName);
        }
      }

      // Update user document in Firestore
      await _userService.updateUserProfile(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        photoUrl: photoUrl,
        bio: bio,
        gender: gender,
        dateOfBirth: dateOfBirth,
        emailNotifications: emailNotifications,
        pushNotifications: pushNotifications,
        jobAlerts: jobAlerts,
        jobCategories: jobCategories,
        preferredLocations: preferredLocations,
      );
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Get current user model
  Future<UserModel?> getCurrentUserModel() async {
    return await _userService.getCurrentUserDataWithFallback();
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
