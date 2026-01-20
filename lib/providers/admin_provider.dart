import 'package:flutter/material.dart';
import 'package:learn_work/models/traning.dart';
import 'package:learn_work/models/course.dart';
import 'package:learn_work/models/job.dart';
import 'package:learn_work/models/user.dart';
import 'package:learn_work/models/assessment_model.dart';
import 'package:learn_work/services/admin_service.dart';
import 'package:learn_work/services/assessment_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:learn_work/services/notification_service.dart';

class AdminProvider extends ChangeNotifier {
  final AdminService _adminService = AdminService();
  final NotificationService _notificationService = NotificationService();
  final AssessmentService _assessmentService = AssessmentService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ... existing code ...

  Future<void> addJob(Job job) async {
    try {
      setState(isLoading: true, errorMessage: null);

      // Add to Firestore
      final docRef = await _firestore.collection('jobs').add(job.toMap());

      // Update local state with the new job (including the generated ID)
      final newJob = job.copyWith(id: docRef.id);
      _jobs.add(newJob);

      // Refresh the jobs list to ensure consistency
      await loadJobs();

      // Send notifications to subscribed students
      // We do this asynchronously and don't await/block the UI success for it
      _notificationService.sendJobNotificationToSubscribers(
        jobTitle: job.title,
        companyName: job.company,
        jobId: docRef.id,
      );
    } catch (e) {
      print('Error adding job: $e');
      _errorMessage = 'Failed to add job: $e';
      if (!_disposed) {
        notifyListeners();
      }
      throw e; // Re-throw to let the UI handle the error
    } finally {
      if (!_disposed) {
        setState(isLoading: false);
      }
    }
  }

  Future<void> addJobs(List<Job> newJobs) async {
    try {
      setState(isLoading: true, errorMessage: null);

      final batch = _firestore.batch();
      for (final job in newJobs) {
        // Create a new document reference to get an ID
        final docRef = _firestore.collection('jobs').doc();
        // Create job with new ID
        final jobWithId = job.copyWith(id: docRef.id);
        batch.set(docRef, jobWithId.toMap());
      }

      await batch.commit();

      // Refresh the jobs list to ensure consistency
      await loadJobs();
    } catch (e) {
      print('Error adding jobs batch: $e');
      _errorMessage = 'Failed to add jobs batch: $e';
      if (!_disposed) {
        notifyListeners();
      }
      throw e;
    } finally {
      if (!_disposed) {
        setState(isLoading: false);
      }
    }
  }

  List<Job> _jobs = [];
  List<Training> _trainings = [];
  List<Course> _courses = [];
  List<AssessmentModel> _assessments = [];
  List<UserModel> _adminUsers = [];
  List<UserModel> _allStudents = [];
  int _selectedIndex = 0;

  // Authentication state
  User? _currentAdminUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _disposed = false;

  // Getters
  List<Job> get jobs => _jobs;
  List<Training> get trainings => _trainings;
  List<Course> get courses => _courses;
  List<AssessmentModel> get assessments => _assessments;
  List<UserModel> get adminUsers => _adminUsers;
  List<UserModel> get allStudents => _allStudents;
  int get selectedIndex => _selectedIndex;
  User? get currentAdminUser => _currentAdminUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentAdminUser != null;

  // Initialize the provider
  AdminProvider() {
    _initializeAdminState();
    // Remove hardcoded sample data initialization
  }

  // Initialize admin authentication state
  void _initializeAdminState() {
    _adminService.adminAuthStateChanges.listen((User? user) {
      // Check if provider is still active before updating state
      if (!_disposed) {
        _currentAdminUser = user;
        if (user != null) {
          _loadAdminData();
        } else {
          _clearAdminData();
        }
        notifyListeners();
      }
    });
  }

