# MentorConnect - Complete User Guide & Technical Documentation

**Version:** 1.0.0  
**Platform:** Android (Flutter)  
**Package:** com.example.mentorship_app  
**Last Updated:** November 2025

---

## Table of Contents

1. [Introduction](#introduction)
2. [Project Overview](#project-overview)
3. [Installation & Setup](#installation--setup)
4. [User Roles](#user-roles)
5. [Features Guide](#features-guide)
6. [Technical Architecture](#technical-architecture)
7. [Firebase Configuration](#firebase-configuration)
8. [Testing Guide](#testing-guide)
9. [Troubleshooting](#troubleshooting)
10. [Development Guide](#development-guide)

---

## Introduction

**MentorConnect** is a comprehensive mentorship management platform that connects students with mentors, facilitating communication, resource sharing, meeting scheduling, and progress tracking. Built with Flutter and Firebase, it provides a seamless mobile experience for both mentors and students.

### Key Capabilities

- **User Management**: Dual-role system (Mentor/Student)
- **Real-Time Communication**: Built-in chat with image sharing
- **Meeting Scheduling**: Online and physical meeting coordination
- **Resource Sharing**: Document and link distribution
- **Form System**: Custom forms for mentor-student matching
- **Review System**: Bi-directional rating and feedback
- **Notification System**: Real-time alerts for all activities
- **Download Feature**: Export form submissions as CSV/TXT

---

## Project Overview

### What is MentorConnect?

MentorConnect is a mobile application designed to streamline the mentorship process in educational and professional settings. It eliminates the friction of managing mentor-student relationships by providing:

1. **Centralized Communication**: All interactions in one place
2. **Automated Workflows**: Form submissions, approvals, notifications
3. **Progress Tracking**: Meeting history, submission tracking
4. **Resource Management**: Shared learning materials
5. **Feedback Loop**: Reviews and ratings system

### Use Cases

- **Universities**: Connect students with academic advisors
- **Corporate Training**: Pair employees with senior mentors
- **Skill Development**: Match learners with experts
- **Career Guidance**: Professional mentorship programs
- **Peer Learning**: Student-to-student knowledge sharing

---

## Installation & Setup

### Prerequisites

- Android device (Android 5.0 / API 21 or higher)
- Internet connection
- Firebase account (for administrators)

### Installation Steps

#### For End Users

1. **Download the APK**

   - Location: `build/app/outputs/flutter-apk/app-release.apk`
   - Transfer to Android device

2. **Install**

   - Open the APK file on your device
   - Allow installation from unknown sources if prompted
   - Follow installation wizard

3. **First Launch**
   - App will request notification permissions
   - Internet access is required

#### For Developers

1. **Clone Repository**

   ```bash
   git clone https://github.com/Cryptdroid/mentor_connect.git
   cd mentorship_app
   ```

2. **Install Flutter**

   - Flutter SDK 3.0.0 or higher required
   - Verify: `flutter doctor`

3. **Install Dependencies**

   ```bash
   flutter pub get
   ```

4. **Configure Firebase**

   - Place `google-services.json` in `android/app/`
   - Update Firebase project settings

5. **Run Application**

   ```bash
   flutter run
   ```

6. **Build Release APK**
   ```bash
   flutter build apk --release
   ```

---

## User Roles

### 1. Student Role

**Purpose**: Individuals seeking mentorship, guidance, and learning opportunities.

**Capabilities**:

- Browse and connect with mentors
- Submit mentorship application forms
- View and access mentor-shared resources
- Schedule and join meetings
- Send messages to mentors
- Submit reviews for mentors
- Track submissions and meeting history

**Dashboard Features**:

- Quick actions (Browse Mentors, My Submissions, My Meetings, Resources)
- Statistics (Mentor count, Upcoming meetings)
- Recent conversations
- Profile management

### 2. Mentor Role

**Purpose**: Experienced individuals offering guidance and sharing knowledge.

**Capabilities**:

- Create custom application forms
- Review and accept/reject student applications
- Share resources (documents, links)
- Schedule meetings with students
- Manage mentee relationships
- Submit reviews for students
- Download submission data
- Create and manage content

**Dashboard Features**:

- Quick actions (Create Form, My Mentees, Schedule Meeting, Add Resource)
- Statistics (Total mentees, Pending submissions, Upcoming meetings)
- Mentee list with profile cards
- Chat overview

---

## Features Guide

### 1. Authentication System

#### Registration

1. **Navigate to Sign Up**

   - Open app → Click "Sign Up"

2. **Choose Role**

   - Select "Student" or "Mentor"
   - This determines your access level

3. **Fill Registration Form**

   - **Full Name**: Your display name
   - **Email**: Valid email address (verification sent)
   - **Password**: Minimum 6 characters
   - **Bio** (Optional): Brief introduction
   - **Expertise/Interests**: Your skills or learning goals
   - **Profile Image** (Optional): Upload from gallery

4. **Email Verification**
   - Check inbox for verification email
   - Click verification link
   - Return to app and log in

#### Login

1. **Enter Credentials**

   - Email and password
   - OR use "Forgot Password" link

2. **Password Reset**
   - Enter registered email
   - Check inbox for reset link
   - Create new password

#### Profile Management

**Edit Profile** (Settings → Edit Profile):

- Update name, bio, expertise
- Change profile picture
- Update contact information
- View account statistics

**Privacy & Security**:

- Privacy Policy available in About section
- Data stored securely in Firebase
- Option to log out from all devices

---

### 2. Mentorship Form System

#### For Mentors: Creating Forms

1. **Access Form Creation**

   - Dashboard → "Create Form" OR
   - Drawer → "Create Form"

2. **Form Builder**

   ```
   Title: e.g., "Web Development Mentorship Application"
   Description: Explain mentorship program details
   Deadline: Set submission cutoff date

   Add Questions:
   - Text: Short answer
   - Long Text: Paragraph response
   - Multiple Choice: Radio buttons
   - Checkboxes: Multiple selections
   - Dropdown: Select from list
   ```

3. **Question Configuration**

   - Each question can be marked required
   - Add options for choice-based questions
   - Reorder questions via drag (if applicable)

4. **Save & Publish**
   - Form becomes visible to all students
   - Students can submit responses

#### For Students: Filling Forms

1. **Browse Available Forms**

   - Dashboard → "Browse Mentors" → Select Mentor → "Apply"
   - OR Drawer → "Browse Mentors"

2. **View Form Details**

   - Read title and description
   - Check deadline
   - Review all questions

3. **Fill Response**

   - Answer all required questions
   - Optional questions can be skipped
   - Text fields support long responses

4. **Submit**

   - Review answers before submission
   - Click "Submit Application"
   - Confirmation shown

5. **Track Submission**
   - Dashboard → "My Submissions"
   - View status: Pending/Accepted/Rejected
   - See mentor's response notes

#### For Mentors: Managing Submissions

1. **View Submissions**

   - Dashboard → "My Forms" → Select Form → "View Submissions"
   - OR Drawer → "Form Submissions"

2. **Review Each Submission**

   - Click submission card
   - Read all responses
   - View student profile

3. **Take Action**

   - **Accept**: Student becomes your mentee
     - Add acceptance note
     - Student receives notification
   - **Reject**: Decline with reason
     - Add rejection note (optional)
     - Maintains professional communication

4. **Download Data**

   - Click download icon in submission detail
   - Choose format: CSV or TXT
   - File saved to device: `/Android/data/com.example.mentorship_app/files/Downloads/`
   - No permissions required

5. **Filter & Search**
   - Pending submissions tab
   - Accepted submissions tab
   - Statistics dashboard

---

### 3. Resource Sharing

#### For Mentors: Adding Resources

1. **Create Resource**

   - Dashboard → "Resources" → FAB (+)
   - OR Drawer → "Resources" → Add button

2. **Resource Form**

   ```
   Title: Resource name
   Description: What students will learn
   Type: Choose category
     - Tutorial
     - Article
     - Video
     - Book
     - Tool
     - Other
   URL: Direct link to resource
   Tags: Keywords for search (comma-separated)
   ```

3. **Share with Students**
   - Choose "All Students" or specific mentees
   - Resource appears in their feed
   - Notification sent automatically

#### For Students: Accessing Resources

1. **View Resources**

   - Dashboard → "Resources"
   - OR Drawer → "Resources"

2. **Filter Resources**

   - All Resources: From all mentors
   - My Mentors: Only from connected mentors
   - Search by title or tags

3. **Open Resource**

   - Click resource card
   - View full description
   - Click "Open Link" to access content
   - Opens in default browser

4. **Track Learning**
   - Resources remain accessible
   - Organized by mentor
   - Timestamped for reference

---

### 4. Meeting Scheduling System

#### Scheduling a Meeting

**For Mentors**:

1. Navigate: Dashboard → "Schedule Meeting" OR Mentees List → Student → "Schedule Meeting"
2. Fill Meeting Form:
   ```
   Title: Meeting topic
   Description: Agenda/discussion points
   Student: Select from your mentees
   Date & Time: Pick future date/time
   Duration: Minutes (e.g., 30, 60)
   Meeting Type:
     - Online: Requires meeting link
     - Physical: Requires location address
   Meeting Link/Location: URL or address
   Notes: Additional information
   ```
3. Submit → Student receives notification

**For Students**:

1. Navigate: Mentor Profile → "Request Meeting"
2. Fill similar form (mentor auto-selected)
3. Submit → Mentor receives notification

#### Managing Meeting Requests

1. **View Pending Requests**

   - Notifications → Meeting request alert
   - OR Dashboard → "My Meetings" → Pending tab

2. **Review Request**

   - Click meeting card
   - View all details
   - Check your availability

3. **Respond**
   - **Approve**: Accept with optional note
   - **Decline**: Reject with reason
   - **Postpone**: Suggest new date/time
     - Enter new date and time
     - Add explanation

#### Viewing Meetings

**Meeting List**:

- **Upcoming Tab**: Future meetings (approved/pending)
- **Past Tab**: Completed/cancelled meetings

**Meeting Details Screen**:

```
Information Displayed:
- Title and description
- Participant details
- Date, time, duration
- Meeting type (online/physical)
- Location/Link (clickable)
- Status (Pending/Approved/Cancelled/Completed)
- Request notes
- Response notes

Actions Available:
- Join Online Meeting (for online type)
- Get Directions (for physical type)
- Cancel Meeting (organizer only)
- Mark as Completed
- View Participant Profile
```

#### Joining Meetings

**Online Meetings**:

1. Click meeting card
2. Click "Join Meeting" button
3. Opens meeting link in browser
4. Join video call (Zoom, Google Meet, etc.)

**Physical Meetings**:

1. Click meeting card
2. View location address
3. Click address → Opens in Maps app
4. Navigate to location

#### Post-Meeting

1. **Mark as Completed**

   - Both participants can mark complete
   - Updates status automatically

2. **Leave Review** (Optional)
   - Rate the meeting experience
   - Provide feedback

---

### 5. Chat & Messaging

#### Starting a Conversation

**For Students**:

1. Browse Mentors → Select Mentor
2. Click "Message" button on mentor profile
3. Chat window opens

**For Mentors**:

1. My Mentees → Select Student
2. Click chat icon
3. OR receive message from student

#### Sending Messages

1. **Text Messages**

   - Type in message field
   - Press send icon
   - Message delivered instantly

2. **Image Messages**

   - Click image/camera icon
   - Choose:
     - Take Photo: Opens camera
     - Choose from Gallery: Opens photo picker
   - Image uploads via ImgBB (free service)
   - Thumbnail shown in chat
   - Click to view full size

3. **Message Features**
   - Real-time delivery
   - Read receipts (isRead status)
   - Timestamp on each message
   - Sender name displayed

#### Managing Chats

**Chat List**:

- All conversations in Dashboard → Chats tab
- Recent messages shown
- Unread count badge (red dot)
- Last message timestamp
- Click to open conversation

**Unread Indicators**:

- **Red badge** on chat tab (bottom navigation)
- **Red badge** on notification bell
- **Red badge** on chat icon (drawer menu)
- Number shows total unread count
- Updates in real-time

**Chat Screen Features**:

- Participant name in header
- Profile picture display
- Message history (scrollable)
- Pull to load older messages
- Auto-scroll to latest message

---

### 6. Review & Rating System

#### Leaving a Review

**Students Review Mentors**:

1. Navigate to Reviews tab on mentor profile
2. Click FAB (+) button
3. Fill review form:
   ```
   Rating: 1-5 stars (required)
   Comment: Detailed feedback (required)
   ```
4. Submit → Mentor receives notification

**Mentors Review Students**:

1. My Mentees → Select Student
2. Click "Write Review" button
3. Fill review form (same as above)
4. Submit → Student receives notification

#### Viewing Reviews

1. **On Profile Page**

   - Overall rating displayed (average)
   - Total number of reviews
   - Star distribution graph

2. **Reviews Tab**

   - All reviews listed
   - Reviewer name and photo
   - Rating stars
   - Comment text
   - Timestamp

3. **Review Limitations**
   - One review per mentor-student pair
   - Cannot review yourself
   - Cannot edit after submission
   - Can only review connected mentees/mentors

---

### 7. Notification System

#### Notification Types

MentorConnect sends notifications for:

1. **Student Acceptance**

   - When mentor accepts your application
   - Shows mentor name

2. **New Resource**

   - When mentor posts new resource
   - Shows resource title

3. **Meeting Scheduled**

   - When meeting request is made
   - Shows meeting title and time

4. **Meeting Response**

   - When meeting is approved/declined/postponed
   - Shows new status

5. **New Chat Message**

   - When someone sends you a message
   - Shows sender name and preview

6. **Review Received**

   - When someone reviews you
   - Shows rating and reviewer

7. **Form Submission**
   - When student submits form (mentors only)
   - Shows student name and form title

#### Notification Settings

1. **View Notifications**

   - Click bell icon (top right)
   - Lists all notifications
   - Newest first

2. **Notification Indicators**

   - **Bold text**: Unread notification
   - **Regular text**: Read notification
   - **Red badge**: Unread count on bell icon

3. **Mark as Read**

   - Click notification to view
   - Automatically marks as read
   - Badge count updates

4. **Local Notifications**
   - Push notifications when app is closed
   - Sound and vibration alerts
   - Banner on lock screen

---

### 8. My Mentees/Mentors Management

#### For Mentors: My Mentees

1. **Access Mentees**

   - Dashboard → Mentees Tab
   - OR Drawer → "My Mentees"

2. **Mentee Cards Display**:

   ```
   - Profile picture
   - Name and email
   - Bio preview
   - Interests/expertise
   - Quick actions:
     * Message
     * Schedule Meeting
     * Write Review
     * View Profile
   ```

3. **Mentee Actions**

   - **Message**: Opens chat
   - **Schedule Meeting**: Opens meeting form
   - **Write Review**: Opens review form
   - **View Full Profile**: See complete profile

4. **Filter Mentees**
   - All mentees listed
   - Search by name
   - View statistics (total count)

#### For Students: My Mentors

1. **View Connected Mentors**

   - Dashboard stats show mentor count
   - Browse Mentors → Filter → "My Mentors"

2. **Mentor Profile Access**
   - Click mentor card
   - View complete profile
   - See shared resources
   - Access all features

---

### 9. Settings & Account

#### Settings Menu

Access: Dashboard → Profile Tab → Settings OR Drawer → Settings

**Available Options**:

1. **Edit Profile**

   - Update personal information
   - Change profile picture
   - Modify bio and expertise

2. **Migration Tool** (Mentors Only)

   - Fix legacy mentorship data
   - Update old accepted students
   - Shown only if needed

3. **About**

   - App version information
   - Developer details
   - App description

4. **Privacy Policy**

   - Data usage information
   - Terms of service
   - Privacy guidelines

5. **Logout**
   - Sign out of account
   - Clears local data
   - Returns to login screen

---

## Technical Architecture

### Technology Stack

**Frontend**:

- **Framework**: Flutter 3.0+
- **Language**: Dart
- **State Management**: Provider pattern
- **UI Components**: Material Design 3

**Backend**:

- **BaaS**: Firebase (Backend as a Service)
- **Authentication**: Firebase Auth
- **Database**: Cloud Firestore (NoSQL)
- **Messaging**: Firebase Cloud Messaging
- **Image Storage**: ImgBB API (free alternative)

**Additional Services**:

- **Local Notifications**: flutter_local_notifications
- **Image Picking**: image_picker
- **URL Launching**: url_launcher
- **File Downloads**: path_provider
- **CSV Export**: csv package

### Project Structure

```
mentorship_app/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── config/
│   │   ├── routes.dart           # Navigation routes
│   │   └── theme.dart            # App theming
│   ├── models/
│   │   ├── user_model.dart       # User data structure
│   │   ├── chat_model.dart       # Chat data structure
│   │   ├── message_model.dart    # Message data structure
│   │   ├── meeting_model.dart    # Meeting data structure
│   │   ├── resource_model.dart   # Resource data structure
│   │   ├── review_model.dart     # Review data structure
│   │   ├── notification_model.dart
│   │   ├── mentorship_form_model.dart
│   │   └── form_submission_model.dart
│   ├── providers/
│   │   ├── auth_provider.dart    # Authentication state
│   │   ├── user_provider.dart    # User data state
│   │   └── chat_provider.dart    # Chat state
│   ├── services/
│   │   ├── auth_service.dart     # Auth operations
│   │   ├── firestore_service.dart # Database operations
│   │   ├── chat_service.dart     # Chat operations
│   │   ├── meeting_service.dart  # Meeting operations
│   │   ├── notification_service.dart
│   │   ├── notification_helper.dart
│   │   └── image_upload_service.dart
│   ├── screens/
│   │   ├── splash_screen.dart
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   ├── register_screen.dart
│   │   │   ├── role_selection_screen.dart
│   │   │   ├── email_verification_screen.dart
│   │   │   └── forgot_password_screen.dart
│   │   ├── student/
│   │   │   ├── student_dashboard.dart
│   │   │   ├── browse_mentors_screen.dart
│   │   │   ├── mentor_profile_screen.dart
│   │   │   ├── fill_form_screen.dart
│   │   │   ├── my_submissions_screen.dart
│   │   │   └── student_meetings_screen.dart
│   │   ├── mentor/
│   │   │   ├── mentor_dashboard.dart
│   │   │   ├── create_form_screen.dart
│   │   │   ├── form_submissions_screen.dart
│   │   │   ├── submission_detail_screen.dart
│   │   │   ├── my_mentees_screen.dart
│   │   │   └── schedule_meeting_screen.dart
│   │   ├── chat/
│   │   │   ├── chat_list_screen.dart
│   │   │   └── chat_detail_screen.dart
│   │   ├── resources/
│   │   │   ├── resources_screen.dart
│   │   │   └── add_resource_screen.dart
│   │   ├── profile/
│   │   │   ├── profile_screen.dart
│   │   │   └── edit_profile_screen.dart
│   │   ├── settings/
│   │   │   └── settings_screen.dart
│   │   ├── notifications/
│   │   │   └── notifications_screen.dart
│   │   ├── reviews/
│   │   │   ├── reviews_screen.dart
│   │   │   └── add_review_screen.dart
│   │   └── about/
│   │       └── about_screen.dart
│   └── widgets/
│       ├── custom_button.dart
│       ├── custom_text_field.dart
│       ├── loading_widget.dart
│       └── empty_state_widget.dart
├── android/                       # Android-specific files
├── assets/
│   ├── images/                    # App images
│   └── icons/                     # App icons
└── pubspec.yaml                   # Dependencies
```

### Data Models

#### User Model

```dart
{
  uid: String,
  name: String,
  email: String,
  role: 'student' | 'mentor',
  profileImage: String?,
  bio: String?,
  expertise: String?,
  rating: double (0-5),
  reviewCount: int,
  createdAt: DateTime
}
```

#### Chat Model

```dart
{
  chatId: String,
  participants: [userId1, userId2],
  participantNames: {userId: name},
  participantImages: {userId: imageUrl},
  lastMessage: String,
  lastMessageSenderId: String,
  lastMessageTime: DateTime,
  unreadCount: {userId: count},
  createdAt: DateTime
}
```

#### Message Model

```dart
{
  messageId: String,
  chatId: String,
  senderId: String,
  senderName: String,
  text: String,
  timestamp: DateTime,
  imageUrl: String?,
  fileUrl: String?,
  fileName: String?,
  isRead: boolean
}
```

#### Meeting Model

```dart
{
  meetingId: String,
  mentorId: String,
  mentorName: String,
  studentId: String,
  studentName: String,
  title: String,
  description: String,
  dateTime: DateTime,
  duration: int (minutes),
  location: String,
  meetingType: 'online' | 'physical',
  status: 'pending' | 'accepted' | 'declined' | 'cancelled' | 'completed',
  requestedBy: 'mentor' | 'student',
  participants: [mentorId, studentId],
  createdAt: DateTime,
  respondedAt: DateTime?,
  responseNote: String?
}
```

#### Resource Model

```dart
{
  resourceId: String,
  mentorId: String,
  mentorName: String,
  title: String,
  description: String,
  type: String ('Tutorial' | 'Article' | 'Video' | 'Book' | 'Tool' | 'Other'),
  url: String,
  tags: List<String>,
  createdAt: DateTime
}
```

#### Review Model

```dart
{
  reviewId: String,
  reviewerId: String,
  reviewerName: String,
  reviewerRole: 'student' | 'mentor',
  reviewedUserId: String,
  reviewedUserName: String,
  rating: int (1-5),
  comment: String,
  createdAt: DateTime
}
```

#### Mentorship Form Model

```dart
{
  formId: String,
  mentorId: String,
  mentorName: String,
  title: String,
  description: String,
  deadline: DateTime,
  questions: [
    {
      questionId: String,
      question: String,
      type: 'text' | 'longText' | 'multipleChoice' | 'checkbox' | 'dropdown',
      options: List<String>?,
      required: boolean
    }
  ],
  createdAt: DateTime
}
```

#### Form Submission Model

```dart
{
  submissionId: String,
  formId: String,
  studentId: String,
  studentName: String,
  studentEmail: String,
  mentorId: String,
  responses: {questionId: answer},
  status: 'pending' | 'accepted' | 'rejected',
  acceptanceNote: String?,
  rejectionNote: String?,
  submittedAt: DateTime,
  reviewedAt: DateTime?
}
```

#### Notification Model

```dart
{
  notificationId: String,
  userId: String,
  title: String,
  body: String,
  type: String,
  relatedId: String?,
  isRead: boolean,
  createdAt: DateTime
}
```

---

## Firebase Configuration

### Collections Structure

```
Firestore Database:
├── users/
│   └── {userId}/
│       ├── uid
│       ├── name
│       ├── email
│       ├── role
│       ├── profileImage
│       ├── bio
│       ├── expertise
│       ├── rating
│       ├── reviewCount
│       └── createdAt
│
├── chats/
│   └── {chatId}/
│       ├── participants: [userId1, userId2]
│       ├── participantNames: {userId: name}
│       ├── participantImages: {userId: imageUrl}
│       ├── lastMessage
│       ├── lastMessageSenderId
│       ├── lastMessageTime
│       ├── unreadCount: {userId: count}
│       └── createdAt
│
├── messages/
│   └── {messageId}/
│       ├── chatId
│       ├── senderId
│       ├── senderName
│       ├── text
│       ├── timestamp
│       ├── imageUrl (optional)
│       ├── fileUrl (optional)
│       ├── fileName (optional)
│       └── isRead
│
├── meetings/
│   └── {meetingId}/
│       ├── mentorId
│       ├── mentorName
│       ├── studentId
│       ├── studentName
│       ├── title
│       ├── description
│       ├── dateTime
│       ├── duration
│       ├── location
│       ├── meetingType
│       ├── status
│       ├── requestedBy
│       ├── participants: [mentorId, studentId]
│       ├── createdAt
│       ├── respondedAt (optional)
│       └── responseNote (optional)
│
├── resources/
│   └── {resourceId}/
│       ├── mentorId
│       ├── mentorName
│       ├── title
│       ├── description
│       ├── type
│       ├── url
│       ├── tags: []
│       └── createdAt
│
├── reviews/
│   └── {reviewId}/
│       ├── reviewerId
│       ├── reviewerName
│       ├── reviewerRole
│       ├── reviewedUserId
│       ├── reviewedUserName
│       ├── rating
│       ├── comment
│       └── createdAt
│
├── mentorshipForms/
│   └── {formId}/
│       ├── mentorId
│       ├── mentorName
│       ├── title
│       ├── description
│       ├── deadline
│       ├── questions: []
│       └── createdAt
│
├── formSubmissions/
│   └── {submissionId}/
│       ├── formId
│       ├── studentId
│       ├── studentName
│       ├── studentEmail
│       ├── mentorId
│       ├── responses: {}
│       ├── status
│       ├── acceptanceNote (optional)
│       ├── rejectionNote (optional)
│       ├── submittedAt
│       └── reviewedAt (optional)
│
├── mentorships/
│   └── {mentorshipId}/
│       ├── mentorId
│       ├── studentId
│       ├── studentName
│       ├── studentEmail
│       ├── status: 'active'
│       ├── acceptedAt
│       └── createdAt
│
└── notifications/
    └── {notificationId}/
        ├── userId
        ├── title
        ├── body
        ├── type
        ├── relatedId (optional)
        ├── isRead
        └── createdAt
```

### Required Firestore Indexes

To avoid "index required" errors, create these composite indexes:

#### 1. Notifications Index

```
Collection: notifications
Fields:
  - userId (Ascending)
  - createdAt (Descending)
```

#### 2. Notifications Unread Index

```
Collection: notifications
Fields:
  - userId (Ascending)
  - isRead (Ascending)
```

#### 3. Mentorships Index

```
Collection: mentorships
Fields:
  - mentorId (Ascending)
  - status (Ascending)
  - acceptedAt (Descending)
```

#### 4. Mentorships Student Index

```
Collection: mentorships
Fields:
  - studentId (Ascending)
  - status (Ascending)
  - acceptedAt (Descending)
```

#### 5. Meetings Participants Index

```
Collection: meetings
Fields:
  - participants (Array)
  - status (Ascending)
  - dateTime (Ascending)
```

#### 6. Meetings All Index

```
Collection: meetings
Fields:
  - participants (Array)
  - dateTime (Ascending)
```

#### 7. Reviews Reviewed User Index

```
Collection: reviews
Fields:
  - reviewedUserId (Ascending)
  - createdAt (Descending)
```

#### 8. Resources Mentor Index

```
Collection: resources
Fields:
  - mentorId (Ascending)
  - createdAt (Descending)
```

#### How to Create Indexes

1. **Via Firebase Console**:

   - Open Firebase Console → Firestore Database
   - Click "Indexes" tab
   - Click "Create Index"
   - Add fields as specified above
   - Click "Create"

2. **Via Error Links**:
   - Run the app and trigger the feature
   - When index error occurs, click the link in the error
   - Automatically creates the index
   - Wait 2-5 minutes for completion

### Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return request.auth.uid == userId;
    }

    // Users collection
    match /users/{userId} {
      allow read: if isAuthenticated();
      allow write: if isOwner(userId);
    }

    // Chats collection
    match /chats/{chatId} {
      allow read, write: if isAuthenticated() &&
        request.auth.uid in resource.data.participants;
    }

    // Messages collection
    match /messages/{messageId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated() &&
        request.auth.uid == request.resource.data.senderId;
      allow update, delete: if isAuthenticated() &&
        request.auth.uid == resource.data.senderId;
    }

    // Meetings collection
    match /meetings/{meetingId} {
      allow read: if isAuthenticated() &&
        request.auth.uid in resource.data.participants;
      allow create: if isAuthenticated();
      allow update: if isAuthenticated() &&
        request.auth.uid in resource.data.participants;
      allow delete: if isAuthenticated() &&
        request.auth.uid in resource.data.participants;
    }

    // Resources collection
    match /resources/{resourceId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated();
      allow update, delete: if isAuthenticated() &&
        request.auth.uid == resource.data.mentorId;
    }

    // Reviews collection
    match /reviews/{reviewId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated();
      allow update, delete: if isAuthenticated() &&
        request.auth.uid == resource.data.reviewerId;
    }

    // Mentorship Forms collection
    match /mentorshipForms/{formId} {
      allow read: if isAuthenticated();
      allow create, update, delete: if isAuthenticated() &&
        request.auth.uid == resource.data.mentorId;
    }

    // Form Submissions collection
    match /formSubmissions/{submissionId} {
      allow read: if isAuthenticated() &&
        (request.auth.uid == resource.data.studentId ||
         request.auth.uid == resource.data.mentorId);
      allow create: if isAuthenticated() &&
        request.auth.uid == request.resource.data.studentId;
      allow update: if isAuthenticated() &&
        request.auth.uid == resource.data.mentorId;
    }

    // Mentorships collection
    match /mentorships/{mentorshipId} {
      allow read: if isAuthenticated() &&
        (request.auth.uid == resource.data.mentorId ||
         request.auth.uid == resource.data.studentId);
      allow create, update: if isAuthenticated();
    }

    // Notifications collection
    match /notifications/{notificationId} {
      allow read, update: if isAuthenticated() &&
        request.auth.uid == resource.data.userId;
      allow create: if isAuthenticated();
    }
  }
}
```

### Firebase Authentication Setup

1. **Enable Email/Password Authentication**:

   - Firebase Console → Authentication
   - Sign-in method tab
   - Enable "Email/Password"

2. **Email Verification**:

   - Automatically sent on registration
   - Template customizable in Firebase Console
   - Users must verify before full access

3. **Password Reset**:
   - Handled via Firebase Auth
   - Email template in Firebase Console
   - Users can reset from login screen

---

## Testing Guide

### Test Accounts Setup

Create test accounts for both roles:

**Mentor Account**:

```
Email: mentor@test.com
Password: test123
Name: Test Mentor
Role: Mentor
```

**Student Account**:

```
Email: student@test.com
Password: test123
Name: Test Student
Role: Student
```

### Feature Testing Checklist

#### Authentication

- [ ] Register new student account
- [ ] Register new mentor account
- [ ] Verify email verification sent
- [ ] Login with valid credentials
- [ ] Login with invalid credentials (should fail)
- [ ] Reset password
- [ ] Logout and login again

#### Student Features

- [ ] Browse mentor list
- [ ] View mentor profile
- [ ] Fill and submit mentorship form
- [ ] View submission status
- [ ] Send message to mentor
- [ ] Receive and read messages
- [ ] View shared resources
- [ ] Open resource links
- [ ] Request meeting
- [ ] View upcoming meetings
- [ ] Write review for mentor
- [ ] View profile
- [ ] Edit profile

#### Mentor Features

- [ ] Create mentorship form
- [ ] View form submissions
- [ ] Accept student submission
- [ ] Reject student submission
- [ ] Download submission as CSV
- [ ] Download submission as TXT
- [ ] View mentees list
- [ ] Send message to student
- [ ] Share new resource
- [ ] Schedule meeting
- [ ] Approve meeting request
- [ ] Decline meeting request
- [ ] Postpone meeting
- [ ] Write review for student
- [ ] View reviews received

#### Notifications

- [ ] Receive notification for new message
- [ ] Receive notification for meeting request
- [ ] Receive notification for form submission (mentor)
- [ ] Receive notification for acceptance (student)
- [ ] Receive notification for new resource (student)
- [ ] Receive notification for review
- [ ] Unread badge appears on bell icon
- [ ] Unread count accurate
- [ ] Mark notification as read
- [ ] Badge updates after reading

#### Chat Features

- [ ] Unread badge on chat tab
- [ ] Unread badge on drawer chat item
- [ ] Send text message
- [ ] Send image from camera
- [ ] Send image from gallery
- [ ] View image full screen
- [ ] Unread count updates
- [ ] Mark messages as read

#### Meeting Features

- [ ] View upcoming meetings
- [ ] View past meetings
- [ ] Join online meeting (link opens)
- [ ] View physical meeting location
- [ ] Cancel meeting
- [ ] Mark meeting as completed
- [ ] Meeting stats in dashboard

### Testing Scenarios

#### Scenario 1: Complete Mentorship Flow

1. Student registers and verifies email
2. Student browses mentors
3. Student applies via form
4. Mentor receives notification
5. Mentor reviews and accepts
6. Student becomes mentee
7. Student receives acceptance notification
8. Mentorship created in database

#### Scenario 2: Meeting Lifecycle

1. Mentor schedules meeting with student
2. Student receives notification
3. Student approves meeting
4. Both see meeting in upcoming list
5. Meeting date arrives
6. Participant joins (online) or attends (physical)
7. Meeting marked as completed
8. Moves to past meetings

#### Scenario 3: Chat Interaction

1. Student messages mentor
2. Unread badge appears for mentor
3. Mentor opens chat
4. Badge clears
5. Mentor replies
6. Student receives notification
7. Student reads message
8. Conversation continues

---

## Troubleshooting

### Common Issues & Solutions

#### 1. "Index Required" Error

**Symptom**: Error when opening notifications, meetings, or other screens.

**Solution**:

- Click the link in the error message
- Redirects to Firebase Console
- Index creation page opens automatically
- Click "Create Index"
- Wait 2-5 minutes
- Retry the action

#### 2. Email Not Sending

**Symptom**: No verification or password reset email received.

**Solutions**:

- Check spam/junk folder
- Verify email address is correct
- Wait 5-10 minutes
- Check Firebase Console → Authentication → Templates
- Ensure email service is enabled

#### 3. Images Not Uploading

**Symptom**: Profile or chat images fail to upload.

**Solutions**:

- Verify internet connection
- Check ImgBB API configuration in `image_upload_service.dart`
- Ensure image size < 10MB
- Try different image format (JPG/PNG)
- Check app permissions for storage

#### 4. Notifications Not Appearing

**Symptom**: No push notifications received.

**Solutions**:

- Check device notification settings
- Ensure app has notification permission
- Verify Firebase Cloud Messaging configured
- Check `google-services.json` file present
- Restart app

#### 5. Login Fails After Registration

**Symptom**: Cannot login with new account.

**Solutions**:

- Verify email first (check inbox)
- Ensure password meets requirements (6+ chars)
- Check internet connection
- Clear app data and retry
- Check Firebase Auth console for account status

#### 6. Forms Not Showing

**Symptom**: No forms visible in browse mentors.

**Solutions**:

- Ensure mentor has created forms
- Check form deadline hasn't passed
- Verify Firestore rules allow reading
- Check internet connection
- Pull to refresh

#### 7. Download Feature Not Working

**Symptom**: CSV/TXT files not downloading.

**Solutions**:

- Check device storage space
- Files save to: `/Android/data/com.example.mentorship_app/files/Downloads/`
- Use file manager to locate
- No permissions required
- Ensure form has submissions

#### 8. Chat Messages Delayed

**Symptom**: Messages take time to appear.

**Solutions**:

- Check internet connection
- Verify Firestore real-time listeners
- Restart app
- Check Firebase usage quotas
- Ensure both users online

#### 9. Meeting Time Zone Issues

**Symptom**: Meeting times showing incorrectly.

**Solutions**:

- All times stored in UTC
- Displayed in device's local time
- Verify device date/time settings
- Ensure automatic time zone enabled

#### 10. App Crashes on Startup

**Symptom**: App closes immediately after launch.

**Solutions**:

- Clear app data
- Reinstall app
- Check Android version (requires 5.0+)
- Ensure `google-services.json` configured
- Check device storage space

### Error Code Reference

| Code                     | Meaning              | Solution                |
| ------------------------ | -------------------- | ----------------------- |
| `user-not-found`         | Email not registered | Register or check email |
| `wrong-password`         | Incorrect password   | Reset password or retry |
| `email-already-in-use`   | Email exists         | Login instead           |
| `weak-password`          | Password < 6 chars   | Use stronger password   |
| `network-request-failed` | No internet          | Check connection        |
| `permission-denied`      | Firestore rule block | Check security rules    |
| `unauthenticated`        | Not logged in        | Login again             |

### Getting Help

If issues persist:

1. **Check Logs**:

   - Use `flutter logs` command
   - View Android Studio logcat
   - Check Firebase Console errors

2. **Report Bug**:

   - Provide error message
   - Steps to reproduce
   - Device and Android version
   - Screenshots if applicable

3. **Contact Support**:
   - Email: support@mentorconnect.app
   - Include account email (not password)
   - Describe issue in detail

---

## Development Guide

### Setting Up Development Environment

1. **Install Flutter SDK**

   ```bash
   # Download from flutter.dev
   # Add to PATH
   flutter doctor
   ```

2. **Install Android Studio**

   - Download Android Studio
   - Install Android SDK
   - Create emulator

3. **Clone & Setup**

   ```bash
   git clone <repository>
   cd mentorship_app
   flutter pub get
   ```

4. **Configure Firebase**

   - Create Firebase project
   - Add Android app
   - Download `google-services.json`
   - Place in `android/app/`

5. **Configure ImgBB**

   - Get API key from imgbb.com
   - Update `image_upload_service.dart`:

   ```dart
   static const String _imgBbApiKey = 'YOUR_API_KEY';
   ```

6. **Run App**
   ```bash
   flutter run
   ```

### Code Style Guidelines

**Dart Style**:

- Use `dartfmt` for formatting
- Follow official Dart style guide
- Use meaningful variable names
- Comment complex logic

**File Naming**:

- snake_case for files
- PascalCase for classes
- camelCase for variables

**Widget Structure**:

```dart
class MyWidget extends StatefulWidget {
  const MyWidget({Key? key}) : super(key: key);

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  @override
  void initState() {
    super.initState();
    // Initialize
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // UI
    );
  }
}
```

### Adding New Features

1. **Plan Feature**:

   - Define requirements
   - Design data model
   - Plan UI screens

2. **Create Model**:

   ```dart
   // lib/models/my_model.dart
   class MyModel {
     final String id;
     final String name;

     MyModel({required this.id, required this.name});

     Map<String, dynamic> toMap() { /* ... */ }
     factory MyModel.fromMap(Map<String, dynamic> map) { /* ... */ }
   }
   ```

3. **Create Service**:

   ```dart
   // lib/services/my_service.dart
   class MyService {
     final FirebaseFirestore _firestore = FirebaseFirestore.instance;

     Future<void> createItem(MyModel item) async { /* ... */ }
     Stream<List<MyModel>> getItems() { /* ... */ }
   }
   ```

4. **Create Screen**:

   ```dart
   // lib/screens/my_screen.dart
   class MyScreen extends StatelessWidget {
     @override
     Widget build(BuildContext context) {
       return Scaffold(
         appBar: AppBar(title: Text('My Feature')),
         body: /* UI */,
       );
     }
   }
   ```

5. **Add Route**:

   ```dart
   // lib/config/routes.dart
   static const String myScreen = '/my-screen';

   case myScreen:
     return MaterialPageRoute(builder: (_) => MyScreen());
   ```

6. **Test Feature**:
   - Unit tests for models
   - Widget tests for UI
   - Integration tests for flows

### Building Release APK

```bash
# Clean build
flutter clean

# Get dependencies
flutter pub get

# Build release
flutter build apk --release

# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Versioning

Update in `pubspec.yaml`:

```yaml
version: 1.0.0+1
# Format: MAJOR.MINOR.PATCH+BUILD_NUMBER
```

### Deployment Checklist

- [ ] All features tested
- [ ] No lint errors
- [ ] Firestore indexes created
- [ ] Security rules updated
- [ ] API keys configured
- [ ] Version bumped
- [ ] Release notes written
- [ ] APK signed (for production)
- [ ] Privacy policy updated
- [ ] Screenshots taken

---

## Appendix

### Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Firebase
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  cloud_firestore: ^4.13.6
  firebase_messaging: ^14.7.9

  # State Management
  provider: ^6.1.1

  # UI
  cupertino_icons: ^1.0.6
  google_fonts: ^6.1.0
  flutter_svg: ^2.0.9
  cached_network_image: ^3.3.0
  shimmer: ^3.0.0

  # Forms
  flutter_form_builder: ^9.1.1
  form_builder_validators: ^11.0.0

  # Utilities
  intl: ^0.19.0
  table_calendar: ^3.0.9
  flutter_local_notifications: ^17.2.3
  timezone: ^0.9.2
  image_picker: ^1.0.4
  file_picker: ^6.1.1
  uuid: ^4.2.1
  url_launcher: ^6.2.2
  share_plus: ^7.2.1
  path_provider: ^2.1.1
  shared_preferences: ^2.2.2
  permission_handler: ^11.0.1
  csv: ^6.0.0
  font_awesome_flutter: ^10.6.0
  flutter_chat_bubble: ^2.0.2
  timeago: ^3.6.0
  http: ^1.1.0
```

### App Permissions

Android permissions required:

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
    android:maxSdkVersion="32" />
```

### App Size

- **APK Size**: ~45 MB (release)
- **Install Size**: ~120 MB
- **Min Android**: 5.0 (API 21)
- **Target Android**: 13 (API 35)

### Performance

- **Startup Time**: < 3 seconds
- **Chat Message Latency**: < 500ms
- **Image Upload Time**: 2-5 seconds
- **Database Queries**: Real-time streaming

### Security Features

- Email verification required
- Secure password storage (Firebase Auth)
- Firestore security rules enforced
- Data encrypted in transit (HTTPS)
- No sensitive data in local storage
- Session management via Firebase

### Privacy & Data

**Data Collected**:

- Email address
- Name and profile information
- Chat messages
- Form submissions
- Meeting schedules
- Reviews and ratings

**Data Usage**:

- Facilitate mentorship connections
- Enable communication
- Improve user experience
- Analytics (anonymous)

**Data Sharing**:

- Mentors see student submissions
- Students see mentor profiles
- No third-party data selling
- Images hosted on ImgBB (free service)

**User Rights**:

- Access your data
- Delete your account
- Export data (via download)
- Modify profile information

### Future Enhancements

Planned features:

1. **Video Calling**

   - Integrated video chat
   - Screen sharing
   - Recording capability

2. **Payment Integration**

   - Paid mentorship programs
   - Subscription tiers
   - Payment history

3. **Advanced Analytics**

   - Progress tracking
   - Learning metrics
   - Engagement reports

4. **Group Features**

   - Group chats
   - Webinars
   - Batch mentoring

5. **Gamification**

   - Achievement badges
   - Leaderboards
   - Rewards system

6. **AI Features**

   - Smart mentor matching
   - Automated suggestions
   - Chatbot support

7. **Multi-language**

   - Internationalization
   - RTL support
   - Language preferences

8. **Offline Mode**
   - Cached content
   - Offline message queue
   - Sync on reconnect

---

## Glossary

**APK**: Android Package Kit - installable file for Android apps

**BaaS**: Backend as a Service - cloud backend platform (Firebase)

**CSV**: Comma-Separated Values - spreadsheet file format

**Firestore**: NoSQL cloud database by Google

**Flutter**: Cross-platform UI framework by Google

**ImgBB**: Free image hosting service

**Mentee**: Student receiving mentorship

**Mentor**: Individual providing guidance

**NoSQL**: Non-relational database structure

**Provider**: State management pattern in Flutter

**Real-time**: Instant data synchronization

**Stream**: Continuous data flow (live updates)

**Widget**: UI building block in Flutter

---

## Contact & Support

### Developer Information

**App Name**: MentorConnect  
**Version**: 1.0.0  
**Developer**: [Your Name/Organization]  
**Email**: support@mentorconnect.app  
**Website**: [Your Website]

### Feedback

We value your feedback! Please reach out for:

- Feature requests
- Bug reports
- General inquiries
- Partnership opportunities

### Contributing

Interested in contributing?

- Fork the repository
- Create feature branch
- Submit pull request
- Follow code guidelines

### License

[Specify License - e.g., MIT, Apache 2.0]

---

## Changelog

### Version 1.0.0 (November 2025)

**Initial Release**:

- Complete authentication system
- Student and mentor dashboards
- Mentorship form system
- Chat and messaging
- Meeting scheduling
- Resource sharing
- Review and rating system
- Notification system
- Download feature (CSV/TXT)
- Real-time unread badges
- Complete UI with Material Design 3

**Bug Fixes**:

- Form submission routing fixed
- Meeting count statistics added
- Unread badge real-time updates
- Download permission handling

**Known Issues**:

- None reported

---

**End of Documentation**

This guide covers all aspects of MentorConnect. For additional help, please contact support.

**Last Updated**: November 15, 2025  
**Document Version**: 1.0
