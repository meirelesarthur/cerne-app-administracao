import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/fazendas/components/activity_detail_sheet.dart';
import 'package:cerne_app/modules/fazendas/types.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: buildAppTheme(AppThemeVariant.light),
  home: Scaffold(body: child),
);

const _activity = Activity(
  id: 'a1',
  title: 'Pesagem do Lote 42',
  subtitle: 'São Pedro · 128 cabeças',
  status: ActivityStatus.concluida,
  time: 'há 12 min',
  kind: ActivityKind.pesagem,
);

void main() {
  group('showActivityDetailSheet', () {
    testWidgets('abre o bottom sheet com o detalhe da atividade', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (context) => ElevatedButton(
              onPressed: () =>
                  showActivityDetailSheet(context, activity: _activity),
              child: const Text('abrir'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();

      expect(find.text('Detalhe da atividade'), findsOneWidget);
      expect(find.text('Pesagem do Lote 42'), findsOneWidget);
      expect(find.text('São Pedro'), findsOneWidget);
      expect(find.text('128 cabeças'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
