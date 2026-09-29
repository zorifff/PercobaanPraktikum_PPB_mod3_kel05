import 'package:flutter_test/flutter_test.dart';
import 'package:mod3_kel05/main.dart';

void main() {
  testWidgets('Country app displays its main navigation', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const CountryApp());
    expect(find.text('Countries'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });
}