import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:learn_work/services/user_service.dart';

// Top-level function to handle background messages
// This must be a top-level or static function
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling background message: ${message.messageId}');
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  // The notification will be shown automatically by the system
  // This handler is for any additional processing needed
}

class PushNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final UserService _userService = UserService();

  static final PushNotificationService _instance =
      PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  Future<void> initialize() async {
    try {
      // Set up background message handler
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      // Request permission
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      print('User granted permission: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        // Get token
        String? token = await _fcm.getToken();
        if (token != null) {
          print('FCM Token: $token');
          await _saveTokenToFirestore(token);
        }

        // Handle token refresh
        _fcm.onTokenRefresh.listen((newToken) async {
          print('FCM Token refreshed: $newToken');
          await _saveTokenToFirestore(newToken);
        });

        // Handle foreground messages
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          print(
            '📨 Received foreground message: ${message.notification?.title}',
          );

          if (message.notification != null) {
            print('   Title: ${message.notification!.title}');
            print('   Body: ${message.notification!.body}');
            // The in-app notification is already created by Cloud Function
            // This is just for showing an immediate visual feedback
          }

          // Data payload from Cloud Function
          if (message.data.isNotEmpty) {
            print('   Data: ${message.data}');
          }
        });

        // Handle when user taps notification (app in background)
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
          print('📬 Notification tapped! Opening app...');
          _handleNotificationTap(message);
        });

        // Handle initial message (app opened from terminated state)
        FirebaseMessaging.instance.getInitialMessage().then((
          RemoteMessage? message,
        ) {
          if (message != null) {
            print('📬 App opened from notification (terminated state)');
            _handleNotificationTap(message);
          }
        });

        print('✅ Push notifications initialized successfully');
      } else {
        print('⚠️  User declined notification permission');
      }
    } catch (e) {
      print('❌ Error initializing push notifications: $e');
      rethrow;
    }
  }

  Future<void> _saveTokenToFirestore(String token) async {
    try {
      await _userService.updateFCMToken(token);
      print('✅ FCM token saved to Firestore');
    } catch (e) {
      print('❌ Error saving FCM token: $e');
    }
  }

  void _handleNotificationTap(RemoteMessage message) {
    final data = message.data;
    print('Notification data: $data');

    // Handle navigation based on notification type
    if (data['type'] == 'job' && data['jobId'] != null) {
      print('Would navigate to job: ${data['jobId']}');
      // TODO: Implement navigation to job details screen
      // Example: navigationService.navigateToJobDetails(data['jobId']);
    }
  }

  /// Unregister FCM token (call on logout)
  Future<void> unregister() async {
    try {
      await _fcm.deleteToken();
      print('✅ FCM token deleted');
    } catch (e) {
      print('❌ Error deleting FCM token: $e');
    }
  }
}
