import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/ui/transaction_detail_sheet.dart';
import 'package:cerne_app/ui/transaction_list_item.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: buildAppTheme(AppThemeVariant.light),
  home: Scaffold(body: child),
);

void main() {
  const sample = AppTransactionItem(
    id: '1',
    title: 'Venda de soja — lote 42',
    subtitle: 'Cooperativa Central',
    time: '09:12',
    value: 'R\$ 12.400,00',
    direction: AppTransactionDirection.income,
  );

  group('showAppTransactionDetailSheet', () {
    testWidgets('abre e mostra o comprovante da transação', (tester) async {
      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (context) => ElevatedButton(
              onPressed: () =>
                  showAppTransactionDetailSheet(context, transaction: sample),
              child: const Text('Abrir'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();

      expect(find.text('Detalhe da transação'), findsOneWidget);
      expect(find.text('Venda de soja — lote 42'), findsOneWidget);
      expect(find.text('Cooperativa Central'), findsOneWidget);
      expect(find.text('+ R\$ 12.400,00'), findsOneWidget);
      expect(find.text('E9040088-2607-000001-GBNK'), findsOneWidget);
    });

    testWidgets('oculta o valor quando hidden=true', (tester) async {
      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showAppTransactionDetailSheet(
                context,
                transaction: sample,
                hidden: true,
              ),
              child: const Text('Abrir'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();

      expect(find.text('••••••'), findsOneWidget);
      expect(find.text('+ R\$ 12.400,00'), findsNothing);
    });

    testWidgets('copia o ID da operação ao tocar no botão', (tester) async {
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      final calls = <MethodCall>[];
      messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
        calls.add(call);
        return null;
      });
      addTearDown(
        () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
      );

      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (context) => ElevatedButton(
              onPressed: () =>
                  showAppTransactionDetailSheet(context, transaction: sample),
              child: const Text('Abrir'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Copiar ID da operação'));
      await tester.pump();

      expect(calls.any((c) => c.method == 'Clipboard.setData'), isTrue);
      expect(find.byTooltip('ID copiado'), findsOneWidget);

      // Após 1.6s o estado "copiado" reverte.
      await tester.pump(const Duration(milliseconds: 1700));
      expect(find.byTooltip('Copiar ID da operação'), findsOneWidget);
    });
  });
}
