import '../ui/ui.dart';
import 'state/prototype_session_store.dart';

/// Registro central de módulos do superapp — espelha `moduleConfig.ts` (spec §3.4/§7.3).
/// O Shell itera este registro para montar o dock de módulos (`AppBottomTabBar`) e injeta os
/// `bottomTabs` do módulo ativo nas `AppContextTabs` do topo.
/// Nenhuma navegação de módulo é hardcodada fora daqui.

class BottomTab {
  const BottomTab({
    required this.id,
    required this.label,
    required this.icon,
    required this.path,
    this.elevated = false,
    this.action,
    this.profiles = const {},
  });

  final String id;
  final String label;
  final AppIconData icon;

  /// Rota relativa dentro do módulo (ex.: '' = home, 'atividades').
  final String path;

  /// Botão central elevado (ex.: "Registrar" em campo).
  final bool elevated;

  /// Ação especial em vez de navegação (ex.: 'menu' abre o RevealMenu global).
  final String? action;

  final Set<UserAccessProfile> profiles;

  bool isVisibleTo(UserAccessProfile? profile) =>
      profiles.isEmpty || profiles.contains(profile);
}

class ModuleMenuItem {
  const ModuleMenuItem({
    required this.id,
    required this.label,
    required this.icon,
    required this.route,
    this.profiles = const {},
  });

  final String id;
  final String label;
  final AppIconData icon;

  /// Rota absoluta do destino.
  final String route;

  final Set<UserAccessProfile> profiles;

  bool isVisibleTo(UserAccessProfile? profile) =>
      profiles.isEmpty || profiles.contains(profile);
}

class ModuleMenuSection {
  const ModuleMenuSection({required this.title, required this.items});

  final String title;
  final List<ModuleMenuItem> items;
}

class ModuleDef {
  const ModuleDef({
    required this.id,
    required this.label,
    required this.icon,
    required this.homeRoute,
    required this.bottomTabs,
    this.menuSections,
  });

  final String id;
  final String label;
  final AppIconData icon;

  /// Rota inicial absoluta do módulo.
  final String homeRoute;
  final List<BottomTab> bottomTabs;

  /// Funcionalidades exibidas no RevealMenu (aba Mais) — contextuais ao módulo.
  /// Quando ausente, o menu deriva uma seção única das bottomTabs navegáveis.
  final List<ModuleMenuSection>? menuSections;
}

/// Fallback do RevealMenu: seção única derivada das abas navegáveis do módulo.
List<ModuleMenuSection> getMenuSections(
  ModuleDef module, {
  UserAccessProfile? profile,
}) {
  if (module.menuSections != null) {
    return module.menuSections!
        .map(
          (section) => ModuleMenuSection(
            title: section.title,
            items: section.items
                .where((item) => item.isVisibleTo(profile))
                .toList(),
          ),
        )
        .where((section) => section.items.isNotEmpty)
        .toList();
  }
  return [
    ModuleMenuSection(
      title: 'Funcionalidades',
      items: visibleBottomTabs(module, profile)
          .where((tab) => tab.path.isNotEmpty && tab.action == null)
          .map(
            (tab) => ModuleMenuItem(
              id: tab.id,
              label: tab.label,
              icon: tab.icon,
              route: '/${module.id}/${tab.path}',
            ),
          )
          .toList(),
    ),
  ];
}

List<BottomTab> visibleBottomTabs(
  ModuleDef module,
  UserAccessProfile? profile,
) => module.bottomTabs.where((tab) => tab.isVisibleTo(profile)).toList();

String moduleHomeRoute(ModuleDef module, UserAccessProfile? profile) {
  if (module.id == 'fazendas' && profile != null) return profile.homeRoute;
  return module.homeRoute;
}

