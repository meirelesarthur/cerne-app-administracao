import '../../../ui/ui.dart' show AppIconData, AppIcons, AppMiniAppTileBadge;

/// Catálogo de mini-apps do hub — espelha `src/modules/hub/mocks/apps.ts`. O contrato
/// (ícone, nome, descrição, rota, selo) permite injetar novos apps sem alterar as telas do hub.

class HubApp {
  const HubApp({
    required this.id,
    required this.icon,
    required this.name,
    required this.description,
    this.route,
    this.badge,
  });

  final String id;
  final AppIconData icon;
  final String name;
  final String description;
  final String? route;
  final AppMiniAppTileBadge? badge;
}

const List<HubApp> hubApps = [
  HubApp(
    id: 'fazendas',
    icon: AppIcons.sprout,
    name: 'Fazendas',
    description: 'Gestão da operação e lançamentos de campo',
    route: '/fazendas',
  ),
  HubApp(
    id: 'bank',
    icon: AppIcons.landmark,
    name: 'GB Bank',
    description: 'Conta, Pix, pagamentos e cartões',
    route: '/bank',
    badge: AppMiniAppTileBadge.novo,
  ),
  HubApp(
    id: 'credito',
    icon: AppIcons.handCoins,
    name: 'Crédito',
    description: 'Simule e contrate crédito para a safra',
    route: '/credito',
  ),
  HubApp(
    id: 'marketplace',
    icon: AppIcons.shoppingBag,
    name: 'Marketplace',
    description: 'Insumos, máquinas e serviços',
    route: '/marketplace',
  ),
  HubApp(
    id: 'armazem',
    icon: AppIcons.warehouse,
    name: 'Armazém',
    description: 'Estoque, movimentações e logística',
    route: '/armazem',
  ),
];

const List<HubApp> appsEmBreve = [
  HubApp(
    id: 'clima',
    icon: AppIcons.cloudSun,
    name: 'Clima',
    description: 'Previsão hiperlocal por talhão',
    badge: AppMiniAppTileBadge.breve,
  ),
  HubApp(
    id: 'cotacoes',
    icon: AppIcons.lineChart,
    name: 'Cotações',
    description: 'Boi gordo, soja e milho em tempo real',
    badge: AppMiniAppTileBadge.breve,
  ),
  HubApp(
    id: 'consultoria',
    icon: AppIcons.headset,
    name: 'Consultoria',
    description: 'Especialistas GB a um toque',
    badge: AppMiniAppTileBadge.breve,
  ),
  HubApp(
    id: 'seguros',
    icon: AppIcons.shieldCheck,
    name: 'Seguros',
    description: 'Proteção de safra e patrimônio',
    badge: AppMiniAppTileBadge.breve,
  ),
];
