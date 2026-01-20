import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:forui/forui.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import '../../providers/admin_provider.dart';
import '../../models/course.dart';

class AddTrainingCsvScreen extends StatefulWidget {
  const AddTrainingCsvScreen({super.key});

  @override
  State<AddTrainingCsvScreen> createState() => _AddTrainingCsvScreenState();
}

class _AddTrainingCsvScreenState extends State<AddTrainingCsvScreen> {
  bool _isLoading = false;

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

          // Check for header
          int startRow = 0;
          if (processedRows.isNotEmpty &&
              processedRows[0].isNotEmpty &&
              processedRows[0][0].toString().toLowerCase().contains('title')) {
            startRow = 1;
          }

          List<Course> coursesToImport = [];

          for (int i = startRow; i < processedRows.length; i++) {
            final row = processedRows[i];
            if (row.length < 5) continue; // Basic validation

            final title = row[0].toString().trim();
            final category = row[1].toString().trim();
            final description = row[2].toString().trim();
            String rawCost = row[3].toString().trim();
            final costStr = rawCost.replaceAll(RegExp(r'[^\d.]'), '');
            final cost = double.tryParse(costStr) ?? 0.0;
            final duration = row[4].toString().trim();

            // Optional fields with defaults
            final level =
                row.length > 5 ? row[5].toString().trim() : 'Beginner';

            // Skip index 6 (image) if present, or handle offset properly
            // Re-mapping based on image removal:
            // 0:Title, 1:Category, 2:Description, 3:Cost, 4:Duration, 5:Level, 6:Instructor, 7:Topics, 8:Requirements, 9:Outcomes

            final instructor =
                row.length > 6 ? row[6].toString().trim() : 'Auto-imported';
            final topicsStr = row.length > 7 ? row[7].toString().trim() : '';
            final topics =
                topicsStr
                    .split(',')
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .toList();
            final requirements =
                row.length > 8
                    ? row[8].toString().trim()
                    : 'No specific requirements';
            final outcomes =
                row.length > 9
                    ? row[9].toString().trim()
                    : 'Master course contents';
            final tentativeStartDate =
                row.length > 10 ? row[10].toString().trim() : 'To be announced';
            String rawEnrollmentFee =
                row.length > 11 ? row[11].toString().trim() : '0.0';
            final enrollmentFeeStr = rawEnrollmentFee.replaceAll(
              RegExp(r'[^\d.]'),
              '',
            );
            final enrollmentFee = double.tryParse(enrollmentFeeStr) ?? 0.0;

            if (title.isEmpty) continue;

            final course = Course(
              id: '',
              title: title,
              category: category,
              description: description,
              cost: cost,
              enrollmentFee: enrollmentFee,
              duration: duration,
              level: level,
              tentativeStartDate: tentativeStartDate,
              createdAt: DateTime.now(),
              isActive: true,
              instructor: instructor,
              topics: topics,
              requirements: requirements,
              outcomes: outcomes,
            );

            coursesToImport.add(course);
          }

          if (coursesToImport.isEmpty) {
            throw Exception("No valid courses found in CSV");
          }

          final provider = context.read<AdminProvider>();
          final addedCount = await provider.addCourses(coursesToImport);

          if (mounted) {
            Navigator.pop(context);
            if (addedCount > 0) {
              final skippedCount = coursesToImport.length - addedCount;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Successfully imported $addedCount new courses.${skippedCount > 0 ? ' ($skippedCount duplicates skipped)' : ''}',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'No new courses were added. All courses in the file already exist.',
                  ),
                  backgroundColor: Colors.orange,
                ),
              );
            }
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
          'Import Courses',
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
                  Icons.auto_awesome_motion_outlined,
                  size: 64,
                  color: theme.colors.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Bulk Import Training Courses',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.colors.foreground,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Upload a CSV file to add multiple courses at once.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.colors.mutedForeground,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 32),

              // Format help
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colors.muted,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.colors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Required CSV Columns:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.colors.foreground,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '1. Title\n2. Category\n3. Description\n4. Cost\n5. Duration\n6. Enrollment Fee',
                      style: TextStyle(
                        color: theme.colors.mutedForeground,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                    const Divider(height: 16),
                    Text(
                      'Optional: Level, Instructor, Topics, Requirements, Outcomes, Tentative Start Date',
                      style: TextStyle(
                        color: theme.colors.mutedForeground,
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              if (_isLoading)
                CircularProgressIndicator(color: theme.colors.primary)
              else
                SizedBox(
                  width: double.infinity,
                  child: FButton(
                    onPress: _importCSV,
                    child: const Text('Select CSV File'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
