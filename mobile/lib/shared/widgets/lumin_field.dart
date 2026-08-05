import 'package:flutter/material.dart';
import 'package:mobile/core/theme/lumin_colors.dart';

class LuminField extends StatelessWidget {
  const LuminField({
    super.key,
    required this.label,
    this.initialValue,
    this.obscureText = false,
    this.icon,
  });

  final String label;
  final String? initialValue;
  final bool obscureText;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      obscureText: obscureText,
      style: const TextStyle(color: LuminColors.text, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: LuminColors.muted, fontSize: 12),
        suffixIcon: icon == null
            ? null
            : Icon(icon, color: LuminColors.text, size: 18),
        filled: true,
        fillColor: LuminColors.panelLight,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
