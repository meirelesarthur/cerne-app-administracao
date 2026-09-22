import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/router/app_router.dart';
import 'package:cerne_app/shell/state/prototype_session_store.dart';

class RouterTestHarness {
  RouterTestHarness({UserAccessProfile? profile}) {
    if (profile != null) {
      container.read(prototypeSessionProvider.notifier).loginAs(profile);
    }
    router = container.read(appRouterProvider);
  }

  final ProviderContainer container = ProviderContainer();
  late final GoRouter router;

  Widget buildApp() => UncontrolledProviderScope(
    container: container,
    child: MaterialApp.router(
      theme: buildAppTheme(AppThemeVariant.light),
      routerConfig: router,
    ),
  );

  void dispose() => container.dispose();
}
