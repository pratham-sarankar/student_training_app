# Firebase Authentication Setup

This project has been integrated with Firebase Authentication to provide secure user authentication for login, registration, and email verification. **Now also supports phone number authentication!**

## Features Implemented

### 1. User Authentication
- **Login**: Users can sign in with email and password OR Indian phone number (+91)
- **Registration**: New users can create accounts with email verification
- **Phone Authentication**: SMS-based phone number verification (India only)
- **Email Verification**: Automatic email verification for new accounts
- **Password Reset**: Users can reset their passwords via email
- **Logout**: Secure sign out functionality

### 2. Authentication Flow
1. **Welcome Screen** → User chooses to login or register
2. **Login/Register** → User enters credentials (email/password OR phone number)
3. **Phone Verification** → Phone users receive SMS verification code
4. **Email Verification** → New users must verify their email
5. **Main App** → Access granted after successful authentication
6. **Profile Management** → Users can view profile and sign out

## Firebase Configuration

### Dependencies Added
```yaml
dependencies:
  firebase_core: ^4.0.0
  firebase_auth: ^6.0.1
  firebase_ui_auth: ^3.0.0
  pinput: ^3.0.1  # For OTP input (optional)
```

### Firebase Setup
- Firebase project is configured with `learn-work-9bbf7` project ID
- Email/password authentication is enabled
- **Phone number authentication is enabled**
- Email verification is required for new accounts

### Phone Authentication Setup
To enable phone authentication in Firebase Console:

1. **Go to Firebase Console** → Your Project → Authentication
2. **Click on "Sign-in method" tab**
3. **Enable "Phone" provider**
4. **Add test phone numbers** (for development)
5. **Configure reCAPTCHA verification** (recommended for production)

#### Android Configuration
- Phone authentication works out of the box with the current setup
- No additional configuration needed for Android

#### iOS Configuration
- Phone authentication requires additional setup for iOS
- Add your app's bundle ID to Firebase project
- Configure APNs authentication key

## File Structure

### Core Authentication Files
- `lib/services/auth_service.dart` - Firebase authentication service (updated with phone auth)
- `lib/widgets/auth_wrapper.dart` - Authentication state management
- `lib/screens/login_screen.dart` - User login interface (updated with phone toggle)
- `lib/screens/register_screen.dart` - User registration interface
- `lib/screens/forgot_password_screen.dart` - Password reset interface
- `lib/screens/email_verification_screen.dart` - Email verification interface

### New Files
- Phone verification functionality is now integrated into the login screen
- Simple phone verification screen for OTP input

### Updated Files
- `lib/main.dart` - Firebase initialization and AuthWrapper integration
- `lib/screens/profile_screen.dart` - User profile with logout functionality
- `lib/screens/login_screen.dart` - Added phone number authentication toggle

## Authentication Service Methods

### AuthService Class
- `signInWithEmailAndPassword()` - User login with email
- `signInWithPhoneNumber()` - **NEW**: Send SMS verification code
- `verifyPhoneNumberWithCode()` - **NEW**: Verify SMS code and sign in
- `createUserWithEmailAndPassword()` - User registration
- `sendEmailVerification()` - Send verification email
- `resetPassword()` - Send password reset email
- `signOut()` - User logout
- `updateUserProfile()` - Update user profile information
- `isEmailVerified` - Check email verification status
- `isPhoneVerified` - **NEW**: Check phone verification status

## Phone Authentication Flow (India Only)

### 1. Phone Number Input
- User enters 10-digit Indian mobile number
- Automatic formatting adds +91 country code
- Supports multiple input formats:
  - 9876543210 → +919876543210
  - 09876543210 → +919876543210
  - +919876543210 → +919876543210

### 2. SMS Verification
- Firebase sends 6-digit verification code via SMS
- User receives code on their phone
- App shows verification screen

### 3. Code Verification
- User enters 6-digit code
- Firebase verifies the code
- User is signed in upon successful verification

### 4. Error Handling
- Invalid phone numbers
- SMS delivery failures
- Invalid verification codes
- Rate limiting (SMS quota exceeded)

## Error Handling

The authentication service includes comprehensive error handling for common Firebase Auth errors:
- Invalid email format
- Weak passwords
- User not found
- Wrong password
- Email already in use
- **Invalid phone number**
- **Invalid verification code**
- **SMS quota exceeded**
- Network errors

## Security Features

- **Email Verification**: Required for account activation
- **Phone Verification**: SMS-based verification for phone authentication
- **Password Strength**: Minimum 6 characters required
- **Secure Logout**: Proper session termination
- **Input Validation**: Client-side form validation
- **Error Messages**: User-friendly error feedback
- **Rate Limiting**: Built-in SMS rate limiting

## Usage

### For Users
1. **Login Options**: 
   - Email/Password: Traditional login method
   - Phone Number: SMS-based authentication
2. **Register**: Create a new account with email verification
3. **Phone Verification**: Receive and enter SMS verification code
4. **Password Reset**: Use "Forgot Password" to reset credentials
5. **Profile**: View account information and sign out

### For Developers
1. **Authentication State**: Use `AuthWrapper` to manage auth state
2. **User Data**: Access current user via `AuthService.currentUser`
3. **Auth Changes**: Listen to `AuthService.authStateChanges` stream
4. **Phone Auth**: Use `signInWithPhoneNumber()` and `verifyPhoneNumberWithCode()`
5. **Error Handling**: Catch and handle authentication errors

## Testing

To test the authentication system:
1. **Email Authentication**:
   - Create a new account with a valid email
   - Check email for verification link
   - Verify email and access the main app
   - Test login with existing credentials
   - Test password reset functionality

2. **Phone Authentication (India Only)**:
   - Use Indian test phone numbers from Firebase Console
   - Enter 10-digit Indian mobile number (e.g., 1234567890)
   - Automatic +91 country code formatting
   - Receive SMS verification code
   - Enter code to verify and sign in
   - Test with invalid codes

3. **General Testing**:
   - Test logout and session termination
   - Test both authentication methods
   - Verify proper error handling

## Next Steps

Potential enhancements for future versions:
- **Social authentication** (Google, Facebook)
- **Two-factor authentication** (2FA)
- **User profile image upload**
- **Account deletion**
- **Admin user management**
- **Phone number linking** to existing email accounts
- **Multi-phone support** for single account

## Troubleshooting

### Common Issues
1. **SMS not received**: Check Firebase Console phone authentication settings
2. **Invalid phone number**: Ensure proper country code format (+1 for US)
3. **Verification failed**: Check if code is entered correctly
4. **Rate limiting**: Wait before requesting new codes

### Development Tips
1. Use test phone numbers during development
2. Monitor Firebase Console for authentication logs
3. Test on both Android and iOS devices
4. Verify Firebase project configuration
