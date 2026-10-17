import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:renovax/main.dart';

Widget panel() => const MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(child: AdminInventoryPanel(preview: true)),
      ),
    );

void screenSize(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  testWidgets('La barra lateral separa las secciones y se puede contraer', (
    tester,
  ) async {
    screenSize(tester, const Size(1280, 900));
    await tester.pumpWidget(panel());
    expect(find.byType(InventoryPage), findsOneWidget);
    expect(find.byType(IncomeHistoryPage), findsNothing);

    await tester.tap(find.byKey(const ValueKey('admin-section-devices')));
    await tester.pumpAndSettle();
    expect(find.byType(InventoryPage), findsNothing);
    expect(find.text('0 teléfonos registrados'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Agregar dispositivo'),
          )
          .onPressed,
      isNull,
    );

    await tester.tap(find.byTooltip('Contraer menú'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Expandir menú'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('admin-section-history')));
    await tester.pumpAndSettle();
    expect(find.byType(IncomeHistoryPage), findsOneWidget);
    expect(find.byType(DeviceInventoryPage), findsNothing);
    expect(find.text('Aún no hay ingresos registrados.'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const ValueKey('admin-section-parts')));
    await tester.pumpAndSettle();
    expect(find.byType(InventoryPage), findsOneWidget);
  });

  testWidgets('El menú permite navegar en una pantalla estrecha',
      (tester) async {
    screenSize(tester, const Size(390, 844));
    await tester.pumpWidget(panel());
    expect(find.byKey(const ValueKey('admin-mobile-menu')), findsOneWidget);
    await tester.tap(find.text('Secciones de administración'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('admin-section-devices')));
    await tester.pumpAndSettle();
    expect(find.byType(DeviceInventoryPage), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('admin-section-history')));
    await tester.pumpAndSettle();
    expect(find.byType(IncomeHistoryPage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Suma teléfonos por marca, modelo y estado sin mezclarlos', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DeviceInventoryTable(
            entries: [
              {
                'brand': 'Samsung',
                'model': 'Galaxy A15',
                'condition': 'Funcional',
                'quantity': 2,
              },
              {
                'brand': ' samsung ',
                'model': 'galaxy  a15',
                'condition': 'Funcional',
                'quantity': 3,
              },
              {
                'brand': 'Samsung',
                'model': 'Galaxy A15',
                'condition': 'Para reparar',
                'quantity': 1,
              },
            ],
          ),
        ),
      ),
    );
    expect(find.text('6 teléfonos registrados'), findsOneWidget);
    final table = tester.widget<DataTable>(find.byType(DataTable));
    expect(table.rows, hasLength(2));
    expect(find.text('5'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('El historial combina piezas y teléfonos por fecha de ingreso', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: IncomeHistoryTable(
            parts: [
              {
                'name': 'GPS',
                'quantity': 3,
                'note': 'Recuperados',
                'createdAt': Timestamp.fromDate(DateTime.utc(2026, 10, 15)),
              },
            ],
            devices: [
              {
                'brand': 'Samsung',
                'model': 'Galaxy A15',
                'quantity': 2,
                'condition': 'Para reparar',
                'note': '',
                'createdAt': Timestamp.fromDate(DateTime.utc(2026, 10, 16)),
              },
            ],
          ),
        ),
      ),
    );
    final table = tester.widget<DataTable>(find.byType(DataTable));
    expect(table.rows, hasLength(2));
    expect(
        (table.rows.first.cells[1].child as Text).data, 'Samsung Galaxy A15');
    expect((table.rows.last.cells[1].child as Text).data, 'GPS');
    expect(find.text('Recuperados'), findsOneWidget);
    expect(find.text('Sin notas'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Rechaza dispositivos sin marca o modelo y cantidades inválidas',
      (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: AddDeviceDialog())),
    );
    await tester.tap(find.text('Guardar ingreso'));
    await tester.pumpAndSettle();
    expect(find.text('Escribí la marca del teléfono.'), findsOneWidget);
    expect(find.text('Escribí el modelo del teléfono.'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).at(0), 'Samsung');
    await tester.enterText(find.byType(TextFormField).at(1), 'Galaxy A15');
    for (final quantity in ['', '0', '-1', '1.5', '1000001']) {
      final field = find.byType(TextFormField).at(2);
      await tester.ensureVisible(field);
      await tester.enterText(field, quantity);
      await tester.tap(find.text('Guardar ingreso'));
      await tester.pumpAndSettle();
      expect(find.text('Ingresá un entero entre 1 y 1000000.'), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });
}
