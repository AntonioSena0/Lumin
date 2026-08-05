import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:mobile/features/camera/detection_confidence_policy.dart';
import 'package:mobile/features/camera/lumin_detector_model.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';

class YoloObjectSelectionService {
  const YoloObjectSelectionService();

  static const confidencePolicy = DetectionConfidencePolicy();

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

    if (selectedResult == null) {
      return null;
    }

    if (hasAmbiguousCandidate(selectedResult, results)) {
      return null;
    }

    return selectedResult;
  }

  bool isCandidate(YOLOResult result) {
    return result.confidence >= LuminDetectorModel.confidenceThreshold &&
        result.className.trim().isNotEmpty &&
        confidencePolicy.accepts(result) &&
        result.normalizedBox.contains(const Offset(0.5, 0.5));
  }

  bool hasAmbiguousCandidate(
    YOLOResult selectedResult,
    List<YOLOResult> results,
  ) {
    for (final result in results) {
      if (identical(result, selectedResult) || !isCandidate(result)) {
        continue;
      }

      if (confidencePolicy.isAmbiguous(selectedResult, result)) {
        return true;
      }
    }

    return false;
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
