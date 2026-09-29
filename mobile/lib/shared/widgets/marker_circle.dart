import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mobile/core/theme/lumin_colors.dart';

class MarkerCircle extends StatefulWidget {
  const MarkerCircle({
    super.key,
    required this.selected,
    this.onTap,
    this.baseColor = LuminColors.violet,
    this.size = 112,
    this.label,
    this.enabled = true,
  });

  final bool selected;
  final VoidCallback? onTap;
  final Color baseColor;
  final double size;
  final String? label;
  final bool enabled;

  @override
  State<MarkerCircle> createState() => _MarkerCircleState();
}

class _MarkerCircleState extends State<MarkerCircle> with TickerProviderStateMixin {
  late final AnimationController pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat();

  late final AnimationController rotation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 5200),
  )..repeat();

  @override
  void dispose() {
    pulse.dispose();
    rotation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final active = widget.enabled;
    return Semantics(
      button: active && widget.onTap != null,
      selected: widget.selected,
      label: widget.label,
      child: GestureDetector(
        onTap: active ? widget.onTap : null,
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: AnimatedBuilder(
            animation: Listenable.merge([pulse, rotation]),
            builder: (context, _) => CustomPaint(
              painter: _MarkerPainter(
                pulse: pulse.value,
                rotation: rotation.value,
                color: active ? widget.baseColor : Colors.white,
                selected: widget.selected,
                enabled: active,
              ),
              child: Center(
                child: Icon(
                  widget.selected ? Icons.center_focus_strong : Icons.add,
                  size: widget.selected ? widget.size * 0.24 : widget.size * 0.2,
                  color: Colors.white.withValues(alpha: active ? 0.92 : 0.38),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MarkerPainter extends CustomPainter {
  const _MarkerPainter({
    required this.pulse,
    required this.rotation,
    required this.color,
    required this.selected,
    required this.enabled,
  });

  final double pulse;
  final double rotation;
  final Color color;
  final bool selected;
  final bool enabled;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 10;
    final bounds = Rect.fromCircle(center: center, radius: radius);
    final breath = 0.5 + 0.5 * math.sin(pulse * 2 * math.pi);
    final opacity = enabled ? 1.0 : 0.36;

    canvas.drawCircle(
      center,
      radius * 0.72,
      Paint()..color = Colors.black.withValues(alpha: enabled ? 0.18 : 0.08),
    );

    if (selected) {
      canvas.drawCircle(
        center,
        radius + 4 + breath * 3,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 12 + breath * 8)
          ..color = color.withValues(alpha: 0.28 * opacity),
      );
    }

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = Colors.white.withValues(alpha: 0.42 * opacity),
    );

    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = selected ? 3.2 : 2.2
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: (selected ? 0.98 : 0.72) * opacity);
    const segment = math.pi * 0.32;
    for (var index = 0; index < 4; index++) {
      final start = rotation * 2 * math.pi + index * math.pi / 2;
      canvas.drawArc(bounds, start, segment, false, arcPaint);
    }

    final innerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = color.withValues(alpha: 0.36 * opacity);
    canvas.drawCircle(center, radius * 0.72, innerPaint);

    canvas.drawCircle(
      center,
      selected ? 3.2 : 2.4,
      Paint()..color = Colors.white.withValues(alpha: 0.9 * opacity),
    );
  }

  @override
  bool shouldRepaint(covariant _MarkerPainter oldDelegate) {
    return oldDelegate.pulse != pulse ||
        oldDelegate.rotation != rotation ||
        oldDelegate.color != color ||
        oldDelegate.selected != selected ||
        oldDelegate.enabled != enabled;
  }
}
