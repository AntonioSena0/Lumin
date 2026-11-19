import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mobile/core/theme/lumin_colors.dart';
import 'package:mobile/core/theme/lumin_spacing.dart';
import 'package:mobile/features/camera/detected_object.dart';
import 'package:mobile/features/camera/detection_confidence_policy.dart';
import 'package:mobile/features/camera/detection_frame.dart';
import 'package:mobile/features/camera/label_stability.dart';
import 'package:mobile/features/camera/lumin_detector_model.dart';
import 'package:mobile/features/camera/object_translation_dictionary.dart';
import 'package:mobile/features/camera/yolo_object_selection_service.dart';
import 'package:mobile/features/translation/save_translation_screen.dart';
import 'package:mobile/main.dart';
import 'package:mobile/shared/widgets/language_flag.dart';
import 'package:mobile/shared/widgets/marker_circle.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';
import 'package:mobile/core/i18n/i18n.dart';

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
      ? tr('Carregando detector personalizado')
      : tr('Carregando detector');
  String? acceptedLabel;
  final labelStability = LabelStability(
    window: LuminDetectorModel.stableFrameWindow,
  );
  bool modelFailed = false;
  bool fallbackModelActive = !LuminDetectorModel.usesCustomModel;
  bool translationDictionaryReady = false;
  DateTime lastAcceptedObject = DateTime.fromMillisecondsSinceEpoch(0);
  String fromLanguage = tr('Origem');
  String fromLanguageCode = '';
  String toLanguage = tr('Destino');
  String toLanguageCode = '';

  @override
  void initState() {
    super.initState();
    unawaited(loadTranslationDictionary());
    unawaited(loadLanguages());
    unawaited(yoloController.setShowOverlays(false));
    unawaited(
      yoloController.setThresholds(
        confidenceThreshold: LuminDetectorModel.confidenceThreshold,
      ),
    );
  }

  Future<void> loadLanguages() async {
    final response = await luminApi.me();
    if (!mounted || !response.ok) return;
    final native = response.map['nativeLanguage'];
    final chosen = response.map['chosenLanguage'];
    setState(() {
      if (native is Map) {
        if (native['name'] is String) fromLanguage = native['name'] as String;
        if (native['code'] is String) {
          fromLanguageCode = native['code'] as String;
        }
      }
      if (chosen is Map) {
        if (chosen['name'] is String) toLanguage = chosen['name'] as String;
        if (chosen['code'] is String) toLanguageCode = chosen['code'] as String;
      }
    });
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
      updateStatus(tr('Centralize um objeto'));
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

  /// Registra um frame sem objeto e só apaga a tradução quando o rótulo sai da janela de votos.
  void clearSelectedObject() {
    labelStability.miss();
    final label = acceptedLabel;
    final lost = label != null && !labelStability.hasVotes(label);

    if (selectedObject == null && !lost) {
      return;
    }

    setState(() {
      selectedObject = null;
      if (lost) {
        detectedTranslation = null;
        acceptedLabel = null;
      }
    });
  }

  /// Vota no rótulo detectado e, quando estável e confiável, monta a tradução na direção língua nativa para idioma de estudo.
  void registerStableObject(YOLOResult result) {
    final detectedLabel = result.className.trim();

    if (detectedLabel.isEmpty) {
      return;
    }

    final stable = labelStability.add(
      detectedLabel,
      required: confidencePolicy.requiredStableFramesFor(detectedLabel),
    );

    if (stable == null) {
      updateStatus(tr('Mantenha o objeto na área iluminada'));
      return;
    }

    if (!confidencePolicy.accepts(result)) {
      setState(() {
        detectedTranslation = null;
        statusText = tr('Detecção incerta');
      });
      return;
    }

    final currentTranslation = detectedTranslation;
    final now = DateTime.now();

    if (currentTranslation != null &&
        (currentTranslation.originalText == detectedLabel ||
            currentTranslation.translatedText == detectedLabel)) {
      return;
    }

    if (now.difference(lastAcceptedObject) < LuminDetectorModel.modelCooldown) {
      return;
    }

    if (!translationDictionaryReady) {
      updateStatus(tr('Preparando traduções'));
      return;
    }

    lastAcceptedObject = now;
    acceptedLabel = detectedLabel;
    final englishText = detectedLabel;
    final portugueseText = ObjectTranslationDictionary.translate(detectedLabel);
    final nativeIsEnglish = fromLanguageCode.toLowerCase().startsWith('en');

    setState(() {
      detectedTranslation = DetectedTranslation(
        originalText: nativeIsEnglish ? englishText : portugueseText,
        translatedText: nativeIsEnglish ? portugueseText : englishText,
        confidence: result.confidence,
      );
      statusText = tr('Tradução pronta');
    });
  }

  Future<void> loadFallbackDetector() async {
    if (fallbackModelActive) {
      if (!mounted) {
        return;
      }

      setState(() {
        modelFailed = true;
        statusText = tr('Não foi possível carregar o detector');
      });
      return;
    }

    setState(() {
      fallbackModelActive = true;
      activeModelPath = LuminDetectorModel.fallbackModelPath;
      activeModelTask = LuminDetectorModel.fallbackTask;
      selectedObject = null;
      detectedTranslation = null;
      labelStability.clear();
      modelFailed = false;
      statusText = tr('Carregando detector rápido');
    });

    try {
      await yoloController.switchModel(
        LuminDetectorModel.fallbackModelPath,
        LuminDetectorModel.fallbackTask,
      );
      updateStatus(tr('Centralize um objeto'));
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        modelFailed = true;
        statusText = tr('Não foi possível carregar o detector');
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

  /// Captura a foto do objeto sem marcações e abre a tela de salvar com a tradução detectada.
  Future<void> saveDetectedTranslation() async {
    final translation = detectedTranslation;

    if (translation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('Aponte para um único objeto primeiro'))),
      );
      return;
    }

    Uint8List? photo;
    try {
      photo = await yoloController.capturePhoto(withOverlays: false);
    } catch (_) {
      photo = null;
    }
    if (!mounted) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SaveTranslationScreen(
          originalText: translation.originalText,
          translatedText: translation.translatedText,
          imageBytes: photo,
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
                updateStatus(tr('Centralize um objeto'));
              },
              onModelError: (_, _, _) {
                unawaited(loadFallbackDetector());
              },
            ),
          ),
          const Positioned.fill(child: IgnorePointer(child: CameraBackdrop())),
          Positioned.fill(
            child: IgnorePointer(child: DetectionFrame(result: objectOnCenter)),
          ),
          SafeArea(
            child: Padding(
              padding: LuminSpacing.page,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CameraPill(label: fromLanguage, code: fromLanguageCode),
                      CameraPill(label: toLanguage, code: toLanguageCode),
                    ],
                  ),
                  const SizedBox(height: 12),
                  CameraTranslationPanel(
                    statusText: statusText,
                    translation: translation,
                    modelFailed: modelFailed,
                  ),
                  const Spacer(),
                  Center(
                    child: MarkerCircle(
                      selected: objectOnCenter != null,
                      enabled: objectOnCenter != null,
                      size: 128,
                      label: tr('Foco do objeto detectado'),
                    ),
                  ),
                  const SizedBox(height: 18),
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

