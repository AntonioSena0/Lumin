import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/i18n/i18n.dart';
import 'package:mobile/core/models/session_summary.dart';

void main() {
  tearDown(() => appLanguage.value = 'pt');

  test('status label is readable and follows the app language', () {
    final open = SessionSummary({'status': 'IN_PROGRESS'});
    final done = SessionSummary({'status': 'FINISHED'});

    expect(open.statusLabel, 'Em andamento');
    expect(done.statusLabel, 'Finalizada');

    appLanguage.value = 'en';
    expect(open.statusLabel, 'In progress');
    expect(done.statusLabel, 'Finished');
  });

  test('a session with every exercise answered still needs finishing until the API says FINISHED', () {
    final answered = SessionSummary({'status': 'IN_PROGRESS', 'currentIndex': 15, 'totalExercises': 15});

    expect(answered.needsFinishing, isTrue);
    expect(SessionSummary({'status': 'FINISHED', 'currentIndex': 15, 'totalExercises': 15}).needsFinishing, isFalse);
    expect(SessionSummary({'status': 'IN_PROGRESS', 'currentIndex': 3, 'totalExercises': 15}).needsFinishing, isFalse);
  });
}
