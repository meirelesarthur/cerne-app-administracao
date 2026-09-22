import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/ui/app_icon.dart';
import 'package:cerne_app/ui/entity_row.dart';
import 'package:cerne_app/ui/tag.dart';

import '../helpers/app_icon_finder.dart';

Widget _wrap(Widget child) {
  final container = ProviderContainer();
  addTearDown(container.dispose);
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      theme: buildAppTheme(AppThemeVariant.light),
      home: Scaffold(body: SizedBox(width: 370, child: child)),
    ),
  );
}

void main() {
  group('AppEntityRow', () {
    testWidgets('renderiza os cinco campos da entidade', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AppEntityRow(
            icon: AppIcons.cash,
            title: 'Casa do adubo',
            tag: AppTag(tone: AppTagTone.success, child: Text('Pré-aprovado')),
            value: r'R$ 720.000,00',
            meta: 'a partir de 1,05% a.m.',
          ),
        ),
      );

      expect(findAppIcon(AppIcons.cash), findsOneWidget);
      expect(find.text('Casa do adubo'), findsOneWidget);
      expect(find.text('Pré-aprovado'), findsOneWidget);
      expect(find.text(r'R$ 720.000,00'), findsOneWidget);
      expect(find.text('a partir de 1,05% a.m.'), findsOneWidget);
      expect(
        tester.getSize(find.byType(AppEntityRow)).height,
        AppEntityRow.height,
      );
    });

    testWidgets('dispara onTap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(
          AppEntityRow(
            icon: AppIcons.package,
            title: 'Pedido #4821',
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.byType(AppEntityRow));
      expect(tapped, isTrue);
    });
  });
}
