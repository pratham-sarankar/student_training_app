import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gradspark/models/user.dart';

class AdminService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current admin user
  User? get currentAdminUser => _auth.currentUser;

  // Stream of admin auth state changes
  Stream<User?> get adminAuthStateChanges => _auth.authStateChanges();

  // Check if current user is admin
  Future<bool> isCurrentUserAdmin() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('🔐 AdminService: No current user found');
        return false;
      }

      print('🔐 AdminService: Checking admin status for user: ${user.uid}');

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        final userData = userDoc.data();
        final role = userData?['role'];
        print('🔐 AdminService: User document found, role: $role');
        return role == 'Admin';
      } else {
        print('🔐 AdminService: User document does not exist in Firestore');
        return false;
      }
    } catch (e) {
      print('🔐 AdminService: Error checking admin status: $e');
      return false;
    }
  }

  // Sign in admin with email and password
  Future<UserCredential> signInAdminWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      print('🔐 AdminService: Attempting to sign in with email: $email');

      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print(
        '🔐 AdminService: Firebase Auth sign in successful for user: ${result.user?.uid}',
      );

      // Verify the user is actually an admin
      if (result.user != null) {
        print('🔐 AdminService: Checking if user has admin role...');
        final isAdmin = await isCurrentUserAdmin();
        print('🔐 AdminService: Admin role check result: $isAdmin');

        if (!isAdmin) {
          print(
            '🔐 AdminService: User does not have admin role, signing out...',
          );
          // Sign out the user if they're not an admin
          await _auth.signOut();
          throw 'Access denied. This account is not authorized for admin access.';
        }

        print('🔐 AdminService: Admin authentication successful!');
      }

      return result;
    } catch (e) {
      print('🔐 AdminService: Error during admin sign in: $e');

      // Don't automatically sign out on authentication errors during login
      // Let the calling code handle the error appropriately
      if (e.toString().contains('Access denied')) {
        // For role verification errors, throw the error as is
        throw e;
      }

      // For authentication errors, just throw the error without signing out
      // This prevents the user from being signed out when they're just trying to log in
      throw _handleAuthError(e);
    }
  }

  // Create admin user (this should only be used by super admins)
  Future<UserCredential> createAdminUser(
    String email,
    String password,
    String firstName,
    String lastName,
  ) async {
    try {
      // Check if current user is authorized to create admins
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw 'Authentication required to create admin users.';
      }

      final currentUserDoc =
          await _firestore.collection('users').doc(currentUser.uid).get();
      if (!currentUserDoc.exists || currentUserDoc.data()?['role'] != 'Admin') {
        throw 'Insufficient permissions. Only admins can create admin users.';
      }

      // Create the user in Firebase Auth
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create admin user document in Firestore
      if (result.user != null) {
        final adminUser = UserModel(
          uid: result.user!.uid,
          firstName: firstName,
          lastName: lastName,
          email: email,
          role: 'Admin',
          isEmailVerified: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(result.user!.uid)
            .set(adminUser.toMap());

        // Update display name in Firebase Auth
        await result.user!.updateDisplayName('$firstName $lastName');
      }

      return result;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Update admin user profile
  Future<void> updateAdminProfile({
    String? firstName,
    String? lastName,
    String? photoUrl,
    String? bio,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'No authenticated user found.';

      // Update display name in Firebase Auth
      if (firstName != null || lastName != null) {
        final newDisplayName = '${firstName ?? ''} ${lastName ?? ''}'.trim();
        if (newDisplayName.isNotEmpty) {
          await user.updateDisplayName(newDisplayName);
        }
      }

      // Update user document in Firestore
      final updateData = <String, dynamic>{
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      if (firstName != null) updateData['firstName'] = firstName;
      if (lastName != null) updateData['lastName'] = lastName;
      if (photoUrl != null) updateData['photoUrl'] = photoUrl;
      if (bio != null) updateData['bio'] = bio;

      await _firestore.collection('users').doc(user.uid).update(updateData);
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Get all admin users
  Future<List<UserModel>> getAllAdminUsers() async {
    try {
      final querySnapshot =
          await _firestore
              .collection('users')
              .where('role', isEqualTo: 'Admin')
              .get();

      final users =
          querySnapshot.docs.map((doc) {
            return UserModel.fromMap(doc.data(), doc.id);
          }).toList();

      // Sort manually in Dart to avoid requiring a composite index
      users.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return users;
    } catch (e) {
      print('Error fetching admin users: $e');
      return [];
    }
  }

  // Get all students
  Future<List<UserModel>> getAllStudents() async {
    try {
      final querySnapshot =
          await _firestore
              .collection('users')
              .where('role', isEqualTo: 'Student')
              .get();

      final users =
          querySnapshot.docs.map((doc) {
            return UserModel.fromMap(doc.data(), doc.id);
          }).toList();

      // Sort manually in Dart to avoid requiring a composite index
      users.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return users;
    } catch (e) {
      print('Error fetching students: $e');
      return [];
    }
  }

  // Get admin user by ID
  Future<UserModel?> getAdminUserById(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error fetching admin user: $e');
      return null;
    }
  }

  // Change admin user role (only super admins can do this)
  Future<void> changeUserRole(String userId, String newRole) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw 'Authentication required to change user roles.';
      }

      final currentUserDoc =
          await _firestore.collection('users').doc(currentUser.uid).get();
      if (!currentUserDoc.exists || currentUserDoc.data()?['role'] != 'Admin') {
        throw 'Insufficient permissions. Only admins can change user roles.';
      }

      // Validate role
      if (!['Student', 'Admin'].contains(newRole)) {
        throw 'Invalid role. Must be Student or Admin.';
      }

      await _firestore.collection('users').doc(userId).update({
        'role': newRole,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Delete admin user (only super admins can do this)
  Future<void> deleteAdminUser(String userId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw 'Authentication required to delete users.';
      }

      if (currentUser.uid == userId) {
        throw 'Cannot delete your own account.';
      }

      final currentUserDoc =
          await _firestore.collection('users').doc(currentUser.uid).get();
      if (!currentUserDoc.exists || currentUserDoc.data()?['role'] != 'Admin') {
        throw 'Insufficient permissions. Only admins can delete users.';
      }

      // Delete user document from Firestore
      await _firestore.collection('users').doc(userId).delete();

      // Note: Deleting the Firebase Auth user requires admin SDK on the backend
      // For now, we'll just delete the Firestore document
      print(
        'User document deleted. Firebase Auth user deletion requires backend implementation.',
      );
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Sign out admin
  Future<void> signOutAdmin() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Reset admin password
  Future<void> resetAdminPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Handle Firebase Auth errors
  String _handleAuthError(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No admin account found with this email address.';
        case 'wrong-password':
          return 'Incorrect password. Please try again.';
        case 'email-already-in-use':
          return 'An account already exists with this email address.';
        case 'weak-password':
          return 'The password provided is too weak.';
        case 'invalid-email':
          return 'The email address is not valid.';
        case 'user-disabled':
          return 'This admin account has been disabled.';
        case 'too-many-requests':
          return 'Too many requests. Please try again later.';
        case 'operation-not-allowed':
          return 'Email/password accounts are not enabled.';
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
}
