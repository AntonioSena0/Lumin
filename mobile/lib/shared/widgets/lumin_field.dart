import 'package:flutter/material.dart';
import 'package:mobile/core/theme/lumin_colors.dart';

class LuminField extends StatelessWidget {
  const LuminField({
    super.key,
    required this.label,
    this.initialValue,
    this.obscureText = false,
    this.icon,
    this.controller,
    this.keyboardType,
    this.onChanged,
    this.onSubmitted,
  });

  final String label;
  final String? initialValue;
  final bool obscureText;
  final IconData? icon;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: controller == null ? initialValue : null,
      obscureText: obscureText,
      style: const TextStyle(color: LuminColors.text, fontSize: 14),
      keyboardType: keyboardType,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
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
