import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/core/theme/lumin_colors.dart';
import 'package:mobile/core/theme/lumin_spacing.dart';
import 'package:mobile/features/camera/detected_object.dart';
import 'package:mobile/features/camera/detection_confidence_policy.dart';
import 'package:mobile/features/camera/lumin_detector_model.dart';
import 'package:mobile/features/camera/object_translation_dictionary.dart';
import 'package:mobile/features/camera/yolo_object_selection_service.dart';
import 'package:mobile/features/translation/save_translation_screen.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final yoloController = YOLOViewController();
  final objectSelectionService = const YoloObjectSelectionService();
  final confidencePolicy = const DetectionConfidencePolicy();

  YOLOResult? selectedObject;
  DetectedTranslation? detectedTranslation;
  String activeModelPath = LuminDetectorModel.configuredModelPath;
  YOLOTask activeModelTask = LuminDetectorModel.configuredTask;
  String statusText = LuminDetectorModel.usesCustomModel
      ? 'Carregando detector personalizado'
      : 'Carregando detector';
  String? stableLabel;
  int stableFrameCount = 0;
  bool modelFailed = false;
  bool fallbackModelActive = !LuminDetectorModel.usesCustomModel;
  bool translationDictionaryReady = false;
  DateTime lastAcceptedObject = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    unawaited(loadTranslationDictionary());
    unawaited(yoloController.setShowOverlays(false));
    unawaited(
      yoloController.setThresholds(
        confidenceThreshold: LuminDetectorModel.confidenceThreshold,
      ),
    );
  }

  Future<void> loadTranslationDictionary() async {
    await ObjectTranslationDictionary.ensureLoaded();

    if (!mounted) {
      return;
    }

    setState(() {
      translationDictionaryReady = true;
    });
  }

  void processYoloResults(List<YOLOResult> results) {
    final selectedObject = objectSelectionService.selectCenteredObject(results);

    if (selectedObject == null) {
      clearSelectedObject();
      updateStatus('Centralize um objeto');
      return;
    }

    updateSelectedObject(selectedObject);
    registerStableObject(selectedObject);
  }

  void updateSelectedObject(YOLOResult selectedObject) {
    if (!shouldRepaintSelectedObject(selectedObject)) {
      this.selectedObject = selectedObject;
      return;
    }

    setState(() {
      this.selectedObject = selectedObject;
    });
  }

  bool shouldRepaintSelectedObject(YOLOResult nextObject) {
    final currentObject = selectedObject;

    if (currentObject == null ||
        currentObject.className.trim() != nextObject.className.trim()) {
      return true;
    }

    final currentBox = currentObject.normalizedBox;
    final nextBox = nextObject.normalizedBox;
    final boxMovement =
        (currentBox.left - nextBox.left).abs() +
        (currentBox.top - nextBox.top).abs() +
        (currentBox.right - nextBox.right).abs() +
        (currentBox.bottom - nextBox.bottom).abs();
    final confidenceMovement =
        (currentObject.confidence - nextObject.confidence).abs();

    return boxMovement > 0.018 || confidenceMovement > 0.08;
  }

  void clearSelectedObject() {
    if (selectedObject == null) {
      return;
    }

    setState(() {
      selectedObject = null;
      detectedTranslation = null;
      stableLabel = null;
      stableFrameCount = 0;
    });
  }

  void registerStableObject(YOLOResult result) {
    final detectedLabel = result.className.trim();

    if (detectedLabel.isEmpty) {
      return;
    }

    if (stableLabel == detectedLabel) {
      stableFrameCount += 1;
    } else {
      stableLabel = detectedLabel;
      stableFrameCount = 1;
    }

    if (stableFrameCount <
        confidencePolicy.requiredStableFramesFor(detectedLabel)) {
      updateStatus('Mantenha o objeto na área iluminada');
      return;
    }

    if (!confidencePolicy.accepts(result)) {
      setState(() {
        detectedTranslation = null;
        statusText = 'Detecção incerta';
      });
      return;
    }

    final currentTranslation = detectedTranslation;
    final now = DateTime.now();

    if (currentTranslation != null &&
        currentTranslation.originalText == detectedLabel) {
      return;
    }

    if (now.difference(lastAcceptedObject) < LuminDetectorModel.modelCooldown) {
      return;
    }

    if (!translationDictionaryReady) {
      updateStatus('Preparando traduções');
      return;
    }

    lastAcceptedObject = now;
    final translatedText = ObjectTranslationDictionary.translate(detectedLabel);

    setState(() {
      detectedTranslation = DetectedTranslation(
        originalText: detectedLabel,
        translatedText: translatedText,
        confidence: result.confidence,
      );
      statusText = 'Tradução pronta';
    });
  }

  Future<void> loadFallbackDetector() async {
    if (fallbackModelActive) {
      if (!mounted) {
        return;
      }

      setState(() {
        modelFailed = true;
        statusText = 'Não foi possível carregar o detector';
      });
      return;
    }

    setState(() {
      fallbackModelActive = true;
      activeModelPath = LuminDetectorModel.fallbackModelPath;
      activeModelTask = LuminDetectorModel.fallbackTask;
      selectedObject = null;
      detectedTranslation = null;
      stableLabel = null;
      stableFrameCount = 0;
      modelFailed = false;
      statusText = 'Carregando detector rápido';
    });

    try {
      await yoloController.switchModel(
        LuminDetectorModel.fallbackModelPath,
        LuminDetectorModel.fallbackTask,
      );
      updateStatus('Centralize um objeto');
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        modelFailed = true;
        statusText = 'Não foi possível carregar o detector';
      });
    }
  }

  void updateStatus(String text) {
    if (!mounted || statusText == text) {
      return;
    }

    setState(() {
      statusText = text;
    });
  }

  Future<void> saveDetectedTranslation() async {
    final translation = detectedTranslation;

    if (translation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aponte para um único objeto primeiro')),
      );
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SaveTranslationScreen(
          originalText: translation.originalText,
          translatedText: translation.translatedText,
        ),
      ),
    );
  }

  @override
  void dispose() {
    yoloController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final translation = detectedTranslation;
    final objectOnCenter = selectedObject;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: YOLOView(
              modelPath: activeModelPath,
              task: activeModelTask,
              controller: yoloController,
              cameraResolution: '720p',
              confidenceThreshold: LuminDetectorModel.confidenceThreshold,
              iouThreshold: 0.45,
              useGpu: true,
              lensFacing: LensFacing.back,
              onResult: processYoloResults,
              onModelLoad: (_, _) {
                unawaited(yoloController.setShowOverlays(false));
                updateStatus('Centralize um objeto');
              },
              onModelError: (_, _, _) {
                unawaited(loadFallbackDetector());
              },
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: NeonObjectDetectionOverlay(selectedObject: objectOnCenter),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.08),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: LuminSpacing.page,
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CameraPill(label: 'Inglês'),
                      CameraPill(label: 'Português'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  CameraTranslationPanel(
                    statusText: statusText,
                    translation: translation,
                    modelFailed: modelFailed,
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: saveDetectedTranslation,
                    child: CameraCaptureButton(enabled: translation != null),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NeonObjectDetectionOverlay extends StatelessWidget {
  const NeonObjectDetectionOverlay({super.key, required this.selectedObject});

  final YOLOResult? selectedObject;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: selectedObject == null
          ? null
          : NeonObjectDetectionPainter(selectedObject!),
    );
  }
}

class NeonObjectDetectionPainter extends CustomPainter {
  const NeonObjectDetectionPainter(this.selectedObject);

  final YOLOResult selectedObject;

  @override
  void paint(Canvas canvas, Size size) {
    final detectedBox = Rect.fromLTRB(
      selectedObject.normalizedBox.left * size.width,
      selectedObject.normalizedBox.top * size.height,
      selectedObject.normalizedBox.right * size.width,
      selectedObject.normalizedBox.bottom * size.height,
    );
    final box = expandBox(detectedBox, size);
    final shapeIsCircular = isCircularShape(box);
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18)
      ..color = LuminColors.magenta.withValues(alpha: 0.55);
    final outerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..color = LuminColors.magenta.withValues(alpha: 0.92);
    final innerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = LuminColors.cyan.withValues(alpha: 0.95);
    final softFillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = LuminColors.magenta.withValues(alpha: 0.08);

    if (shapeIsCircular) {
      canvas.drawOval(box, softFillPaint);
      canvas.drawOval(box, glowPaint);
      canvas.drawOval(box, outerPaint);
      canvas.drawOval(box.deflate(7), innerPaint);
      return;
    }

    final radius = Radius.circular((box.shortestSide * 0.18).clamp(18, 42));
    final roundedBox = RRect.fromRectAndRadius(box, radius);
    canvas.drawRRect(roundedBox, softFillPaint);
    canvas.drawRRect(roundedBox, glowPaint);
    canvas.drawRRect(roundedBox, outerPaint);
    canvas.drawRRect(roundedBox.deflate(7), innerPaint);
  }

  Rect expandBox(Rect box, Size size) {
    final horizontalPadding = (box.width * 0.16).clamp(18, 54).toDouble();
    final verticalPadding = (box.height * 0.16).clamp(18, 54).toDouble();

    return Rect.fromLTRB(
      (box.left - horizontalPadding).clamp(0, size.width).toDouble(),
      (box.top - verticalPadding).clamp(0, size.height).toDouble(),
      (box.right + horizontalPadding).clamp(0, size.width).toDouble(),
      (box.bottom + verticalPadding).clamp(0, size.height).toDouble(),
    );
  }

  bool isCircularShape(Rect box) {
    final ratio = box.width / box.height;
    return ratio >= 0.72 && ratio <= 1.28;
  }

  @override
  bool shouldRepaint(covariant NeonObjectDetectionPainter oldDelegate) {
    return oldDelegate.selectedObject != selectedObject;
  }
}

