import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/course_note.dart';

class CourseNotesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get course notes stream for a specific course
  Stream<List<CourseNote>> getCourseNotes(String courseId) {
    // Load notes from the course's notes subcollection
    return _firestore
        .collection('courses')
        .doc(courseId)
        .collection('notes')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => CourseNote.fromFirestore(doc)).toList();
    });
  }

  // Search notes by tags or content
  Stream<List<CourseNote>> searchCourseNotes(String courseId, String query) {
    return _firestore
        .collection('courses')
        .doc(courseId)
        .collection('notes')
        .where('title', isGreaterThanOrEqualTo: query)
        .where('title', isLessThan: query + '\uf8ff')
        .orderBy('title')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => CourseNote.fromFirestore(doc)).toList();
    });
  }

  // Get all course notes across all courses (for admin/instructor view)
  Stream<List<Map<String, dynamic>>> getAllCourseNotes() {
    return _firestore
        .collection('courses')
        .snapshots()
        .map((coursesSnapshot) {
      List<Map<String, dynamic>> allNotes = [];
      
      for (var courseDoc in coursesSnapshot.docs) {
        final courseData = courseDoc.data();
        final courseId = courseDoc.id;
        final courseTitle = courseData['title'] ?? '';
        
        // Get notes for this course
        _firestore
            .collection('courses')
            .doc(courseId)
            .collection('notes')
            .get()
            .then((notesSnapshot) {
          for (var noteDoc in notesSnapshot.docs) {
            final noteData = noteDoc.data();
            allNotes.add({
              'noteId': noteDoc.id,
              'courseId': courseId,
              'courseTitle': courseTitle,
              'title': noteData['title'] ?? '',
              'content': noteData['content'] ?? '',
              'tags': noteData['tags'] ?? [],
              'timestamp': noteData['timestamp'],
              'updatedAt': noteData['updatedAt'],
              'createdBy': noteData['createdBy'] ?? '',
              'createdByName': noteData['createdByName'] ?? '',
            });
          }
        });
      }
      
      return allNotes;
    });
  }
}
