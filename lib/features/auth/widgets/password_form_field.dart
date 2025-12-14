import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

class PasswordFormField extends StatefulWidget {
  const PasswordFormField({
    super.key,
    this.hintText = "Enter your password",
    this.controller,
  });
  final TextEditingController? controller;
  final String? hintText;
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
    return TextField(
      controller: widget.controller,
      decoration: InputDecoration(
        hintText: widget.hintText,
        suffixIcon: IconButton(
          icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
          onPressed: _toggleObscureText,
        ),
        prefixIcon: const Icon(HeroIcons.lock_closed),
      ),
      obscureText: _obscureText,
      textInputAction: TextInputAction.done,
    );
  }
}
