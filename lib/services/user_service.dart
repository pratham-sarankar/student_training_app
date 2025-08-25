import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Create or update user document
  Future<void> createOrUpdateUser({
    required String uid,
    required String name,
    required String email,
    String? photoUrl,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'name': name,
        'email': email,
        'photoUrl': photoUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to create/update user: $e');
    }
  }

  // Get user by ID
  Future<Map<String, dynamic>?> getUserById(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  // Get current user data
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    final user = currentUser;
    if (user == null) return null;
    
    return await getUserById(user.uid);
  }

  // Search users by name or email
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      final currentUser = this.currentUser;
      if (currentUser == null) return [];

      // Search by name (case-insensitive)
      final nameQuery = await _firestore
          .collection('users')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: query + '\uf8ff')
          .get();

      // Search by email (case-insensitive)
      final emailQuery = await _firestore
          .collection('users')
          .where('email', isGreaterThanOrEqualTo: query)
          .where('email', isLessThan: query + '\uf8ff')
          .get();

      // Combine and deduplicate results
      final allDocs = [...nameQuery.docs, ...emailQuery.docs];
      final uniqueDocs = <String, DocumentSnapshot>{};
      
      for (final doc in allDocs) {
        uniqueDocs[doc.id] = doc;
      }

      // Filter out current user and convert to list
      return uniqueDocs.values
          .where((doc) => doc.id != currentUser.uid)
          .map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'uid': doc.id,
          'name': data['name'] ?? 'Unknown User',
          'email': data['email'] ?? '',
          'photoUrl': data['photoUrl'] ?? '',
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? name,
    String? photoUrl,
  }) async {
    final user = currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (name != null) updates['name'] = name;
      if (photoUrl != null) updates['photoUrl'] = photoUrl;

      await _firestore
          .collection('users')
          .doc(user.uid)
          .update(updates);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // Delete user account
  Future<void> deleteUserAccount() async {
    final user = currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      // Delete user document
      await _firestore.collection('users').doc(user.uid).delete();
      
      // Delete user authentication
      await user.delete();
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }

  // Get all users (for admin purposes)
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'uid': doc.id,
          'name': data['name'] ?? 'Unknown User',
          'email': data['email'] ?? '',
          'photoUrl': data['photoUrl'] ?? '',
          'createdAt': data['createdAt'],
          'updatedAt': data['updatedAt'],
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to get all users: $e');
    }
  }
}
