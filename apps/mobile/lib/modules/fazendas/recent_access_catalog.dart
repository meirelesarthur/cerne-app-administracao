import '../../ui/ui.dart';
import 'functional_catalog.dart';
import 'group_icons.dart';

/// Atalhos populares da fazenda para completar o histórico recente até dez
/// opções, incluindo os cinco painéis principais e as tarefas operacionais.
const farmQuickAccessDefaultIds = <String>[
  'farm:activities',
  'consulta-os',
  'painel-financeiro',
  'lotacao-currais',
  'suprimentos',
  'ativos',
  'analise-uso',
  'consultas-gerenciais',
  'saldo-estoque',
  'consulta-produtos',
];

class FarmQuickAccessDefinition {
  const FarmQuickAccessDefinition({
    required this.id,
    required this.label,
    required this.icon,
    required this.route,
  });

  final String id;
  final String label;
  final AppIconData icon;
  final String route;
}

FarmQuickAccessDefinition? farmQuickAccessDefinitionForId(String id) {
  switch (id) {
    case 'farm:activities':
      return const FarmQuickAccessDefinition(
        id: 'farm:activities',
        label: 'Atividades',
        icon: AppIcons.activity,
        route: '/fazendas/atividades',
      );
    case 'farm:consultas':
      return const FarmQuickAccessDefinition(
        id: 'farm:consultas',
        label: 'Consultas',
        icon: AppIcons.search,
        route: '/fazendas/consultas',
      );
  }

  final feature = featureById(id);
  if (feature == null) return null;

  return FarmQuickAccessDefinition(
    id: feature.id,
    label: feature.title,
    icon: featureIcon(feature.id, feature.group),
    route: feature.existingRoute ?? '/fazendas/administracao/${feature.id}',
  );
}

FarmQuickAccessDefinition? farmQuickAccessDefinitionForRoute(String route) {
  final path = Uri.tryParse(route)?.path ?? route;

  if (path == '/fazendas/atividades') {
    return farmQuickAccessDefinitionForId('farm:activities');
  }
  if (path == '/fazendas/consultas') {
    return farmQuickAccessDefinitionForId('farm:consultas');
  }

  for (final feature in allFeatures) {
    final definition = farmQuickAccessDefinitionForId(feature.id)!;
    if (path == definition.route ||
        path == '/fazendas/administracao/${feature.id}' ||
        path == '/fazendas/consultas/${feature.id}') {
      return definition;
    }
  }

  return null;
}
