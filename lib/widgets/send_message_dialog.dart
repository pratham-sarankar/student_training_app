import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:learn_work/models/traning.dart';
import 'package:learn_work/providers/admin_provider.dart';

class SendMessageDialog extends StatefulWidget {
  final String trainingId;
  final String scheduleId;

  const SendMessageDialog({
    super.key,
    required this.trainingId,
    required this.scheduleId,
  });

  @override
  State<SendMessageDialog> createState() => _SendMessageDialogState();
}

class _SendMessageDialogState extends State<SendMessageDialog> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Send Message'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Send a message to all students enrolled in this training schedule.',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _messageController,
                decoration: const InputDecoration(
                  labelText: 'Message',
                  border: OutlineInputBorder(),
                  hintText: 'Enter your message here...',
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a message';
                  }
                  if (value.length < 10) {
                    return 'Message must be at least 10 characters long';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue[700],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This message will be sent to all students enrolled in this specific training schedule.',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontSize: 12,
                        ),
                      ),
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
          onPressed: _sendMessage,
          child: const Text('Send Message'),
        ),
      ],
    );
  }

  void _sendMessage() {
    if (_formKey.currentState!.validate()) {
      final message = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: _messageController.text.trim(),
        sentAt: DateTime.now(),
      );

      context.read<AdminProvider>().sendMessage(
        widget.trainingId,
        widget.scheduleId,
        message,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Message sent successfully to all enrolled students'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop();
    }
  }
}
