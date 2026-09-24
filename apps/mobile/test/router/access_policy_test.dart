import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/router/app_router.dart';
import 'package:cerne_app/shell/state/prototype_session_store.dart';

void main() {
  group('política funcional de acesso', () {
    const signedOut = PrototypeSessionState.signedOut();
    const administration = PrototypeSessionState.signedIn(
      UserAccessProfile.administration,
    );

    test('sem sessão só login e onboarding permanecem públicos', () {
      expect(redirectForSession('/login', signedOut), isNull);
      expect(redirectForSession('/onboarding', signedOut), isNull);

      for (final path in [
        '/',
        '/inicio',
        '/bank/extrato',
        '/perfil',
        '/notificacoes',
        '/fazendas/administracao',
      ]) {
        expect(redirectForSession(path, signedOut), '/login', reason: path);
      }
    });

    test('com sessão, as rotas administrativas passam direto', () {
      for (final path in [
        '/fazendas/administracao',
        '/fazendas/administracao/saldo-estoque',
        '/fazendas/dashboards/financeiro',
        '/fazendas/consultas',
        '/fazendas/ordem-servico',
        '/bank/extrato',
      ]) {
        expect(redirectForSession(path, administration), isNull, reason: path);
      }
    });

    test('raiz, login e links antigos da Home abrem Fazendas', () {
      for (final profile in UserAccessProfile.values) {
        final session = PrototypeSessionState.signedIn(profile);
        for (final path in [
          '/',
          '/login',
          '/inicio',
          '/inicio/apps',
          '/inicio/carteira',
        ]) {
          expect(
            redirectForSession(path, session),
            profile.landingRoute,
            reason: '${profile.name}: $path',
          );
        }
        expect(
          redirectForSession('/fazendas', session),
          profile.homeRoute,
          reason: '${profile.name}: /fazendas',
        );
        expect(
          redirectForSession('/fazendas/mais', session),
          profile.homeRoute,
          reason: '${profile.name}: /fazendas/mais',
        );
      }
    });
  });
}
