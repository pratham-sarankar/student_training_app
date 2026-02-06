import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/app_logo.png'),
                            fit: BoxFit.contain,
                          ),
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
                        'Gradspark is your ultimate companion for finding student jobs, internships, and professional training. We provide top-notch upskilling courses and career assessments to help graduates and students succeed in their professional journey in 2026.',
                        textAlign: TextAlign.center,
                        style: theme.typography.base.copyWith(
                          color: theme.colors.mutedForeground,
                          height: 1.6,
                        ),
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
}
