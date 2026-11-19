import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/camera/detection_confidence_policy.dart';
import 'package:mobile/features/camera/label_stability.dart';
import 'package:mobile/features/camera/yolo_object_selection_service.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';

YOLOResult result(String label, double confidence, Rect box) => YOLOResult(
      classIndex: 0,
      className: label,
      confidence: confidence,
      boundingBox: box,
      normalizedBox: box,
    );

void main() {
  const service = YoloObjectSelectionService();
  const policy = DetectionConfidencePolicy();

  test('object near the center is selected even if it does not cover the exact center', () {
    final cup = result('cup', 0.7, const Rect.fromLTRB(0.55, 0.45, 0.75, 0.65));

    expect(service.selectCenteredObject([cup]), same(cup));
  });

  test('object far from the center is ignored', () {
    final cup = result('cup', 0.9, const Rect.fromLTRB(0.8, 0.8, 0.95, 0.95));

    expect(service.selectCenteredObject([cup]), isNull);
  });

  test('overlapping synonyms with close confidence pick the best instead of nothing', () {
    final cup = result('cup', 0.70, const Rect.fromLTRB(0.3, 0.3, 0.7, 0.7));
    final mug = result('mug', 0.66, const Rect.fromLTRB(0.32, 0.3, 0.7, 0.72));

    expect(service.selectCenteredObject([cup, mug]), same(cup));
  });

  test('diagonal pen (square box) is accepted', () {
    final pen = result('pen', 0.8, const Rect.fromLTRB(0.35, 0.35, 0.65, 0.65));

    expect(policy.accepts(pen), isTrue);
  });

  test('low confidence is still rejected', () {
    final cup = result('cup', 0.2, const Rect.fromLTRB(0.3, 0.3, 0.7, 0.7));

    expect(service.selectCenteredObject([cup]), isNull);
  });

  group('LabelStability', () {
    test('a single flickering frame does not reset the vote', () {
      final vote = LabelStability(window: 10);
      final frames = ['cup', 'cup', 'mug', 'cup', 'cup', 'cup', 'cup'];
      String? stable;
      for (final f in frames) {
        stable = vote.add(f, required: 6);
      }
      expect(stable, 'cup');
    });

    test('not stable before enough votes', () {
      final vote = LabelStability(window: 10);
      String? stable;
      for (final f in ['cup', 'mug', 'cup', 'mug', 'cup']) {
        stable = vote.add(f, required: 6);
      }
      expect(stable, isNull);
    });

    test('a single frame without object does not reset the vote', () {
      final vote = LabelStability(window: 10);
      for (var i = 0; i < 5; i++) {
        vote.add('cup', required: 6);
      }
      vote.miss();
      expect(vote.add('cup', required: 6), 'cup');
    });

    test('label loses its votes only after leaving the whole window', () {
      final vote = LabelStability(window: 3);
      vote.add('cup', required: 1);
      vote.miss();
      vote.miss();
      expect(vote.hasVotes('cup'), isTrue);
      vote.miss();
      expect(vote.hasVotes('cup'), isFalse);
    });

    test('clear forgets previous votes', () {
      final vote = LabelStability(window: 10);
      for (var i = 0; i < 6; i++) {
        vote.add('cup', required: 6);
      }
      vote.clear();
      expect(vote.add('cup', required: 6), isNull);
    });
  });
}
