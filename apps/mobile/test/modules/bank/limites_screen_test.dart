import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/bank/screens/limites_screen.dart';

import '../../support/test_viewport.dart';

Widget _wrap() => ProviderScope(
  child: MaterialApp(
    theme: buildAppTheme(AppThemeVariant.light),
    home: const Scaffold(body: LimitesScreen()),
  ),
);

void main() {
  group('LimitesScreen', () {
    testWidgets('renderiza todas as faixas de limite sem exceção', (
      tester,
    ) async {
      await setTallSurface(tester);
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      expect(find.text('Limites'), findsOneWidget);
      expect(find.text('Limite de crédito'), findsOneWidget);
      expect(find.text('Pix por transação (diurno)'), findsOneWidget);
      expect(find.text('Pix por transação (noturno)'), findsOneWidget);
      expect(find.text('Saque diário'), findsOneWidget);
      expect(find.textContaining('36% utilizado'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
