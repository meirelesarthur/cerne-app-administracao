import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/ui/ui.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: buildAppTheme(AppThemeVariant.light),
  home: Scaffold(body: child),
);

const _items = [
  AppCollectionItemView(title: 'Lote Engorda 05', subtitle: '111'),
];

void main() {
  group('AppCollectionList', () {
    testWidgets('sem onAdd fica somente leitura: sem faixa de ação nem '
        'ícones por item', (tester) async {
      await tester.pumpWidget(
        _wrap(const AppCollectionList(name: 'Animais alvo', items: _items)),
      );

      expect(find.text('Animais alvo'), findsOneWidget);
      expect(find.text('Adicionar'), findsNothing);
      expect(find.text('Lote Engorda 05'), findsOneWidget);
      expect(find.byTooltip('Editar item'), findsNothing);
      expect(find.byTooltip('Remover item'), findsNothing);
    });

    testWidgets('com onAdd mostra a faixa "Adicionar"', (tester) async {
      await tester.pumpWidget(
        _wrap(AppCollectionList(name: 'Insumos', items: _items, onAdd: () {})),
      );

      expect(find.text('Adicionar'), findsOneWidget);
    });

    testWidgets('onEdit e onRemove disparam com o índice do item', (
      tester,
    ) async {
      int? edited;
      int? removed;
      await tester.pumpWidget(
        _wrap(
          AppCollectionList(
            name: 'Insumos',
            items: _items,
            onAdd: () {},
            onEdit: (index) => edited = index,
            onRemove: (index) => removed = index,
          ),
        ),
      );

      await tester.tap(find.byTooltip('Editar item'));
      expect(edited, 0);

      await tester.tap(find.byTooltip('Remover item'));
      expect(removed, 0);
    });
  });
}
