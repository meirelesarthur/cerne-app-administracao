import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/ui/ui.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: buildAppTheme(AppThemeVariant.light),
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

void main() {
  testWidgets('Pressable expõe semântica e dispara toque', (tester) async {
    final semantics = tester.ensureSemantics();
    var tapped = false;
    await tester.pumpWidget(
      _wrap(
        AppPressable(
          semanticLabel: 'Abrir registro',
          onPressed: () => tapped = true,
          child: const Text('Registro'),
        ),
      ),
    );

    expect(find.bySemanticsLabel(RegExp('Abrir registro')), findsOneWidget);
    await tester.tap(find.text('Registro'));
    expect(tapped, isTrue);
    semantics.dispose();
  });

  testWidgets('Pressable preserva alvo mínimo e ativação por teclado', (
    tester,
  ) async {
    var activated = false;
    await tester.pumpWidget(
      _wrap(
        AppPressable(
          semanticLabel: 'Abrir filtro',
          selected: true,
          onPressed: () => activated = true,
          child: const Text('Filtro'),
        ),
      ),
    );

    final size = tester.getSize(find.byType(AppPressable));
    expect(size.width, greaterThanOrEqualTo(44));
    expect(size.height, greaterThanOrEqualTo(44));

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();

    expect(activated, isTrue);
  });

  testWidgets('grupo repetível incrementa pelo callback', (tester) async {
    String? group;
    await tester.pumpWidget(
      _wrap(
        AppAddableGroupList(
          groups: const ['Matérias-primas'],
          counts: const {'Matérias-primas': 1},
          onAdd: (value) => group = value,
        ),
      ),
    );

    await tester.tap(find.text('Adicionar'));
    expect(group, 'Matérias-primas');
  });

  testWidgets('simulador de dispositivos usa descoberta em duas etapas', (
    tester,
  ) async {
    var capture = '';
    await tester.pumpWidget(
      _wrap(
        AppHardwareSimulator(
          kind: AppHardwareSimulationKind.devices,
          onCapture: (value) => capture = value,
        ),
      ),
    );

    await tester.tap(find.text('Buscar dispositivos'));
    await tester.pump();
    expect(find.text('Balança BT-42'), findsOneWidget);
    await tester.tap(find.text('Conectar dispositivos'));
    expect(capture, contains('Leitor RFID'));
  });

  testWidgets('auditoria prepara CSV e informa o resultado', (tester) async {
    AppAuditExport? result;
    await tester.pumpWidget(
      _wrap(
        AppAuditExportPanel(
          filename: 'auditoria',
          rows: const [
            {'data': '2026-08-16', 'ação': 'Teste'},
          ],
          onExport: (value) => result = value,
        ),
      ),
    );

    await tester.tap(find.text('Preparar CSV'));
    await tester.pump();

    expect(result?.filename, 'auditoria-30-dias.csv');
    expect(result?.content, contains('"data","ação"'));
    expect(find.textContaining('preparado com 1 registros'), findsOneWidget);
  });
}
