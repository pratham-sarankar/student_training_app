import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:learn_work/models/traning.dart';
import 'package:learn_work/providers/admin_provider.dart';

class UploadNoteDialog extends StatefulWidget {
  final String trainingId;
  final String scheduleId;

  const UploadNoteDialog({
    super.key,
    required this.trainingId,
    required this.scheduleId,
  });

  @override
  State<UploadNoteDialog> createState() => _UploadNoteDialogState();
}

class _UploadNoteDialogState extends State<UploadNoteDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  String? _selectedFileType;
  String? _filePath;

  final List<String> _fileTypes = ['PDF', 'Text', 'Word', 'PowerPoint'];

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Upload Notes'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Note Title',
                  border: OutlineInputBorder(),
                  hintText: 'Enter a descriptive title for the note',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a note title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedFileType,
                decoration: const InputDecoration(
                  labelText: 'File Type',
                  border: OutlineInputBorder(),
                ),
                items: _fileTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedFileType = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a file type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Icon(
                      _filePath != null ? Icons.file_present : Icons.upload_file,
                      size: 48,
                      color: _filePath != null ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _filePath != null ? 'File selected' : 'No file selected',
                      style: TextStyle(
                        color: _filePath != null ? Colors.green : Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FilledButton.icon(
                      onPressed: _selectFile,
                      icon: const Icon(Icons.attach_file),
                      label: const Text('Select File'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _uploadNote,
          child: const Text('Upload Note'),
        ),
      ],
    );
  }

  void _selectFile() {
    // In a real app, this would use file_picker to select a file
    // For now, we'll simulate file selection
    setState(() {
      _filePath = '/path/to/selected/file.pdf';
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('File selection simulated. In a real app, this would open a file picker.'),
      ),
    );
  }

  void _uploadNote() {
    if (_formKey.currentState!.validate() && _filePath != null) {
      final note = Note(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        filePath: _filePath!,
        fileType: _selectedFileType!,
        uploadedAt: DateTime.now(),
      );

      context.read<AdminProvider>().uploadNote(
        widget.trainingId,
        widget.scheduleId,
        note,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Note uploaded successfully'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop();
    } else if (_filePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a file to upload'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
