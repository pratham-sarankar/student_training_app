import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'assessment_list_screen.dart';
import '../../services/assessment_results_service.dart';

class AssessmentsScreen extends StatefulWidget {
  const AssessmentsScreen({super.key});

  @override
  State<AssessmentsScreen> createState() => _AssessmentsScreenState();
}

class _AssessmentsScreenState extends State<AssessmentsScreen> {
  Map<String, dynamic> _data = {};
  bool _isLoading = true;
  String _selectedCategory = 'Technical';
  final List<String> _categories = ['Technical', 'Non-Technical'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/data/assessments.json',
      );
      final data = json.decode(response);
      setState(() {
        _data = data;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading data: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

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
      body:
          _isLoading
              ? Center(
                child: CircularProgressIndicator(color: theme.colors.primary),
              )
              : Column(
                children: [
                  // Custom Tabs (Chips)
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

                            // Define custom colors
                            Color activeColor =
                                category == 'Technical'
                                    ? const Color(0xFF0097A7)
                                    : Colors.amber;
                            Color activeTextColor = Colors.white;

                            return Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedCategory = category;
                                  });
                                },
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
                                    boxShadow:
                                        isSelected
                                            ? [
                                              BoxShadow(
                                                color: activeColor.withValues(
                                                  alpha: 0.3,
                                                ),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ]
                                            : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '$category',
                                      style: theme.typography.sm.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color:
                                            isSelected
                                                ? activeTextColor
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

                  // Content
                  Expanded(child: _buildSetList(theme)),
                ],
              ),
    );
  }

  Widget _buildSetList(FThemeData theme) {
    // Currently acting as if multiple sets might exist, but hardcoding "Set 1" as per request
    final count =
        _selectedCategory == 'Technical'
            ? (_data['technical'] as List? ?? []).length
            : (_data['non_technical'] as List? ?? []).length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GestureDetector(
          onTap: () async {
            // Navigate to the list screen
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => AssessmentListScreen(
                      title: '$_selectedCategory - PracticeSet 1',
                      assessments:
                          _selectedCategory == 'Technical'
                              ? (_data['technical'] ?? [])
                              : (_data['non_technical'] ?? []),
                    ),
              ),
            );
            // Refresh to show any progress updates
            setState(() {});
          },
          child: Container(
            padding: const EdgeInsets.all(20),
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
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.folder_copy_outlined,
                    color: theme.colors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Practice Set 1',
                        style: TextStyle(
                          color: theme.colors.foreground,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$count Tests',
                        style: TextStyle(
                          color: theme.colors.mutedForeground,
                          fontSize: 14,
                        ),
                      ),
                      if (AssessmentResultsService().hasTakenAny(
                        _selectedCategory == 'Technical'
                            ? (_data['technical'] ?? [])
                            : (_data['non_technical'] ?? []),
                      )) ...[
                        const SizedBox(height: 8),
                        _buildSetStats(
                          theme,
                          _selectedCategory == 'Technical'
                              ? (_data['technical'] ?? [])
                              : (_data['non_technical'] ?? []),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: theme.colors.mutedForeground,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSetStats(FThemeData theme, List<dynamic> assessments) {
    final service = AssessmentResultsService();
    final avg = service.getAverageScore(assessments);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: theme.colors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'Avg Score: ${avg.toStringAsFixed(1)}%',
            style: TextStyle(
              color: theme.colors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
