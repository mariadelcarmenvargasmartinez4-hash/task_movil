import 'package:flutter_test/flutter_test.dart';
import 'package:task_movie/main.dart';

void main() {
  testWidgets('HomeTask Smart app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const HomeTaskApp());
    await tester.pumpAndSettle();

    // Verify that the title "HomeTask Smart" is present on the login screen
    expect(find.text('HomeTask Smart'), findsOneWidget);
    
    // Verify that the login credentials screen is displayed
    expect(find.text('Iniciar Sesión'), findsOneWidget);
    expect(find.text('Usuario'), findsOneWidget);
    expect(find.text('Contraseña'), findsOneWidget);
    expect(find.text('Ingresar'), findsOneWidget);
  });
}
