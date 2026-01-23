import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import '../../services/assessment_service.dart';
import '../../models/assessment_model.dart';
import '../../models/user.dart';
import '../../services/assessment_results_service.dart';
import '../../models/assessment_result.dart';
import '../../services/user_service.dart';
import 'test_screen.dart';
import 'assessment_analysis_screen.dart';

class AssessmentsScreen extends StatefulWidget {
  const AssessmentsScreen({super.key});

  @override
  State<AssessmentsScreen> createState() => _AssessmentsScreenState();
}

class _AssessmentsScreenState extends State<AssessmentsScreen> {
  String _selectedCategory = 'Technical';
  final List<String> _categories = ['Technical', 'Non-Technical'];
  final AssessmentService _assessmentService = AssessmentService();
  final AssessmentResultsService _resultsService = AssessmentResultsService();
  final UserService _userService = UserService();

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final userId = _userService.currentUser?.uid;

    return Scaffold(
      backgroundColor: theme.colors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: theme.colors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Assessments',
          style: TextStyle(
            color: theme.colors.foreground,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: StreamBuilder<List<AssessmentModel>>(
        stream: _assessmentService.getAssessments(),
        builder: (context, assessmentSnapshot) {
          if (assessmentSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: theme.colors.primary),
            );
          }

          if (assessmentSnapshot.hasError) {
            return Center(child: Text('Error: ${assessmentSnapshot.error}'));
          }

          final allAssessments = assessmentSnapshot.data ?? [];

          return StreamBuilder<List<AssessmentResult>>(
            stream:
                userId != null
                    ? _resultsService.getUserResults(userId)
                    : Stream.value([]),
            builder: (context, resultSnapshot) {
              final filteredAssessments =
                  allAssessments
                      .where(
                        (a) =>
                            a.type.toLowerCase() ==
                            _selectedCategory.toLowerCase(),
                      )
                      .toList();

              // Group by Set Name
              final Map<String, List<AssessmentModel>> sets = {};
              for (var a in filteredAssessments) {
                if (!sets.containsKey(a.setName)) {
                  sets[a.setName] = [];
                }
                sets[a.setName]!.add(a);
              }

              final setNames = sets.keys.toList()..sort();

              return Column(
                children: [
                  // Custom Tabs
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children:
                          _categories.asMap().entries.map((entry) {
                            int idx = entry.key;
                            String category = entry.value;
                            bool isSelected = _selectedCategory == category;
                            Color activeColor =
                                category == 'Technical'
                                    ? const Color(0xFF0097A7)
                                    : Colors.amber;

                            return Expanded(
                              child: GestureDetector(
                                onTap:
                                    () => setState(
                                      () => _selectedCategory = category,
                                    ),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin:
                                      idx == 0
                                          ? const EdgeInsets.only(right: 8)
                                          : const EdgeInsets.only(left: 8),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        isSelected
                                            ? activeColor
                                            : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color:
                                          isSelected
                                              ? activeColor
                                              : theme.colors.border,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      category,
                                      style: theme.typography.sm.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color:
                                            isSelected
                                                ? Colors.white
                                                : theme.colors.mutedForeground,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ),

                  // Sets List
                  Expanded(
                    child:
                        setNames.isEmpty
                            ? Center(
                              child: Text(
                                'No $_selectedCategory assessments available.',
                                style: TextStyle(
                                  color: theme.colors.mutedForeground,
                                ),
                              ),
                            )
                            : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: setNames.length,
                              itemBuilder: (context, index) {
                                final setName = setNames[index];
                                final testCount = sets[setName]!.length;
                                return _buildSetCard(
                                  context,
                                  setName,
                                  testCount,
                                  sets[setName]!,
                                );
                              },
                            ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSetCard(
    BuildContext context,
    String setName,
    int testCount,
    List<AssessmentModel> tests,
  ) {
    final theme = context.theme;

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
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => SetDetailsScreen(
                      setName: setName,
                      category: _selectedCategory,
                      tests: tests,
                    ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.folder_open,
                    color: theme.colors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        setName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: theme.colors.foreground,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                        ),
                      ),
                      Text(
                        '$testCount Tests',
                        style: TextStyle(
                          color: theme.colors.mutedForeground,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (tests.any((t) => t.isFree))
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF0097A7,
                                ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                "Practice Set (Free)",
                                style: TextStyle(
                                  color: Color(0xFF0097A7),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          if (tests.any((t) => !t.isFree)) ...[
                            if (tests.any((t) => t.isFree))
                              const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                "Premium",
                                style: TextStyle(
                                  color: Colors.amber,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: theme.colors.mutedForeground),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SetDetailsScreen extends StatefulWidget {
  final String setName;
  final String category;
  final List<AssessmentModel> tests;

  const SetDetailsScreen({
    super.key,
    required this.setName,
    required this.category,
    required this.tests,
  });

  @override
  State<SetDetailsScreen> createState() => _SetDetailsScreenState();
}

class _SetDetailsScreenState extends State<SetDetailsScreen> {
  final UserService _userService = UserService();
  final AssessmentResultsService _resultsService = AssessmentResultsService();
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await _userService.getCurrentUserData();
    if (mounted) {
      setState(() => _currentUser = user);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _processAssessmentPurchase(AssessmentModel assessment) async {
    // Directly simulate successful purchase for now
    await _userService.purchaseAssessment(assessment.id);
    await _loadUser();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${assessment.title}" has been unlocked!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showEnrolmentDialog(AssessmentModel assessment) {
    showDialog(
      context: context,
      builder:
          (context) => FDialog(
            title: const Text('Unlock Premium Assessment'),
            body: Text(
              'This is a premium assessment (₹${assessment.price.toStringAsFixed(0)}). Would you like to unlock it and start the test?',
            ),
            actions: [
              FButton(
                onPress: () => Navigator.pop(context),
                style: FButtonStyle.ghost,
                child: const Text('Cancel'),
              ),
              FButton(
                onPress: () {
                  Navigator.pop(context);
                  _processAssessmentPurchase(assessment);
                },
                child: const Text('Unlock Now'),
              ),
            ],
          ),
    );
  }

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

        return Scaffold(
          backgroundColor: theme.colors.background,
          appBar: AppBar(
            backgroundColor: theme.colors.background,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: theme.colors.foreground),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              '${widget.category} - ${widget.setName}',
              style: TextStyle(
                color: theme.colors.foreground,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: widget.tests.length,
            itemBuilder: (context, index) {
              final assessment = widget.tests[index];
              final result = resultsMap[assessment.id];
              return _buildTestCard(context, assessment, result);
            },
          ),
        );
      },
    );
  }

  Widget _buildTestCard(
    BuildContext context,
    AssessmentModel assessment,
    AssessmentResult? result,
  ) {
    final theme = context.theme;

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
          onTap: () async {
            if (result != null) {
              // Show Analysis
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => AssessmentAnalysisScreen(
                        assessment: assessment,
                        result: result,
                      ),
                ),
              );
              return;
            }

            if (!assessment.isFree) {
              final isPurchased =
                  _currentUser?.purchasedAssessments.contains(assessment.id) ??
                  false;
              if (!isPurchased) {
                _showEnrolmentDialog(assessment);
                return;
              }
            }

            await Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => TestScreen(assessmentData: assessment.toMap()),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
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
                            "${assessment.questions.length} Questions",
                            style: TextStyle(
                              color: theme.colors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "${assessment.timeLimitMinutes} mins",
                          style: TextStyle(
                            color: theme.colors.mutedForeground,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color:
                            assessment.isFree
                                ? const Color(0xFF0097A7).withValues(alpha: 0.1)
                                : Colors.amber.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        assessment.isFree
                            ? "Practice Set"
                            : "₹${assessment.price.toStringAsFixed(0)}",
                        style: TextStyle(
                          color:
                              assessment.isFree
                                  ? const Color(0xFF0097A7)
                                  : Colors.amber,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  assessment.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme.colors.foreground,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                ),
                if (assessment.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    assessment.description,
                    style: TextStyle(
                      color: theme.colors.mutedForeground,
                      fontSize: 14,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 16,
                          color: theme.colors.mutedForeground,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "Pass: ${assessment.passingMarks} marks",
                          style: TextStyle(
                            color: theme.colors.mutedForeground,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),

                    if (result != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: theme.colors.primary.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 14,
                              color: theme.colors.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Completed',
                              style: TextStyle(
                                color: theme.colors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
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