  // Load admin data from Firebase
  Future<void> _loadAdminData() async {
    if (_currentAdminUser == null) return;

    setState(isLoading: true, errorMessage: null);

    try {
      // Load admin users (don't fail completely if this fails)
      try {
        await loadAdminUsers();
      } catch (e) {
        print('Warning: Failed to load admin users: $e');
        // Don't set error message for this, just log it
      }

      // Load all students (don't fail completely if this fails)
      try {
        await loadAllStudents();
      } catch (e) {
        print('Warning: Failed to load students: $e');
        // Don't set error message for this, just log it
      }

      // Load jobs and trainings from Firestore
      await loadJobs();
      await loadTrainings();
      await loadAssessments();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      setState(isLoading: false);
    }
  }

  // Load jobs from Firestore
  Future<void> loadJobs() async {
    try {
      final jobsStream = _firestore.collection('jobs').snapshots().map((
        snapshot,
      ) {
        return snapshot.docs.map((doc) {
          return Job.fromMap(doc.data(), doc.id);
        }).toList();
      });

      jobsStream.listen((jobs) {
        if (!_disposed) {
          _jobs = jobs;

          // Check for expired jobs and deactivate them
          final now = DateTime.now();
          for (final job in jobs) {
            if (job.isActive && job.deadline != null) {
              // Check if the deadline has passed (is before now)
              // We compare date parts to avoid issues with time of day if needed,
              // but typically exact comparison is fine.
              // If deadline is today (any time), it should probably still be active until the end of the day?
              // Or if deadline is a specific time. Assuming deadline is just a date usually set to 00:00:00.
              // If deadline is 14th Dec 00:00, and now is 14th Dec 08:00, it is passed.
              // If the user meant "deadline is inclusive", we might need to check if now is after deadline + 1 day.
              // Usually "deadline" means "due by". If passed, it's late.
              // Let's assume strict comparison for now.
              if (job.deadline!.isBefore(now)) {
                print(
                  'Auto-deactivating expired job: ${job.title} (${job.id})',
                );
                // We don't await this to avoid blocking the UI update
                // The update will trigger a new snapshot
                _firestore
                    .collection('jobs')
                    .doc(job.id)
                    .update({'isActive': false})
                    .catchError((e) => print('Error deactivating job: $e'));
              }
            }
          }

          // Sort by creation date (newest first)
          _jobs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          notifyListeners();
        }
      });
    } catch (e) {
      print('Error loading jobs: $e');
      _errorMessage = 'Failed to load jobs: $e';
      if (!_disposed) {
        notifyListeners();
      }
    }
  }

  // Load trainings from Firestore
  Future<void> loadTrainings() async {
    try {
      print('AdminProvider: Starting loadTrainings');

      // Get a one-time snapshot instead of using a stream
      final snapshot = await _firestore.collection('courses').get();

      final trainingsList = <Training>[];
      final coursesList = <Course>[];

      for (var doc in snapshot.docs) {
        try {
          final data = doc.data();
          data['id'] = doc.id;

          // Map to Training for legacy support
          trainingsList.add(Training.fromJson(data));

          // Map to Course for modern UI
          coursesList.add(Course.fromMap(data, doc.id));
        } catch (parseError) {
          print('Error parsing document ${doc.id}: $parseError');
        }
      }

      if (!_disposed) {
        _trainings = trainingsList;
        _courses = coursesList;

        // Sort both
        _trainings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        _courses.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        notifyListeners();
      }
    } catch (e) {
      print('Error loading trainings: $e');
      _errorMessage = 'Failed to load trainings: $e';
      if (!_disposed) {
        notifyListeners();
      }
    }
  }

