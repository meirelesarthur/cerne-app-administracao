import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/ui/avatar.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: buildAppTheme(AppThemeVariant.light),
  home: Scaffold(body: child),
);

void main() {
  group('AppAvatar', () {
    testWidgets('deriva iniciais a partir do nome quando não informadas', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const AppAvatar(name: 'Maria Souza Lima')));

      expect(find.text('MS'), findsOneWidget);
    });

    testWidgets('usa iniciais explícitas quando informadas', (tester) async {
      await tester.pumpWidget(
        _wrap(const AppAvatar(name: 'Carlos', initials: 'C+')),
      );

      expect(find.text('C+'), findsOneWidget);
    });

    testWidgets('renderiza todos os tamanhos sem exceções', (tester) async {
      for (final size in AppAvatarSize.values) {
        await tester.pumpWidget(_wrap(AppAvatar(name: 'Ana Lima', size: size)));
        expect(tester.takeException(), isNull);
      }
    });

    test('deriveInitials lida com nome vazio', () {
      expect(AppAvatar.deriveInitials('   '), '');
    });
  });
}
