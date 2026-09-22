import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../design/generated/app_radius.dart';
import '../../../design/generated/app_spacing.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../shared/rise_in.dart';
import '../../../ui/ui.dart';
import 'package:cerne_app/design/generated/app_typography.dart';
import '../../../design/generated/app_layout.dart';

class _LinkItem {
  const _LinkItem({required this.label, required this.icon, required this.to});
  final String label;
  final AppIconData icon;
  final String to;
}

class _Group {
  const _Group({required this.title, required this.items});
  final String title;
  final List<_LinkItem> items;
}

const _groups = [
  // Cinco paineis de decisao, na ordem em que o administrador pergunta:
  // dinheiro, rebanho, compra, patrimonio, governanca. Ver
  // docs/ESTEIRA-DASHBOARDS-ADM.md, secao 2.
  _Group(
    title: 'Painéis de decisão',
    items: [
      _LinkItem(
        label: 'Resultado',
        icon: AppIcons.wallet,
        to: '/fazendas/dashboards/resultado',
      ),
      _LinkItem(
        label: 'Rebanho & Confinamento',
        icon: AppIcons.warehouse,
        to: '/fazendas/dashboards/confinamento',
      ),
      _LinkItem(
        label: 'Suprimentos',
        icon: AppIcons.boxes,
        to: '/fazendas/dashboards/suprimentos',
      ),
      _LinkItem(
        label: 'Ativos & Manutenção',
        icon: AppIcons.package,
        to: '/fazendas/dashboards/ativos',
      ),
      _LinkItem(
        label: 'Adoção & Governança',
        icon: AppIcons.users,
        to: '/fazendas/dashboards/uso',
      ),
    ],
  ),
  _Group(
    title: 'Consultas e auditoria',
    items: [
      _LinkItem(
        label: 'Consultas gerenciais',
        icon: AppIcons.search,
        to: '/fazendas/consultas',
      ),
      _LinkItem(
        label: 'Todas as atividades',
        icon: AppIcons.activity,
        to: '/fazendas/atividades',
      ),
    ],
  ),
  _Group(
    title: 'Operacional',
    items: [
      _LinkItem(
        label: 'Sincronização',
        icon: AppIcons.refreshCw,
        to: '/fazendas/campo/sincronizacao',
      ),
    ],
  ),
];

/// Menu "Mais" (spec §3.2) — espelha `MaisScreen.tsx`: hub expandido com
/// acesso a dashboards e áreas do módulo.
class MaisScreen extends StatelessWidget {
  const MaisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.space4),
      children: [
        const RiseIn(child: AppHeading(child: Text('Mais'))),
        const SizedBox(height: AppSpacing.space4),
        for (var g = 0; g < _groups.length; g++)
          RiseIn(
            index: g + 1,
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.space5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSectionTitle(child: Text(_groups[g].title)),
                  const SizedBox(height: AppSpacing.space2),
                  Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: semantic.bgSurface,
                      borderRadius: BorderRadius.circular(AppRadius.xl3),
                      border: Border.all(color: semantic.borderDefault),
                    ),
                    child: Column(
                      children: [
                        for (final it in _groups[g].items)
                          _MaisRow(
                            item: it,
                            showDivider: it != _groups[g].items.last,
                            onTap: () => context.go(it.to),
                            semantic: semantic,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _MaisRow extends StatelessWidget {
  const _MaisRow({
    required this.item,
    required this.showDivider,
    required this.onTap,
    required this.semantic,
  });

  final _LinkItem item;
  final bool showDivider;
  final VoidCallback onTap;
  final AppSemanticColors semantic;

  @override
  Widget build(BuildContext context) {
    return AppPressable(
      semanticLabel: item.label,
      onPressed: onTap,
      minTouchTarget: false,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space4,
          vertical: AppSpacing.space3,
        ),
        decoration: showDivider
            ? BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: semantic.borderSubtle),
                ),
              )
            : null,
        child: Row(
          children: [
            Container(
              width: AppSpacing.space9,
              height: AppSpacing.space9,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: semantic.accentSubtle,
              ),
              child: AppIcon(
                item.icon,
                size: AppSize.iconSmPlus,
                color: semantic.accentDefault,
              ),
            ),
            const SizedBox(width: AppSpacing.space3),
            Expanded(
              child: Text(
                item.label,
                style: TextStyle(
                  fontWeight: AppTypography.weightMedium,
                  color: semantic.fgDefault,
                ),
              ),
            ),
            AppIcon(
              AppIcons.chevronRight,
              size: AppSize.iconSm,
              color: semantic.fgSubtle,
            ),
          ],
        ),
      ),
    );
  }
}
