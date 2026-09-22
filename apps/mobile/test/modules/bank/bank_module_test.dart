import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:cerne_app/modules/bank/bank_module.dart';
import 'package:cerne_app/modules/bank/screens/bank_home_screen.dart';
import 'package:cerne_app/modules/bank/screens/cartoes_screen.dart';
import 'package:cerne_app/modules/bank/screens/extrato_screen.dart';
import 'package:cerne_app/modules/bank/screens/limites_screen.dart';
import 'package:cerne_app/modules/bank/screens/pagamentos_screen.dart';

void main() {
  group('buildBankModuleRoute', () {
    test('registra /bank e os 6 sub-caminhos esperados', () {
      final route = buildBankModuleRoute();

      expect(route.path, '/bank');
      final subPaths = route.routes
          .whereType<GoRoute>()
          .map((r) => r.path)
          .toSet();
      expect(subPaths, {
        'extrato',
        'pagamentos',
        'cartoes',
        'pix',
        'limites',
        'ajuda',
      });
    });

    test('cada rota constrói o widget esperado', () {
      final route = buildBankModuleRoute();
      final byPath = {
        for (final r in route.routes.whereType<GoRoute>()) r.path: r,
      };

      expect(route.builder, isNotNull);
      expect(byPath['extrato']!.builder, isNotNull);
      expect(byPath['cartoes']!.builder, isNotNull);
      expect(byPath['limites']!.builder, isNotNull);
      expect(byPath['pagamentos']!.builder, isNotNull);
      expect(byPath['pix']!.builder, isNotNull);
      expect(byPath['ajuda']!.builder, isNotNull);
    });
  });

  // Sanidade de tipos — garante que as importações resolvem para os widgets certos.
  test('tipos das telas do módulo existem', () {
    expect(BankHomeScreen, isNotNull);
    expect(ExtratoScreen, isNotNull);
    expect(CartoesScreen, isNotNull);
    expect(LimitesScreen, isNotNull);
    expect(PagamentosScreen, isNotNull);
  });
}
