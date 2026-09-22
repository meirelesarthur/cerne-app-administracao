import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/ui/step_progress.dart';

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
  group('AppStepProgress', () {
    testWidgets('expõe a etapa atual e cria um segmento por etapa', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const AppStepProgress(total: 4, current: 2)),
      );

      expect(find.bySemanticsLabel('Etapa 2 de 4'), findsOneWidget);
      final progress = find.byType(AppStepProgress);
      expect(
        find.descendant(of: progress, matching: find.byType(Expanded)),
        findsNWidgets(4),
      );
    });

    testWidgets('limita a etapa informada ao total', (tester) async {
      await tester.pumpWidget(
        _wrap(const AppStepProgress(total: 3, current: 9)),
      );

      expect(find.bySemanticsLabel('Etapa 3 de 3'), findsOneWidget);
    });
  });
}
