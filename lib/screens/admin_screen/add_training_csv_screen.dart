import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:forui/forui.dart';
import 'package:provider/provider.dart';
import '../../services/course_service.dart';
import '../../providers/admin_provider.dart';

class AddTrainingCsvScreen extends StatefulWidget {
  const AddTrainingCsvScreen({super.key});

  @override
  State<AddTrainingCsvScreen> createState() => _AddTrainingCsvScreenState();
}

class _AddTrainingCsvScreenState extends State<AddTrainingCsvScreen> {
  final CourseService _courseService = CourseService();
  bool _isUploading = false;
  String? _fileName;
  List<List<dynamic>>? _csvData;

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final input = file.readAsStringSync();
        final fields = const CsvToListConverter().convert(input);

        setState(() {
          _fileName = result.files.single.name;
          _csvData = fields;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking file: $e')));
    }
  }

  Future<void> _uploadData() async {
    if (_csvData == null || _csvData!.isEmpty) return;

    setState(() {
      _isUploading = true;
    });

    try {
      await _courseService.uploadCoursesFromCsvData(_csvData!);

      if (mounted) {
        // Refresh trainings in provider
        await context.read<AdminProvider>().loadTrainings();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Courses uploaded successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error uploading data: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Import Trainings CSV'),
        backgroundColor: theme.colors.background,
        foregroundColor: theme.colors.foreground,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue),
                  const SizedBox(height: 8),
                  Text(
                    'Expected CSV Format:',
                    style: theme.typography.base.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Domain, Recommended Courses, Cost and duration, Mode, Days, Timing',
                    textAlign: TextAlign.center,
                    style: theme.typography.sm.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Duration "4 weeks" will be Summer Training.\nOthers will be Job Oriented Training (with free demo).',
                    textAlign: TextAlign.center,
                    style: theme.typography.xs.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: _isUploading ? null : _pickFile,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: theme.colors.border,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      size: 48,
                      color: theme.colors.mutedForeground,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _fileName ?? 'Tap to select CSV file',
                      style: theme.typography.base.copyWith(
                        color:
                            _fileName != null
                                ? theme.colors.foreground
                                : theme.colors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            if (_csvData != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Found ${_csvData!.length - 1} courses in file',
                  textAlign: TextAlign.center,
                  style: theme.typography.sm,
                ),
              ),
            FButton(
              onPress: (_csvData == null || _isUploading) ? null : _uploadData,
              child:
                  _isUploading
                      ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : const Text('Start Import'),
            ),
          ],
        ),
      ),
    );
  }
}