  Future<int> addCourses(List<Course> newCourses) async {
    try {
      setState(isLoading: true, errorMessage: null);

      // Get existing course titles to skip duplicates
      final snapshot = await _firestore.collection('courses').get();
      final existingTitles =
          snapshot.docs
              .map((doc) => doc.data()['title'].toString().toLowerCase().trim())
              .toSet();

      final batch = _firestore.batch();
      int addedCount = 0;

      for (final course in newCourses) {
        final normalizedTitle = course.title.toLowerCase().trim();
        if (!existingTitles.contains(normalizedTitle)) {
          final docRef = _firestore.collection('courses').doc();
          batch.set(docRef, course.toMap());
          existingTitles.add(
            normalizedTitle,
          ); // Avoid duplicates within the same batch
          addedCount++;
        }
      }

      if (addedCount > 0) {
        await batch.commit();
        await loadTrainings(); // Refresh both lists
      }
      return addedCount;
    } catch (e) {
      print('Error adding courses batch: $e');
      _errorMessage = 'Failed to add courses batch: $e';
      if (!_disposed) {
        notifyListeners();
      }
      rethrow;
    } finally {
      if (!_disposed) {
        setState(isLoading: false);
      }
    }
  }

  // Clear admin data when signing out
  void _clearAdminData() {
    _adminUsers.clear();
    _allStudents.clear();
    _jobs.clear();
    _trainings.clear();
    _errorMessage = null;
    if (!_disposed) {
      notifyListeners();
    }
  }

  // Set loading state
  void setState({bool? isLoading, String? errorMessage}) {
    if (isLoading != null) _isLoading = isLoading;
    if (errorMessage != null) _errorMessage = errorMessage;
    if (!_disposed) {
      notifyListeners();
    }
  }

  // Load admin users from Firebase
  Future<void> loadAdminUsers() async {
    try {
      _adminUsers = await _adminService.getAllAdminUsers();
      if (!_disposed) {
        notifyListeners();
      }
    } catch (e) {
      print('Warning: Failed to load admin users: $e');
      // Don't set error message, just log it
      // This prevents login failures due to admin user list loading issues
    }
  }

  // Load all students from Firebase
  Future<void> loadAllStudents() async {
    try {
      _allStudents = await _adminService.getAllStudents();
      if (!_disposed) {
        notifyListeners();
      }
    } catch (e) {
      print('Warning: Failed to load students: $e');
      // Don't set error message for this, just log it
    }
  }

  // Update user job alerts
  Future<void> updateUserJobAlerts(String userId, bool jobAlerts) async {
    try {
      await _adminService.updateUserJobAlerts(userId, jobAlerts);
      // Refresh the students list to get updated data
      await loadAllStudents();
    } catch (e) {
      print('Error updating user job alerts: $e');
      _errorMessage = 'Failed to update user job alerts: $e';
      if (!_disposed) {
        notifyListeners();
      }
    }
  }

  // Sign in admin
  Future<bool> signInAdmin(String email, String password) async {
    setState(isLoading: true, errorMessage: null);

    try {
      print('🔐 AdminProvider: Attempting to sign in admin...');
      await _adminService.signInAdminWithEmailAndPassword(email, password);
      print('🔐 AdminProvider: Admin sign in successful');
      return true;
    } catch (e) {
      print('🔐 AdminProvider: Admin sign in failed: $e');
      _errorMessage = e.toString();
      if (!_disposed) {
        notifyListeners();
      }
      return false;
    } finally {
      setState(isLoading: false);
    }
  }

  // Sign out admin
  Future<void> signOutAdmin() async {
    setState(isLoading: true);

    try {
      await _adminService.signOutAdmin();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      setState(isLoading: false);
    }
  }

  // Create new admin user
  Future<bool> createAdminUser(
    String email,
    String password,
    String firstName,
    String lastName,
  ) async {
    setState(isLoading: true, errorMessage: null);

    try {
      await _adminService.createAdminUser(email, password, firstName, lastName);
      await loadAdminUsers(); // Refresh the list
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      if (!_disposed) {
        notifyListeners();
      }
      return false;
    } finally {
      setState(isLoading: false);
    }
  }

  // Update admin user role
  Future<bool> changeUserRole(String userId, String newRole) async {
    setState(isLoading: true, errorMessage: null);

    try {
      await _adminService.changeUserRole(userId, newRole);
      await loadAdminUsers(); // Refresh the list
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      if (!_disposed) {
        notifyListeners();
      }
      return false;
    } finally {
      setState(isLoading: false);
    }
  }

