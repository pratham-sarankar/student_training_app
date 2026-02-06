import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();

  // Get current user ID
  String? get _currentUserId => _auth.currentUser?.uid;

  /// Pick an image from the specified source (camera or gallery)
  Future<XFile?> pickImage({required ImageSource source}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      throw Exception('Failed to pick image: $e');
    }
  }

  /// Upload profile picture to Firebase Storage
  /// Returns the download URL of the uploaded image
  Future<String> uploadProfilePicture(File imageFile) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      // Create a reference to the profile pictures directory
      final String fileName =
          'profile_${_currentUserId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference storageRef = _storage
          .ref()
          .child('profile_pictures')
          .child(_currentUserId!)
          .child(fileName);

      // Upload the file
      final UploadTask uploadTask = storageRef.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'userId': _currentUserId!,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      // Wait for upload to complete
      final TaskSnapshot snapshot = await uploadTask;

      // Get download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload profile picture: $e');
    }
  }

  /// Delete old profile picture from Firebase Storage
  Future<void> deleteProfilePicture(String imageUrl) async {
    try {
      // Extract the path from the URL
      final Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      // Ignore errors if file doesn't exist or can't be deleted
      print('Error deleting old profile picture: $e');
    }
  }

  /// Upload resume (PDF/DOC) to Firebase Storage
  /// Returns the download URL of the uploaded file
  Future<String> uploadResume(File resumeFile, String originalFileName) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final String extension = originalFileName.split('.').last;
      final String fileName =
          'resume_${_currentUserId}_${DateTime.now().millisecondsSinceEpoch}.$extension';

      final Reference storageRef = _storage
          .ref()
          .child('resumes')
          .child(_currentUserId!)
          .child(fileName);

      // Determine content type
      String contentType = 'application/pdf';
      if (extension.toLowerCase() == 'doc') {
        contentType = 'application/msword';
      } else if (extension.toLowerCase() == 'docx') {
        contentType =
            'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      }

      final UploadTask uploadTask = storageRef.putFile(
        resumeFile,
        SettableMetadata(
          contentType: contentType,
          customMetadata: {
            'userId': _currentUserId!,
            'originalName': originalFileName,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      final TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload resume: $e');
    }
  }

  /// Upload any image to a custom path
  Future<String> uploadImage({
    required File imageFile,
    required String path,
    String? fileName,
  }) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final String finalFileName =
          fileName ?? 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final Reference storageRef = _storage
          .ref()
          .child(path)
          .child(finalFileName);

      final UploadTask uploadTask = storageRef.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'userId': _currentUserId!,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Get upload progress stream
  Stream<double> getUploadProgress(UploadTask uploadTask) {
    return uploadTask.snapshotEvents.map((snapshot) {
      return snapshot.bytesTransferred / snapshot.totalBytes;
    });
  }

  /// Delete any file from Firebase Storage
  Future<void> deleteFile(String fileUrl) async {
    try {
      final Reference ref = _storage.refFromURL(fileUrl);
      await ref.delete();
    } catch (e) {
      print('Error deleting file: $e');
    }
  }
}
