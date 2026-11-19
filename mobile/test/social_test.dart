import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/social/people_screen.dart';

Map<String, dynamic> profile({bool followedByMe = false, bool me = false}) => {
      'id': 2,
      'name': 'bia',
      'avatar': null,
      'nativeLanguage': {'id': 1, 'code': 'pt-BR', 'name': 'Português (Brasil)'},
      'chosenLanguage': {'id': 2, 'code': 'en', 'name': 'English'},
      'followers': 10,
      'following': 3,
      'followedByMe': followedByMe,
      'me': me,
    };

Future<void> pump(WidgetTester tester, Map<String, dynamic> data, {VoidCallback? onToggle}) {
  return tester.pumpWidget(MaterialApp(
    home: Scaffold(body: PublicProfileView(profile: data, onToggleFollow: onToggle ?? () {})),
  ));
}

void main() {
  testWidgets('shows name and follow counts', (tester) async {
    await pump(tester, profile());

    expect(find.text('bia'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('follow button reflects whether I follow and calls toggle', (tester) async {
    var toggled = 0;
    await pump(tester, profile(), onToggle: () => toggled++);
    expect(find.text('Seguir'), findsOneWidget);

    await tester.tap(find.text('Seguir'));
    expect(toggled, 1);

    await pump(tester, profile(followedByMe: true));
    expect(find.text('Deixar de seguir'), findsOneWidget);
  });

  testWidgets('own profile has no follow button', (tester) async {
    await pump(tester, profile(me: true));

    expect(find.text('Seguir'), findsNothing);
    expect(find.text('Deixar de seguir'), findsNothing);
  });
}
