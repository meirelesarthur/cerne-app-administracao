import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/ui/banner.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: buildAppTheme(AppThemeVariant.light),
  home: Scaffold(body: child),
);

void main() {
  group('AppBanner', () {
    testWidgets('renderiza o conteúdo e a ação', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AppBanner(
            tone: AppBannerTone.warning,
            action: TextButton(onPressed: () {}, child: const Text('Ação')),
            child: const Text('Aviso importante'),
          ),
        ),
      );

      expect(find.text('Aviso importante'), findsOneWidget);
      expect(find.text('Ação'), findsOneWidget);
    });

    testWidgets('renderiza todos os tons sem exceções', (tester) async {
      for (final tone in AppBannerTone.values) {
        await tester.pumpWidget(
          _wrap(AppBanner(tone: tone, child: const Text('X'))),
        );
        expect(tester.takeException(), isNull);
      }
    });
  });
}