  // Delete admin user
  Future<bool> deleteAdminUser(String userId) async {
    setState(isLoading: true, errorMessage: null);

    try {
      await _adminService.deleteAdminUser(userId);
      await loadAdminUsers(); // Refresh the list
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      if (!_disposed) {
        notifyListeners();
      }
      return false;
    } finally {
      setState(isLoading: false);
    }
  }

  // Update admin profile
  Future<bool> updateAdminProfile({
    String? firstName,
    String? lastName,
    String? photoUrl,
    String? bio,
  }) async {
    setState(isLoading: true, errorMessage: null);

    try {
      await _adminService.updateAdminProfile(
        firstName: firstName,
        lastName: lastName,
        photoUrl: photoUrl,
        bio: bio,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      if (!_disposed) {
        notifyListeners();
      }
      return false;
    } finally {
      setState(isLoading: false);
    }
  }

  // Reset admin password
  Future<bool> resetAdminPassword(String email) async {
    setState(isLoading: true, errorMessage: null);

    try {
      await _adminService.resetAdminPassword(email);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      if (!_disposed) {
        notifyListeners();
      }
      return false;
    } finally {
      setState(isLoading: false);
    }
  }

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    if (!_disposed) {
      notifyListeners();
    }
  }

  Future<void> updateJob(Job job) async {
    try {
      setState(isLoading: true, errorMessage: null);

      // Update in Firestore
      await _firestore.collection('jobs').doc(job.id).update(job.toMap());

      // Update local state
      final index = _jobs.indexWhere((j) => j.id == job.id);
      if (index != -1) {
        _jobs[index] = job;
      } else {
        // If job not found in local state, add it
        _jobs.add(job);
      }

      // Refresh the jobs list to ensure consistency
      await loadJobs();
    } catch (e) {
      print('Error updating job: $e');
      _errorMessage = 'Failed to update job: $e';
      if (!_disposed) {
        notifyListeners();
      }
      throw e; // Re-throw to let the UI handle the error
    } finally {
      if (!_disposed) {
        setState(isLoading: false);
      }
    }
  }

  Future<void> deleteJob(String jobId) async {
    try {
      // Delete from Firestore
      await _firestore.collection('jobs').doc(jobId).delete();
      // Remove from local state
      _jobs.removeWhere((job) => job.id == jobId);
      if (!_disposed) {
        notifyListeners();
      }
    } catch (e) {
      print('Error deleting job: $e');
      _errorMessage = 'Failed to delete job: $e';
      if (!_disposed) {
        notifyListeners();
      }
    }
  }

  Future<void> deleteTraining(String trainingId) async {
    try {
      print(
        'AdminProvider: Starting training deletion - trainingId: $trainingId',
      );

      // Delete from Firestore first
      await _firestore.collection('courses').doc(trainingId).delete();
      print('AdminProvider: Training deleted from Firestore successfully');

      // Refresh the list
      await loadTrainings();

      if (!_disposed) {
        notifyListeners();
      }
    } catch (e) {
      print('AdminProvider: Error deleting training: $e');
      _errorMessage = 'Failed to delete training: $e';
      if (!_disposed) {
        notifyListeners();
      }
      rethrow;
    }
  }

