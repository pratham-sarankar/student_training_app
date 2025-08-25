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
      final courses = snapshot.docs.map((doc) {
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
      final courses = snapshot.docs.map((doc) {
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
      return snapshot.docs.map((doc) {
        return Course.fromMap(doc.data(), doc.id);
      }).where((course) {
        return course.title.toLowerCase().contains(query.toLowerCase()) ||
            course.description.toLowerCase().contains(query.toLowerCase()) ||
            course.category.toLowerCase().contains(query.toLowerCase()) ||
            course.instructor.toLowerCase().contains(query.toLowerCase());
      }).toList();
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
      final docRef = await _firestore.collection(_collection).add(course.toMap());
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
      final categories = snapshot.docs
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
    try {
      // Check if courses already exist
      final snapshot = await _firestore.collection(_collection).limit(1).get();
      if (snapshot.docs.isNotEmpty) {
        print('Courses already exist, skipping initialization');
        return;
      }

      final sampleCourses = [
        {
          'title': 'Flutter Development Fundamentals',
          'category': 'Technology',
          'description': 'Learn Flutter from scratch and build beautiful mobile applications for iOS and Android.',
          'cost': 99.99,
          'duration': '8 weeks',
          'level': 'Beginner',
          'image': 'https://elements-resized.envatousercontent.com/envato-dam-assets-production/EVA/TRX/2b/0b/38/42/89/v1_E10/E107OQSH.JPG?w=1600&cf_fit=scale-down&mark-alpha=18&mark=https%3A%2F%2Felements-assets.envato.com%2Fstatic%2Fwatermark4.png&q=85&format=auto&s=65dd1c957cd287a87f8117a41cedb3edb353b9f9bfc6b1e352c9b8f94e95154c',
          'schedules': [
            {'time': 'Mon, Wed 6:00 PM', 'seats': 15, 'startDate': '2024-02-01'},
            {'time': 'Tue, Thu 7:00 PM', 'seats': 12, 'startDate': '2024-02-15'},
            {'time': 'Sat 10:00 AM', 'seats': 20, 'startDate': '2024-02-10'},
          ],
          'instructor': 'Sarah Johnson',
          'topics': [
            'Flutter Basics',
            'Widgets and Layouts',
            'State Management',
            'Navigation',
            'API Integration',
            'Testing',
            'Deployment',
          ],
          'requirements': 'Basic programming knowledge, familiarity with Dart is helpful but not required.',
          'outcomes': 'Build complete Flutter apps, understand mobile development principles, deploy to app stores.',
          'createdAt': Timestamp.now(),
          'isActive': true,
        },
        {
          'title': 'UI/UX Design Masterclass',
          'category': 'Design',
          'description': 'Master the principles of user interface and user experience design.',
          'cost': 149.99,
          'duration': '6 weeks',
          'level': 'Intermediate',
          'image': 'https://elements-resized.envatousercontent.com/envato-dam-assets-production/EVA/TRX/2b/0b/38/42/89/v1_E10/E107OQSH.JPG?w=1600&cf_fit=scale-down&mark-alpha=18&mark=https%3A%2F%2Felements-assets.envato.com%2Fstatic%2Fwatermark4.png&q=85&format=auto&s=65dd1c957cd287a87f8117a41cedb3edb353b9f9bfc6b1e352c9b8f94e95154c',
          'schedules': [
            {'time': 'Mon, Wed 7:00 PM', 'seats': 18, 'startDate': '2024-02-05'},
            {'time': 'Sat 2:00 PM', 'seats': 25, 'startDate': '2024-02-12'},
          ],
          'instructor': 'Michael Chen',
          'topics': [
            'Design Principles',
            'User Research',
            'Wireframing',
            'Prototyping',
            'Visual Design',
            'Usability Testing',
            'Design Systems',
          ],
          'requirements': 'Basic design software knowledge (Figma, Sketch, or Adobe XD).',
          'outcomes': 'Create professional UI/UX designs, conduct user research, build design systems.',
          'createdAt': Timestamp.now(),
          'isActive': true,
        },
        {
          'title': 'Data Science with Python',
          'category': 'Technology',
          'description': 'Learn data analysis, machine learning, and statistical modeling with Python.',
          'cost': 199.99,
          'duration': '10 weeks',
          'level': 'Advanced',
          'image': 'https://elements-resized.envatousercontent.com/envato-dam-assets-production/EVA/TRX/2b/0b/38/42/89/v1_E10/E107OQSH.JPG?w=1600&cf_fit=scale-down&mark-alpha=18&mark=https%3A%2F%2Felements-assets.envato.com%2Fstatic%2Fwatermark4.png&q=85&format=auto&s=65dd1c957cd287a87f8117a41cedb3edb353b9f9bfc6b1e352c9b8f94e95154c',
          'schedules': [
            {'time': 'Tue, Thu 6:30 PM', 'seats': 10, 'startDate': '2024-02-08'},
            {'time': 'Sun 11:00 AM', 'seats': 15, 'startDate': '2024-02-18'},
          ],
          'instructor': 'Dr. Emily Rodriguez',
          'topics': [
            'Python Programming',
            'Data Manipulation',
            'Statistical Analysis',
            'Machine Learning',
            'Data Visualization',
            'Deep Learning',
            'Big Data Processing',
          ],
          'requirements': 'Strong programming background, knowledge of statistics and mathematics.',
          'outcomes': 'Build ML models, analyze complex datasets, create data-driven solutions.',
          'createdAt': Timestamp.now(),
          'isActive': true,
        },
        {
          'title': 'Digital Marketing Strategy',
          'category': 'Marketing',
          'description': 'Develop comprehensive digital marketing strategies for business growth.',
          'cost': 129.99,
          'duration': '5 weeks',
          'level': 'Beginner',
          'image': 'https://elements-resized.envatousercontent.com/envato-dam-assets-production/EVA/TRX/2b/0b/38/42/89/v1_E10/E107OQSH.JPG?w=1600&cf_fit=scale-down&mark-alpha=18&mark=https%3A%2F%2Felements-assets.envato.com%2Fstatic%2Fwatermark4.png&q=85&format=auto&s=65dd1c957cd287a87f8117a41cedb3edb353b9f9bfc6b1e352c9b8f94e95154c',
          'schedules': [
            {'time': 'Wed, Fri 6:00 PM', 'seats': 22, 'startDate': '2024-02-03'},
            {'time': 'Sat 9:00 AM', 'seats': 30, 'startDate': '2024-02-20'},
          ],
          'instructor': 'Lisa Thompson',
          'topics': [
            'Marketing Fundamentals',
            'Social Media Marketing',
            'Content Marketing',
            'SEO and SEM',
            'Email Marketing',
            'Analytics and ROI',
            'Marketing Automation',
          ],
          'requirements': 'No prior experience required, basic computer skills needed.',
          'outcomes': 'Create marketing campaigns, analyze performance, drive business growth.',
          'createdAt': Timestamp.now(),
          'isActive': true,
        },
        {
          'title': 'Business Analytics',
          'category': 'Business',
          'description': 'Learn to analyze business data and make data-driven decisions.',
          'cost': 179.99,
          'duration': '7 weeks',
          'level': 'Intermediate',
          'image': 'https://elements-resized.envatousercontent.com/envato-dam-assets-production/EVA/TRX/2b/0b/38/42/89/v1_E10/E107OQSH.JPG?w=1600&cf_fit=scale-down&mark-alpha=18&mark=https%3A%2F%2Felements-assets.envato.com%2Fstatic%2Fwatermark4.png&q=85&format=auto&s=65dd1c957cd287a87f8117a41cedb3edb353b9f9bfc6b1e352c9b8f94e95154c',
          'schedules': [
            {'time': 'Mon, Thu 7:30 PM', 'seats': 16, 'startDate': '2024-02-06'},
            {'time': 'Sun 3:00 PM', 'seats': 20, 'startDate': '2024-02-25'},
          ],
          'instructor': 'David Wilson',
          'topics': [
            'Business Intelligence',
            'Data Analysis',
            'Performance Metrics',
            'Forecasting',
            'Dashboard Creation',
            'Statistical Modeling',
            'Strategic Planning',
          ],
          'requirements': 'Basic Excel knowledge, understanding of business processes.',
          'outcomes': 'Analyze business performance, create reports, make strategic decisions.',
          'createdAt': Timestamp.now(),
          'isActive': true,
        },
      ];

      // Add all sample courses to Firebase
      for (final courseData in sampleCourses) {
        await _firestore.collection(_collection).add(courseData);
      }

      print('Sample courses initialized successfully');
    } catch (e) {
      print('Error initializing sample courses: $e');
    }
  }
}
