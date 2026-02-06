import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:forui/forui.dart';
import 'add_assessment_screen.dart';
import '../../providers/admin_provider.dart';
import '../../models/assessment_model.dart';

class AdminAssessmentsScreen extends StatefulWidget {
  const AdminAssessmentsScreen({super.key});

  @override
  State<AdminAssessmentsScreen> createState() => _AdminAssessmentsScreenState();
}

class _AdminAssessmentsScreenState extends State<AdminAssessmentsScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh assessments when entering the screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadAssessments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Scaffold(
      backgroundColor: theme.colors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddAssessmentScreen(),
            ),
          );
        },
        backgroundColor: theme.colors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, child) {
          if (adminProvider.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: theme.colors.primary),
            );
          }

          if (adminProvider.assessments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    size: 64,
                    color: theme.colors.mutedForeground,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No assessments found',
                    style: TextStyle(
                      color: theme.colors.foreground,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to create a new assessment',
                    style: TextStyle(
                      color: theme.colors.mutedForeground,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          // Group by Set Name
          final Map<String, List<AssessmentModel>> sets = {};
          for (var a in adminProvider.assessments) {
            if (!sets.containsKey(a.setName)) {
              sets[a.setName] = [];
            }
            sets[a.setName]!.add(a);
          }

          final setNames = sets.keys.toList()..sort();

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: setNames.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final setName = setNames[index];
              final tests = sets[setName]!;
              return _buildSetCard(context, setName, tests);
            },
          );
        },
      ),
    );
  }

  Widget _buildSetCard(
    BuildContext context,
    String setName,
    List<AssessmentModel> tests,
  ) {
    final theme = context.theme;

    return Container(
      decoration: BoxDecoration(
        color: theme.colors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        AdminSetDetailsScreen(setName: setName, tests: tests),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.folder_copy_outlined,
                    color: theme.colors.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        setName,
                        style: TextStyle(
                          color: theme.colors.foreground,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${tests.length} Tests inside',
                        style: TextStyle(
                          color: theme.colors.mutedForeground,
                          fontSize: 13,
                        ),
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

class AdminSetDetailsScreen extends StatefulWidget {
  final String setName;
  final List<AssessmentModel> tests;

  const AdminSetDetailsScreen({
    super.key,
    required this.setName,
    required this.tests,
  });

  @override
  State<AdminSetDetailsScreen> createState() => _AdminSetDetailsScreenState();
}

class _AdminSetDetailsScreenState extends State<AdminSetDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final provider = context.read<AdminProvider>();

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
          widget.setName,
          style: TextStyle(
            color: theme.colors.foreground,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: widget.tests.length,
        itemBuilder: (context, index) {
          final assessment = widget.tests[index];
          return _buildAssessmentInSetCard(context, assessment, provider);
        },
      ),
    );
  }

  Widget _buildAssessmentInSetCard(
    BuildContext context,
    AssessmentModel assessment,
    AdminProvider provider,
  ) {
    final theme = context.theme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color:
                assessment.type.toLowerCase() == 'technical'
                    ? const Color(0xFF0097A7).withValues(alpha: 0.1)
                    : Colors.amber.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            assessment.type.toLowerCase() == 'technical'
                ? Icons.code
                : Icons.psychology,
            color:
                assessment.type.toLowerCase() == 'technical'
                    ? const Color(0xFF0097A7)
                    : Colors.amber[700],
            size: 20,
          ),
        ),
        title: Text(
          assessment.title,
          style: TextStyle(
            color: theme.colors.foreground,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${assessment.questions.length} Qs • ${assessment.timeLimitMinutes} mins • Pass: ${assessment.passingMarks}',
              style: TextStyle(
                color: theme.colors.mutedForeground,
                fontSize: 12,
              ),
            ),
            if (assessment.description.isNotEmpty)
              Text(
                assessment.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: theme.colors.mutedForeground,
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.delete_outline,
            color: theme.colors.destructive,
            size: 20,
          ),
          onPressed: () => _confirmDelete(context, assessment, provider),
        ),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    AssessmentModel assessment,
    AdminProvider provider,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => FDialog(
            title: const Text('Delete Assessment'),
            body: Text(
              'Are you sure you want to delete "${assessment.title}"?',
            ),
            actions: [
              FButton(
                style: FButtonStyle.outline,
                onPress: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FButton(
                style: FButtonStyle.destructive,
                onPress: () async {
                  final navigator = Navigator.of(context);
                  navigator.pop(); // Close the dialog

                  await provider.deleteAssessment(assessment.id);

                  if (mounted) {
                    setState(() {
                      widget.tests.removeWhere((t) => t.id == assessment.id);
                    });

                    if (widget.tests.isEmpty) {
                      navigator.pop(); // Close the details screen
                    }
                  }
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}
