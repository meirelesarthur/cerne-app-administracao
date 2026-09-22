import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/ui/app_icon.dart';
import 'package:cerne_app/ui/greeting_header.dart';

import '../helpers/app_icon_finder.dart';

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
  group('AppGreetingHeader', () {
    testWidgets('mostra identidade, contexto e sino', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AppGreetingHeader(
            greeting: 'Boa tarde,',
            name: 'Silvio Ventura',
            subtitle: 'Ambiente Operação',
            hasUnread: true,
          ),
        ),
      );

      expect(find.text('Boa tarde,'), findsOneWidget);
      expect(find.text('Silvio Ventura'), findsOneWidget);
      expect(find.text('Ambiente Operação'), findsOneWidget);
      expect(findAppIcon(AppIcons.bell), findsOneWidget);
      expect(find.bySemanticsLabel('Notificações, há novas'), findsOneWidget);
    });

    testWidgets('abre perfil e notificações', (tester) async {
      var profile = false;
      var notifications = false;
      await tester.pumpWidget(
        _wrap(
          AppGreetingHeader(
            greeting: 'Bom dia,',
            name: 'Maria Souza',
            onProfile: () => profile = true,
            onNotifications: () => notifications = true,
          ),
        ),
      );

      await tester.tap(find.text('Maria Souza'));
      await tester.tap(findAppIcon(AppIcons.bell));
      expect(profile, isTrue);
      expect(notifications, isTrue);
    });
  });
}
