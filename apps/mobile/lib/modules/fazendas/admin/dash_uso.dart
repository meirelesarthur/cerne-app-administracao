import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design/generated/app_layout.dart';
import '../../../design/generated/app_radius.dart';
import '../../../design/generated/app_spacing.dart';
import '../../../design/generated/app_typography.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../shell/state/shell_store.dart';
import '../../../ui/ui.dart';
import '../mocks/dashboards_mocks.dart';
import 'dashboard_screen.dart';
import 'package:cerne_app/design/generated/app_colors.dart';
import 'package:cerne_app/design/generated/app_motion.dart';

const _periodos = ['Hoje', '7 dias', '30 dias'];
const _todosUsuarios = '__todos_usuarios__';

List<AppFormSelectOption> _opcoesUsuarios() {
  final nomes = {
    for (final fazenda in usoFazendas)
      for (final usuario in fazenda.usuarios) usuario.nome,
  }.toList()..sort();

  return [
    const AppFormSelectOption(
      value: _todosUsuarios,
      label: 'Todos os usuários',
    ),
    for (final nome in nomes) AppFormSelectOption(value: nome, label: nome),
  ];
}

/// Painel **Adoção & Governança** (spec §4.6) — observabilidade multi-tenant.
///
/// Era uma lista expansível de usuários, sem nenhum indicador. Ganhou o topo de
/// KPI, a leitura de adoção por fazenda e a trilha de auditoria: as exportações
/// de log existiam no catálogo (`auditExport`) sem casa visual própria, e
/// adoção e auditoria são a mesma pergunta de governança. Tela sensível:
/// marcada como "Acesso restrito" no cabeçalho (via `DashboardScreen`).
/// Ver docs/ESTEIRA-DASHBOARDS-ADM.md, seção 2.
class DashUso extends ConsumerStatefulWidget {
  const DashUso({super.key});

  @override
  ConsumerState<DashUso> createState() => _DashUsoState();
}

class _DashUsoState extends ConsumerState<DashUso> {
  String _periodo = _periodos.first;
  String? _usuario;
  String? _expandido = usoFazendas.first.id;
  int _tentativa = 0;

  @override
  Widget build(BuildContext context) {
    final isOnline = ref.watch(shellStoreProvider.select((s) => s.isOnline));

    // Dados multi-tenant em tempo real não são cacheáveis offline → estado de
    // erro com retry (spec §7.1).
    if (!isOnline) {
      return DashboardScreen(
        key: ValueKey(_tentativa),
        title: 'Adoção & Governança',
        restricted: true,
        hideOfflineBanner: true,
        child: AppErrorState(
          title: 'Indisponível offline',
          description:
              'A atividade de usuários em tempo real exige conexão. Reconecte para visualizar.',
          onRetry: () => setState(() => _tentativa++),
        ),
      );
    }

    final fazendas = [
      for (final fazenda in usoFazendas)
        if (_usuario == null ||
            fazenda.usuarios.any((usuario) => usuario.nome == _usuario))
          FazendaAtividade(
            id: fazenda.id,
            nome: fazenda.nome,
            online: fazenda.usuarios
                .where(
                  (usuario) =>
                      (_usuario == null || usuario.nome == _usuario) &&
                      usuario.ativo,
                )
                .length,
            usuarios: [
              for (final usuario in fazenda.usuarios)
                if (_usuario == null || usuario.nome == _usuario) usuario,
            ],
          ),
    ];
    final totalOnline = fazendas.fold<int>(0, (s, f) => s + f.online);
    final totalUsuarios = fazendas.fold<int>(
      0,
      (s, f) => s + f.usuarios.length,
    );
    final fazendasAtivas = fazendas.where((f) => f.online > 0).length;
    final adocaoPct = totalUsuarios == 0
        ? 0
        : ((totalOnline / totalUsuarios) * 100).round();
    final expanded = fazendas.any((f) => f.id == _expandido)
        ? _expandido
        : fazendas.isEmpty
        ? null
        : fazendas.first.id;
    final todosUsuarios = _usuario == null;

    return DashboardScreen(
      title: 'Adoção & Governança',
      restricted: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppFormField(
            label: 'Usuário',
            hint: todosUsuarios
                ? 'Visão consolidada de todos os usuários.'
                : 'As métricas mostram apenas a atividade deste usuário.',
            child: AppFormSelect(
              options: _opcoesUsuarios(),
              value: _usuario ?? _todosUsuarios,
              onChanged: (value) => setState(
                () => _usuario = value == _todosUsuarios ? null : value,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.space4),
          SizedBox(
            height: AppSize.controlSm,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final p in _periodos) ...[
                  _FiltroPill(
                    label: p,
                    selected: _periodo == p,
                    onTap: () => setState(() => _periodo = p),
                  ),
                  const SizedBox(width: AppSpacing.space2),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.space3),
          AppMetricGrid(
            children: [
              AppKpiStatCard(
                label: 'Usuários online',
                value: '$totalOnline',
                caption: 'de $totalUsuarios cadastrados',
                tone: AppKpiStatTone.positive,
              ),
              AppKpiStatCard(
                label: 'Adoção',
                value: '$adocaoPct%',
                caption: 'ativos agora',
              ),
              AppKpiStatCard(
                label: 'Fazendas ativas',
                value: '$fazendasAtivas',
                caption: 'de ${usoFazendas.length}',
                tone: fazendasAtivas < usoFazendas.length
                    ? AppKpiStatTone.warning
                    : AppKpiStatTone.neutral,
              ),
              AppKpiStatCard(label: 'Período', value: _periodo),
            ],
          ),
          const SizedBox(height: AppSpacing.space4),
          AppChartCard(
            title: 'Adoção por fazenda',
            period: _periodo,
            footnote: todosUsuarios
                ? 'Usuários online contra o total cadastrado de cada fazenda.'
                : 'Atividade de $_usuario nas fazendas vinculadas.',
            child: AppBulletChart(
              targetLabel: 'cadastrados',
              data: [
                for (final f in fazendas)
                  AppBulletDatum(
                    label: f.nome,
                    value: f.online.toDouble(),
                    target: f.usuarios.length.toDouble(),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.space5),
          const AppSectionTitle(child: Text('Atividade por fazenda')),
          const SizedBox(height: AppSpacing.space2),
          Column(
            children: [
              for (final f in fazendas) ...[
                _FazendaTile(
                  fazenda: f,
                  open: expanded == f.id,
                  onTap: () => setState(
                    () => _expandido = expanded == f.id ? null : f.id,
                  ),
                ),
                if (f != fazendas.last)
                  const SizedBox(height: AppSpacing.space2),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.space5),
          const AppSectionTitle(child: Text('Trilha de auditoria')),
          const SizedBox(height: AppSpacing.space2),
          const _AuditoriaLinks(),
        ],
      ),
    );
  }
}

/// Atalhos para as duas exportações de log do catálogo administrativo. A tela
/// de exportação continua sendo a genérica (`MappedFeatureScreen`, via
/// `auditExport`) — aqui só há a porta de entrada, não uma segunda cópia dela.
class _AuditoriaLinks extends StatelessWidget {
  const _AuditoriaLinks();

  static const _itens = [
    (
      label: 'Exportar log de estoque',
      icon: AppIcons.boxes,
      to: '/fazendas/administracao/exportar-log-estoque',
    ),
    (
      label: 'Exportar log da pecuária',
      icon: AppIcons.beef,
      to: '/fazendas/administracao/exportar-log-pecuaria',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final item in _itens)
          Padding(
            padding: EdgeInsets.only(
              bottom: item == _itens.last
                  ? AppSpacing.space0
                  : AppSpacing.space2,
            ),
            child: AppMenuItem(
              icon: item.icon,
              label: item.label,
              onTap: () => context.push(item.to),
            ),
          ),
      ],
    );
  }
}

class _FiltroPill extends StatelessWidget {
  const _FiltroPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return AppPressable(
      semanticLabel: 'Filtrar por $label',
      selected: selected,
      onPressed: onTap,
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space3,
          vertical: AppSpacing.space1,
        ),
        decoration: BoxDecoration(
          color: selected ? semantic.accentDefault : semantic.bgSurface,
          border: Border.all(
            color: selected ? semantic.accentDefault : semantic.borderDefault,
          ),
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: AppTypography.base,
            fontWeight: AppTypography.weightSemibold,
            color: selected ? AppColors.neutral0 : semantic.fgMuted,
          ),
        ),
      ),
    );
  }
}

