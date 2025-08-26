import 'package:flutter/material.dart';
import 'package:learn_work/models/traning.dart';
import 'package:learn_work/models/job.dart';

class AdminProvider extends ChangeNotifier {
  List<Job> _jobs = [];
  List<Training> _trainings = [];
  int _selectedIndex = 0;

  List<Job> get jobs => _jobs;
  List<Training> get trainings => _trainings;
  int get selectedIndex => _selectedIndex;

  // Sample data for demonstration
  AdminProvider() {
    _initializeSampleData();
  }

  void _initializeSampleData() {
    // Sample jobs
    _jobs = [
      Job(
        id: '1',
        title: 'Flutter Developer',
        company: 'Tech Corp',
        location: 'New York',
        type: 'Full-time',
        salary: '\$80,000 - \$120,000',
        category: 'Development',
        posted: '2 days ago',
        logo: 'https://example.com/logo1.png',
        description: 'We are looking for a skilled Flutter developer...',
        requirements: ['Flutter', 'Dart', 'Mobile Development'],
        responsibilities: ['Develop mobile apps', 'Code review', 'Team collaboration'],
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        isActive: true,
      ),
      Job(
        id: '2',
        title: 'UI/UX Designer',
        company: 'Design Studio',
        location: 'San Francisco',
        type: 'Full-time',
        salary: '\$70,000 - \$100,000',
        category: 'Design',
        posted: '1 day ago',
        logo: 'https://example.com/logo2.png',
        description: 'Creative designer needed for mobile app projects...',
        requirements: ['UI/UX Design', 'Figma', 'Prototyping'],
        responsibilities: ['Design interfaces', 'User research', 'Prototype creation'],
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        isActive: true,
      ),
    ];

    // Sample trainings
    _trainings = [
      Training(
        id: '1',
        title: 'Flutter Development Course',
        description: 'Learn Flutter from basics to advanced concepts',
        price: 299.99,
        schedules: [
          TrainingSchedule(
            id: '1',
            startDate: DateTime.now().add(const Duration(days: 7)),
            endDate: DateTime.now().add(const Duration(days: 14)),
            time: const TimeOfDay(hour: 10, minute: 0),
            capacity: 20,
            enrolledStudents: [
              EnrolledStudent(
                id: '1',
                name: 'John Doe',
                email: 'john@example.com',
                enrolledDate: DateTime.now().subtract(const Duration(days: 3)),
                isSubscribedToJobs: true,
              ),
              EnrolledStudent(
                id: '2',
                name: 'Jane Smith',
                email: 'jane@example.com',
                enrolledDate: DateTime.now().subtract(const Duration(days: 2)),
                isSubscribedToJobs: false,
              ),
            ],
            notes: [],
            messages: [],
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
    ];
  }

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void addJob(Job job) {
    _jobs.add(job);
    notifyListeners();
  }

  void updateJob(Job job) {
    final index = _jobs.indexWhere((j) => j.id == job.id);
    if (index != -1) {
      _jobs[index] = job;
      notifyListeners();
    }
  }

  void deleteJob(String jobId) {
    _jobs.removeWhere((job) => job.id == jobId);
    notifyListeners();
  }

  void addTraining(Training training) {
    _trainings.add(training);
    notifyListeners();
  }

  void updateTraining(Training training) {
    final index = _trainings.indexWhere((t) => t.id == training.id);
    if (index != -1) {
      _trainings[index] = training;
      notifyListeners();
    }
  }

  void deleteTraining(String trainingId) {
    _trainings.removeWhere((training) => training.id == trainingId);
    notifyListeners();
  }

  void addScheduleToTraining(String trainingId, TrainingSchedule schedule) {
    final trainingIndex = _trainings.indexWhere((t) => t.id == trainingId);
    if (trainingIndex != -1) {
      _trainings[trainingIndex].schedules.add(schedule);
      notifyListeners();
    }
  }

  void sendJobNotifications() {
    // This would typically integrate with an email service
    // For now, we'll just show a success message
    print('Job notifications sent to all subscribed students');
  }

  void uploadNote(String trainingId, String scheduleId, Note note) {
    final trainingIndex = _trainings.indexWhere((t) => t.id == trainingId);
    if (trainingIndex != -1) {
      final scheduleIndex = _trainings[trainingIndex]
          .schedules
          .indexWhere((s) => s.id == scheduleId);
      if (scheduleIndex != -1) {
        _trainings[trainingIndex].schedules[scheduleIndex].notes.add(note);
        notifyListeners();
      }
    }
  }

  void sendMessage(String trainingId, String scheduleId, Message message) {
    final trainingIndex = _trainings.indexWhere((t) => t.id == trainingId);
    if (trainingIndex != -1) {
      final scheduleIndex = _trainings[trainingIndex]
          .schedules
          .indexWhere((s) => s.id == scheduleId);
      if (scheduleIndex != -1) {
        _trainings[trainingIndex].schedules[scheduleIndex].messages.add(message);
        notifyListeners();
      }
    }
  }

  void deleteScheduleFromTraining(String trainingId, String scheduleId) {
    final trainingIndex = _trainings.indexWhere((t) => t.id == trainingId);
    if (trainingIndex != -1) {
      _trainings[trainingIndex].schedules.removeWhere((s) => s.id == scheduleId);
      notifyListeners();
    }
  }

  void updateScheduleInTraining(String trainingId, TrainingSchedule updatedSchedule) {
    final trainingIndex = _trainings.indexWhere((t) => t.id == trainingId);
    if (trainingIndex != -1) {
      final scheduleIndex = _trainings[trainingIndex].schedules.indexWhere((s) => s.id == updatedSchedule.id);
      if (scheduleIndex != -1) {
        _trainings[trainingIndex].schedules[scheduleIndex] = updatedSchedule;
        notifyListeners();
      }
    }
  }
}
