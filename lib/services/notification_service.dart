import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:learn_work/models/notification.dart';
import 'package:learn_work/models/user.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create notification for a specific user
  Future<void> createNotification({
    required String userId,
    required String title,
    required String message,
    required NotificationType type,
    String? relatedId,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .add({
            'title': title,
            'message': message,
            'type': type.toString().split('.').last,
            'createdAt': FieldValue.serverTimestamp(),
            'isRead': false,
            'relatedId': relatedId,
          });
    } catch (e) {
      print('Error creating notification: $e');
      throw e;
    }
  }

  // Create notification for all subscribed users (Job Alert)
  // NOTE: Push notifications are automatically sent by Cloud Functions (see functions/index.js)
  // This method creates in-app notifications as a backup/fallback mechanism.
  // The Cloud Function 'sendJobNotification' triggers automatically when a job is created
  // and handles both in-app notifications AND FCM push notifications.
  Future<void> sendJobNotificationToSubscribers({
    required String jobTitle,
    required String companyName,
    required String jobId,
  }) async {
    try {
      // This is now handled by Cloud Functions automatically!
      // The Cloud Function triggers on firestore.collection('jobs').onCreate()
      // and sends both in-app and push notifications to all users with jobAlerts = true

      print(
        'Job created: $jobTitle at $companyName. '
        'Cloud Function will automatically send notifications to subscribed users.',
      );

      // Optional: You can still create in-app notifications here as a backup
      // if the Cloud Function fails, but it's redundant in most cases.
      // Uncomment the code below if you want client-side backup notifications:

      /*
      final querySnapshot = await _firestore
          .collection('users')
          .where('jobAlerts', isEqualTo: true)
          .get();

      final batch = _firestore.batch();

      for (final doc in querySnapshot.docs) {
        final notifRef = _firestore
            .collection('users')
            .doc(doc.id)
            .collection('notifications')
            .doc();

        batch.set(notifRef, {
          'title': 'New Job Opportunity',
          'message': 'New job posted: $jobTitle at $companyName',
          'type': 'job',
          'createdAt': FieldValue.serverTimestamp(),
          'isRead': false,
          'relatedId': jobId,
        });
      }

      await batch.commit();
      print('Backup in-app notifications created for ${querySnapshot.docs.length} users');
      */
    } catch (e) {
      print('Error in notification service: $e');
      // Don't throw to avoid blocking the main job creation flow
    }
  }

  // Get notifications stream for a user
  Stream<List<NotificationModel>> getUserNotifications(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return NotificationModel.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }

  // Mark notification as read
  Future<void> markAsRead(String userId, String notificationId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  // Mark all as read
  Future<void> markAllAsRead(String userId) async {
    final snapshot =
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('notifications')
            .where('isRead', isEqualTo: false)
            .get();

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }
}
