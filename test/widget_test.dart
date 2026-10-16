import 'package:flutter_test/flutter_test.dart';
import 'package:renovax/main.dart';

void main() {
  testWidgets('Muestra la bienvenida de Renovax', (tester) async {
    await tester.pumpWidget(const RenovaxApp());
    expect(find.text('Renovax'), findsOneWidget);
    expect(find.text('Bienvenido a Renovax'), findsOneWidget);
  });
}
