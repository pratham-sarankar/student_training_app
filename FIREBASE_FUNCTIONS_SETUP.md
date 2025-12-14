# Firebase Cloud Functions Setup for Job Notifications

This document explains how to set up and deploy Firebase Cloud Functions to send push notifications when an admin creates a new job.

## Architecture Overview

1. **Flutter App**: Creates job in Firestore
2. **Cloud Function**: Automatically triggers on job creation
3. **Firebase Admin SDK**: Sends push notifications to all users with `jobAlerts: true`
4. **FCM Tokens**: Stored in user documents for push notification delivery

## Prerequisites

- Firebase CLI installed (`npm install -g firebase-tools`)
- Node.js 18 or higher
- Firebase project with Blaze plan (Cloud Functions require paid plan)

## Setup Steps

### 1. Initialize Firebase in Your Project

If not already done, run:
```bash
firebase login
firebase init
```

Select:
- Functions (JavaScript)
- Use existing project (select your Firebase project)
- Use ESLint: No
- Install dependencies: Yes

### 2. Configure Firebase Admin SDK

The service account key JSON file (`learn-work-9bbf7-eac905a05d68.json`) is already in your project root. The Cloud Function will automatically use Firebase Admin SDK credentials when deployed.

**Important**: Do NOT commit this JSON file to git. Add it to `.gitignore`.

### 3. Install Dependencies

Navigate to the functions directory and install dependencies:
```bash
cd functions
npm install
```

### 4. Deploy Cloud Functions

Deploy the functions to Firebase:
```bash
firebase deploy --only functions
```

This will deploy:
- `sendJobNotification`: Triggers when a new job is created
- `updateFcmToken`: (Optional) Callable function to update FCM tokens

### 5. Update User Model in Firestore

Ensure all user documents have the following fields:
- `jobAlerts` (boolean): Whether user wants job notifications
- `pushNotifications` (boolean): Whether user enabled push notifications
- `fcmToken` (string): Firebase Cloud Messaging token for the user's device

### 6. Initialize FCM in Flutter App

In your `main.dart`, initialize FCM when the app starts:

```dart
import 'package:learn_work/services/fcm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Initialize FCM
  final fcmService = FcmService();
  await fcmService.initialize();
  
  runApp(MyApp());
}
```

Also initialize FCM when a user logs in (in your authentication service):

```dart
// After successful login
final fcmService = FcmService();
await fcmService.initialize();
```

### 7. Handle Notification Permissions (Android)

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest>
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    
    <application>
        <!-- Add this inside <application> tag -->
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_channel_id"
            android:value="job_alerts_channel" />
    </application>
</manifest>
```

### 8. Handle Notification Permissions (iOS)

Ensure `ios/Runner/AppDelegate.swift` has:

```swift
import UIKit
import Flutter
import FirebaseCore
import FirebaseMessaging

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

## Testing

### 1. Test In-App Notifications

1. Ensure at least one user has `jobAlerts: true` in Firestore
2. As admin, create a new job
3. Check the user's `notifications` subcollection in Firestore
4. Verify notification appears in the app's notification screen

### 2. Test Push Notifications

1. Ensure a user has:
   - `jobAlerts: true`
   - `pushNotifications: true`  
   - Valid `fcmToken` (set when user logs in)
2. Close or background the app
3. As admin, create a new job
4. User should receive push notification on their device

### 3. View Function Logs

Check Cloud Function execution logs:
```bash
firebase functions:log
```

Or view in Firebase Console:
- Go to Firebase Console → Functions
- Click on `sendJobNotification`
- View execution history and logs

## How It Works

1. **Job Creation**: Admin creates a job via `AdminProvider.addJob()`
2. **Firestore Write**: Job is added to `jobs` collection
3. **Trigger**: Cloud Function `sendJobNotification` is triggered automatically
4. **Query Users**: Function queries all users where `jobAlerts == true`
5. **Create In-App Notifications**: For each user, creates a notification document in `users/{userId}/notifications`
6. **Send Push Notifications**: For users with `fcmToken`, sends push notification via FCM
7. **Logging**: Function logs success/failure for monitoring

## Troubleshooting

### No notifications received:
- Check user has `jobAlerts: true` in Firestore
- Verify `fcmToken` exists and is valid
- Check Cloud Function logs for errors
- Ensure Blaze plan is active

### Cloud Function not triggering:
- Verify function is deployed: `firebase functions:list`
- Check Firebase Console → Functions for deployment status
- Look for errors in function logs

### Push notifications not showing:
- Verify FCM token is valid and saved correctly
- Check notification permissions are granted
- Ensure app is backgrounded (foreground notifications need custom handling)
- Check device notification settings

## Production Considerations

1. **Rate Limiting**: For large user bases, batch notifications to avoid overwhelming FCM
2. **Token Cleanup**: Periodically remove invalid/expired FCM tokens
3. **Monitoring**: Set up Cloud Function alerts for failures
4. **Costs**: Monitor Cloud Function invocations and Firestore reads
5. **Security**: Ensure Firestore rules prevent unauthorized access to tokens

## Files Created

- `functions/index.js`: Cloud Functions implementation
- `functions/package.json`: Node.js dependencies
- `lib/services/fcm_service.dart`: Flutter FCM service
- `FIREBASE_FUNCTIONS_SETUP.md`: This documentation

## Next Steps

1. Deploy Cloud Functions: `firebase deploy --only functions`
2. Test with a real device
3. Monitor function execution in Firebase Console
4. Adjust notification content as needed
5. Implement notification navigation in the Flutter app
