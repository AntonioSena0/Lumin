import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/auth/welcome_screen.dart';
import 'package:mobile/shared/widgets/language_flag.dart';

void main() {
  testWidgets('shows welcome screen', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: WelcomeScreen()));

    expect(find.text('Explore'), findsOneWidget);
    expect(find.text('Começar'), findsOneWidget);
  });

  test('maps language codes to flag countries served by the API', () {
    expect(languageCountryForCode('pt-BR'), 'br');
    expect(languageCountryForCode('en'), 'us');
    expect(languageCountryForCode('pt'), 'br');
    expect(languageCountryForCode(''), isNull);
  });
}
