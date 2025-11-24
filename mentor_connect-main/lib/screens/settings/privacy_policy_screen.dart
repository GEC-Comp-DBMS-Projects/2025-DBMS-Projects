import 'package:flutter/material.dart';
import '../../config/theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          const Text(
            'Privacy Policy',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Last updated: October 22, 2025',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),

          // Introduction
          _buildSection(
            title: '1. Introduction',
            content:
                'Welcome to MentorConnect. We respect your privacy and are committed to protecting your personal data. This privacy policy will inform you about how we handle your personal information when you use our app.',
          ),

          _buildSection(
            title: '2. Information We Collect',
            content: 'We collect and process the following information:\n\n'
                '• Account Information: Name, email address, role (mentor/student)\n'
                '• Profile Information: Bio, phone number, profile picture, expertise, and interests\n'
                '• Usage Data: Messages, resources shared, form submissions, reviews\n'
                '• Device Information: Device type, operating system, app version',
          ),

          _buildSection(
            title: '3. How We Use Your Information',
            content: 'We use your information to:\n\n'
                '• Provide and maintain our services\n'
                '• Connect students with mentors\n'
                '• Enable communication between users\n'
                '• Share educational resources\n'
                '• Improve our services and user experience\n'
                '• Send important notifications about your account',
          ),

          _buildSection(
            title: '4. Data Storage & Security',
            content:
                'Your data is securely stored using Firebase and Google Cloud Platform services. We implement appropriate security measures to protect your personal information from unauthorized access, alteration, disclosure, or destruction.',
          ),

          _buildSection(
            title: '5. Information Sharing',
            content:
                'We do not sell, trade, or rent your personal information to third parties. Your information is only shared:\n\n'
                '• With other users as necessary for the app\'s functionality (e.g., profile information visible to connected mentors/students)\n'
                '• When required by law or to protect our rights\n'
                '• With service providers who help us operate the app (e.g., Firebase)',
          ),

          _buildSection(
            title: '6. Your Rights',
            content: 'You have the right to:\n\n'
                '• Access your personal data\n'
                '• Update or correct your information\n'
                '• Delete your account and associated data\n'
                '• Opt-out of certain communications\n'
                '• Request a copy of your data',
          ),

          _buildSection(
            title: '7. Data Retention',
            content:
                'We retain your personal information for as long as your account is active or as needed to provide you services. If you delete your account, we will delete or anonymize your personal information within 30 days.',
          ),

          _buildSection(
            title: '8. Children\'s Privacy',
            content:
                'Our service is intended for users aged 13 and above. We do not knowingly collect personal information from children under 13. If you believe we have collected information from a child under 13, please contact us immediately.',
          ),

          _buildSection(
            title: '9. Third-Party Services',
            content: 'Our app uses the following third-party services:\n\n'
                '• Firebase (Authentication, Database, Hosting)\n'
                '• ImgBB (Image Hosting)\n\n'
                'These services have their own privacy policies governing the use of your information.',
          ),

          _buildSection(
            title: '10. Changes to This Policy',
            content:
                'We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "Last updated" date.',
          ),

          _buildSection(
            title: '11. Contact Us',
            content:
                'If you have any questions about this Privacy Policy, please contact us:\n\n'
                '• Email: support@mentorshipapp.com\n'
                '• Website: www.mentorshipapp.com',
          ),

          const SizedBox(height: 24),

          // Consent
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.verified_user,
                  color: AppTheme.primaryColor,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'By using MentorConnect, you agree to this Privacy Policy.',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