class CameraTranslationPanel extends StatelessWidget {
  const CameraTranslationPanel({
    super.key,
    required this.statusText,
    required this.translation,
    required this.modelFailed,
  });

  final String statusText;
  final DetectedTranslation? translation;
  final bool modelFailed;

  @override
  Widget build(BuildContext context) {
    final activeTranslation = translation;
    final confidenceText = activeTranslation == null
        ? null
        : '${(activeTranslation.confidence * 100).round()}%';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: LuminColors.panel.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: activeTranslation == null
              ? Colors.transparent
              : LuminColors.magenta.withValues(alpha: 0.7),
        ),
      ),
      child: activeTranslation == null
          ? Text(
              statusText,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: modelFailed ? Colors.redAccent : LuminColors.text,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            )
          : Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activeTranslation.originalText.toUpperCase(),
                        style: const TextStyle(
                          color: LuminColors.muted,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        activeTranslation.translatedText,
                        style: const TextStyle(
                          color: LuminColors.text,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                if (confidenceText != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: LuminColors.panelLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      confidenceText,
                      style: const TextStyle(
                        color: LuminColors.magenta,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

class CameraCaptureButton extends StatelessWidget {
  const CameraCaptureButton({super.key, required this.enabled});

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: enabled ? 1 : 0.48,
      child: Container(
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: LuminColors.magenta, width: 5),
          color: LuminColors.text,
          boxShadow: [
            BoxShadow(
              color: LuminColors.magenta.withValues(alpha: enabled ? 0.45 : 0),
              blurRadius: 22,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }
}

class CameraPill extends StatelessWidget {
  const CameraPill({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: LuminColors.panel.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.keyboard_arrow_down, size: 16),
        ],
      ),
    );
  }
}
