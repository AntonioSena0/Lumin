import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app/lumin_app.dart';

void main() {
  testWidgets('shows welcome screen', (tester) async {
    await tester.pumpWidget(const LuminApp());

    expect(find.text('Explore'), findsOneWidget);
    expect(find.text('Começar'), findsOneWidget);
  });
}
