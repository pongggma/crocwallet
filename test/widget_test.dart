// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:croc_wallet/app.dart';
import 'package:croc_wallet/providers/app_state.dart';

void main() {
  testWidgets('Croc Wallet home screen renders', (WidgetTester tester) async {
    final state = AppState();
    addTearDown(state.dispose);

    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: state,
        child: const CrocWalletApp(),
      ),
    );

    expect(find.text('CrocWallet'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
  });
}
