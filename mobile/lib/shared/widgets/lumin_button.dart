import 'package:flutter/material.dart';
import 'package:mobile/core/theme/lumin_colors.dart';

class LuminButton extends StatelessWidget {
  const LuminButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [LuminColors.violet, LuminColors.magenta],
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: TextButton.icon(
          onPressed: onPressed,
          icon: icon == null ? const SizedBox.shrink() : Icon(icon, size: 18),
          label: Text(
            label,
            style: const TextStyle(
              color: LuminColors.text,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