const List<ModuleDef> modules = [
  // New-UI — hub agregador: porta de entrada do superapp, Banking central.
  ModuleDef(
    id: 'inicio',
    label: 'Início',
    icon: AppIcons.home,
    homeRoute: '/inicio',
    bottomTabs: [
      BottomTab(id: 'home', label: 'Início', icon: AppIcons.home, path: ''),
      BottomTab(
        id: 'carteira',
        label: 'Carteira',
        icon: AppIcons.wallet,
        path: 'carteira',
      ),
      BottomTab(
        id: 'apps',
        label: 'Apps',
        icon: AppIcons.layoutGrid,
        path: 'apps',
      ),
      BottomTab(
        id: 'menu',
        label: 'Menu',
        icon: AppIcons.menu,
        path: 'menu',
        action: 'menu',
      ),
    ],
    // Vazio, não omitido (ver plano de UX): sem isso, o menu "reveal" cai no
    // fallback de `getMenuSections` — que deriva a lista das próprias
    // `bottomTabs` — e mostra de novo "Apps"/"Carteira" ali dentro, que já são
    // abas visíveis no topo. O menu "Mais" deste módulo vira só a seção CONTA.
    menuSections: [],
  ),
  ModuleDef(
    id: 'fazendas',
    label: 'Fazendas',
    icon: AppIcons.sprout,
    homeRoute: '/fazendas',
    bottomTabs: [
      BottomTab(
        id: 'dashboard',
        label: 'Gestão',
        icon: AppIcons.layoutDashboard,
        path: 'administracao',
        profiles: {UserAccessProfile.administration},
      ),
      BottomTab(
        id: 'consultas',
        label: 'Consultas',
        icon: AppIcons.search,
        path: 'consultas',
        profiles: {UserAccessProfile.administration},
      ),
      // Substitui a antiga aba "Operacional": a Administração não acessa mais
      // os cadastros operacionais de campo por aqui — só a consulta,
      // 100% leitura, das Ordens de Serviço e dos Apontamentos agrícolas
      // lançados pelo Operacional (`admin/dash_ordem_servico.dart`,
      // `admin/dash_apontamentos.dart`).
      BottomTab(
        id: 'ordem-servico-adm',
        label: 'Ordens de Serviço',
        icon: AppIcons.fileText,
        path: 'ordem-servico',
        profiles: {UserAccessProfile.administration},
      ),
      BottomTab(
        id: 'mais',
        label: 'Mais',
        icon: AppIcons.moreHorizontal,
        path: 'mais',
        action: 'menu',
      ),
    ],
    // Vazio, não omitido (ver plano de UX): toda esta lista duplicava algo
    // que já existe em outro lugar — "Central de gestão/rotinas" é a própria
    // aba de contexto ativa; os 7 "Dashboards gerenciais" já são o grupo
    // "Painéis de decisão"/"Consultas e auditoria" da central; "Fila de
    // sincronização" já é o grupo "Sincronização"; a consulta de Ordens de
    // Serviço já é a aba "Ordens de Serviço". Dois caminhos para o mesmo
    // destino não é conveniência, é a pessoa não saber se são a mesma coisa.
    menuSections: [],
  ),
  ModuleDef(
    id: 'bank',
    label: 'Bank',
    icon: AppIcons.landmark,
    homeRoute: '/bank',
    bottomTabs: [
      BottomTab(id: 'inicio', label: 'Início', icon: AppIcons.home, path: ''),
      BottomTab(
        id: 'extrato',
        label: 'Extrato',
        icon: AppIcons.receipt,
        path: 'extrato',
      ),
      BottomTab(
        id: 'pagamentos',
        label: 'Pagamentos',
        icon: AppIcons.arrowLeftRight,
        path: 'pagamentos',
      ),
      BottomTab(
        id: 'cartoes',
        label: 'Cartões',
        icon: AppIcons.creditCard,
        path: 'cartoes',
      ),
      BottomTab(
        id: 'mais',
        label: 'Mais',
        icon: AppIcons.moreHorizontal,
        path: 'mais',
        action: 'menu',
      ),
    ],
    menuSections: [
      // Pix não é aba (só Extrato/Pagamentos/Cartões são) — fica. Pagamentos,
      // Extrato e Cartões saíram daqui: já são abas de contexto visíveis no
      // topo, repeti-las no menu "Mais" era o mesmo destino duas vezes.
      ModuleMenuSection(
        title: 'Pagamentos e transferências',
        items: [
          ModuleMenuItem(
            id: 'pix',
            label: 'Pix',
            icon: AppIcons.zap,
            route: '/bank/pix',
          ),
        ],
      ),
      ModuleMenuSection(
        title: 'Cartão',
        items: [
          ModuleMenuItem(
            id: 'limites',
            label: 'Limites',
            icon: AppIcons.slidersHorizontal,
            route: '/bank/limites',
          ),
        ],
      ),
      ModuleMenuSection(
        title: 'Suporte',
        items: [
          ModuleMenuItem(
            id: 'ajuda',
            label: 'Ajuda',
            icon: AppIcons.helpCircle,
            route: '/bank/ajuda',
          ),
        ],
      ),
    ],
  ),
  ModuleDef(
    id: 'credito',
    label: 'Crédito',
    icon: AppIcons.handCoins,
    homeRoute: '/credito',
    bottomTabs: [
      BottomTab(id: 'inicio', label: 'Início', icon: AppIcons.home, path: ''),
      BottomTab(
        id: 'propostas',
        label: 'Minhas Propostas',
        icon: AppIcons.fileText,
        path: 'propostas',
      ),
      BottomTab(
        id: 'simular',
        label: 'Simular',
        icon: AppIcons.calculator,
        path: 'simular',
      ),
      BottomTab(
        id: 'mais',
        label: 'Mais',
        icon: AppIcons.moreHorizontal,
        path: 'mais',
        action: 'menu',
      ),
    ],
    menuSections: [
      // Simular e Propostas saíram: já são abas de contexto no topo.
      // Contratos não é aba — fica.
      ModuleMenuSection(
        title: 'Crédito',
        items: [
          ModuleMenuItem(
            id: 'contratos',
            label: 'Contratos',
            icon: AppIcons.fileSignature,
            route: '/credito/contratos',
          ),
        ],
      ),
      ModuleMenuSection(
        title: 'Suporte',
        items: [
          ModuleMenuItem(
            id: 'ajuda',
            label: 'Ajuda',
            icon: AppIcons.helpCircle,
            route: '/credito/ajuda',
          ),
        ],
      ),
    ],
  ),
  ModuleDef(
    id: 'marketplace',
    label: 'Marketplace',
    icon: AppIcons.shoppingBag,
    homeRoute: '/marketplace',
    bottomTabs: [
      BottomTab(id: 'inicio', label: 'Início', icon: AppIcons.home, path: ''),
      BottomTab(
        id: 'categorias',
        label: 'Categorias',
        icon: AppIcons.listOrdered,
        path: 'categorias',
      ),
      BottomTab(
        id: 'pedidos',
        label: 'Pedidos',
        icon: AppIcons.receipt,
        path: 'pedidos',
      ),
      BottomTab(
        id: 'mais',
        label: 'Mais',
        icon: AppIcons.moreHorizontal,
        path: 'mais',
        action: 'menu',
      ),
    ],
    menuSections: [
      // Categorias e Pedidos saíram: já são abas de contexto no topo.
      // Favoritos não é aba — fica.
      ModuleMenuSection(
        title: 'Compras',
        items: [
          ModuleMenuItem(
            id: 'favoritos',
            label: 'Favoritos',
            icon: AppIcons.heart,
            route: '/marketplace/favoritos',
          ),
        ],
      ),
      ModuleMenuSection(
        title: 'Suporte',
        items: [
          ModuleMenuItem(
            id: 'ajuda',
            label: 'Ajuda',
            icon: AppIcons.helpCircle,
            route: '/marketplace/ajuda',
          ),
        ],
      ),
    ],
  ),
  ModuleDef(
    id: 'armazem',
    label: 'Armazém',
    icon: AppIcons.warehouse,
    homeRoute: '/armazem',
    bottomTabs: [
      BottomTab(id: 'inicio', label: 'Início', icon: AppIcons.home, path: ''),
      BottomTab(
        id: 'estoque',
        label: 'Estoque',
        icon: AppIcons.boxes,
        path: 'estoque',
      ),
      BottomTab(
        id: 'movimentacoes',
        label: 'Movimentações',
        icon: AppIcons.arrowLeftRight,
        path: 'movimentacoes',
      ),
      BottomTab(
        id: 'mais',
        label: 'Mais',
        icon: AppIcons.moreHorizontal,
        path: 'mais',
        action: 'menu',
      ),
    ],
    menuSections: [
      // Estoque e Movimentações saíram: já são abas de contexto no topo.
      // Unidades não é aba — fica.
      ModuleMenuSection(
        title: 'Operação',
        items: [
          ModuleMenuItem(
            id: 'unidades',
            label: 'Unidades',
            icon: AppIcons.warehouse,
            route: '/armazem/unidades',
          ),
        ],
      ),
      ModuleMenuSection(
        title: 'Gestão',
        items: [
          ModuleMenuItem(
            id: 'relatorios',
            label: 'Relatórios',
            icon: AppIcons.barChart3,
            route: '/armazem/relatorios',
          ),
        ],
      ),
    ],
  ),
];

final Map<String, ModuleDef> moduleMap = {for (final m in modules) m.id: m};

ModuleDef? getModule(String? id) => id == null ? null : moduleMap[id];
