import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/study/exercise_widgets.dart';

Widget host(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('exerciseKind', () {
    test('picks the answer format from type, subType and options', () {
      expect(exerciseKind({'type': 'speaking'}), ExerciseKind.speaking);
      expect(exerciseKind({'type': 'written', 'subType': 'MULTIPLE_CHOICE', 'options': ['a', 'b']}), ExerciseKind.choice);
      expect(exerciseKind({'type': 'written', 'subType': 'FILL_IN', 'options': ['a', 'b']}), ExerciseKind.choice);
      expect(exerciseKind({'type': 'written', 'subType': 'TRANSLATE', 'options': ['a', 'b']}), ExerciseKind.sentence);
      expect(exerciseKind({'type': 'written', 'subType': 'REWRITE', 'options': ['a', 'b']}), ExerciseKind.sentence);
    });

    test('sessions created before word blocks fall back to typing', () {
      expect(exerciseKind({'type': 'written', 'subType': 'TRANSLATE', 'options': []}), ExerciseKind.text);
      expect(exerciseKind({'type': 'written', 'subType': 'FILL_IN'}), ExerciseKind.text);
    });
  });

  testWidgets('sentence builder keeps tap order and handles repeated words', (tester) async {
    String answer = '';
    await tester.pumpWidget(host(SentenceBuilder(
      blocks: const ['the', 'desk', 'The', 'keyboard', 'the'],
      onChanged: (value) => answer = value,
    )));

    await tester.tap(find.text('The'));
    await tester.tap(find.text('keyboard'));
    await tester.tap(find.text('the').first);
    await tester.tap(find.text('desk'));
    await tester.pump();
    expect(answer, 'The keyboard the desk');

    await tester.tap(find.byKey(const ValueKey('placed-1')));
    await tester.pump();
    expect(answer, 'The the desk');
    expect(find.text('keyboard'), findsOneWidget);
  });

  testWidgets('choice answer reports the selected option', (tester) async {
    String? selected;
    await tester.pumpWidget(host(ChoiceAnswer(
      options: const ['mouse', 'keyboard'],
      selected: null,
      onSelect: (value) => selected = value,
    )));

    await tester.tap(find.text('keyboard'));
    expect(selected, 'keyboard');
  });

  testWidgets('fill-in prompt shows the chosen word inside the blank', (tester) async {
    await tester.pumpWidget(host(const FillInPrompt(prompt: 'She cleaned the _____ today.', filled: 'keyboard')));

    expect(find.textContaining('keyboard', findRichText: true), findsOneWidget);
    expect(find.textContaining('_____', findRichText: true), findsNothing);
  });
}
