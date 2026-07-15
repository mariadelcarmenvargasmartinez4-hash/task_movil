import 'package:flutter_test/flutter_test.dart';
import 'package:task_movie/main.dart';

void main() {
  testWidgets('HomeTask Smart app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const HomeTaskApp());

    // Verify that the title "HomeTask Smart" is present
    expect(find.text('HomeTask Smart'), findsOneWidget);
    
    // Verify that "Ecosistema Familiar Activo" subtitle is present
    expect(find.text('Ecosistema Familiar Activo'), findsOneWidget);
  });
}
