import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/job.dart';

class JobService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'jobs';

  // Get all active jobs (limit 50 for safety since we're fetching all)
  Stream<List<Job>> getJobs() {
    return _firestore.collection(_collection).snapshots().map((snapshot) {
      final jobs =
          snapshot.docs
              .map((doc) {
                return Job.fromMap(doc.data(), doc.id);
              })
              .where((job) {
                final isExpired =
                    job.deadline != null &&
                    job.deadline!.isBefore(DateTime.now());
                return job.isActive && !isExpired;
              })
              .toList();

      // Sort locally to avoid Firestore index requirements
      jobs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return jobs;
    });
  }

  // Get jobs by category
  Stream<List<Job>> getJobsByCategory(String category) {
    return _firestore
        .collection(_collection)
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) {
          final jobs =
              snapshot.docs
                  .map((doc) {
                    return Job.fromMap(doc.data(), doc.id);
                  })
                  .where((job) {
                    final isExpired =
                        job.deadline != null &&
                        job.deadline!.isBefore(DateTime.now());
                    return job.isActive && !isExpired;
                  })
                  .toList();

          // Sort locally to avoid Firestore index requirements
          jobs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return jobs;
        });
  }

  // Search jobs
  Stream<List<Job>> searchJobs(String query) {
    return _firestore.collection(_collection).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) {
            return Job.fromMap(doc.data(), doc.id);
          })
          .where((job) {
            final isExpired =
                job.deadline != null && job.deadline!.isBefore(DateTime.now());
            if (!job.isActive || isExpired) return false;

            return job.title.toLowerCase().contains(query.toLowerCase()) ||
                job.company.toLowerCase().contains(query.toLowerCase()) ||
                job.location.toLowerCase().contains(query.toLowerCase()) ||
                job.category.toLowerCase().contains(query.toLowerCase());
          })
          .toList();
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
      await _firestore.collection(_collection).doc(jobId).delete();
      return true;
    } catch (e) {
      print('Error deleting job: $e');
      return false;
    }
  }
}
