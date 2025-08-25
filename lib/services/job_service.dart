import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/job.dart';

class JobService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'jobs';

  // Get all active jobs (simplified query to avoid index issues)
  Stream<List<Job>> getJobs() {
    return _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      final jobs = snapshot.docs.map((doc) {
        return Job.fromMap(doc.data(), doc.id);
      }).toList();
      
      // Sort locally to avoid Firestore index requirements
      jobs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return jobs;
    });
  }

  // Get jobs by category
  Stream<List<Job>> getJobsByCategory(String category) {
    return _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) {
      final jobs = snapshot.docs.map((doc) {
        return Job.fromMap(doc.data(), doc.id);
      }).toList();
      
      // Sort locally to avoid Firestore index requirements
      jobs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return jobs;
    });
  }

  // Search jobs
  Stream<List<Job>> searchJobs(String query) {
    return _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Job.fromMap(doc.data(), doc.id);
      }).where((job) {
        return job.title.toLowerCase().contains(query.toLowerCase()) ||
            job.company.toLowerCase().contains(query.toLowerCase()) ||
            job.location.toLowerCase().contains(query.toLowerCase()) ||
            job.category.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  // Get job by ID
  Future<Job?> getJobById(String jobId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(jobId).get();
      if (doc.exists) {
        return Job.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting job: $e');
      return null;
    }
  }

  // Add new job
  Future<String?> addJob(Job job) async {
    try {
      final docRef = await _firestore.collection(_collection).add(job.toMap());
      return docRef.id;
    } catch (e) {
      print('Error adding job: $e');
      return null;
    }
  }

  // Update job
  Future<bool> updateJob(String jobId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(_collection).doc(jobId).update(data);
      return true;
    } catch (e) {
      print('Error updating job: $e');
      return false;
    }
  }

  // Delete job (soft delete by setting isActive to false)
  Future<bool> deleteJob(String jobId) async {
    try {
      await _firestore.collection(_collection).doc(jobId).update({
        'isActive': false,
      });
      return true;
    } catch (e) {
      print('Error deleting job: $e');
      return false;
    }
  }

  // Initialize sample jobs in Firebase
  Future<void> initializeSampleJobs() async {
    try {
      // Check if jobs already exist
      final snapshot = await _firestore.collection(_collection).limit(1).get();
      if (snapshot.docs.isNotEmpty) {
        print('Jobs already exist, skipping initialization');
        return;
      }

      final sampleJobs = [
        {
          'title': 'Senior Flutter Developer',
          'company': 'TechCorp Solutions',
          'location': 'Bangalore',
          'type': 'Full-time',
          'salary': '₹12,00,000 - ₹18,00,000',
          'category': 'Software Development',
          'posted': '2 days ago',
          'logo': 'TC',
          'description': 'We are looking for an experienced Flutter developer to join our team and help build innovative mobile applications.',
          'requirements': [
            '5+ years of experience in mobile development',
            'Strong knowledge of Flutter and Dart',
            'Experience with state management (Provider, Bloc, Riverpod)',
            'Knowledge of REST APIs and JSON',
            'Experience with Git and version control',
          ],
          'responsibilities': [
            'Develop and maintain Flutter applications',
            'Collaborate with cross-functional teams',
            'Write clean, maintainable code',
            'Participate in code reviews',
            'Stay updated with latest Flutter trends',
          ],
          'createdAt': Timestamp.now(),
          'isActive': true,
        },
        {
          'title': 'Data Analyst',
          'company': 'DataFlow Inc',
          'location': 'Mumbai',
          'type': 'Full-time',
          'salary': '₹8,00,000 - ₹12,00,000',
          'category': 'Data Science',
          'posted': '1 day ago',
          'logo': 'DF',
          'description': 'Join our data team to analyze complex datasets and provide actionable insights for business decisions.',
          'requirements': [
            '3+ years of experience in data analysis',
            'Proficiency in SQL and Python',
            'Experience with data visualization tools',
            'Strong analytical and problem-solving skills',
            'Knowledge of statistical analysis',
          ],
          'responsibilities': [
            'Analyze large datasets to identify trends',
            'Create reports and dashboards',
            'Collaborate with business stakeholders',
            'Develop data models and algorithms',
            'Present findings to management',
          ],
          'createdAt': Timestamp.now(),
          'isActive': true,
        },
        {
          'title': 'UI/UX Designer',
          'company': 'Creative Studios',
          'location': 'Delhi',
          'type': 'Contract',
          'salary': '₹10,00,000 - ₹15,00,000',
          'category': 'Design',
          'posted': '3 days ago',
          'logo': 'CS',
          'description': 'Create beautiful and intuitive user experiences for our digital products and applications.',
          'requirements': [
            '4+ years of experience in UI/UX design',
            'Proficiency in Figma, Sketch, or Adobe XD',
            'Strong portfolio showcasing mobile and web designs',
            'Understanding of user-centered design principles',
            'Experience with design systems',
          ],
          'responsibilities': [
            'Design user interfaces for mobile and web apps',
            'Conduct user research and usability testing',
            'Create wireframes, prototypes, and mockups',
            'Collaborate with developers and product managers',
            'Maintain design consistency across products',
          ],
          'createdAt': Timestamp.now(),
          'isActive': true,
        },
        {
          'title': 'Marketing Manager',
          'company': 'Growth Marketing',
          'location': 'Hyderabad',
          'type': 'Full-time',
          'salary': '₹9,00,000 - ₹14,00,000',
          'category': 'Marketing',
          'posted': '5 days ago',
          'logo': 'GM',
          'description': 'Lead our marketing initiatives and drive growth through strategic campaigns and digital marketing.',
          'requirements': [
            '5+ years of experience in digital marketing',
            'Experience with Google Ads, Facebook Ads, and SEO',
            'Strong analytical skills and data-driven approach',
            'Experience with marketing automation tools',
            'Excellent communication and leadership skills',
          ],
          'responsibilities': [
            'Develop and execute marketing strategies',
            'Manage digital advertising campaigns',
            'Analyze campaign performance and optimize ROI',
            'Lead the marketing team and coordinate with other departments',
            'Stay updated with latest marketing trends',
          ],
          'createdAt': Timestamp.now(),
          'isActive': true,
        },
        {
          'title': 'Sales Representative',
          'company': 'SalesForce Pro',
          'location': 'Chennai',
          'type': 'Full-time',
          'salary': '₹6,00,000 - ₹10,00,000',
          'category': 'Sales',
          'posted': '1 week ago',
          'logo': 'SP',
          'description': 'Join our sales team to drive revenue growth and build strong customer relationships.',
          'requirements': [
            '2+ years of experience in B2B sales',
            'Strong negotiation and communication skills',
            'Experience with CRM systems',
            'Ability to meet and exceed sales targets',
            'Willingness to travel for client meetings',
          ],
          'responsibilities': [
            'Generate new business opportunities',
            'Build and maintain client relationships',
            'Present product demonstrations to prospects',
            'Negotiate contracts and close deals',
            'Provide regular sales reports and forecasts',
          ],
          'createdAt': Timestamp.now(),
          'isActive': true,
        },
        {
          'title': 'Customer Success Manager',
          'company': 'Support Hub',
          'location': 'Pune',
          'type': 'Full-time',
          'salary': '₹7,00,000 - ₹12,00,000',
          'category': 'Customer Service',
          'posted': '4 days ago',
          'logo': 'SH',
          'description': 'Ensure customer satisfaction and success by providing excellent support and building long-term relationships.',
          'requirements': [
            '3+ years of experience in customer success or support',
            'Excellent communication and problem-solving skills',
            'Experience with customer support tools and CRM systems',
            'Ability to handle difficult customer situations',
            'Strong empathy and customer-focused mindset',
          ],
          'responsibilities': [
            'Onboard new customers and ensure smooth adoption',
            'Provide ongoing support and training',
            'Monitor customer health and identify upsell opportunities',
            'Collect and analyze customer feedback',
            'Work with product team to improve customer experience',
          ],
          'createdAt': Timestamp.now(),
          'isActive': true,
        },
      ];

      // Add all sample jobs to Firebase
      for (final jobData in sampleJobs) {
        await _firestore.collection(_collection).add(jobData);
      }

      print('Sample jobs initialized successfully');
    } catch (e) {
      print('Error initializing sample jobs: $e');
    }
  }
}
