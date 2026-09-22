import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/fazendas/components/activity_list_item.dart';
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
  group('ActivityListItem', () {
    testWidgets('renderiza título, subtítulo e status sem exceção', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const ActivityListItem(activity: _activity)),
      );

      expect(find.text('Pesagem do Lote 42'), findsOneWidget);
      expect(find.text('São Pedro · 128 cabeças'), findsOneWidget);
      expect(find.text('Concluída'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('dispara onTap ao tocar', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(
          ActivityListItem(activity: _activity, onTap: () => tapped = true),
        ),
      );

      await tester.tap(find.byType(ActivityListItem));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });
}
