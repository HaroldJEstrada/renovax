import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:renovax/main.dart';
import 'package:renovax/config.dart';
import 'package:renovax/brand_theme.dart';

void main() {
  setUp(() => appTheme.value = ThemeMode.light);
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
  testWidgets('El tema oscuro permanece al navegar a misión y administración', (
    tester,
  ) async {
    await tester.pumpWidget(const RenovaxApp());
    await tester.tap(find.text('Oscuro'));
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.byType(PublicPage))).brightness,
      Brightness.dark,
    );
    await tester.tap(find.text('Misión'));
    await tester.pumpAndSettle();
    expect(
      find.text('Cómo llevamos nuestra misión a la práctica'),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (w) =>
            w is Image &&
            w.image is AssetImage &&
            (w.image as AssetImage).assetName == 'component_camera.jpg',
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Administración'));
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.byType(AdminPage))).brightness,
      Brightness.dark,
    );
    await tester.tap(find.byTooltip('Activar modo claro'));
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.byType(AdminPage))).brightness,
      Brightness.light,
    );
  });

  testWidgets('Misión y visión se adaptan a una pantalla estrecha', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const RenovaxApp());
    await tester.tap(find.text('Misión'));
    await tester.pumpAndSettle();
    expect(find.text('Nuestra misión'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Visión'));
    await tester.pumpAndSettle();
    expect(find.text('Nuestra visión'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('Los nombres de piezas se normalizan para evitar duplicados', () {
    expect(partKey('  MOTOR   vibrador  '), partKey('Motor vibrador'));
  });
}
