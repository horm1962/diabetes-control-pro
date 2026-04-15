// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:controlando_mi_diabetes/main.dart';
import 'package:controlando_mi_diabetes/services/auth_service.dart';

void main() {
  testWidgets('Muestra pantalla de login cuando no hay sesion', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthService>(
        create: (_) => AuthService(),
        child: const ControlDiabetesApp(),
      ),
    );

    expect(find.text('Controlando Mi Diabetes'), findsOneWidget);
    expect(find.text('Iniciar Sesión'), findsOneWidget);
  });
}
