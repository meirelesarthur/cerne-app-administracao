import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:cerne_app/modules/armazem/armazem_module.dart';
import 'package:cerne_app/modules/armazem/screens/armazem_home_screen.dart';
import 'package:cerne_app/modules/armazem/screens/estoque_screen.dart';
import 'package:cerne_app/modules/armazem/screens/movimentacoes_screen.dart';
import 'package:cerne_app/modules/armazem/screens/relatorios_screen.dart';
import 'package:cerne_app/modules/armazem/screens/unidades_screen.dart';

void main() {
  group('buildArmazemModuleRoute', () {
    test('registra /armazem e os 4 sub-caminhos esperados', () {
      final route = buildArmazemModuleRoute();

      expect(route.path, '/armazem');
      final subPaths = route.routes
          .whereType<GoRoute>()
          .map((r) => r.path)
          .toSet();
      expect(subPaths, {'estoque', 'movimentacoes', 'unidades', 'relatorios'});
    });

    test('cada rota constrói o widget esperado', () {
      final route = buildArmazemModuleRoute();
      final byPath = {
        for (final r in route.routes.whereType<GoRoute>()) r.path: r,
      };

      expect(route.builder, isNotNull);
      expect(byPath['estoque']!.builder, isNotNull);
      expect(byPath['movimentacoes']!.builder, isNotNull);
      expect(byPath['unidades']!.builder, isNotNull);
      expect(byPath['relatorios']!.builder, isNotNull);
    });
  });

  // Sanidade de tipos — garante que as importações resolvem para os widgets certos.
  test('tipos das telas do módulo existem', () {
    expect(ArmazemHomeScreen, isNotNull);
    expect(EstoqueScreen, isNotNull);
    expect(MovimentacoesScreen, isNotNull);
    expect(UnidadesScreen, isNotNull);
    expect(RelatoriosScreen, isNotNull);
  });
}
