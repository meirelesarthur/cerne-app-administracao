import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/fazendas/functional_catalog.dart';
import 'package:cerne_app/modules/fazendas/screens/busca_global_screen.dart';
import 'package:cerne_app/shell/state/prototype_session_store.dart';
import 'package:cerne_app/ui/discovery_tile.dart';
import 'package:cerne_app/ui/menu_item.dart';

Widget _app(WidgetTester tester, UserAccessProfile? profile) {
  final container = ProviderContainer();
  addTearDown(container.dispose);
  if (profile != null) {
    container.read(prototypeSessionProvider.notifier).loginAs(profile);
  }
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      theme: buildAppTheme(AppThemeVariant.light),
      home: const BuscaGlobalScreen(),
    ),
  );
}

Future<void> _buscar(WidgetTester tester, String termo) async {
  await tester.enterText(find.byType(EditableText), termo);
  await tester.pump();
}

void main() {
  group('normalizeForSearch', () {
    test('ignora caixa, acento e espaço em volta', () {
      expect(normalizeForSearch('  Pecuária  '), 'pecuaria');
      expect(normalizeForSearch('REPRODUÇÃO'), 'reproducao');
      expect(normalizeForSearch('Órgão'), 'orgao');
    });

    test('termo vazio continua vazio', () {
      expect(normalizeForSearch('   '), '');
    });
  });

  group('searchFeatures', () {
    test('termo vazio não devolve resultado', () {
      expect(searchFeatures('', sessionProfile: null), isEmpty);
    });

    test('encontra no catálogo administrativo', () {
      final resultados = searchFeatures(
        'a',
        sessionProfile: UserAccessProfile.administration,
      );
      final perfis = resultados.map((r) => r.feature.profile).toSet();

      expect(resultados, isNotEmpty);
      expect(perfis, containsAll(FeatureProfile.values));
    });

    test('acha sem acento o que está acentuado no catálogo', () {
      final comAcento = searchFeatures('pecuária', sessionProfile: null);
      final semAcento = searchFeatures('pecuaria', sessionProfile: null);

      expect(semAcento, isNotEmpty);
      expect(
        semAcento.map((r) => r.feature.id),
        comAcento.map((r) => r.feature.id),
      );
    });

    test('casa também pelo objetivo e pelo nome do módulo', () {
      final feature = allFeatures.firstWhere(
        (f) => f.objective.split(' ').length > 3,
      );
      final palavraDoObjetivo = feature.objective
          .split(' ')
          .firstWhere((w) => w.length > 6);

      final porObjetivo = searchFeatures(
        palavraDoObjetivo,
        sessionProfile: null,
      );
      expect(porObjetivo.map((r) => r.feature.id), contains(feature.id));

      final porGrupo = searchFeatures(feature.group, sessionProfile: null);
      expect(porGrupo.map((r) => r.feature.id), contains(feature.id));
    });

    test('com sessão administrativa tudo é abrível', () {
      final resultados = searchFeatures(
        'a',
        sessionProfile: UserAccessProfile.administration,
      );

      expect(resultados, isNotEmpty);
      expect(resultados.every((r) => r.openable), isTrue);
    });

    test('sessão sem perfil não abre nada', () {
      final resultados = searchFeatures('a', sessionProfile: null);

      expect(resultados, isNotEmpty);
      expect(resultados.every((r) => !r.openable), isTrue);
    });
  });

  group('featureDestination', () {
    test('respeita a rota própria quando existe', () {
      final comRota = allFeatures.firstWhere((f) => f.existingRoute != null);

      expect(featureDestination(comRota), comRota.existingRoute);
    });

    test('cai no segmento administrativo quando não há rota própria', () {
      final admin = allFeatures.firstWhere((f) => f.existingRoute == null);

      expect(featureDestination(admin), '/fazendas/administracao/${admin.id}');
    });
  });

  group('BuscaGlobalScreen', () {
    testWidgets('abre com produtos, acessos recentes e histórico', (
      tester,
    ) async {
      await tester.pumpWidget(_app(tester, UserAccessProfile.administration));
      await tester.pump();

      expect(find.text('Seus Produtos'), findsOneWidget);
      expect(find.text('Mais acessados'), findsOneWidget);
      expect(find.text('Open Finance'), findsWidgets);
      expect(find.text('Histórico'), findsOneWidget);
      expect(find.byType(AppDiscoveryTile), findsNWidgets(8));
      expect(find.byType(AppMenuItem), findsNothing);
    });

    testWidgets('lista o que encontrou com o ícone do módulo', (tester) async {
      await tester.pumpWidget(_app(tester, UserAccessProfile.administration));
      await tester.pump();
      await _buscar(tester, 'pecuaria');

      final itens = tester.widgetList<AppMenuItem>(find.byType(AppMenuItem));
      expect(itens, isNotEmpty);
      for (final item in itens) {
        expect(item.icon, isNotNull, reason: 'resultado sem ícone');
      }
    });

    testWidgets('termo sem correspondência mostra o estado vazio', (
      tester,
    ) async {
      await tester.pumpWidget(_app(tester, UserAccessProfile.administration));
      await tester.pump();
      await _buscar(tester, 'zzzzzzzz');

      expect(find.text('Nenhuma função encontrada'), findsOneWidget);
      expect(find.byType(AppMenuItem), findsNothing);
    });
  });
}
