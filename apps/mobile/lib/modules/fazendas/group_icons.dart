import '../../ui/ui.dart';

/// Ícone por grupo de `FeatureDefinition.group` — usado no acesso rápido e nos
/// cards de módulo da central de gestão (`ResponsibilityWorkspace`) e
/// na tela fullscreen de funções de um grupo (`GroupFeaturesScreen`).
///
/// `FeatureDefinition` não carrega ícone próprio (é um contrato de dados puro
/// — `functional_catalog.dart` não deve depender de UI), então o mapeamento
/// fica aqui, isolado do catálogo.
AppIconData groupIcon(String group) => switch (group) {
  'Painéis de decisão' => AppIcons.layoutDashboard,
  'Consultas e auditoria' => AppIcons.search,
  'Ordem de serviço' => AppIcons.fileText,
  _ => AppIcons.layers,
};

/// Ícone específico de uma função dentro do módulo. O catálogo funcional
/// guarda a regra e o texto, não componentes visuais; este mapa mantém a
/// grade interna expressiva sem espalhar decisões de UI pelo catálogo.
///
/// Antes devolvia sempre o ícone do grupo: os cinco painéis (e as dez
/// consultas) eram ladrilhos idênticos, e só o texto os diferenciava.
AppIconData featureIcon(String featureId, String group) => switch (featureId) {
  // Painéis de decisão
  'painel-financeiro' => AppIcons.wallet,
  'lotacao-currais' => AppIcons.confinamento,
  'suprimentos' => AppIcons.shoppingCart,
  'ativos' => AppIcons.tractor,
  'analise-uso' => AppIcons.users,
  // Ordem de serviço
  'consulta-os' => AppIcons.ordemServico,
  'consulta-apontamentos' => AppIcons.agricultura,
  // Consultas e auditoria
  'consultas-gerenciais' => AppIcons.fileBarChart,
  'saldo-estoque' => AppIcons.estoque,
  'consulta-produtos' => AppIcons.packageSearch,
  'areas' => AppIcons.mapPinned,
  'lotes-reproducao' => AppIcons.reproducao,
  'processamentos' => AppIcons.pecuaria,
  'compras-animais' => AppIcons.handCoins,
  'vendas' => AppIcons.receipt,
  'exportar-log-estoque' || 'exportar-log-pecuaria' => AppIcons.download,
  _ => groupIcon(group),
};

/// Rótulo de apresentação dos módulos na central de responsabilidade. O
/// catálogo mantém o nome de domínio para chaves, slugs e auditoria; a home
/// usa o vocabulário curto que aparece no layout de referência.
String groupDisplayLabel(String group) => switch (group) {
  'Ordem de serviço' => 'Ordem de Serviço',
  _ => group,
};

/// Ordem de exibição dos grupos na central de responsabilidade.
///
/// Sem isso, a ordem seria a de inserção no array do catálogo — acidente de
/// edição, não decisão de produto. Painéis vêm primeiro porque são a leitura
/// diária da Administração; Ordem de Serviço fecha a lista por ser o trabalho
/// que se despacha depois de decidir.
const List<String> _groupDisplayOrder = [
  'Painéis de decisão',
  'Consultas e auditoria',
  'Ordem de serviço',
];

/// Posição do grupo na ordem de exibição. Grupos fora da lista (ex.: um grupo
/// novo esquecido aqui) vão para o fim, sem quebrar a navegação.
int groupOrder(String group) {
  final index = _groupDisplayOrder.indexOf(group);
  return index == -1 ? _groupDisplayOrder.length : index;
}

/// Slug estável por grupo, usado no segmento de rota `grupo/:slug`.
///
/// Evita colocar o nome do grupo (com espaços/acentos) cru na URL: o
/// go_router já decodifica `pathParameters` automaticamente, e o percurso
/// round-trip pelo endereço do navegador no Flutter Web pode re-codificar o
/// caminho de forma inconsistente, quebrando um `Uri.decodeComponent` extra
/// no lado da leitura. Um slug ASCII fixo não tem esse problema.
const Map<String, String> _groupSlugs = {
  'Painéis de decisão': 'paineis-de-decisao',
  'Consultas e auditoria': 'consultas-e-auditoria',
  'Ordem de serviço': 'ordem-de-servico',
};

/// Converte um `feature.group` no slug usado na rota. Grupos fora do mapa
/// (ex.: um grupo novo esquecido aqui) caem num fallback determinístico em
/// vez de quebrar a navegação.
String groupToSlug(String group) =>
    _groupSlugs[group] ??
    group
        .toLowerCase()
        .replaceAll(RegExp('[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');

/// Resolve um slug de volta ao nome do grupo original. Retorna `null` quando
/// o slug não corresponde a nenhum grupo conhecido — quem chama decide o
/// fallback (ex.: `GroupFeaturesScreen` mostra estado vazio).
String? groupFromSlug(String slug) {
  for (final entry in _groupSlugs.entries) {
    if (entry.value == slug) return entry.key;
  }
  return null;
}