class CameraBackdrop extends StatelessWidget {
  const CameraBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x66000000), Color(0x12000000), Color(0x80000000)],
          stops: [0.0, 0.45, 1.0],
        ),
      ),
      child: CustomPaint(painter: _CameraVignettePainter()),
    );
  }
}

class _CameraVignettePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.48);
    final radius = size.longestSide * 0.72;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            LuminColors.violet.withValues(alpha: 0.06),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
  }

  @override
  bool shouldRepaint(covariant _CameraVignettePainter oldDelegate) => false;
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
    final active = translation;
    final ready = active != null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: ready
              ? LuminColors.violet
              : Colors.white.withValues(alpha: 0.18),
          width: ready ? 1.4 : 1,
        ),
        boxShadow: ready
            ? [
                BoxShadow(
                  color: LuminColors.violet.withValues(alpha: 0.28),
                  blurRadius: 22,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: ready ? _readyBody(active) : _statusBody(),
    );
  }

  Widget _statusBody() {
    return Row(
      children: [
        if (!modelFailed) ...[
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
        ] else ...[
          const Icon(Icons.error_outline, color: LuminColors.violet, size: 18),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Text(
            statusText,
            style: TextStyle(
              color: modelFailed ? Colors.white : LuminColors.text,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _readyBody(DetectedTranslation active) {
    final confidence = '${(active.confidence * 100).round()}%';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text(
              tr('OBJETO IDENTIFICADO'),
              style: TextStyle(
                color: LuminColors.violet,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.1,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                const Icon(Icons.verified, color: Colors.white, size: 14),
                const SizedBox(width: 4),
                Text(
                  confidence,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          active.originalText.toUpperCase(),
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 12,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          active.translatedText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            height: 1.1,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class CameraCaptureButton extends StatelessWidget {
  const CameraCaptureButton({super.key, required this.enabled});

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 220),
      opacity: enabled ? 1 : 0.45,
      child: Container(
        width: 84,
        height: 84,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: LuminColors.text,
          border: Border.all(
            color: enabled ? LuminColors.violet : Colors.white24,
            width: 2,
          ),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: LuminColors.violet.withValues(alpha: 0.42),
                    blurRadius: 24,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: enabled ? 60 : 52,
            height: enabled ? 60 : 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: enabled
                  ? const LinearGradient(
                      colors: [LuminColors.violet, LuminColors.magenta],
                    )
                  : null,
              color: enabled ? null : LuminColors.muted,
            ),
            child: Icon(
              Icons.bookmark_add_outlined,
              color: LuminColors.text,
              size: enabled ? 30 : 24,
            ),
          ),
        ),
      ),
    );
  }
}

class CameraPill extends StatelessWidget {
  const CameraPill({super.key, required this.label, required this.code});

  final String label;
  final String code;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: LuminColors.violet.withValues(alpha: 0.7)),
      ),
      child: Row(
        children: [
          LanguageFlag(code: code, size: 17),
          const SizedBox(width: 6),
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
