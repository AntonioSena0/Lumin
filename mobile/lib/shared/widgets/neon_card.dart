import 'package:flutter/material.dart';

class NeonCard extends StatelessWidget {
  const NeonCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.borderRadius = 18,
    this.glowColor = const Color(0xFF7B2CFF),
    this.glowStrength = 1,
    this.borderWidth = 1.4,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color glowColor;
  final double glowStrength;
  final double borderWidth;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final strength = glowStrength.clamp(0.0, 2.0);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D12),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: glowColor.withValues(alpha: 0.55 * strength.clamp(0.0, 1.0)),
          width: borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: glowColor.withValues(alpha: 0.32 * strength),
            blurRadius: 26 * strength,
            spreadRadius: 1.5,
          ),
          BoxShadow(
            color: glowColor.withValues(alpha: 0.14 * strength),
            blurRadius: 60 * strength,
            spreadRadius: 6,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class NeonCardTitle extends StatelessWidget {
  const NeonCardTitle({super.key, required this.text, this.color = Colors.white});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: color,
        fontSize: 12,
        letterSpacing: 1.4,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class NeonCardValue extends StatelessWidget {
  const NeonCardValue({super.key, required this.text, this.size = 26, this.glowColor});

  final String text;
  final double size;
  final Color? glowColor;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: Colors.white,
      fontSize: size,
      height: 1.15,
      fontWeight: FontWeight.w900,
    );

    if (glowColor == null) return Text(text, style: style);

    return Stack(
      children: [
        Text(
          text,
          style: style.copyWith(
            color: glowColor,
            shadows: [
              Shadow(color: glowColor!.withValues(alpha: 0.8), blurRadius: 16),
              Shadow(color: glowColor!.withValues(alpha: 0.5), blurRadius: 34),
            ],
          ),
        ),
        Text(text, style: style),
      ],
    );
  }
}
