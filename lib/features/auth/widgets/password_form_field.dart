import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

class PasswordFormField extends StatefulWidget {
  const PasswordFormField({super.key, this.controller});
  final TextEditingController? controller;
  @override
  State<PasswordFormField> createState() => _PasswordFormFieldState();
}

class _PasswordFormFieldState extends State<PasswordFormField> {
  bool _obscureText = true;

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextField(
      controller: widget.controller,
      decoration: InputDecoration(
        hintText: 'Enter your password',
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: _toggleObscureText,
        ),
        border: UnderlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: Icon(HeroIcons.lock_closed),
        fillColor: theme.colorScheme.surfaceBright,
        filled: true,
      ),
      obscureText: _obscureText,
      textInputAction: TextInputAction.done,
    );
  }
}
