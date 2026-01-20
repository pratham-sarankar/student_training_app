import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class CourseAvatar extends StatelessWidget {
  final String title;
  final double size;

  const CourseAvatar({super.key, required this.title, this.size = 48});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final firstLetter = title.isNotEmpty ? title[0].toUpperCase() : '?';

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: theme.colors.muted,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          firstLetter,
          style: TextStyle(
            color: theme.colors.mutedForeground,
            fontWeight: FontWeight.w500,
            fontSize: size * 0.45,
          ),
        ),
      ),
    );
  }
}
