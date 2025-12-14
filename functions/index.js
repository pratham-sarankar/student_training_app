const functions = require('firebase-functions');
const admin = require('firebase-admin');

// Initialize Firebase Admin SDK
admin.initializeApp();

// Cloud Function to send push notifications when a new job is created
exports.sendJobNotification = functions.firestore
    .document('jobs/{jobId}')
    .onCreate(async (snapshot, context) => {
        try {
            const jobData = snapshot.data();
            const jobId = context.params.jobId;

            console.log(`New job created: ${jobData.title} (${jobId})`);

            // Get all users with jobAlerts = true
            const usersSnapshot = await admin.firestore()
                .collection('users')
                .where('jobAlerts', '==', true)
                .get();

            if (usersSnapshot.empty) {
                console.log('No users have job alerts enabled');
                return null;
            }

            console.log(`Found ${usersSnapshot.size} users with job alerts enabled`);

            // Prepare notification payload
            const notificationTitle = 'New Job Opportunity';
            const notificationBody = `New job posted: ${jobData.title} at ${jobData.company}`;

            // Collect FCM tokens from users with job alerts enabled
            const tokens = [];

            for (const userDoc of usersSnapshot.docs) {
                const userData = userDoc.data();

                // Only add token if user has FCM token and push notifications enabled
                if (userData.fcmToken && userData.pushNotifications !== false) {
                    tokens.push(userData.fcmToken);
                }
            }

            // Send push notifications to devices with FCM tokens
            if (tokens.length > 0) {
                const message = {
                    notification: {
                        title: notificationTitle,
                        body: notificationBody,
                    },
                    data: {
                        type: 'job',
                        jobId: jobId,
                        jobTitle: jobData.title,
                        company: jobData.company,
                    },
                    tokens: tokens,
                };

                const response = await admin.messaging().sendEachForMulticast(message);
                console.log(`✅ Successfully sent ${response.successCount} push notifications`);

                if (response.failureCount > 0) {
                    console.log(`⚠️  Failed to send ${response.failureCount} push notifications`);

                    // Log failures
                    response.responses.forEach((resp, idx) => {
                        if (!resp.success) {
                            console.error(`Failed to send to token ${tokens[idx]}:`, resp.error);
                        }
                    });
                }

                return {
                    success: true,
                    totalUsersWithAlerts: usersSnapshot.size,
                    notificationsSent: response.successCount,
                    notificationsFailed: response.failureCount,
                };
            } else {
                console.log('⚠️  No valid FCM tokens found. Users may need to login to register their tokens.');
                return {
                    success: false,
                    totalUsersWithAlerts: usersSnapshot.size,
                    notificationsSent: 0,
                    message: 'No FCM tokens available',
                };
            }

        } catch (error) {
            console.error('Error sending job notifications:', error);
            throw error;
        }
    });

// Optional: Cloud Function to handle FCM token updates
exports.updateFcmToken = functions.https.onCall(async (data, context) => {
    // Verify user is authenticated
    if (!context.auth) {
        throw new functions.https.HttpsError(
            'unauthenticated',
            'User must be authenticated to update FCM token'
        );
    }

    const { token } = data;
    const userId = context.auth.uid;

    if (!token) {
        throw new functions.https.HttpsError(
            'invalid-argument',
            'FCM token is required'
        );
    }

    try {
        await admin.firestore().collection('users').doc(userId).update({
            fcmToken: token,
            fcmTokenUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        console.log(`Updated FCM token for user ${userId}`);
        return { success: true };
    } catch (error) {
        console.error(`Error updating FCM token for user ${userId}:`, error);
        throw new functions.https.HttpsError('internal', error.message);
    }
});
