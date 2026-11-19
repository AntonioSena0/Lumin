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

  /// Retorna a confiança mínima do rótulo, mais alta para objetos fáceis de confundir.
  double minimumConfidenceFor(String label) {
    final normalizedLabel = ObjectTranslationDictionary.normalize(label);

    if (cautiousLabels.contains(normalizedLabel)) {
      return LuminDetectorModel.cautiousConfidenceThreshold;
    }

    return LuminDetectorModel.confidenceThreshold;
  }

  /// Retorna quantos votos na janela o rótulo precisa para ser considerado estável.
  int requiredStableFramesFor(String label) {
    final normalizedLabel = ObjectTranslationDictionary.normalize(label);

    if (cautiousLabels.contains(normalizedLabel)) {
      return LuminDetectorModel.cautiousStableFrameTarget;
    }

    return LuminDetectorModel.stableFrameTarget;
  }

  /// Aceita a detecção quando tem rótulo, confiança mínima e área útil na tela.
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

    return true;
  }

  /// Rejeita caixas pequenas demais ou que ocupam quase a tela inteira.
  bool hasUsefulArea(Rect box) {
    final area = box.width * box.height;
    return area >= 0.0025 && area <= 0.82;
  }
}