  Future<void> addScheduleToTraining(
    String trainingId,
    TrainingSchedule schedule,
  ) async {
    try {
      print(
        'AdminProvider: Starting schedule addition - trainingId: $trainingId, scheduleId: ${schedule.id}',
      );
      print('AdminProvider: Current trainings count: ${_trainings.length}');

      final trainingIndex = _trainings.indexWhere((t) => t.id == trainingId);
      print('AdminProvider: Found training at index: $trainingIndex');

      if (trainingIndex != -1) {
        final training = _trainings[trainingIndex];
        print(
          'AdminProvider: Training has ${training.schedules.length} schedules before addition',
        );

        // Add to local state first
        training.schedules.add(schedule);
        print(
          'AdminProvider: Added schedule to local state. Training now has ${training.schedules.length} schedules',
        );

        // Update in Firestore
        final updatedSchedules =
            training.schedules.map((s) => s.toJson()).toList();
        print(
          'AdminProvider: Updating Firestore with ${updatedSchedules.length} schedules',
        );

        await _firestore.collection('courses').doc(trainingId).update({
          'schedules': updatedSchedules,
        });

        print('AdminProvider: Firestore updated successfully');

        if (!_disposed) {
          print('AdminProvider: Notifying listeners');
          notifyListeners();
        }

        print('AdminProvider: Schedule addition completed successfully');
      } else {
        print('AdminProvider: Training not found with ID: $trainingId');
      }
    } catch (e) {
      print('AdminProvider: Error adding schedule: $e');
      _errorMessage = 'Failed to add schedule: $e';
      if (!_disposed) {
        notifyListeners();
      }
    }
  }

  void sendJobNotifications() {
    // This would typically integrate with an email service
    // For now, we'll just show a success message
    print('Job notifications sent to all subscribed students');
  }

  Future<void> deleteScheduleFromTraining(
    String trainingId,
    String scheduleId,
  ) async {
    try {
      print(
        'AdminProvider: Starting schedule deletion - trainingId: $trainingId, scheduleId: $scheduleId',
      );
      print('AdminProvider: Current trainings count: ${_trainings.length}');

      final trainingIndex = _trainings.indexWhere((t) => t.id == trainingId);
      print('AdminProvider: Found training at index: $trainingIndex');

      if (trainingIndex != -1) {
        final training = _trainings[trainingIndex];
        print(
          'AdminProvider: Training has ${training.schedules.length} schedules before deletion',
        );

        // Remove from local state
        final scheduleIndex = training.schedules.indexWhere(
          (s) => s.id == scheduleId,
        );
        if (scheduleIndex != -1) {
          training.schedules.removeAt(scheduleIndex);
          print('AdminProvider: Removed schedule from local state');

          // Update in Firestore
          final updatedSchedules =
              training.schedules.map((s) => s.toJson()).toList();
          await _firestore.collection('courses').doc(trainingId).update({
            'schedules': updatedSchedules,
          });
          print('AdminProvider: Firestore updated successfully');

          if (!_disposed) {
            notifyListeners();
          }
        }
      }
    } catch (e) {
      print('Error deleting schedule: $e');
      _errorMessage = 'Failed to delete schedule: $e';
      if (!_disposed) {
        notifyListeners();
      }
    }
  }

  // Load assessments
  Future<void> loadAssessments() async {
    try {
      _assessmentService.getAssessments().listen((assessments) {
        if (!_disposed) {
          _assessments = assessments;
          notifyListeners();
        }
      });
    } catch (e) {
      print('Error loading assessments: $e');
      _errorMessage = 'Failed to load assessments: $e';
      if (!_disposed) notifyListeners();
    }
  }

  // Add assessment
  Future<bool> addAssessment(AssessmentModel assessment) async {
    try {
      setState(isLoading: true, errorMessage: null);

      // Check for duplicate
      final snapshot =
          await _firestore
              .collection('assessments')
              .where('setName', isEqualTo: assessment.setName)
              .where('title', isEqualTo: assessment.title)
              .get();

      if (snapshot.docs.isNotEmpty) {
        return false; // Duplicate found
      }

      await _assessmentService.addAssessment(assessment);
      return true;
    } catch (e) {
      print('Error adding assessment: $e');
      _errorMessage = 'Failed to add assessment: $e';
      if (!_disposed) notifyListeners();
      return false;
    } finally {
      setState(isLoading: false);
    }
  }

