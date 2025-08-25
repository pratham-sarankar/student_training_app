# User Model Documentation

This document describes the comprehensive `UserModel` class that manages all user-related data in the Learn Work app.

## Overview

The `UserModel` class provides a structured way to handle user data, including:
- Basic profile information (name, email, phone)
- Personal details (gender, date of birth, bio)
- Account status (verification, role)
- Preferences and settings
- Learning progress (courses, jobs)
- Integration with Firebase Auth and Firestore

## Class Structure

### Core Properties

```dart
class UserModel {
  final String uid;                    // Unique user identifier
  final String firstName;              // User's first name
  final String lastName;               // User's last name
  final String email;                  // User's email address
  final String? phoneNumber;           // User's phone number
  final String? photoUrl;              // Profile picture URL
  final String? bio;                   // User's biography
  final String? gender;                // User's gender
  final DateTime? dateOfBirth;         // User's date of birth
  final String role;                   // User's role (default: 'Student')
  final bool isEmailVerified;          // Email verification status
  final bool isPhoneVerified;          // Phone verification status
  final DateTime createdAt;            // Account creation timestamp
  final DateTime updatedAt;            // Last update timestamp
}
```

### Preferences and Settings

```dart
  final bool emailNotifications;       // Email notification preference
  final bool pushNotifications;        // Push notification preference
  final bool jobAlerts;                // Job alert preference
  final List<String> jobCategories;    // Preferred job categories
  final List<String> preferredLocations; // Preferred job locations
```

### Learning Progress

```dart
  final List<String> enrolledCourses;  // Currently enrolled courses
  final List<String> completedCourses; // Completed courses
  final List<String> savedJobs;        // Saved/favorited jobs
  final List<String> appliedJobs;      // Jobs user has applied to
```

## Factory Constructors

### 1. From Firebase Auth User

```dart
UserModel.fromFirebaseUser(User user, {
  String? phoneNumber,
  String? bio,
  String? gender,
  DateTime? dateOfBirth,
  // ... other optional parameters
})
```

**Usage:**
```dart
final user = FirebaseAuth.instance.currentUser;
if (user != null) {
  final userModel = UserModel.fromFirebaseUser(
    user,
    phoneNumber: '+919876543210',
    bio: 'Software Developer',
  );
}
```

### 2. From Firestore Document

```dart
UserModel.fromMap(Map<String, dynamic> map, String id)
```

**Usage:**
```dart
final doc = await FirebaseFirestore.instance
    .collection('users')
    .doc('user_id')
    .get();

if (doc.exists) {
  final userModel = UserModel.fromMap(doc.data()!, doc.id);
}
```

## Utility Methods

### Getters

```dart
// Get full name
String get fullName => '$firstName $lastName'.trim();

// Get display name (first name only if last name is empty)
String get displayName => lastName.isNotEmpty ? fullName : firstName;

// Get initials for avatar
String get initials => '${firstName[0]}${lastName[0]}'.toUpperCase();

// Check if profile is complete
bool get hasCompletedProfile => firstName.isNotEmpty && 
                               lastName.isNotEmpty && 
                               phoneNumber != null && 
                               dateOfBirth != null;

// Check if user is verified
bool get isVerified => isEmailVerified || isPhoneVerified;

// Calculate user age
int? get age => // Calculated from dateOfBirth

// Get formatted date of birth
String? get formattedDateOfBirth => // Returns "DD/MM/YYYY" format
```

### Course and Job Methods

```dart
// Check course enrollment
bool isEnrolledInCourse(String courseId) => enrolledCourses.contains(courseId);

// Check course completion
bool hasCompletedCourse(String courseId) => completedCourses.contains(courseId);

// Check saved jobs
bool hasSavedJob(String jobId) => savedJobs.contains(jobId);

// Check applied jobs
bool hasAppliedToJob(String jobId) => appliedJobs.contains(jobId);
```

### Data Conversion

```dart
// Convert to Firestore document
Map<String, dynamic> toMap() => // Returns map for Firestore

// Create copy with updated fields
UserModel copyWith({...}) => // Returns new instance with updated fields
```

## Integration with Services

### UserService

The `UserService` provides comprehensive user management:

```dart
class UserService {
  // Create or update user
  Future<void> createOrUpdateUser(UserModel userModel);
  
  // Get user by ID
  Future<UserModel?> getUserById(String uid);
  
  // Get current user data
  Future<UserModel?> getCurrentUserData();
  
  // Update user profile
  Future<void> updateUserProfile({...});
  
  // Course management
  Future<void> enrollInCourse(String courseId);
  Future<void> completeCourse(String courseId);
  
  // Job management
  Future<void> saveJob(String jobId);
  Future<void> unsaveJob(String jobId);
  Future<void> applyToJob(String jobId);
}
```

### AuthService

The `AuthService` integrates with the user model:

