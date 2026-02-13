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

          courses.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return courses;
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

  // Delete course
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

  // Logic to process CSV data and segrigate courses
  Future<void> uploadCoursesFromCsvData(List<List<dynamic>> csvData) async {
    // Expected headers: Domain, Recommended Courses, Cost and duration, Mode, Days, Timing
    if (csvData.isEmpty) return;

    // Check if first row is header
    int startIndex = 0;
    if (csvData[0][0].toString().toLowerCase().contains('domain')) {
      startIndex = 1;
    }

    String currentDomain = '';

    for (int i = startIndex; i < csvData.length; i++) {
      final row = csvData[i];
      if (row.length < 6) continue;

      final domainCell = row[0].toString().trim();
      if (domainCell.isNotEmpty) {
        currentDomain = domainCell;
      }

      final recommendedCoursesRaw = row[1].toString().trim();
      final costAndDuration = row[2].toString().trim();
      final mode = row[3].toString().trim();
      final days = row[4].toString().trim();
      final timing = row[5].toString().trim();

      if (currentDomain.isEmpty || recommendedCoursesRaw.isEmpty) continue;

      // Parse cost and duration: e.g., "3500/4 weeks"
      final parts = costAndDuration.split('/');
      double cost = 0;
      String duration = '';

      if (parts.length >= 2) {
        cost =
            double.tryParse(parts[0].replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
        duration = parts[1].trim();
      } else {
        duration = costAndDuration;
      }

      // Segregation Logic
      // 4 weeks duration is summer traning, any more is job oriented
      final bool isSummerTraining = duration.toLowerCase().contains('4 weeks');
      final String type = isSummerTraining ? 'Summer Training' : 'Job Oriented';

      // Both have 500 RS enrollment fee
      const double enrollmentFee = 500.0;

      // Only job oriented have free demo
      final bool hasFreeDemo = !isSummerTraining;

      // Split recommended courses if they are comma or slash separated
      // We use a regex to handle various delimiters (comma, slash with spaces)
      final List<String> coursesToCreate =
          recommendedCoursesRaw
              .split(RegExp(r',|\s/\s|(?<=\s)/(?=\s)'))
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();

      for (var courseName in coursesToCreate) {
        if (courseName.isEmpty) continue;

        final course = Course(
          id: '',
          domain: currentDomain,
          recommendedCourses: courseName,
          cost: cost,
          duration: duration,
          mode: mode,
          days: days,
          timing: timing,
          type: type,
          enrollmentFee: enrollmentFee,
          hasFreeDemo: hasFreeDemo,
          createdAt: DateTime.now(),
          isActive: true,
        );

        await addCourse(course);
      }
    }
  }

  // Placeholder for compatibility
  Future<void> initializeSampleCourses() async {
    return;
  }
}
