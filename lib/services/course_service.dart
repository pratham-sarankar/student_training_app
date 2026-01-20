import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/course.dart';

class CourseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'courses';

  // Get all active courses
  Stream<List<Course>> getCourses() {
    return _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          final courses =
              snapshot.docs.map((doc) {
                return Course.fromMap(doc.data(), doc.id);
              }).toList();

          // Sort locally to avoid Firestore index requirements
          courses.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return courses;
        });
  }

  // Get courses by category
  Stream<List<Course>> getCoursesByCategory(String category) {
    if (category == 'All') {
      return getCourses();
    }

    return _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) {
          final courses =
              snapshot.docs.map((doc) {
                return Course.fromMap(doc.data(), doc.id);
              }).toList();

          // Sort locally to avoid Firestore index requirements
          courses.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return courses;
        });
  }

  // Search courses
  Stream<List<Course>> searchCourses(String query) {
    return _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) {
                return Course.fromMap(doc.data(), doc.id);
              })
              .where((course) {
                return course.title.toLowerCase().contains(
                      query.toLowerCase(),
                    ) ||
                    course.description.toLowerCase().contains(
                      query.toLowerCase(),
                    ) ||
                    course.category.toLowerCase().contains(
                      query.toLowerCase(),
                    ) ||
                    course.instructor.toLowerCase().contains(
                      query.toLowerCase(),
                    );
              })
              .toList();
        });
  }

  // Get course by ID
  Future<Course?> getCourseById(String courseId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(courseId).get();
      if (doc.exists) {
        return Course.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting course: $e');
      return null;
    }
  }

  // Add new course
  Future<String?> addCourse(Course course) async {
    try {
      final docRef = await _firestore
          .collection(_collection)
          .add(course.toMap());
      return docRef.id;
    } catch (e) {
      print('Error adding course: $e');
      return null;
    }
  }

  // Update course
  Future<bool> updateCourse(String courseId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(_collection).doc(courseId).update(data);
      return true;
    } catch (e) {
      print('Error updating course: $e');
      return false;
    }
  }

  // Delete course (soft delete by setting isActive to false)
  Future<bool> deleteCourse(String courseId) async {
    try {
      await _firestore.collection(_collection).doc(courseId).update({
        'isActive': false,
      });
      return true;
    } catch (e) {
      print('Error deleting course: $e');
      return false;
    }
  }

  // Get course categories
  Stream<List<String>> getCourseCategories() {
    return _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          final categories =
              snapshot.docs
                  .map((doc) => doc.data()['category'] as String)
                  .where((category) => category.isNotEmpty)
                  .toSet()
                  .toList();

          categories.sort();
          return ['All', ...categories];
        });
  }

  // Initialize sample courses in Firebase
  Future<void> initializeSampleCourses() async {
    // Sample courses initialization removed as per user request
    return;
  }
}