  Future<int> addAssessments(List<AssessmentModel> newAssessments) async {
    try {
      setState(isLoading: true, errorMessage: null);

      // Get existing assessments for the sets being added to skip duplicates
      final setNames = newAssessments.map((a) => a.setName).toSet();
      final Map<String, Set<String>> existingBySet = {};

      for (String setName in setNames) {
        final snapshot =
            await _firestore
                .collection('assessments')
                .where('setName', isEqualTo: setName)
                .get();

        existingBySet[setName] =
            snapshot.docs
                .map(
                  (doc) => doc.data()['title'].toString().toLowerCase().trim(),
                )
                .toSet();
      }

      final batch = _firestore.batch();
      int addedCount = 0;

      for (final assessment in newAssessments) {
        final normalizedTitle = assessment.title.toLowerCase().trim();
        final setName = assessment.setName;

        if (!(existingBySet[setName]?.contains(normalizedTitle) ?? false)) {
          final docRef = _firestore.collection('assessments').doc();
          batch.set(docRef, assessment.toMap());

          // Track within the batch to avoid duplicates in the same file
          if (!existingBySet.containsKey(setName)) {
            existingBySet[setName] = {};
          }
          existingBySet[setName]!.add(normalizedTitle);
          addedCount++;
        }
      }

      if (addedCount > 0) {
        await batch.commit();
      }
      return addedCount;
    } catch (e) {
      print('Error adding assessments batch: $e');
      _errorMessage = 'Failed to add assessments batch: $e';
      if (!_disposed) {
        notifyListeners();
      }
      rethrow;
    } finally {
      if (!_disposed) {
        setState(isLoading: false);
      }
    }
  }

  // Delete assessment
  Future<void> deleteAssessment(String assessmentId) async {
    try {
      await _assessmentService.deleteAssessment(assessmentId);
    } catch (e) {
      print('Error deleting assessment: $e');
      _errorMessage = 'Failed to delete assessment: $e';
      if (!_disposed) notifyListeners();
    }
  }

  Future<void> updateScheduleInTraining(
    String trainingId,
    TrainingSchedule updatedSchedule,
  ) async {
    try {
      print(
        'AdminProvider: Starting schedule update - trainingId: $trainingId, scheduleId: ${updatedSchedule.id}',
      );
      print('AdminProvider: Current trainings count: ${_trainings.length}');

      final trainingIndex = _trainings.indexWhere((t) => t.id == trainingId);
      print('AdminProvider: Found training at index: $trainingIndex');

      if (trainingIndex != -1) {
        final training = _trainings[trainingIndex];
        print(
          'AdminProvider: Training has ${training.schedules.length} schedules',
        );

        final scheduleIndex = training.schedules.indexWhere(
          (s) => s.id == updatedSchedule.id,
        );
        print('AdminProvider: Found schedule at index: $scheduleIndex');

        if (scheduleIndex != -1) {
          // Update local state first
          training.schedules[scheduleIndex] = updatedSchedule;
          print('AdminProvider: Updated schedule in local state');

          // Update in Firestore
          final updatedSchedules =
              training.schedules.map((s) => s.toJson()).toList();
          print(
            'AdminProvider: Updating Firestore with ${updatedSchedules.length} schedules',
          );

          await _firestore.collection('courses').doc(trainingId).update({
            'schedules': updatedSchedules,
          });

          print('AdminProvider: Firestore updated successfully');

          if (!_disposed) {
            print('AdminProvider: Notifying listeners');
            notifyListeners();
          }

          print('AdminProvider: Schedule update completed successfully');
        } else {
          print(
            'AdminProvider: Schedule not found with ID: ${updatedSchedule.id}',
          );
        }
      } else {
        print('AdminProvider: Training not found with ID: $trainingId');
      }
    } catch (e) {
      print('AdminProvider: Error updating schedule: $e');
      _errorMessage = 'Failed to update schedule: $e';
      if (!_disposed) {
        notifyListeners();
      }
    }
  }

  // Clear error message
  void clearError() {
    if (!_disposed) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
