import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/fazendas/functional_catalog.dart';
import 'package:cerne_app/modules/fazendas/screens/mapped_feature_screen.dart';

import '../../../support/test_viewport.dart';

Widget _wrap(
  ProviderContainer container, {
  required String featureId,
  required FeatureProfile profile,
}) => UncontrolledProviderScope(
  container: container,
  child: MaterialApp(
    theme: buildAppTheme(AppThemeVariant.light),
    home: Scaffold(
      body: MappedFeatureScreen(featureId: featureId, profile: profile),
    ),
  ),
);

void main() {
  group('MappedFeatureScreen — Onda D', () {
    test('toda funcionalidade Ready tem destino executável', () {
      final ready = allFeatures.where(
        (feature) => feature.status == FeatureStatus.ready,
      );

      // CERNE ADM: só o catálogo administrativo (17 funcionalidades, todas
      // Ready) — as 38 de campo vivem no app irmão. Ver
      // functional_catalog_test.dart.
      expect(ready, hasLength(17));
      for (final feature in ready) {
        final handledByMappedScreen =
            feature.auditExport != null ||
            feature.listMode ||
            feature.fields.isNotEmpty ||
            feature.sections.isNotEmpty;
        expect(
          feature.existingRoute != null || handledByMappedScreen,
          isTrue,
          reason: feature.id,
        );
      }
    });

    testWidgets('saldo de estoque abre dados demonstrativos e detalhe', (
      tester,
    ) async {
      await setTallSurface(tester);
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await tester.pumpWidget(
        _wrap(
          container,
          featureId: 'saldo-estoque',
          profile: FeatureProfile.administration,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ração Engorda'), findsOneWidget);
      expect(find.text('Sal Mineral'), findsOneWidget);
      expect(find.text('Vacina Aftosa'), findsOneWidget);
      expect(find.text('Novo registro'), findsNothing);

      await tester.tap(find.text('Ração Engorda'));
      await tester.pumpAndSettle();
      expect(find.text('12.400 kg'), findsWidgets);
      expect(find.text('1.000 kg'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('auditoria alterna para JSON e prepara três registros', (
      tester,
    ) async {
      await setTallSurface(tester);
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await tester.pumpWidget(
        _wrap(
          container,
          featureId: 'exportar-log-estoque',
          profile: FeatureProfile.administration,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Preparar arquivo de auditoria'), findsOneWidget);
      expect(find.text('Baixar CSV'), findsOneWidget);

      final selects = find.byType(DropdownButtonFormField<String>);
      await tester.tap(selects.at(1));
      await tester.pumpAndSettle();
      await tester.tap(find.text('JSON').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Baixar JSON'));
      await tester.pump();

      expect(
        find.text('auditoria-estoque-30-dias.json preparado com 3 registros.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

  });
}
