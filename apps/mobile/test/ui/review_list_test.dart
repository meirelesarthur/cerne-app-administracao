import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/ui/field_capsule.dart';
import 'package:cerne_app/ui/ui.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: buildAppTheme(AppThemeVariant.light),
  home: Scaffold(body: child),
);

void main() {
  group('AppReviewList', () {
    testWidgets('estilo card (padrão): rótulo em versalete, sem AppFormField', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const AppReviewList(
            items: [AppReviewItem(label: 'Responsável', value: 'Maria Souza')],
          ),
        ),
      );

      expect(find.text('RESPONSÁVEL'), findsOneWidget);
      expect(find.text('Maria Souza'), findsOneWidget);
      expect(find.byType(AppFormField), findsNothing);
      expect(find.byType(AppFieldCapsule), findsNothing);
    });

    testWidgets(
      'estilo inputCapsule: rótulo como em AppFormField, valor dentro de '
      'AppFieldCapsule',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            const AppReviewList(
              style: AppReviewStyle.inputCapsule,
              items: [
                AppReviewItem(label: 'Responsável', value: 'Maria Souza'),
              ],
            ),
          ),
        );

        // Sem versalete: o rótulo aparece como em qualquer AppFormField.
        expect(find.text('RESPONSÁVEL'), findsNothing);
        expect(find.text('Responsável'), findsOneWidget);
        expect(find.text('Maria Souza'), findsOneWidget);
        expect(find.byType(AppFormField), findsOneWidget);
        expect(find.byType(AppFieldCapsule), findsOneWidget);
      },
    );

    testWidgets('inputCapsule copiável mostra o botão de copiar', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const AppReviewList(
            style: AppReviewStyle.inputCapsule,
            items: [AppReviewItem(label: 'Lote', value: 'Lote Recria 02')],
          ),
        ),
      );

      expect(find.byTooltip('Copiar Lote'), findsOneWidget);
    });
  });
}