class _FazendaTile extends StatelessWidget {
  const _FazendaTile({
    required this.fazenda,
    required this.open,
    required this.onTap,
  });

  final FazendaAtividade fazenda;
  final bool open;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final onlineColor = fazenda.online > 0
        ? semantic.accentDefault
        : semantic.borderStrong;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: semantic.bgSurface,
        border: Border.all(color: semantic.borderDefault),
        borderRadius: BorderRadius.circular(AppRadius.xl2),
      ),
      child: Column(
        children: [
          AppPressable(
            semanticLabel: open
                ? 'Recolher detalhes de ${fazenda.nome}'
                : 'Expandir detalhes de ${fazenda.nome}',
            toggled: open,
            onPressed: onTap,
            minTouchTarget: false,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.space3),
              child: Row(
                children: [
                  AppIcon(
                    AppIcons.circle,
                    size: AppSize.iconXs,
                    color: onlineColor,
                  ),
                  const SizedBox(width: AppSpacing.space3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          fazenda.nome,
                          style: TextStyle(
                            fontWeight: AppTypography.weightSemibold,
                            color: semantic.fgDefault,
                          ),
                        ),
                        Text(
                          '${fazenda.online} usuário(s) online',
                          style: TextStyle(
                            fontSize: AppTypography.base,
                            color: semantic.fgMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: open ? 0.5 : 0,
                    duration: AppMotion.fast,
                    child: AppIcon(
                      AppIcons.chevronDown,
                      size: AppSize.iconSmPlus,
                      color: semantic.fgSubtle,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (open)
            Column(
              children: [
                Divider(height: 1, color: semantic.borderSubtle),
                for (final u in fazenda.usuarios)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.space4,
                      vertical: AppSpacing.space2,
                    ),
                    child: Row(
                      children: [
                        AppIcon(
                          AppIcons.circle,
                          size: AppSize.iconXs,
                          color: u.ativo
                              ? semantic.accentDefault
                              : semantic.borderStrong,
                        ),
                        const SizedBox(width: AppSpacing.space3),
                        Expanded(
                          child: Text(
                            u.nome,
                            style: TextStyle(
                              fontSize: AppTypography.base,
                              color: semantic.fgDefault,
                            ),
                          ),
                        ),
                        Text(
                          u.ultimoAcesso,
                          style: TextStyle(
                            fontSize: AppTypography.xs,
                            color: semantic.fgSubtle,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
