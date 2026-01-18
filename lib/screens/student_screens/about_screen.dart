import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'About',
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
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: theme.colors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.school, size: 50, color: theme.colors.primary),
            ),
            const SizedBox(height: 24),
            Text(
              'Gradspark',
              style: theme.typography.xl4.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colors.foreground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Version 1.0.0',
              style: theme.typography.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Gradspark is your ultimate companion for career growth and learning. We provide top-notch training courses and job opportunities to help you succeed in your professional journey.',
              textAlign: TextAlign.center,
              style: theme.typography.base.copyWith(
                color: theme.colors.mutedForeground,
                height: 1.5,
              ),
            ),
            // _buildLinkItem(
            //   context,
            //   title: 'Privacy Policy',
            //   onTap: () {
            //     // TODO: Open Privacy Policy
            //   },
            // ),
            // const SizedBox(height: 12),
            // _buildLinkItem(
            //   context,
            //   title: 'Terms of Service',
            //   onTap: () {
            //     // TODO: Open Terms of Service
            //   },
            // ),
            // const SizedBox(height: 12),
            // _buildLinkItem(
            //   context,
            //   title: 'Rate Us',
            //   onTap: () {
            //     // TODO: Open App Store / Play Store
            //   },
            // ),
            const Spacer(),
            Text(
              '© 2024 Gradspark. All rights reserved.',
              style: theme.typography.xs.copyWith(
                color: theme.colors.mutedForeground.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkItem(
    BuildContext context, {
    required String title,
    required VoidCallback onTap,
  }) {
    final theme = context.theme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: theme.colors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.colors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: theme.typography.base.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colors.foreground,
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: theme.colors.mutedForeground,
            ),
          ],
        ),
      ),
    );
  }
}
