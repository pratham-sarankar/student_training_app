# Job Alert Push Notifications - Quick Start Guide

## Overview

Your app now has a complete push notification system! When an admin creates a new job, all users who have enabled job alerts will automatically receive:
1. **Push Notification** on their device (even when app is closed)
2. **In-App Notification** in the notifications screen

## How It Works

```
Admin Creates Job → Firestore → Cloud Function → FCM → User's Device
                          ↓
                  In-App Notification
```

1. Admin creates a job via the app
2. Job is saved to Firestore `jobs` collection
3. Cloud Function automatically triggers
4. Function queries users with `jobAlerts: true`
5. Function sends push notifications via FCM
6. Function creates in-app notifications
7. Users receive notifications!

## Quick Setup (5 Steps)

### Step 1: Install Firebase CLI

Open PowerShell and run:
```powershell
npm install -g firebase-tools
```

### Step 2: Login to Firebase

```powershell
firebase login
```

### Step 3: Initialize Firebase Project

In your project directory:
```powershell
firebase init
```

Select:
- **Functions**: Use arrow keys to select, press space to check the box
- **Use an existing project**: Select your Firebase project
- **JavaScript**: Press Enter
- **ESLint**: Type `n` and press Enter
- **Install dependencies**: Type `y` and press Enter

### Step 4: Install Dependencies

```powershell
cd functions
npm install
cd ..
```

### Step 5: Deploy Cloud Functions

```powershell
firebase deploy --only functions
```

This will upload your Cloud Functions to Firebase. It may take 2-3 minutes.

## Update Your Flutter App

### 1. Initialize FCM Service

Open `lib/main.dart` and add FCM initialization after Firebase.initializeApp():

```dart
import 'package:learn_work/services/fcm_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize FCM for push notifications
  final fcmService = FcmService();
  await fcmService.initialize();
  
  runApp(const MyApp());
}
```

### 2. Initialize FCM on User Login

Find your login/authentication service and add this after successful login:

```dart
// After user signs in successfully
final fcmService = FcmService();
await fcmService.initialize();
```

### 3. Android Configuration

Add to `android/app/src/main/AndroidManifest.xml` (inside `<manifest>` tag):

```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

Also add inside `<application>` tag:

```xml
<meta-data
    android:name="com.google.firebase.messaging.default_notification_channel_id"
    android:value="job_alerts_channel" />
```

## Testing the Notifications

### Test 1: In-App Notifications

1. Open Firestore in Firebase Console
2. Find a user document and set:
   ```
   jobAlerts: true
   ```
3. As admin, create a new job
4. Check the user's `notifications` subcollection
5. Open the app and check notifications screen

### Test 2: Push Notifications

1. Make sure a user has:
   - `jobAlerts: true`
   - `pushNotifications: true`
   - Valid `fcmToken` (automatically created when user logs in)
2. **Close or background the app**
3. As admin, create a new job
4. User should receive a push notification!

### Debugging

View Cloud Function logs:
```powershell
firebase functions:log
```

Or check in Firebase Console:
- Go to Firebase Console → Functions
- Click on your function
- View execution logs

## Important Notes

### ⚠️ Firebase Blaze Plan Required

Cloud Functions require Firebase Blaze (pay-as-you-go) plan. Don't worry - it's free for low usage:
- First 2 million invocations/month: **FREE**
- Your app will likely stay in free tier

To upgrade:
1. Go to Firebase Console
2. Click "Upgrade" in the bottom left
3. Select Blaze plan

### 🔐 Security

The service account JSON file (`learn-work-9bbf7-eac905a05d68.json`) should **NEVER** be committed to Git or shared publicly. It contains sensitive credentials.

Add to `.gitignore`:
```
*.json
!firebase.json
!functions/package.json
```

### 📱 iOS Considerations

For iOS, additional setup is required:
1. Add Push Notification capability in Xcode
2. Upload APNs certificate to Firebase Console
3. Update `AppDelegate.swift` (see `FIREBASE_FUNCTIONS_SETUP.md`)

## Verification Checklist

- [ ] Firebase CLI installed
- [ ] Logged in to Firebase
- [ ] Cloud Functions deployed successfully
- [ ] FCM service initialized in `main.dart`
- [ ] Android permission added to `AndroidManifest.xml`
- [ ] Tested in-app notifications
- [ ] Tested push notifications on real device

## Files Created

| File | Purpose |
|------|---------|
| `functions/index.js` | Cloud Function that sends notifications |
| `functions/package.json` | Node.js dependencies |
| `lib/services/fcm_service.dart` | Flutter service for FCM token management |
| `firebase.json` | Firebase configuration |
| `FIREBASE_FUNCTIONS_SETUP.md` | Detailed setup guide |
| `README_NOTIFICATIONS.md` | This quick start guide |

## Troubleshooting

**No push notifications received?**
- Check user has `jobAlerts: true` and `fcmToken` in Firestore
- Verify Cloud Function deployed: `firebase functions:list`
- Check function logs: `firebase functions:log`
- Ensure you're on Firebase Blaze plan

**Cloud Function not triggering?**
- Verify deployment status in Firebase Console
- Check if function appears in Functions section
- Look for errors in deployment logs

**App crashes on startup?**
- Make sure `firebase_messaging` is in `pubspec.yaml`
- Run `flutter pub get`
- Rebuild the app completely

## Next Steps

1. **Deploy**: `firebase deploy --only functions`
2. **Test**: Create a job and verify notifications
3. **Customize**: Edit notification title/body in `functions/index.js`
4. **Monitor**: Check Cloud Functions dashboard for usage stats

## Support

For detailed information, see:
- `FIREBASE_FUNCTIONS_SETUP.md` - Complete technical documentation
- Firebase Console → Functions - View execution logs
- Flutter Firebase Messaging Docs: https://firebase.flutter.dev/docs/messaging

---

**Ready to test?** 
1. Deploy functions: `firebase deploy --only functions`
2. Add FCM initialization to `main.dart`
3. Create a test job as admin
4. Watch the magic happen! ✨
