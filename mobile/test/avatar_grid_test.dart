import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/profile/edit_profile_screen.dart';

void main() {
  testWidgets('twelve avatars fit a small phone and tapping selects one', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final avatars = [
      for (var i = 1; i <= 12; i++) {'id': i, 'name': 'Avatar $i', 'imgUrl': ''},
    ];
    int? selected;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: AvatarGrid(avatars: avatars, selectedId: 3, onSelect: (id) => selected = id),
      ),
    ));

    expect(tester.takeException(), isNull);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Avatar 1'));
    expect(selected, 1);
  });
}
