import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:mobile/features/camera/detection_confidence_policy.dart';
import 'package:mobile/features/camera/lumin_detector_model.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';

class YoloObjectSelectionService {
  const YoloObjectSelectionService();

  static const confidencePolicy = DetectionConfidencePolicy();

  /// Escolhe a detecção com maior pontuação entre as candidatas próximas ao centro.
  YOLOResult? selectCenteredObject(List<YOLOResult> results) {
    YOLOResult? selectedResult;
    var selectedScore = double.negativeInfinity;

    for (final result in results) {
      if (!isCandidate(result)) {
        continue;
      }

      final score = priorityScore(result);

      if (score > selectedScore) {
        selectedResult = result;
        selectedScore = score;
      }
    }

    return selectedResult;
  }

  /// Indica se a detecção tem confiança, rótulo e posição suficientes para ser escolhida.
  bool isCandidate(YOLOResult result) {
    return result.confidence >= LuminDetectorModel.confidenceThreshold &&
        result.className.trim().isNotEmpty &&
        confidencePolicy.accepts(result) &&
        isNearCenter(result.normalizedBox);
  }

  /// Aceita objetos que cobrem o centro da tela ou cujo centro está dentro da tolerância.
  bool isNearCenter(Rect box) {
    return box.contains(const Offset(0.5, 0.5)) ||
        centerDistance(box) <= LuminDetectorModel.centerTolerance;
  }

  double priorityScore(YOLOResult result) {
    final box = result.normalizedBox;
    final distance = centerDistance(box);
    final area = box.width * box.height;
    final readableArea = area.clamp(0.02, 0.55);

    return result.confidence + readableArea * 0.12 - distance * 0.55;
  }

  double centerDistance(Rect box) {
    final boxCenter = box.center;
    return sqrt(pow(boxCenter.dx - 0.5, 2) + pow(boxCenter.dy - 0.5, 2));
  }
}
