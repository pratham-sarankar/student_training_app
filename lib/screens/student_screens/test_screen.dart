import 'dart:async';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import '../../services/assessment_results_service.dart';

class TestScreen extends StatefulWidget {
  final Map<String, dynamic> assessmentData;

  const TestScreen({super.key, required this.assessmentData});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  int _currentQuestionIndex = 0;
  Map<int, int> _selectedAnswers = {}; // Map<QuestionIndex, OptionIndex>
  late List<dynamic> _questions;
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _isSubmitted = false;

  @override
  void initState() {
    super.initState();
    _questions = widget.assessmentData['questions'] ?? [];
    if (_questions.isNotEmpty) {
      int durationMinutes = widget.assessmentData['duration_minutes'] ?? 0;
      _remainingSeconds = durationMinutes * 60;
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel();
        _submitTest();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _submitTest() {
    _timer?.cancel();
    setState(() {
      _isSubmitted = true;
    });
    // Calculate score
    int score = 0;
    for (int i = 0; i < _questions.length; i++) {
      if (_selectedAnswers[i] == _questions[i]['correct_option_index']) {
        score++;
      }
    }

    // Save result
    if (widget.assessmentData.containsKey('id')) {
      AssessmentResultsService().saveResult(
        widget.assessmentData['id'],
        score,
        _questions.length,
      );
    }

    // Show result dialog or navigate to result screen
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('Assessment Completed'),
            content: Text('You scored $score out of ${_questions.length}'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to assessments screen
                },
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: theme.colors.background,
        appBar: AppBar(
          backgroundColor: theme.colors.background,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: theme.colors.foreground),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Text(
            'No questions available for this assessment.',
            style: TextStyle(color: theme.colors.mutedForeground),
          ),
        ),
      );
    }

    final currentQuestion = _questions[_currentQuestionIndex];

    return Scaffold(
      backgroundColor: theme.colors.background,
      appBar: AppBar(
        backgroundColor: theme.colors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close, color: theme.colors.foreground),
          onPressed: () {
            // Confirm exit
            showDialog(
              context: context,
              builder:
                  (context) => AlertDialog(
                    title: const Text('Quit Assessment?'),
                    content: const Text('Your progress will be lost.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        child: const Text('Quit'),
                      ),
                    ],
                  ),
            );
          },
        ),
        title: Text(
          _formatTime(_remainingSeconds),
          style: TextStyle(
            color: theme.colors.primary,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress Bar
            LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / _questions.length,
              backgroundColor: theme.colors.muted.withValues(alpha: 0.2),
              color: theme.colors.primary,
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
            const SizedBox(height: 16),

            // Question Counter
            Text(
              'Question ${_currentQuestionIndex + 1}/${_questions.length}',
              style: TextStyle(
                color: theme.colors.mutedForeground,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            // Question Text
            Text(
              currentQuestion['question'],
              style: TextStyle(
                color: theme.colors.foreground,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // Options
            Expanded(
              child: ListView.builder(
                itemCount: (currentQuestion['options'] as List).length,
                itemBuilder: (context, index) {
                  final option = currentQuestion['options'][index];
                  final isSelected =
                      _selectedAnswers[_currentQuestionIndex] == index;

                  return GestureDetector(
                    onTap:
                        _isSubmitted
                            ? null
                            : () {
                              setState(() {
                                _selectedAnswers[_currentQuestionIndex] = index;
                              });
                            },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? theme.colors.primary.withValues(alpha: 0.1)
                                : theme.colors.background,
                        border: Border.all(
                          color:
                              isSelected
                                  ? theme.colors.primary
                                  : theme.colors.border,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color:
                                    isSelected
                                        ? theme.colors.primary
                                        : theme.colors.mutedForeground,
                                width: 2,
                              ),
                              color: isSelected ? theme.colors.primary : null,
                            ),
                            child:
                                isSelected
                                    ? const Icon(
                                      Icons.check,
                                      size: 16,
                                      color: Colors.white,
                                    )
                                    : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              option,
                              style: TextStyle(
                                color:
                                    isSelected
                                        ? theme.colors.primary
                                        : theme.colors.foreground,
                                fontWeight:
                                    isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Navigation Buttons
            const SizedBox(height: 16),
            Row(
              children: [
                if (_currentQuestionIndex > 0)
                  Expanded(
                    child: FButton(
                      style: FButtonStyle.outline,
                      onPress: () {
                        setState(() {
                          _currentQuestionIndex--;
                        });
                      },
                      child: const Text('Previous'),
                    ),
                  ),
                if (_currentQuestionIndex > 0) const SizedBox(width: 16),
                Expanded(
                  child: FButton(
                    onPress: () {
                      if (_currentQuestionIndex < _questions.length - 1) {
                        setState(() {
                          _currentQuestionIndex++;
                        });
                      } else {
                        _submitTest();
                      }
                    },
                    child: Text(
                      _currentQuestionIndex < _questions.length - 1
                          ? 'Next'
                          : 'Submit',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
