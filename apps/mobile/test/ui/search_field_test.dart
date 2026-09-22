import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/ui/app_icon.dart';
import 'package:cerne_app/ui/search_field.dart';

import '../helpers/app_icon_finder.dart';

Widget _wrap(Widget child, AppThemeVariant variant) {
  final container = ProviderContainer();
  addTearDown(container.dispose);
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      theme: buildAppTheme(variant),
      home: Scaffold(body: SizedBox(width: 370, child: child)),
    ),
  );
}

void main() {
  group('AppSearchField', () {
    testWidgets('mantém anatomia e abre a busca', (tester) async {
      var opened = false;
      await tester.pumpWidget(
        _wrap(
          AppSearchField(
            placeholder: 'Buscar em Confinamento',
            onTap: () => opened = true,
          ),
          AppThemeVariant.light,
        ),
      );

      expect(find.text('Buscar em Confinamento'), findsOneWidget);
      expect(findAppIcon(AppIcons.aiSearch), findsOneWidget);
      expect(
        tester.getSize(find.byType(AppSearchField)).height,
        AppSearchField.height,
      );
      await tester.tap(find.byType(AppSearchField));
      expect(opened, isTrue);
    });

    testWidgets('renderiza nos dois temas', (tester) async {
      for (final variant in AppThemeVariant.values) {
        await tester.pumpWidget(_wrap(const AppSearchField(), variant));
        expect(tester.takeException(), isNull);
      }
    });
  });
}
