import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/ui/app_icon.dart';
import 'package:cerne_app/ui/top_bar.dart';

import '../helpers/app_icon_finder.dart';

Widget _wrap(Widget child) {
  final container = ProviderContainer();
  addTearDown(container.dispose);
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      theme: buildAppTheme(AppThemeVariant.light),
      home: Scaffold(body: SizedBox(width: 402, child: child)),
    ),
  );
}

void main() {
  group('AppTopBar', () {
    testWidgets('centraliza o título e reserva as duas ações', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AppTopBar(
            title: 'Cadastro',
            onBack: () {},
            actionIcon: AppIcons.moreVertical,
            actionLabel: 'Mais opções',
            onAction: () {},
          ),
        ),
      );

      expect(find.text('Cadastro'), findsOneWidget);
      expect(findAppIcon(AppIcons.arrowLeft), findsOneWidget);
      expect(findAppIcon(AppIcons.moreVertical), findsOneWidget);
    });

    testWidgets('dispara voltar e ação', (tester) async {
      var voltou = false;
      var abriu = false;
      await tester.pumpWidget(
        _wrap(
          AppTopBar(
            title: 'Cadastro',
            onBack: () => voltou = true,
            actionIcon: AppIcons.moreVertical,
            actionLabel: 'Mais opções',
            onAction: () => abriu = true,
          ),
        ),
      );

      await tester.tap(findAppIcon(AppIcons.arrowLeft));
      await tester.tap(findAppIcon(AppIcons.moreVertical));
      expect(voltou, isTrue);
      expect(abriu, isTrue);
    });
  });
}
