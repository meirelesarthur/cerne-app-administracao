import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/shell/module_config.dart';
import 'package:cerne_app/shell/state/prototype_session_store.dart';
import 'package:cerne_app/ui/app_icon.dart';

void main() {
  group('module_config', () {
    test('os 5 módulos ativos têm bottomTabs não vazios', () {
      expect(modules.length, 5);
      for (final m in modules) {
        expect(m.bottomTabs, isNotEmpty);
      }
      expect(getModule('inicio'), isNull);
    });

    test('getModule resolve por id e retorna null para desconhecido/nulo', () {
      expect(getModule('fazendas')?.label, 'Fazendas');
      expect(getModule('inexistente'), isNull);
      expect(getModule(null), isNull);
    });

    test('a navbar mostra os módulos ativos e chama Marketplace de Market', () {
      expect(modules.map((module) => module.id), [
        'fazendas',
        'bank',
        'credito',
        'marketplace',
        'armazem',
      ]);
      expect(getModule('marketplace')?.label, 'Market');
    });

    test('getMenuSections usa menuSections quando definido', () {
      final bank = getModule('bank')!;
      final sections = getMenuSections(bank);
      expect(
        sections.map((s) => s.title),
        contains('Pagamentos e transferências'),
      );
    });

    test(
      'getMenuSections cai no fallback derivado das bottomTabs quando ausente',
      () {
        // Nenhum dos 5 módulos reais deixa `menuSections` ausente hoje (ver
        // teste abaixo) — o fallback só existe como rede de segurança para um
        // módulo futuro sem seção própria. Testado aqui com um `ModuleDef`
        // sintético, não com um módulo real.
        const synthetic = ModuleDef(
          id: 'sintetico',
          label: 'Sintético',
          icon: AppIcons.circle,
          homeRoute: '/sintetico',
          bottomTabs: [
            BottomTab(
              id: 'home',
              label: 'Início',
              icon: AppIcons.home,
              path: '',
            ),
            BottomTab(
              id: 'apps',
              label: 'Apps',
              icon: AppIcons.layoutGrid,
              path: 'apps',
            ),
            BottomTab(
              id: 'carteira',
              label: 'Carteira',
              icon: AppIcons.wallet,
              path: 'carteira',
            ),
            BottomTab(
              id: 'menu',
              label: 'Menu',
              icon: AppIcons.menu,
              path: 'menu',
              action: 'menu',
            ),
          ],
        );
        final sections = getMenuSections(synthetic);
        expect(sections, hasLength(1));
        expect(sections.first.title, 'Funcionalidades');
        // 'menu' tem action e é excluído; '' (home) também é excluído por path vazio.
        expect(
          sections.first.items.map((i) => i.id),
          containsAll(['apps', 'carteira']),
        );
        expect(sections.first.items.map((i) => i.id), isNot(contains('menu')));
      },
    );

    test('Fazendas não repete as próprias abas no menu "Mais"', () {
      expect(getMenuSections(getModule('fazendas')!), isEmpty);
    });

    test('Fazendas expõe as abas administrativas', () {
      final fazendas = getModule('fazendas')!;
      final adminTabs = visibleBottomTabs(
        fazendas,
        UserAccessProfile.administration,
      );

      expect(adminTabs.map((tab) => tab.id), contains('dashboard'));
      expect(adminTabs.map((tab) => tab.id), isNot(contains('rotinas')));
      expect(
        adminTabs.where((tab) => tab.action == null).map((tab) => tab.label),
        ['Visão geral', 'Painéis', 'Consultas'],
      );
    });
  });
}
