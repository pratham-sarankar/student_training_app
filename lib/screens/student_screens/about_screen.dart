import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Scaffold(
      backgroundColor: theme.colors.background,
      appBar: AppBar(
        title: Text(
          'About',
          style: theme.typography.lg.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colors.foreground,
          ),
        ),
        backgroundColor: theme.colors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: theme.colors.foreground,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 64,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: theme.colors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.school_rounded,
                          size: 60,
                          color: theme.colors.primary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Gradspark',
                        style: theme.typography.xl4.copyWith(
                          fontWeight: FontWeight.w800,
                          color: theme.colors.foreground,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Version 1.0.2',
                        style: theme.typography.sm.copyWith(
                          color: theme.colors.mutedForeground,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        'Gradspark is your ultimate companion for career growth and learning. We provide top-notch training courses and job opportunities to help you succeed in your professional journey.',
                        textAlign: TextAlign.center,
                        style: theme.typography.base.copyWith(
                          color: theme.colors.mutedForeground,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 48),
                      _buildLinkItem(
                        context,
                        title: 'Privacy Policy',
                        onTap:
                            () => _launchUrl('https://gradspark.com/privacy'),
                      ),
                      const SizedBox(height: 12),
                      _buildLinkItem(
                        context,
                        title: 'Terms of Service',
                        onTap: () => _launchUrl('https://gradspark.com/terms'),
                      ),
                      const SizedBox(height: 12),
                      _buildLinkItem(
                        context,
                        title: 'Official Website',
                        onTap: () => _launchUrl('https://gradspark.com'),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 40, bottom: 20),
                    child: Text(
                      '© 2026 Gradspark. All rights reserved.',
                      style: theme.typography.xs.copyWith(
                        color: theme.colors.mutedForeground.withValues(
                          alpha: 0.6,
                        ),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: theme.typography.base.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colors.foreground,
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: theme.colors.mutedForeground,
            ),
          ],
        ),
      ),
    );
  }
}
