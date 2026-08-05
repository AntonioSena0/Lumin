import 'package:ultralytics_yolo/ultralytics_yolo.dart';

class LuminDetectorModel {
  const LuminDetectorModel._();

  static const configuredModelPath = String.fromEnvironment(
    'LUMIN_DETECTOR_MODEL_PATH',
    defaultValue: 'assets/models/lumin_yoloe_26n_seg.tflite',
  );

  static const configuredTaskName = String.fromEnvironment(
    'LUMIN_DETECTOR_TASK',
    defaultValue: 'segment',
  );

  static const fallbackModelPath = 'yolo26n';
  static const fallbackTask = YOLOTask.detect;
  static const confidenceThreshold = 0.48;
  static const stableFrameTarget = 8;
  static const modelCooldown = Duration(seconds: 3);

  static YOLOTask get configuredTask {
    return switch (configuredTaskName) {
      'segment' => YOLOTask.segment,
      'semantic' => YOLOTask.semantic,
      'classify' => YOLOTask.classify,
      'pose' => YOLOTask.pose,
      'obb' => YOLOTask.obb,
      _ => YOLOTask.detect,
    };
  }

  static bool get usesCustomModel {
    return configuredModelPath != fallbackModelPath;
  }
}
