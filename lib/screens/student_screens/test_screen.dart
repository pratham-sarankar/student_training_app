import 'dart:async';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import '../../services/assessment_results_service.dart';
import '../../models/assessment_result.dart';
import '../../services/user_service.dart';

class TestScreen extends StatefulWidget {
  final Map<String, dynamic> assessmentData;

  const TestScreen({super.key, required this.assessmentData});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  int _currentQuestionIndex = 0;
  final Map<int, int> _selectedAnswers = {}; // Map<QuestionIndex, OptionIndex>
  late List<dynamic> _questions;
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _isSubmitted = false;

  @override
  void initState() {
    super.initState();
    _questions = widget.assessmentData['questions'] ?? [];
    if (_questions.isNotEmpty) {
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

  void _submitTest() async {
    if (_isSubmitted) return;
    _timer?.cancel();
    if (mounted) {
      setState(() {
        _isSubmitted = true;
      });
    }

    final userId = UserService().currentUser?.uid;
    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User not authenticated. Progress not saved.'),
          ),
        );
        Navigator.pop(context);
      }
      return;
    }

    // Calculate score
    int score = 0;
    for (int i = 0; i < _questions.length; i++) {
      if (_selectedAnswers[i] == _questions[i]['correctOptionIndex']) {
        score++;
      }
    }

    // Save result
    final assessmentId = widget.assessmentData['id'];
    if (assessmentId != null) {
      final result = AssessmentResult(
        id: '', // Firestore will generate this
        assessmentId: assessmentId,
        userId: userId,
        score: score,
        totalQuestions: _questions.length,
        selectedAnswers: _selectedAnswers,
        timestamp: DateTime.now(),
      );

      try {
        await AssessmentResultsService().saveResult(result);
      } catch (e) {
        debugPrint("Error saving result: $e");
      }
    }

    final passingMarks = widget.assessmentData['passingMarks'] ?? 9;
    final isPassed = score >= passingMarks;

    if (!mounted) return;

    // Show result dialog with premium look
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => FDialog(
            title: Text(isPassed ? 'Test Completed!' : 'Test Completed'),
            body: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: (isPassed ? Colors.green : Colors.red).withValues(
                      alpha: 0.1,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPassed
                        ? Icons.emoji_events
                        : Icons.sentiment_dissatisfied,
                    size: 64,
                    color: isPassed ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  '${((score / _questions.length) * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: isPassed ? Colors.green : Colors.red,
                  ),
                ),
                Text(
                  'Your Score: $score / ${_questions.length}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  isPassed
                      ? 'Congratulations! You passed the assessment.'
                      : 'You did not reach the passing score of $passingMarks.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            actions: [
              FButton(
                onPress: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context, true); // Go back with success
                },
                child: const Text('Return to Assessments'),
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
            'No questions available.',
            style: TextStyle(color: theme.colors.mutedForeground),
          ),
        ),
      );
    }

    final currentQuestion = _questions[_currentQuestionIndex];
    final bool isLastQuestion = _currentQuestionIndex == _questions.length - 1;
    final bool isFirstQuestion = _currentQuestionIndex == 0;

    return Scaffold(
      backgroundColor: theme.colors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: theme.colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: theme.colors.foreground),
          onPressed: () {
            showDialog(
              context: context,
              builder:
                  (context) => FDialog(
                    title: const Text('Quit Assessment?'),
                    body: const Text(
                      'Your hard work will not be saved if you quit now.',
                    ),
                    actions: [
                      FButton(
                        style: FButtonStyle.ghost,
                        onPress: () => Navigator.pop(context),
                        child: const Text('Resume'),
                      ),
                      FButton(
                        style: FButtonStyle.destructive,
                        onPress: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        child: const Text('Quit Anyway'),
                      ),
                    ],
                  ),
            );
          },
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color:
                _remainingSeconds < 60
                    ? Colors.red.withValues(alpha: 0.1)
                    : theme.colors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.timer_outlined,
                size: 20,
                color:
                    _remainingSeconds < 60 ? Colors.red : theme.colors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                _formatTime(_remainingSeconds),
                style: TextStyle(
                  color:
                      _remainingSeconds < 60
                          ? Colors.red
                          : theme.colors.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / _questions.length,
            backgroundColor: theme.colors.muted.withValues(alpha: 0.1),
            color: theme.colors.primary,
            minHeight: 6,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'QUESTION ${_currentQuestionIndex + 1} OF ${_questions.length}',
                      style: TextStyle(
                        color: theme.colors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    currentQuestion['questionText'],
                    style: TextStyle(
                      color: theme.colors.foreground,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ...List.generate(
                    (currentQuestion['options'] as List).length,
                    (index) {
                      final option = currentQuestion['options'][index];
                      final isSelected =
                          _selectedAnswers[_currentQuestionIndex] == index;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: InkWell(
                          onTap: () {
                            if (!_isSubmitted) {
                              setState(() {
                                _selectedAnswers[_currentQuestionIndex] = index;
                              });
                            }
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? theme.colors.primary.withValues(
                                        alpha: 0.05,
                                      )
                                      : theme.colors.background,
                              border: Border.all(
                                color:
                                    isSelected
                                        ? theme.colors.primary
                                        : theme.colors.border,
                                width: isSelected ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow:
                                  isSelected
                                      ? [
                                        BoxShadow(
                                          color: theme.colors.primary
                                              .withValues(alpha: 0.1),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                      : [],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color:
                                          isSelected
                                              ? theme.colors.primary
                                              : theme.colors.mutedForeground,
                                      width: 2,
                                    ),
                                    color:
                                        isSelected
                                            ? theme.colors.primary
                                            : Colors.transparent,
                                  ),
                                  child:
                                      isSelected
                                          ? const Icon(
                                            Icons.check,
                                            size: 18,
                                            color: Colors.white,
                                          )
                                          : Center(
                                            child: Text(
                                              String.fromCharCode(65 + index),
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    theme
                                                        .colors
                                                        .mutedForeground,
                                              ),
                                            ),
                                          ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    option,
                                    style: TextStyle(
                                      color:
                                          isSelected
                                              ? theme.colors.foreground
                                              : theme.colors.mutedForeground,
                                      fontSize: 16,
                                      fontWeight:
                                          isSelected
                                              ? FontWeight.bold
                                              : FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colors.background,
              border: Border(top: BorderSide(color: theme.colors.border)),
            ),
            child: Row(
              children: [
                if (!isFirstQuestion) ...[
                  Expanded(
                    child: FButton(
                      style: FButtonStyle.outline,
                      onPress: () => setState(() => _currentQuestionIndex--),
                      child: const Text('Back'),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                Expanded(
                  flex: 2,
                  child: FButton(
                    onPress: () {
                      if (!isLastQuestion) {
                        setState(() => _currentQuestionIndex++);
                      } else {
                        _submitTest();
                      }
                    },
                    child: Text(
                      isLastQuestion ? 'Submit Test' : 'Next Question',
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
