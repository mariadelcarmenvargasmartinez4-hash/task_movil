import 'package:flutter_test/flutter_test.dart';
import 'package:task_movie/main.dart';

void main() {
  testWidgets('HomeTask Smart app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const HomeTaskApp());
    await tester.pumpAndSettle();

    // Verify that the title "HomeTask Smart" is present on the login screen
    expect(find.text('HomeTask Smart'), findsOneWidget);
    
    // Verify that the login role selection card is displayed
    expect(find.text('Selecciona tu Rol'), findsOneWidget);
    expect(find.text('Papá / Mamá'), findsOneWidget);
    expect(find.text('Hijo / Hija'), findsOneWidget);
  });
}
