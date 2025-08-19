import 'package:flutter_test/flutter_test.dart';
import 'package:lembrar_mais/app.dart'; // troque para onde está sua classe App

void main() {
  testWidgets('Carrega a tela de login', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const App());

    // Verifica se a tela de login aparece
    expect(find.text('Login'), findsOneWidget);
  });
}
