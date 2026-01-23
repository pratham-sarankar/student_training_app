import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'test_screen.dart';
import '../../services/assessment_results_service.dart';
import '../../models/assessment_result.dart';
import '../../services/user_service.dart';
import 'assessment_analysis_screen.dart';
import '../../models/assessment_model.dart';

class AssessmentListScreen extends StatefulWidget {
  final String title;
  final List<dynamic> assessments;

  const AssessmentListScreen({
    super.key,
    required this.title,
    required this.assessments,
  });

  @override
  State<AssessmentListScreen> createState() => _AssessmentListScreenState();
}

class _AssessmentListScreenState extends State<AssessmentListScreen> {
  final AssessmentResultsService _resultsService = AssessmentResultsService();
  final UserService _userService = UserService();

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final userId = _userService.currentUser?.uid;

    return StreamBuilder<List<AssessmentResult>>(
      stream:
          userId != null
              ? _resultsService.getUserResults(userId)
              : Stream.value([]),
      builder: (context, snapshot) {
        final results = snapshot.data ?? [];
        final resultsMap = {for (var r in results) r.assessmentId: r};
        final analysis = _resultsService.analyzePerformance(
          widget.assessments,
          results,
        );
        final hasData = results.any(
          (r) => widget.assessments.any(
            (a) =>
                (a is Map ? a['id'] : (a as AssessmentModel).id) ==
                r.assessmentId,
          ),
        );

        return Scaffold(
          backgroundColor: theme.colors.background,
          appBar: AppBar(
            backgroundColor: theme.colors.background,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: theme.colors.foreground),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              widget.title,
              style: TextStyle(
                color: theme.colors.foreground,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            actions: [
              if (hasData)
                IconButton(
                  icon: Icon(
                    Icons.analytics_outlined,
                    color: theme.colors.primary,
                  ),
                  onPressed: () => _showAnalysisSheet(context, theme, analysis),
                  tooltip: 'View Analysis',
                ),
              const SizedBox(width: 8),
            ],
          ),
          body:
              widget.assessments.isEmpty
                  ? Center(
                    child: Text(
                      'No assessments available.',
                      style: TextStyle(color: theme.colors.mutedForeground),
                    ),
                  )
                  : Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          itemCount: widget.assessments.length,
                          itemBuilder: (context, index) {
                            final exam = widget.assessments[index];
                            final assessmentId =
                                exam is Map
                                    ? exam['id']
                                    : (exam as AssessmentModel).id;
                            final result = resultsMap[assessmentId];

                            return AssessmentCard(
                              data: exam,
                              result: result,
                              onTap: () async {
                                if (result != null) {
                                  // Navigating to analysis screen if completed
                                  final assessmentModel =
                                      exam is AssessmentModel
                                          ? exam
                                          : AssessmentModel.fromMap(
                                            exam as Map<String, dynamic>,
                                            (exam as Map)['id'] ?? '',
                                          );

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => AssessmentAnalysisScreen(
                                            assessment: assessmentModel,
                                            result: result,
                                          ),
                                    ),
                                  );

                                  return;
                                }

                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => TestScreen(
                                          assessmentData:
                                              exam is Map
                                                  ? exam as Map<String, dynamic>
                                                  : (exam as AssessmentModel)
                                                      .toMap(),
                                        ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
        );
      },
    );
  }

  void _showAnalysisSheet(
    BuildContext context,
    FThemeData theme,
    Map<String, List<String>> analysis,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.5,
            minChildSize: 0.3,
            maxChildSize: 0.9,
            expand: false,
            builder:
                (context, scrollController) => SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: theme.colors.muted.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Icon(
                            Icons.analytics_outlined,
                            color: theme.colors.primary,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Performance Analysis',
                            style: TextStyle(
                              color: theme.colors.foreground,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      if (analysis['strong']!.isNotEmpty) ...[
                        _buildResultRow(
                          theme,
                          'Strong Areas',
                          analysis['strong']!,
                          Colors.green,
                          Icons.trending_up,
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (analysis['weak']!.isNotEmpty) ...[
                        _buildResultRow(
                          theme,
                          'Areas for Improvement',
                          analysis['weak']!,
                          Colors.redAccent,
                          Icons.warning_amber_rounded,
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (analysis['average']!.isNotEmpty) ...[
                        _buildResultRow(
                          theme,
                          'Average Performance',
                          analysis['average']!,
                          Colors.orange,
                          Icons.remove_circle_outline,
                        ),
                        const SizedBox(height: 16),
                      ],
                      const SizedBox(height: 24),
                      FButton(
                        onPress: () => Navigator.pop(context),
                        style: FButtonStyle.outline,
                        child: const Text('Close Analysis'),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  Widget _buildResultRow(
    FThemeData theme,
    String label,
    List<String> items,
    Color color,
    IconData icon,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children:
                    items.map((item) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: color.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          item,
                          style: TextStyle(
                            color: color.withValues(
                              alpha: 0.8,
                            ), // Darken slightly for readability
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class AssessmentCard extends StatelessWidget {
  final dynamic data;
  final AssessmentResult? result;
  final VoidCallback onTap;

  const AssessmentCard({
    super.key,
    required this.data,
    this.result,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final Map<String, dynamic> assessmentMap =
        data is Map
            ? data as Map<String, dynamic>
            : (data as AssessmentModel).toMap();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.colors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "${assessmentMap['questions'] != null ? (assessmentMap['questions'] as List).length : assessmentMap['total_questions'] ?? 0} Questions",
                        style: TextStyle(
                          color: theme.colors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      "${assessmentMap['timeLimitMinutes'] ?? assessmentMap['duration_minutes'] ?? 15} mins",
                      style: TextStyle(
                        color: theme.colors.mutedForeground,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  assessmentMap['title'] ?? 'Assessment',
                  style: TextStyle(
                    color: theme.colors.foreground,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  assessmentMap['description'] ??
                      assessmentMap['subtitle'] ??
                      '',
                  style: TextStyle(
                    color: theme.colors.mutedForeground,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),

                // Footer: Show pass marks or user score if taken
                if (result != null)
                  Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colors.primary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colors.primary.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: theme.colors.primary,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Completed",
                                      style: TextStyle(
                                        color: theme.colors.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Finished on ${result!.timestamp.day}/${result!.timestamp.month}/${result!.timestamp.year}",
                                  style: TextStyle(
                                    color: theme.colors.mutedForeground,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    (result!.percentage >= 40)
                                        ? Colors.green.withValues(alpha: 0.1)
                                        : Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    "${result!.score}/${result!.totalQuestions}",
                                    style: TextStyle(
                                      color:
                                          (result!.percentage >= 40)
                                              ? Colors.green
                                              : Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    "${result!.percentage.toStringAsFixed(0)}%",
                                    style: TextStyle(
                                      color:
                                          (result!.percentage >= 40)
                                              ? Colors.green
                                              : Colors.red,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.bar_chart,
                            size: 14,
                            color: theme.colors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "Tap to review your answers",
                            style: TextStyle(
                              color: theme.colors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 16,
                        color: theme.colors.mutedForeground,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "Pass: ${assessmentMap['passingMarks'] ?? assessmentMap['pass_marks'] ?? 9} marks",
                        style: TextStyle(
                          color: theme.colors.mutedForeground,
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
