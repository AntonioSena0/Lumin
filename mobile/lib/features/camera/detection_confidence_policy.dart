import 'package:flutter/widgets.dart';
import 'package:mobile/features/camera/lumin_detector_model.dart';
import 'package:mobile/features/camera/object_translation_dictionary.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';

class DetectionConfidencePolicy {
  const DetectionConfidencePolicy();

  static const cautiousLabels = {
    'adapter',
    'adhesive tape',
    'cable',
    'candle',
    'charging cable',
    'charger',
    'comb',
    'cotton swab',
    'fork',
    'glue stick',
    'highlighter',
    'key',
    'knife',
    'lighter',
    'marker',
    'mechanical pencil',
    'paint brush',
    'pen',
    'pencil',
    'screw',
    'screwdriver',
    'ruler',
    'scissors',
    'spoon',
    'straw',
    'tablet pen',
    'toothpick',
    'toothbrush',
    'wire',
    'wrench',
  };

  static const slenderLabels = {
    'adapter',
    'adhesive tape',
    'cable',
    'candle',
    'charging cable',
    'cotton swab',
    'glue stick',
    'highlighter',
    'knife',
    'lighter',
    'marker',
    'mechanical pencil',
    'paint brush',
    'pen',
    'pencil',
    'ruler',
    'screw',
    'screwdriver',
    'straw',
    'tablet pen',
    'toothpick',
    'toothbrush',
    'wire',
    'wrench',
  };

  double minimumConfidenceFor(String label) {
    final normalizedLabel = ObjectTranslationDictionary.normalize(label);

    if (cautiousLabels.contains(normalizedLabel)) {
      return 0.72;
    }

    return LuminDetectorModel.confidenceThreshold;
  }

  int requiredStableFramesFor(String label) {
    final normalizedLabel = ObjectTranslationDictionary.normalize(label);

    if (cautiousLabels.contains(normalizedLabel)) {
      return 12;
    }

    return LuminDetectorModel.stableFrameTarget;
  }

  bool accepts(YOLOResult result) {
    final normalizedLabel = ObjectTranslationDictionary.normalize(
      result.className,
    );

    if (normalizedLabel.isEmpty) {
      return false;
    }

    if (result.confidence < minimumConfidenceFor(normalizedLabel)) {
      return false;
    }

    if (!hasUsefulArea(result.normalizedBox)) {
      return false;
    }

    if (slenderLabels.contains(normalizedLabel)) {
      return hasSlenderShape(result.normalizedBox);
    }

    return true;
  }

  bool isAmbiguous(YOLOResult selectedResult, YOLOResult candidate) {
    final candidateLabel = ObjectTranslationDictionary.normalize(
      candidate.className,
    );
    final selectedLabel = ObjectTranslationDictionary.normalize(
      selectedResult.className,
    );
    final confidenceGap = selectedResult.confidence - candidate.confidence;

    return candidateLabel.isNotEmpty &&
        candidateLabel != selectedLabel &&
        confidenceGap >= 0 &&
        confidenceGap <= 0.1 &&
        candidate.normalizedBox.overlaps(selectedResult.normalizedBox);
  }

  bool hasUsefulArea(Rect box) {
    final area = box.width * box.height;
    return area >= 0.0025 && area <= 0.82;
  }

  bool hasSlenderShape(Rect box) {
    final ratio = box.width / box.height;
    return ratio <= 0.58 || ratio >= 1.72;
  }
}
