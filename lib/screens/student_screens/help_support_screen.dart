import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Help & Support',
          style: theme.typography.lg.copyWith(fontWeight: FontWeight.w600),
        ),
        backgroundColor: theme.colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colors.foreground),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Frequently Asked Questions',
              style: theme.typography.xl.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colors.foreground,
              ),
            ),
            const SizedBox(height: 16),
            _buildFAQItem(
              context,
              'How do I view my courses?',
              'You can view your purchased courses in the "My Courses" section on the Profile screen.',
            ),
            const SizedBox(height: 12),
            _buildFAQItem(
              context,
              'How can I update my profile?',
              'Go to "Edit Profile" from the Profile screen to update your personal information.',
            ),
            const SizedBox(height: 12),
            _buildFAQItem(
              context,
              'Where can I see my job subscriptions?',
              'You can manage your job alerts in the "Job Subscriptions" section on the Profile screen.',
            ),
            const SizedBox(height: 32),
            Text(
              'Contact Us',
              style: theme.typography.xl.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colors.foreground,
              ),
            ),
            const SizedBox(height: 16),
            _buildContactOption(
              context,
              icon: Icons.email_outlined,
              title: 'Email Support',
              subtitle: 'support@gradspark.com',
              onTap: () {
                // TODO: Implement email launch
              },
            ),
            const SizedBox(height: 12),
            _buildContactOption(
              context,
              icon: Icons.phone_outlined,
              title: 'Call Us',
              subtitle: '+1 234 567 8900',
              onTap: () {
                // TODO: Implement phone launch
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(BuildContext context, String question, String answer) {
    final theme = context.theme;

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        collapsedBackgroundColor: theme.colors.primary.withValues(alpha: 0.05),
        backgroundColor: theme.colors.primary.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: theme.colors.border),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: theme.colors.border),
        ),
        title: Text(
          question,
          style: theme.typography.base.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colors.foreground,
          ),
        ),
        children: [
          Text(
            answer,
            style: theme.typography.sm.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = context.theme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: theme.colors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.typography.base.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colors.foreground,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.typography.sm.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: theme.colors.mutedForeground),
          ],
        ),
      ),
    );
  }
}
