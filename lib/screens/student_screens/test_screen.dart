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
      // Use timeLimitMinutes from dynamic map
      int durationMinutes = widget.assessmentData['timeLimitMinutes'] ?? 15;
      _remainingSeconds = durationMinutes * 60;
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        if (mounted) {
          setState(() {
            _remainingSeconds--;
          });
        }
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
    if (mounted) {
      setState(() {
        _isSubmitted = true;
      });
    }

    // Calculate score
    int score = 0;
    for (int i = 0; i < _questions.length; i++) {
      if (_selectedAnswers[i] == _questions[i]['correctOptionIndex']) {
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

    final passingMarks = widget.assessmentData['passingMarks'] ?? 9;
    final isPassed = score >= passingMarks;

    // Show result dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => FDialog(
            title: Text(isPassed ? 'Congratulations!' : 'Try Again'),
            body: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPassed ? Icons.check_circle : Icons.cancel,
                  size: 48,
                  color: isPassed ? Colors.green : Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  'You scored $score out of ${_questions.length}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isPassed
                      ? 'You passed the assessment.'
                      : 'You did not reach the passing score of $passingMarks.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              FButton(
                onPress: () {
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
    final bool isLastQuestion = _currentQuestionIndex == _questions.length - 1;

    return Scaffold(
      backgroundColor: theme.colors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: theme.colors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close, color: theme.colors.foreground),
          onPressed: () {
            showDialog(
              context: context,
              builder:
                  (context) => FDialog(
                    title: const Text('Quit Assessment?'),
                    body: const Text('Your progress will be lost.'),
                    actions: [
                      FButton(
                        style: FButtonStyle.outline,
                        onPress: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      FButton(
                        style: FButtonStyle.destructive,
                        onPress: () {
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
            color: const Color(0xFF004D61),
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / _questions.length,
              backgroundColor: theme.colors.muted.withValues(alpha: 0.2),
              color: const Color(0xFF004D61),
              minHeight: 4,
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question Counter
                  Text(
                    'Question ${_currentQuestionIndex + 1}/${_questions.length}',
                    style: TextStyle(
                      color: theme.colors.mutedForeground,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Question Text
                  Text(
                    currentQuestion['questionText'],
                    style: TextStyle(
                      color: theme.colors.foreground,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 32),

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
                                    if (mounted) {
                                      setState(() {
                                        _selectedAnswers[_currentQuestionIndex] =
                                            index;
                                      });
                                    }
                                  },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colors.background,
                              border: Border.all(
                                color:
                                    isSelected
                                        ? const Color(0xFF004D61)
                                        : const Color(0xFFE0E0E0),
                                width: isSelected ? 1.5 : 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color:
                                          isSelected
                                              ? const Color(0xFF004D61)
                                              : const Color(0xFFBDBDBD),
                                      width: isSelected ? 6 : 1.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    option,
                                    style: TextStyle(
                                      color: theme.colors.foreground,
                                      fontSize: 16,
                                      fontWeight:
                                          isSelected
                                              ? FontWeight.w600
                                              : FontWeight.w500,
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
                ],
              ),
            ),
          ),

          // Bottom Buttons
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                if (isLastQuestion && _currentQuestionIndex > 0) ...[
                  Expanded(
                    child: FButton(
                      style: FButtonStyle.outline,
                      onPress: () {
                        if (mounted) setState(() => _currentQuestionIndex--);
                      },
                      child: const Text('Previous'),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                Expanded(
                  child: FButton(
                    onPress: () {
                      if (!isLastQuestion) {
                        if (mounted) setState(() => _currentQuestionIndex++);
                      } else {
                        _submitTest();
                      }
                    },
                    child: Text(
                      isLastQuestion ? 'Submit' : 'Next',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
