# Firebase Phone Authentication Implementation

This project implements Firebase Phone Authentication using Flutter and follows the best practices outlined in the Firebase documentation.

## Features

- ✅ **Phone Number Input Screen** - Clean UI for entering phone numbers
- ✅ **SMS Verification Screen** - OTP input with resend functionality
- ✅ **Enhanced AuthService** - Comprehensive phone authentication service
- ✅ **Error Handling** - Detailed error messages and user feedback
- ✅ **State Management** - Proper handling of authentication states
- ✅ **Resend Support** - Cooldown timer for resending verification codes
- ✅ **International Support** - Handles various phone number formats
- ✅ **Demo Screen** - Interactive demo to test all features

## Setup Requirements

### 1. Firebase Configuration
- Firebase project with Phone Authentication enabled
- `google-services.json` file in `android/app/`
- Proper SHA-1 and SHA-256 fingerprints configured

### 2. Dependencies
The following dependencies are already included in `pubspec.yaml`:
```yaml
firebase_core: ^4.0.0
firebase_auth: ^6.0.1
firebase_ui_auth: ^3.0.0
```

### 3. Android Configuration
- Minimum SDK: 23 (Android 6.0+)
- Google Play Services required for Play Integrity API
- reCAPTCHA fallback for devices without Google Play Services

## How to Use

### 1. Start Phone Authentication
```dart
// Navigate to phone input screen
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => const PhoneNumberInputScreen(),
  ),
);
```

### 2. Send Verification Code
```dart
final authService = AuthService();

try {
  await authService.signInWithPhoneNumber('+1234567890');
  // SMS sent successfully
} catch (e) {
  // Handle error
  print('Error: $e');
}
```

### 3. Verify SMS Code
```dart
try {
  final userCredential = await authService.verifyPhoneNumberWithCode('123456');
  // Phone number verified successfully
} catch (e) {
  // Handle verification error
  print('Error: $e');
}
```

### 4. Check Authentication State
```dart
final authService = AuthService();

// Get current user
User? user = authService.currentUser;

// Check if phone is verified
bool isPhoneVerified = authService.isPhoneVerified;

// Get user's phone number
String? phoneNumber = authService.userPhoneNumber;
```

## File Structure

```
lib/
├── services/
│   └── auth_service.dart          # Enhanced authentication service
├── screens/
│   ├── phone_number_input_screen.dart    # Phone number input UI
│   ├── phone_verification.dart           # OTP verification UI
│   ├── phone_auth_demo.dart              # Demo and testing screen
│   └── welcome_screen.dart               # Entry point with phone auth option
```

## Authentication Flow

1. **User enters phone number** → `PhoneNumberInputScreen`
2. **Firebase sends SMS** → `AuthService.signInWithPhoneNumber()`
3. **User enters OTP** → `PhoneVerificationScreen`
4. **Code verification** → `AuthService.verifyPhoneNumberWithCode()`
5. **User signed in** → Navigate to main app

## Error Handling

The implementation includes comprehensive error handling for:
- Invalid phone numbers
- SMS quota exceeded
- Invalid verification codes
- Network failures
- App verification failures
- Session timeouts

## Testing

### Real Phone Numbers
- Use actual phone numbers to receive real SMS
- Test on physical devices with Google Play Services

### Test Phone Numbers (Firebase Console)
1. Go to Firebase Console → Authentication → Sign-in method
2. Enable Phone provider
3. Add test phone numbers in "Phone numbers for testing"
4. Use these numbers for development testing

### Emulator Testing
- May trigger reCAPTCHA verification
- Ensure SHA-1 fingerprint is configured
- Test with fictional phone numbers

## Security Considerations

- **Play Integrity API**: Primary verification method for devices with Google Play Services
- **reCAPTCHA**: Fallback verification for devices without Google Play Services
- **Rate Limiting**: Firebase enforces SMS quotas to prevent abuse
- **Phone Number Validation**: Proper format validation before sending SMS

## Best Practices

1. **User Experience**
   - Clear error messages
   - Loading states during operations
   - Resend functionality with cooldown
   - Proper navigation flow

2. **Error Handling**
   - Catch and display specific error types
   - Provide actionable error messages
   - Handle network failures gracefully

3. **State Management**
   - Track authentication progress
   - Prevent multiple simultaneous requests
   - Clean up resources properly

4. **Testing**
   - Test on various devices
   - Test error scenarios
   - Use test phone numbers for development

## Troubleshooting

### Common Issues

1. **"App not authorized" error**
   - Check SHA-1/SHA-256 fingerprints in Firebase Console
   - Ensure `google-services.json` is up to date

2. **reCAPTCHA required**
   - Device doesn't have Google Play Services
   - App not distributed through Google Play Store
   - SafetyNet/Play Integrity verification failed

3. **SMS not received**
   - Check phone number format
   - Verify SMS quota not exceeded
   - Check carrier restrictions

4. **Verification timeout**
   - Default timeout is 60 seconds
   - User must enter code before timeout
   - Resend functionality available after timeout

### Debug Information

Enable debug logging in `AuthService`:
```dart
// Logs are already included in the implementation
print('🔐 Attempting to sign in with phone number: $phoneNumber');
print('✅ SMS verification code sent successfully');
print('❌ Error: $e');
```

## API Reference

### AuthService Methods

| Method | Description | Returns |
|--------|-------------|---------|
| `signInWithPhoneNumber(phoneNumber)` | Send SMS verification code | `Future<void>` |
| `verifyPhoneNumberWithCode(smsCode)` | Verify SMS code and sign in | `Future<UserCredential>` |
| `resendVerificationCode(phoneNumber)` | Resend verification code | `Future<void>` |
| `cancelPhoneAuth()` | Cancel ongoing authentication | `void` |
| `signOut()` | Sign out current user | `Future<void>` |

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `currentUser` | `User?` | Currently signed-in user |
| `isPhoneVerified` | `bool` | Whether user's phone is verified |
| `userPhoneNumber` | `String?` | User's verified phone number |
| `isPhoneAuthInProgress` | `bool` | Whether phone auth is in progress |

## Contributing

When modifying the phone authentication implementation:

1. Maintain backward compatibility
2. Add comprehensive error handling
3. Include proper logging for debugging
4. Test on multiple devices and scenarios
5. Update this documentation

## License

This implementation follows Firebase's terms of service and best practices for phone authentication.
