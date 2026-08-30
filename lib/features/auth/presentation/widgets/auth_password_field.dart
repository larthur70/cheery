import 'package:cheery/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Password field with visibility toggle.
class AuthPasswordField extends StatefulWidget {
  const AuthPasswordField({
    required this.label,
    required this.controller,
    this.textInputAction,
    this.validator,
    this.onChanged,
    this.enabled = true,
    super.key,
  });

  final String label;
  final TextEditingController controller;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final bool enabled;

  @override
  State<AuthPasswordField> createState() => _AuthPasswordFieldState();
}

class _AuthPasswordFieldState extends State<AuthPasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      enabled: widget.enabled,
      obscureText: _obscure,
      textInputAction: widget.textInputAction,
      autofillHints: const [AutofillHints.password],
      validator: widget.validator,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        labelText: widget.label,
        filled: true,
        fillColor: AppColors.surfaceElevated,
        suffixIcon: IconButton(
          tooltip: _obscure ? 'Mostrar senha' : 'Ocultar senha',
          onPressed: () => setState(() => _obscure = !_obscure),
          icon: Icon(
            _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: AppColors.inkMuted,
          ),
        ),
      ),
    );
  }
}
