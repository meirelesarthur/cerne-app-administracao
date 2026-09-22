import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/shell/state/prototype_session_store.dart';

void main() {
  group('PrototypeSessionNotifier', () {
    test('inicia sem sessão', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final session = container.read(prototypeSessionProvider);

      expect(session.isAuthenticated, isFalse);
      expect(session.profile, isNull);
    });

    test('login preserva o perfil escolhido durante a sessão', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container
          .read(prototypeSessionProvider.notifier)
          .loginAs(UserAccessProfile.administration);

      final session = container.read(prototypeSessionProvider);
      expect(session.isAuthenticated, isTrue);
      expect(session.profile, UserAccessProfile.administration);
      expect(session.profile?.homeRoute, '/fazendas/administracao');
    });

    test('logout invalida a sessão', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(prototypeSessionProvider.notifier);
      notifier.loginAs(UserAccessProfile.administration);

      notifier.logout();

      expect(container.read(prototypeSessionProvider).isAuthenticated, isFalse);
    });
  });
}