```dart
class AuthService {
  // Get current user model
  Future<UserModel?> getCurrentUserModel();
  
  // Update profile comprehensively
  Future<void> updateUserProfileComprehensive({...});
}
```

## Usage Examples

### 1. Creating a New User

```dart
final userModel = UserModel(
  uid: 'unique_user_id',
  firstName: 'John',
  lastName: 'Doe',
  email: 'john.doe@example.com',
  phoneNumber: '+919876543210',
  bio: 'Software Developer',
  gender: 'Male',
  dateOfBirth: DateTime(1990, 5, 15),
  role: 'Student',
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

await userService.createOrUpdateUser(userModel);
```

### 2. Updating User Profile

```dart
final currentUser = await userService.getCurrentUserData();
if (currentUser != null) {
  final updatedUser = currentUser.copyWith(
    bio: 'Updated bio',
    gender: 'Male',
    dateOfBirth: DateTime(1990, 5, 15),
  );
  
  await userService.createOrUpdateUser(updatedUser);
}
```

### 3. Managing Course Enrollment

```dart
// Enroll in a course
await userService.enrollInCourse('course_123');

// Check if enrolled
final user = await userService.getCurrentUserData();
if (user?.isEnrolledInCourse('course_123') == true) {
  print('User is enrolled in course 123');
}

// Mark as completed
await userService.completeCourse('course_123');
```

### 4. Managing Job Interactions

```dart
// Save a job
await userService.saveJob('job_456');

// Check if saved
final user = await userService.getCurrentUserData();
if (user?.hasSavedJob('job_456') == true) {
  print('Job is saved');
}

// Apply to job
await userService.applyToJob('job_456');
```

## Firebase Collection Structure

The user data is stored in Firestore with the following structure:

```json
{
  "firstName": "John",
  "lastName": "Doe",
  "email": "john.doe@example.com",
  "phoneNumber": "+919876543210",
  "photoUrl": "https://example.com/photo.jpg",
  "bio": "Software Developer",
  "gender": "Male",
  "dateOfBirth": "1990-05-15T00:00:00.000Z",
  "role": "Student",
  "isEmailVerified": true,
  "isPhoneVerified": false,
  "createdAt": "2024-01-01T00:00:00.000Z",
  "updatedAt": "2024-01-01T00:00:00.000Z",
  "emailNotifications": true,
  "pushNotifications": true,
  "jobAlerts": true,
  "jobCategories": ["Software Development", "Mobile Development"],
  "preferredLocations": ["Bangalore", "Mumbai"],
  "enrolledCourses": ["course_1", "course_2"],
  "completedCourses": ["course_3"],
  "savedJobs": ["job_1", "job_2"],
  "appliedJobs": ["job_3"]
}
```

## Best Practices

### 1. Always Use copyWith for Updates

```dart
// ✅ Good
final updatedUser = currentUser.copyWith(
  bio: 'New bio',
  updatedAt: DateTime.now(),
);

// ❌ Bad - Don't modify properties directly
currentUser.bio = 'New bio'; // This won't work with final properties
```

### 2. Check for Null Values

```dart
// ✅ Good
if (user?.dateOfBirth != null) {
  final age = user!.age;
  print('User age: $age');
}

// ❌ Bad - Don't assume values exist
final age = user.age; // Could be null
```

### 3. Use Service Methods for Data Operations

```dart
// ✅ Good - Use service methods
await userService.enrollInCourse('course_123');

// ❌ Bad - Don't manipulate data directly
user.enrolledCourses.add('course_123'); // Won't persist to Firestore
```

### 4. Handle Loading States

```dart
class _MyWidgetState extends State<MyWidget> {
  UserModel? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() => _isLoading = true);
    try {
      final user = await userService.getCurrentUserData();
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      // Handle error
    }
  }
}
```

## Migration from Old System

If you're migrating from the old user system:

1. **Update imports**: Replace old user-related imports with `UserModel`
2. **Update service calls**: Use `UserService` methods instead of direct Firestore calls
3. **Update UI**: Use `UserModel` properties instead of raw data maps
4. **Test thoroughly**: Ensure all user-related functionality works with the new model

## Troubleshooting

### Common Issues

1. **Null Safety Errors**: Always check for null values before accessing properties
2. **Firestore Timestamp Issues**: Use the provided factory methods for proper conversion
3. **State Management**: Ensure proper state management when updating user data
4. **Performance**: Use `copyWith` for efficient updates instead of creating new instances

### Debug Tips

```dart
// Print user data for debugging
print('User: ${user.toString()}');
print('Full name: ${user.fullName}');
print('Profile complete: ${user.hasCompletedProfile}');
print('Verified: ${user.isVerified}');
```

## Conclusion

The `UserModel` provides a robust, type-safe way to manage user data throughout the Learn Work app. It integrates seamlessly with Firebase services and provides comprehensive user management capabilities. Follow the best practices outlined in this document to ensure optimal performance and maintainability.
