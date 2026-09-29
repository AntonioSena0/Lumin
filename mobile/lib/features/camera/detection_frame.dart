import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mobile/core/theme/lumin_colors.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';

class DetectionFrame extends StatefulWidget {
  const DetectionFrame({super.key, required this.result, this.horizontalScan = true});

  final YOLOResult? result;
  final bool horizontalScan;

  @override
  State<DetectionFrame> createState() => _DetectionFrameState();
}

class _DetectionFrameState extends State<DetectionFrame> with SingleTickerProviderStateMixin {
  late final AnimationController controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3000),
  )..repeat();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    if (result == null) return const SizedBox.shrink();
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => CustomPaint(
        painter: DetectionFramePainter(
          result: result,
          phase: controller.value,
          horizontalScan: widget.horizontalScan,
        ),
      ),
    );
  }
}

class DetectionFramePainter extends CustomPainter {
  const DetectionFramePainter({
    required this.result,
    required this.phase,
    this.horizontalScan = true,
  });

  final YOLOResult result;
  final double phase;
  final bool horizontalScan;

  @override
  void paint(Canvas canvas, Size size) {
    final box = expandBox(detectedRect(size), size);
    final path = buildPath(box, isCircular(box));
    final breath = 0.5 + 0.5 * math.sin(phase * 2 * math.pi);
    final scan = Curves.easeInOut.transform((phase * 1.6) % 1.0);

    canvas.drawPath(
      path,
      Paint()
        ..color = LuminColors.violet.withValues(alpha: 0.08 + breath * 0.04)
        ..style = PaintingStyle.fill,
    );
    _paintGlow(canvas, path, breath);
    _paintBorder(canvas, path, breath);
    _paintCorners(canvas, box, breath);
    if (horizontalScan) _paintScanLine(canvas, box, scan);
    _paintLabel(canvas, box);
  }

  void _paintGlow(Canvas canvas, Path path, double breath) {
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8 + breath * 4
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 14 + breath * 8)
        ..color = LuminColors.violet.withValues(alpha: 0.28 + breath * 0.12),
    );
  }

  void _paintBorder(Canvas canvas, Path path, double breath) {
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeJoin = StrokeJoin.round
        ..color = LuminColors.violet.withValues(alpha: 0.82 + breath * 0.18),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.white.withValues(alpha: 0.65),
    );
  }

  void _paintCorners(Canvas canvas, Rect box, double breath) {
    final length = (box.shortestSide * 0.18).clamp(18, 42).toDouble();
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3 + breath
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.82 + breath * 0.18);

    void corner(Offset pivot, double x, double y) {
      final path = Path()
        ..moveTo(pivot.dx + x * length, pivot.dy)
        ..lineTo(pivot.dx, pivot.dy)
        ..lineTo(pivot.dx, pivot.dy + y * length);
      canvas.drawPath(path, paint);
    }

    corner(box.topLeft, 1, 1);
    corner(box.topRight, -1, 1);
    corner(box.bottomLeft, 1, -1);
    corner(box.bottomRight, -1, -1);
  }

  void _paintScanLine(Canvas canvas, Rect box, double progress) {
    final y = box.top + box.height * progress;
    final line = Rect.fromLTWH(box.left, y, box.width, 2);
    canvas.drawRect(
      line,
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.transparent,
            LuminColors.violet.withValues(alpha: 0.95),
            Colors.transparent,
          ],
        ).createShader(line),
    );
  }

  void _paintLabel(Canvas canvas, Rect box) {
    final label = result.className.trim().toUpperCase();
    if (label.isEmpty) return;

    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    const padding = EdgeInsets.symmetric(horizontal: 10, vertical: 6);
    final tag = Rect.fromLTWH(
      (box.left + box.width / 2 - (textPainter.width + padding.horizontal) / 2)
          .clamp(8, double.maxFinite),
      (box.top - textPainter.height - padding.vertical - 8).clamp(10, double.maxFinite),
      textPainter.width + padding.horizontal,
      textPainter.height + padding.vertical,
    );
    final shape = RRect.fromRectAndRadius(tag, const Radius.circular(6));

    canvas.drawRRect(shape, Paint()..color = Colors.black.withValues(alpha: 0.82));
    canvas.drawRRect(
      shape,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = LuminColors.violet,
    );
    textPainter.paint(canvas, Offset(tag.left + padding.left, tag.top + padding.top));
  }

  Rect detectedRect(Size size) => Rect.fromLTRB(
        result.normalizedBox.left * size.width,
        result.normalizedBox.top * size.height,
        result.normalizedBox.right * size.width,
        result.normalizedBox.bottom * size.height,
      );

  Rect expandBox(Rect box, Size size) {
    final horizontal = (box.width * 0.14).clamp(16, 48).toDouble();
    final vertical = (box.height * 0.14).clamp(16, 48).toDouble();
    return Rect.fromLTRB(
      (box.left - horizontal).clamp(0, size.width).toDouble(),
      (box.top - vertical).clamp(0, size.height).toDouble(),
      (box.right + horizontal).clamp(0, size.width).toDouble(),
      (box.bottom + vertical).clamp(0, size.height).toDouble(),
    );
  }

  bool isCircular(Rect box) {
    if (box.height <= 0) return false;
    final ratio = box.width / box.height;
    return ratio >= 0.78 && ratio <= 1.28;
  }

  Path buildPath(Rect box, bool circle) {
    if (circle) return Path()..addOval(box);
    final radius = Radius.circular((box.shortestSide * 0.2).clamp(20, 46).toDouble());
    return Path()..addRRect(RRect.fromRectAndRadius(box, radius));
  }

  @override
  bool shouldRepaint(covariant DetectionFramePainter oldDelegate) {
    return oldDelegate.result != result || oldDelegate.phase != phase;
  }
}
