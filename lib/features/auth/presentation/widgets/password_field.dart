import 'package:flutter/material.dart';

class PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool obscurePassword;
  final VoidCallback onVisibilityChanged;
  final String labelText;
  final String? Function(String?)? validator;

  const PasswordField({
    super.key,
    required this.controller,
    required this.obscurePassword,
    required this.onVisibilityChanged,
    this.labelText = 'كلمة المرور',
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscurePassword,
      textDirection: TextDirection.ltr,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: const Icon(Icons.lock_outlined),
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(
            obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
          onPressed: onVisibilityChanged,
        ),
      ),
      validator:
          validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'يرجى إدخال $labelText';
            }
            if (value.length < 6) {
              return '$labelText يجب أن تكون 6 أحرف على الأقل';
            }
            return null;
          },
    );
  }
}
