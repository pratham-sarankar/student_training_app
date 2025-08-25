# Course Notes Setup Guide

## Overview
Course notes are now integrated with Firebase and are **read-only** for students. Notes are created by instructors/admins and displayed to students in the course details screen.

## Firebase Collection Structure

### Collection: `courses/{courseId}/notes/{noteId}`
Each course has a `notes` subcollection where individual notes are stored. The structure is:

```json
{
  "title": "Getting Started with Flutter",
  "content": "Flutter is Google's UI toolkit for building beautiful, natively compiled applications for mobile, web, and desktop from a single codebase.",
  "timestamp": "2024-01-15T10:00:00Z",
  "updatedAt": "2024-01-15T10:00:00Z",
  "tags": ["flutter", "mobile", "beginner"],
  "isPublic": true,
  "createdBy": "instructor_uid",
  "createdByName": "John Doe"
}
```

**Note**: The `courseId` and `courseTitle` are not stored in each note document since they're already available from the parent course document.

## Adding Course Notes

### Method 1: Firebase Console
1. Go to Firebase Console > Firestore Database
2. Navigate to the `courses` collection
3. Find your course document (e.g., `flutter_basics_101`)
4. Click on the course document
5. Click "Start collection" and name it `notes`
6. Add a new document with the required fields:
   - `title`: The title of the note
   - `content`: The content of the note
   - `tags`: Array of relevant tags
   - `isPublic`: Set to true for public notes
   - `createdBy`: Your user ID or instructor ID
   - `createdByName`: Your display name
   - `timestamp`: Current timestamp
   - `updatedAt`: Current timestamp

### Method 2: Admin Panel (Future Implementation)
A future admin panel will allow instructors to:
- Create notes directly from the app
- Edit existing notes
- Delete notes
- Manage note visibility

## Example Notes

### Note 1: Course Introduction
```json
{
  "title": "Welcome to Flutter Development",
  "content": "Welcome to Flutter Basics 101! In this course, you'll learn the fundamentals of Flutter development, including widgets, state management, and building your first mobile app.",
  "timestamp": "2024-01-15T09:00:00Z",
  "updatedAt": "2024-01-15T09:00:00Z",
  "tags": ["welcome", "introduction", "flutter"],
  "isPublic": true,
  "createdBy": "instructor_john",
  "createdByName": "John Smith"
}
```

### Note 2: Key Concepts
```json
{
  "title": "Key Flutter Concepts",
  "content": "Important concepts to remember: 1) Everything is a widget, 2) Stateless vs Stateful widgets, 3) Hot reload for fast development, 4) Material Design components.",
  "timestamp": "2024-01-15T10:00:00Z",
  "updatedAt": "2024-01-15T10:00:00Z",
  "tags": ["concepts", "widgets", "important"],
  "isPublic": true,
  "createdBy": "instructor_john",
  "createdByName": "John Smith"
}
```

## Student Experience
- Students can view all public notes for their enrolled courses
- Notes are displayed in chronological order (newest first)
- Notes include tags for easy categorization
- Students can search notes by title or content
- Notes show who created them and when they were last updated

## Security Rules
Ensure your Firestore security rules allow:
- Read access to course notes for authenticated users enrolled in the course
- Write access only for instructors/admins

Example security rule:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /courses/{courseId}/notes/{noteId} {
      allow read: if request.auth != null && 
        exists(/databases/$(database)/documents/users/$(request.auth.uid)/enrolled_courses/$(courseId));
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'instructor';
    }
  }
}
```

## Troubleshooting
- **Notes not showing**: Check if the course document exists and has a `notes` subcollection
- **Permission denied**: Verify Firestore security rules for the course notes subcollection
- **Empty notes list**: Ensure notes are marked as `isPublic: true`
- **Tags not displaying**: Verify tags are stored as an array, not a string
- **Course not found**: Verify the course ID matches exactly with your course document
