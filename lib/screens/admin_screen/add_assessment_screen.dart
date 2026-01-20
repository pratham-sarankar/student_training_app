import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:forui/forui.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:uuid/uuid.dart';
import '../../providers/admin_provider.dart';
import '../../models/assessment_model.dart';

class AddAssessmentScreen extends StatefulWidget {
  const AddAssessmentScreen({super.key});

  @override
  State<AddAssessmentScreen> createState() => _AddAssessmentScreenState();
}

class _AddAssessmentScreenState extends State<AddAssessmentScreen> {
  bool _isLoading = false;
  String _selectedType = 'Technical';

  Future<void> _importCSV() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null) {
        setState(() => _isLoading = true);
        final fileParams = result.files.single;
        final path = fileParams.path;

        // Extract Set Name from filename (strip extension and clean suffixes like "- Sheet1" or "(2)")
        String setName = fileParams.name.split('.').first;
        setName =
            setName
                .replaceAll(
                  RegExp(r'\s*-\s*Sheet\d+', caseSensitive: false),
                  '',
                )
                .replaceAll(RegExp(r'\s*\(\d+\)'), '')
                .trim();

        if (path != null) {
          final file = File(path);
          final csvString = await file.readAsString();

          final List<List<dynamic>> rows = const CsvToListConverter(
            eol: '\n',
            shouldParseNumbers: false,
          ).convert(csvString);

          List<List<dynamic>> processedRows = rows;
          if (rows.length <= 1 && csvString.contains('\r\n')) {
            processedRows = const CsvToListConverter(
              eol: '\r\n',
              shouldParseNumbers: false,
            ).convert(csvString);
          }

          if (processedRows.isEmpty) {
            throw Exception("Empty CSV file");
          }

          // Group by Subtitle (Index 0)
          // Row structure: Subtitle, SubtitleDescription, Question, Opt1, Opt2, Opt3, Opt4, CorrectIndex
          final Map<String, List<Question>> subtitleGroups = {};
          final Map<String, String> subtitleDescriptions = {};

          // Check for header
          int startRow = 0;
          if (processedRows.isNotEmpty &&
              processedRows[0].isNotEmpty &&
              processedRows[0][0].toString().toLowerCase().contains(
                'subtitle',
              )) {
            startRow = 1;
          }

          for (int i = startRow; i < processedRows.length; i++) {
            final row = processedRows[i];
            if (row.length < 8) continue;

            final subtitle = row[0].toString().trim();
            final subtitleDesc = row[1].toString().trim();
            if (subtitle.isEmpty) continue;

            final qText = row[2].toString().trim();
            final options = [
              row[3].toString().trim(),
              row[4].toString().trim(),
              row[5].toString().trim(),
              row[6].toString().trim(),
            ];

            // Correct Index parsing
            String correctStr = row[7].toString().toLowerCase().trim();
            int correctIndex = 0;
            if (RegExp(r'^[0-3]$').hasMatch(correctStr)) {
              correctIndex = int.parse(correctStr);
            } else if (RegExp(r'^[1-4]$').hasMatch(correctStr)) {
              correctIndex = int.parse(correctStr) - 1;
            } else {
              switch (correctStr) {
                case 'a':
                  correctIndex = 0;
                  break;
                case 'b':
                  correctIndex = 1;
                  break;
                case 'c':
                  correctIndex = 2;
                  break;
                case 'd':
                  correctIndex = 3;
                  break;
              }
            }

            if (!subtitleGroups.containsKey(subtitle)) {
              subtitleGroups[subtitle] = [];
              subtitleDescriptions[subtitle] = subtitleDesc;
            }
            subtitleGroups[subtitle]!.add(
              Question(
                id: const Uuid().v4(),
                questionText: qText,
                options: options,
                correctOptionIndex: correctIndex,
              ),
            );
          }

          // Validate: Each subtitle test should have at least 1 question
          List<String> invalidSubtitles = [];
          subtitleGroups.forEach((subtitle, questions) {
            if (questions.length < 1) {
              invalidSubtitles.add("$subtitle (${questions.length} questions)");
            }
          });

          if (invalidSubtitles.isNotEmpty) {
            throw Exception(
              "Validation Failed: Each sub-test must have questions. \nIssues with: ${invalidSubtitles.join(', ')}",
            );
          }

          final provider = context.read<AdminProvider>();
          int addedCount = 0;

          for (var entry in subtitleGroups.entries) {
            final subtitle = entry.key;
            final questions = entry.value;

            final assessment = AssessmentModel(
              id: '',
              title: subtitle,
              setName: setName,
              description: subtitleDescriptions[subtitle] ?? '',
              type: _selectedType,
              questions: questions,
              timeLimitMinutes: 15,
              passingMarks: 9,
              createdAt: DateTime.now(),
            );

            await provider.addAssessment(assessment);
            addedCount++;
          }

          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Successfully imported $addedCount sub-tests for Set: $setName',
                ),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder:
              (context) => FDialog(
                title: const Text('Import Error'),
                body: Text(e.toString()),
                actions: [
                  FButton(
                    onPress: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Scaffold(
      backgroundColor: theme.colors.background,
      appBar: AppBar(
        backgroundColor: theme.colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: theme.colors.foreground),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Upload Assessment',
          style: TextStyle(
            color: theme.colors.foreground,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.colors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.upload_file,
                  size: 64,
                  color: theme.colors.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Import Set Questions',
                style: TextStyle(
                  color: theme.colors.foreground,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Type Selector
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: theme.colors.muted,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedType,
                    isExpanded: true,
                    items:
                        ['Technical', 'Non-Technical'].map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                    onChanged: (val) => setState(() => _selectedType = val!),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Text(
                'File name will be used as the Set Name.\nEach row should start with the Subtitle.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.colors.mutedForeground,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'Format: Subtitle, Description, Question, Opt1, Opt2, Opt3, Opt4, Correct',
                style: TextStyle(fontSize: 12, fontFamily: 'monospace'),
              ),
              const SizedBox(height: 32),

              if (_isLoading)
                CircularProgressIndicator(color: theme.colors.primary)
              else
                SizedBox(
                  width: double.infinity,
                  child: FButton(
                    onPress: _importCSV,
                    child: const Text('Pick CSV File'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
