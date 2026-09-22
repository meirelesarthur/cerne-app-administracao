@Tags(['captura'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/shell/state/prototype_session_store.dart';

import '../support/router_test_harness.dart';

/// Captura temporária de tela para conferência visual da migração ao padrão
/// global. Não é um golden de regressão: roda sob a tag `captura`, que a suíte
/// normal exclui, e os PNGs ficam em `test/golden/captura/` (ignorado).
///
/// Rodar:
/// `flutter test --tags captura --run-skipped --update-goldens test/golden/_captura_visual_test.dart`
void main() {
  Future<void> capturar(
    WidgetTester tester, {
    required String nome,
    required String rota,
    required UserAccessProfile perfil,
  }) async {
    await tester.binding.setSurfaceSize(const Size(402, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final harness = RouterTestHarness(profile: perfil);
    addTearDown(harness.dispose);

    harness.router.go(rota);
    await tester.pumpWidget(harness.buildApp());
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('captura/$nome.png'),
    );
  }

  testWidgets('home administrativa', (tester) async {
    await capturar(
      tester,
      nome: 'home-administrativa',
      rota: '/fazendas/administracao',
      perfil: UserAccessProfile.administration,
    );
  });

  testWidgets('dashboard administrativo', (tester) async {
    await capturar(
      tester,
      nome: 'dashboard-adm',
      rota: '/fazendas/dashboards/resultado',
      perfil: UserAccessProfile.administration,
    );
  });

  testWidgets('home do bank', (tester) async {
    await capturar(
      tester,
      nome: 'home-bank',
      rota: '/bank',
      perfil: UserAccessProfile.administration,
    );
  });
}
