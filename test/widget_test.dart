import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:renovax/main.dart';
import 'package:renovax/config.dart';

void main() {
  testWidgets('Navega a donaciones sin exigir Firebase al abrir la página', (
    tester,
  ) async {
    await tester.pumpWidget(const RenovaxApp());
    expect(
      find.text('Tu celular en desuso.\nUna nueva posibilidad.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Donaciones'));
    await tester.pumpAndSettle();
    expect(find.text('Continuar con Google'), findsOneWidget);
    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Continuar con Google'),
    );
    expect(button.onPressed, isNull);
  });
  testWidgets(
    'Inventario de vista previa inicia en cero y no permite escrituras',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: InventoryPage(preview: true)),
          ),
        ),
      );
      for (final name in baseParts) {
        expect(find.text(name), findsOneWidget);
      }
      final button = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Agregar pieza'),
      );
      expect(button.onPressed, isNull);
    },
  );
  test('Los nombres de piezas se normalizan para evitar duplicados', () {
    expect(partKey('  MOTOR   vibrador  '), partKey('Motor vibrador'));
  });
}
