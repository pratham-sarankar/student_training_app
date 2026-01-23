import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import '../../models/assessment_model.dart';
import '../../models/assessment_result.dart';

class AssessmentAnalysisScreen extends StatelessWidget {
  final AssessmentModel assessment;
  final AssessmentResult result;

  const AssessmentAnalysisScreen({
    super.key,
    required this.assessment,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final isPassed = result.score >= assessment.passingMarks;

    return Scaffold(
      backgroundColor: theme.colors.background,
      appBar: AppBar(
        backgroundColor: theme.colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colors.foreground),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Assessment Analysis',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          _buildSummaryCard(theme, isPassed),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: assessment.questions.length,
              itemBuilder: (context, index) {
                return _buildQuestionAnalysis(context, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(FThemeData theme, bool isPassed) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            isPassed
                ? Colors.green.withValues(alpha: 0.05)
                : Colors.red.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isPassed
                  ? Colors.green.withValues(alpha: 0.2)
                  : Colors.red.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
                  isPassed
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.red.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPassed ? Icons.check_circle : Icons.cancel,
              size: 32,
              color: isPassed ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPassed ? 'Assessment Passed' : 'Assessment Failed',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isPassed ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Score: ${result.score}/${result.totalQuestions}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.colors.foreground,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(width: 1, height: 12, color: theme.colors.border),
                    const SizedBox(width: 12),
                    Text(
                      '${result.percentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colors.mutedForeground,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionAnalysis(BuildContext context, int index) {
    final theme = context.theme;
    final question = assessment.questions[index];
    final selectedOption = result.selectedAnswers[index];
    final correctOption = question.correctOptionIndex;
    final isCorrect = selectedOption == correctOption;
    final isUnattempted = selectedOption == null;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'QUESTION ${index + 1}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: theme.colors.mutedForeground,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              _buildStatusBadge(isUnattempted, isCorrect),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            question.questionText,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(question.options.length, (optIdx) {
            final isUsersChoice = optIdx == selectedOption;
            final isCorrectAns = optIdx == correctOption;

            if (!isUsersChoice && !isCorrectAns) return const SizedBox.shrink();

            return Container(
              margin: const EdgeInsets.only(top: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color:
                    isCorrectAns
                        ? Colors.green.withValues(alpha: 0.05)
                        : Colors.red.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color:
                      isCorrectAns
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.red.withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isCorrectAns ? Icons.check_circle : Icons.cancel,
                    size: 14,
                    color: isCorrectAns ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isCorrectAns
                          ? 'Correct: ${question.options[optIdx]}'
                          : 'Your Choice: ${question.options[optIdx]}',
                      style: TextStyle(
                        fontSize: 13,
                        color:
                            isCorrectAns ? Colors.green[700] : Colors.red[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isUnattempted, bool isCorrect) {
    Color color = Colors.red;
    String text = 'Wrong';
    IconData icon = Icons.close;

    if (isUnattempted) {
      color = Colors.orange;
      text = 'Skipped';
      icon = Icons.redo;
    } else if (isCorrect) {
      color = Colors.green;
      text = 'Correct';
      icon = Icons.check;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
