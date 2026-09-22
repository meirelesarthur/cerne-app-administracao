import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/ui/file_upload.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: buildAppTheme(AppThemeVariant.light),
  home: Scaffold(body: child),
);

void main() {
  group('AppFileUpload', () {
    testWidgets('estado vazio renderiza a dropzone sem exceções', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(AppFileUpload(onChanged: (_) {})));

      expect(find.text('Selecionar arquivo XML'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tocar na dropzone dispara onChanged com um nome de arquivo', (
      tester,
    ) async {
      String? file;
      await tester.pumpWidget(_wrap(AppFileUpload(onChanged: (v) => file = v)));

      await tester.tap(find.text('Selecionar arquivo XML'));
      await tester.pump();

      expect(file, isNotNull);
    });

    testWidgets(
      'com value definido mostra o nome do arquivo e permite remover',
      (tester) async {
        String? file = 'nota-fiscal.xml';
        await tester.pumpWidget(
          _wrap(AppFileUpload(value: file, onChanged: (v) => file = v)),
        );

        expect(find.text('nota-fiscal.xml'), findsOneWidget);

        await tester.tap(find.byType(InkWell));
        await tester.pump();

        expect(file, isNull);
      },
    );
  });
}
