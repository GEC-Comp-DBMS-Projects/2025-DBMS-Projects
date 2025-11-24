import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/role_selection_screen.dart';
import '../screens/auth/email_verification_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/student/student_dashboard.dart';
import '../screens/student/browse_mentors_screen.dart';
import '../screens/student/mentor_profile_screen.dart';
import '../screens/student/fill_form_screen.dart';
import '../screens/student/my_submissions_screen.dart';
import '../screens/student/student_meetings_screen.dart';
import '../screens/mentor/mentor_dashboard.dart';
import '../screens/mentor/create_form_screen.dart';
import '../screens/mentor/form_submissions_screen.dart';
import '../screens/mentor/submission_detail_screen.dart';
import '../screens/mentor/my_mentees_screen.dart';
import '../screens/mentor/schedule_meeting_screen.dart';
import '../screens/student/meetings_list_screen.dart';
import '../screens/student/meeting_detail_screen.dart';
import '../screens/mentor/my_forms_screen.dart';
import '../screens/mentor/mentorship_migration_screen.dart';
import '../screens/chat/chat_list_screen.dart';
import '../screens/chat/chat_detail_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/resources/resources_screen.dart';
import '../screens/resources/add_resource_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/settings/privacy_policy_screen.dart';
import '../screens/about/about_screen.dart';
import '../screens/reviews/reviews_screen.dart';
import '../screens/reviews/add_review_screen.dart';

class AppRoutes {
  // Route names
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String roleSelection = '/role-selection';
  static const String emailVerification = '/email-verification';
  static const String forgotPassword = '/forgot-password';

  // Student routes
  static const String studentDashboard = '/student/dashboard';
  static const String browseMentors = '/student/browse-mentors';
  static const String mentorProfile = '/student/mentor-profile';
  static const String fillForm = '/student/fill-form';
  static const String mySubmissions = '/student/my-submissions';
  static const String studentMeetings = '/student/meetings';

  // Mentor routes
  static const String mentorDashboard = '/mentor/dashboard';
  static const String createForm = '/mentor/create-form';
  static const String myForms = '/mentor/my-forms';
  static const String formSubmissions = '/mentor/form-submissions';
  static const String submissionDetail = '/mentor/submission-detail';
  static const String myMentees = '/mentor/my-mentees';
  static const String scheduleMeeting = '/mentor/schedule-meeting';
  static const String mentorshipMigration = '/mentor/mentorship-migration';

  // Common routes
  static const String chatList = '/chat-list';
  static const String chatDetail = '/chat-detail';
  static const String notifications = '/notifications';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String resources = '/resources';
  static const String addResource = '/add-resource';
  static const String settings = '/settings';
  static const String privacyPolicy = '/privacy-policy';
  static const String about = '/about';
  static const String reviews = '/reviews';
  static const String addReview = '/add-review';

  // Meeting routes
  static const String meetingsList = '/meetings-list';
  static const String meetingDetail = '/meeting-detail';

  // Route generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case register:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => RegisterScreen(
            role: args?['role'],
          ),
        );

      case roleSelection:
        return MaterialPageRoute(builder: (_) => const RoleSelectionScreen());

      case emailVerification:
        return MaterialPageRoute(
            builder: (_) => const EmailVerificationScreen());

      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());

      // Student routes
      case studentDashboard:
        return MaterialPageRoute(builder: (_) => const StudentDashboard());

      case browseMentors:
        return MaterialPageRoute(builder: (_) => const BrowseMentorsScreen());

      case mentorProfile:
        final mentorId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => MentorProfileScreen(mentorId: mentorId),
        );

      case fillForm:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => FillFormScreen(
            formId: args['formId'],
            mentorId: args['mentorId'],
          ),
        );

      case mySubmissions:
        return MaterialPageRoute(builder: (_) => const MySubmissionsScreen());

      case studentMeetings:
        return MaterialPageRoute(builder: (_) => const StudentMeetingsScreen());

      // Mentor routes
      case mentorDashboard:
        return MaterialPageRoute(builder: (_) => const MentorDashboard());

      case createForm:
        final formId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => CreateFormScreen(formId: formId),
        );

      case myForms:
        return MaterialPageRoute(builder: (_) => const MyFormsScreen());

      case formSubmissions:
        final formId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => FormSubmissionsScreen(formId: formId),
        );

      case submissionDetail:
        final submissionId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => SubmissionDetailScreen(submissionId: submissionId),
        );

      case myMentees:
        return MaterialPageRoute(builder: (_) => const MyMenteesScreen());

      case scheduleMeeting:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ScheduleMeetingScreen(
            otherUserId: args['otherUserId'],
            otherUserName: args['otherUserName'],
            otherUserRole: args['otherUserRole'],
          ),
        );

      case mentorshipMigration:
        return MaterialPageRoute(
          builder: (_) => const MentorshipMigrationScreen(),
        );

      // Common routes
      case chatList:
        return MaterialPageRoute(builder: (_) => const ChatListScreen());

      case chatDetail:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ChatDetailScreen(
            chatId: args['chatId'],
            otherUserId: args['otherUserId'],
            otherUserName: args['otherUserName'],
            otherUserImage: args['otherUserImage'],
          ),
        );

      case notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());

      case profile:
        final userId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => ProfileScreen(userId: userId),
        );

      case editProfile:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());

      case AppRoutes.resources:
        return MaterialPageRoute(builder: (_) => const ResourcesScreen());

      case AppRoutes.addResource:
        return MaterialPageRoute(builder: (_) => const AddResourceScreen());

      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());

      case AppRoutes.privacyPolicy:
        return MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen());

      case AppRoutes.about:
        return MaterialPageRoute(builder: (_) => const AboutScreen());

      case AppRoutes.reviews:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ReviewsScreen(
            userId: args['userId'],
            userName: args['userName'],
            userRole: args['userRole'],
          ),
        );

      case AppRoutes.addReview:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => AddReviewScreen(
            revieweeId: args['revieweeId'],
            revieweeName: args['revieweeName'],
            revieweeRole: args['revieweeRole'],
          ),
        );

      case AppRoutes.meetingsList:
        return MaterialPageRoute(builder: (_) => const MeetingsListScreen());

      case AppRoutes.meetingDetail:
        final meetingId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => MeetingDetailScreen(meetingId: meetingId),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
