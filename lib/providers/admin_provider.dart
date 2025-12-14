import 'package:flutter/material.dart';
import 'package:learn_work/models/traning.dart';
import 'package:learn_work/models/job.dart';
import 'package:learn_work/models/user.dart';
import 'package:learn_work/services/admin_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:learn_work/services/notification_service.dart';

class AdminProvider extends ChangeNotifier {
  final AdminService _adminService = AdminService();
  final NotificationService _notificationService = NotificationService();
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

  List<Job> _jobs = [];
  List<Training> _trainings = [];
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

      final trainings =
          snapshot.docs.map((doc) {
            try {
              final data = doc.data();
              data['id'] = doc.id; // Add the document ID to the data
              return Training.fromJson(data);
            } catch (parseError) {
              print('Error parsing training document ${doc.id}: $parseError');
              print('Document data: ${doc.data()}');
              // Return a default training object for corrupted documents
              return Training(
                id: doc.id,
                title: 'Error Loading Course',
                description: 'This course could not be loaded properly',
                price: 0.0,
                schedules: [],
                createdAt: DateTime.now(),
              );
            }
          }).toList();

      if (!_disposed) {
        _trainings = trainings;
        // Sort by creation date (newest first)
        _trainings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        print('AdminProvider: Loaded ${_trainings.length} trainings');
        notifyListeners();
      }
    } catch (e) {
      print('AdminProvider: Error loading trainings: $e');
      _errorMessage = 'Failed to load trainings: $e';
      if (!_disposed) {
        notifyListeners();
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
      // Delete from Firestore (soft delete by setting isActive to false)
      await _firestore.collection('jobs').doc(jobId).update({
        'isActive': false,
      });
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

  Future<void> addTraining(Training training) async {
    try {
      print('Adding training: ${training.id}');
      print('Training data: ${training.toJson()}');

      // Add to Firestore
      final docRef = await _firestore
          .collection('courses')
          .add(training.toJson());
      print('Successfully added training to Firestore with ID: ${docRef.id}');

      // Update local state with the new training (including the generated ID)
      final newTraining = training.copyWith(id: docRef.id);
      _trainings.add(newTraining);
      print('Added training to local state');

      if (!_disposed) {
        notifyListeners();
        print('Notified listeners of training addition');
      }
    } catch (e) {
      print('Error adding training: $e');
      _errorMessage = 'Failed to add training: $e';
      if (!_disposed) {
        notifyListeners();
      }
      rethrow; // Re-throw to let the UI handle the error
    }
  }

  Future<void> updateTraining(Training training) async {
    try {
      print('Updating training: ${training.id}');
      print('Training data: ${training.toJson()}');

      // Update in Firestore
      await _firestore
          .collection('courses')
          .doc(training.id)
          .update(training.toJson());
      print('Successfully updated training in Firestore');

      // Update local state
      final index = _trainings.indexWhere((t) => t.id == training.id);
      if (index != -1) {
        _trainings[index] = training;
        print('Updated training in local state at index: $index');
      } else {
        print('Warning: Training not found in local state, adding it');
        _trainings.add(training);
      }

      if (!_disposed) {
        notifyListeners();
        print('Notified listeners of training update');
      }
    } catch (e) {
      print('Error updating training: $e');
      _errorMessage = 'Failed to update training: $e';
      if (!_disposed) {
        notifyListeners();
      }
      rethrow; // Re-throw to let the UI handle the error
    }
  }

  Future<void> deleteTraining(String trainingId) async {
    try {
      print(
        'AdminProvider: Starting training deletion - trainingId: $trainingId',
      );
      print('AdminProvider: Current trainings count: ${_trainings.length}');

      // Find the training index before deletion
      final trainingIndex = _trainings.indexWhere((t) => t.id == trainingId);
      print('AdminProvider: Found training at index: $trainingIndex');

      if (trainingIndex != -1) {
        // Delete from Firestore first
        await _firestore.collection('courses').doc(trainingId).delete();
        print('AdminProvider: Training deleted from Firestore successfully');

        // Remove from local state
        _trainings.removeAt(trainingIndex);
        print(
          'AdminProvider: Training removed from local state. New count: ${_trainings.length}',
        );

        // Notify listeners immediately
        if (!_disposed) {
          print('AdminProvider: Notifying listeners after deletion');
          notifyListeners();

          // Also verify that the training was actually removed
          final remainingTraining = _trainings.any((t) => t.id == trainingId);
          if (remainingTraining) {
            print(
              'AdminProvider: WARNING - Training still exists in local state after deletion!',
            );
          } else {
            print(
              'AdminProvider: Training successfully removed from local state',
            );
          }
        }

        print('AdminProvider: Training deletion completed successfully');
      } else {
        print('AdminProvider: Training not found with ID: $trainingId');
        throw Exception('Training not found in local state');
      }
    } catch (e) {
      print('AdminProvider: Error deleting training: $e');
      _errorMessage = 'Failed to delete training: $e';
      if (!_disposed) {
        notifyListeners();
      }
      rethrow; // Re-throw the error so the calling code can handle it
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

  Future<void> uploadNote(
    String trainingId,
    String scheduleId,
    Note note,
  ) async {
    try {
      final trainingIndex = _trainings.indexWhere((t) => t.id == trainingId);
      if (trainingIndex != -1) {
        final scheduleIndex = _trainings[trainingIndex].schedules.indexWhere(
          (s) => s.id == scheduleId,
        );
        if (scheduleIndex != -1) {
          // Add to local state first
          _trainings[trainingIndex].schedules[scheduleIndex].notes.add(note);

          // Update in Firestore
          final updatedSchedules =
              _trainings[trainingIndex].schedules
                  .map((s) => s.toJson())
                  .toList();
          await _firestore.collection('courses').doc(trainingId).update({
            'schedules': updatedSchedules,
          });

          if (!_disposed) {
            notifyListeners();
          }
        }
      }
    } catch (e) {
      print('Error uploading note: $e');
      _errorMessage = 'Failed to upload note: $e';
      if (!_disposed) {
        notifyListeners();
      }
    }
  }

  Future<void> sendMessage(
    String trainingId,
    String scheduleId,
    Message message,
  ) async {
    try {
      final trainingIndex = _trainings.indexWhere((t) => t.id == trainingId);
      if (trainingIndex != -1) {
        final scheduleIndex = _trainings[trainingIndex].schedules.indexWhere(
          (s) => s.id == scheduleId,
        );
        if (scheduleIndex != -1) {
          // Add to local state first
          _trainings[trainingIndex].schedules[scheduleIndex].messages.add(
            message,
          );

          // Update in Firestore
          final updatedSchedules =
              _trainings[trainingIndex].schedules
                  .map((s) => s.toJson())
                  .toList();
          await _firestore.collection('courses').doc(trainingId).update({
            'schedules': updatedSchedules,
          });

          if (!_disposed) {
            notifyListeners();
          }
        }
      }
    } catch (e) {
      print('Error sending message: $e');
      _errorMessage = 'Failed to send message: $e';
      if (!_disposed) {
        notifyListeners();
      }
    }
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

        // Remove from local state first
        final initialCount = training.schedules.length;
        training.schedules.removeWhere((s) => s.id == scheduleId);
        final finalCount = training.schedules.length;
        print(
          'AdminProvider: Removed ${initialCount - finalCount} schedules from local state',
        );
        print(
          'AdminProvider: Training now has ${training.schedules.length} schedules',
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

        print('AdminProvider: Schedule deletion completed successfully');
      } else {
        print('AdminProvider: Training not found with ID: $trainingId');
      }
    } catch (e) {
      print('AdminProvider: Error deleting schedule: $e');
      _errorMessage = 'Failed to delete schedule: $e';
      if (!_disposed) {
        notifyListeners();
      }
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
