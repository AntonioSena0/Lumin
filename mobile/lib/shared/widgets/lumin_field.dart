import 'package:flutter/material.dart';
import 'package:mobile/core/theme/lumin_colors.dart';

class LuminField extends StatelessWidget {
  const LuminField({
    super.key,
    required this.label,
    this.initialValue,
    this.obscureText = false,
    this.icon,
    this.onIconTap,
    this.labelAbove = false,
    this.labelInset = 0,
    this.controller,
    this.keyboardType,
    this.onChanged,
    this.onSubmitted,
  });

  final String label;
  final String? initialValue;
  final bool obscureText;
  final IconData? icon;

  /// Se informado, o ícone vira um botão (ex.: mostrar/ocultar senha).
  final VoidCallback? onIconTap;

  /// Se true, o rótulo aparece acima da caixa (como no wireframe de login).
  /// Padrão false: mantém o comportamento original em todas as outras telas.
  final bool labelAbove;

  /// Recuo à esquerda do rótulo quando [labelAbove] é true.
  final double labelInset;

  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final field = TextFormField(
      controller: controller,
      initialValue: controller == null ? initialValue : null,
      obscureText: obscureText,
      style: const TextStyle(color: LuminColors.text, fontSize: 14),
      keyboardType: keyboardType,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      decoration: InputDecoration(
        labelText: labelAbove ? null : label,
        labelStyle: const TextStyle(color: LuminColors.muted, fontSize: 12),
        suffixIcon: icon == null
            ? null
            : onIconTap == null
                ? Icon(icon, color: LuminColors.text, size: 18)
                : IconButton(
                    onPressed: onIconTap,
                    splashRadius: 20,
                    icon: Icon(icon, color: LuminColors.text, size: 22),
                  ),
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

    if (!labelAbove) return field;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: labelInset),
          child: Text(
            label,
            style: const TextStyle(
              color: LuminColors.text,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 10),
        field,
      ],
    );
  }
}