import 'package:flutter/material.dart';

import '../../../design/generated/app_spacing.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../ui/ui.dart';
import '../types.dart';
import 'package:cerne_app/design/generated/app_typography.dart';
import '../../../design/generated/app_layout.dart';

/// Ícone por tipo de atividade — fonte única, reutilizado no
/// `ActivityDetailSheet` (Lei 2). Espelha `KIND_ICON` de `ActivityListItem.tsx`.
const Map<ActivityKind, AppIconData> kindIcon = {
  ActivityKind.pesagem: AppIcons.scale,
  ActivityKind.evento: AppIcons.arrowLeftRight,
  ActivityKind.nfe: AppIcons.fileText,
  ActivityKind.venda: AppIcons.truck,
  ActivityKind.insumo: AppIcons.sprout,
  ActivityKind.arracoamento: AppIcons.wheat,
};

/// Rótulo de categoria por tipo de atividade — fonte única, reutilizado pela
/// tela de sincronização (`SincronizacaoFlow`) para agrupar a fila por tipo.
const Map<ActivityKind, String> kindLabel = {
  ActivityKind.pesagem: 'Pesagem',
  ActivityKind.evento: 'Eventos do rebanho',
  ActivityKind.nfe: 'Notas fiscais',
  ActivityKind.venda: 'Vendas',
  ActivityKind.insumo: 'Insumos',
  ActivityKind.arracoamento: 'Arraçoamento',
};

/// Rótulo + tom de status — fonte única, reutilizado no `ActivityDetailSheet`
/// (Lei 2). Espelha `STATUS_META`.
class StatusMeta {
  const StatusMeta({required this.label, required this.tone});
  final String label;
  final AppChipTone tone;
}

const Map<ActivityStatus, StatusMeta> statusMeta = {
  ActivityStatus.andamento: StatusMeta(
    label: 'Em andamento',
    tone: AppChipTone.blue,
  ),
  ActivityStatus.concluida: StatusMeta(
    label: 'Concluída',
    tone: AppChipTone.brand,
  ),
  ActivityStatus.autorizada: StatusMeta(
    label: 'Autorizada',
    tone: AppChipTone.brand,
  ),
  ActivityStatus.atrasada: StatusMeta(label: 'Atrasada', tone: AppChipTone.red),
};

/// Item da lista "Atividades recentes" (spec §6.7) — espelha `ActivityListItem.tsx`.
class ActivityListItem extends StatelessWidget {
  const ActivityListItem({
    super.key,
    required this.activity,
    this.onTap,
    this.showDivider = true,
  });

  final Activity activity;
  final VoidCallback? onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final icon = kindIcon[activity.kind]!;
    final status = statusMeta[activity.status]!;

    final row = Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.space3),
      decoration: showDivider
          ? BoxDecoration(
              border: Border(bottom: BorderSide(color: semantic.borderSubtle)),
            )
          : null,
      child: Row(
        children: [
          Container(
            width: AppSpacing.space10,
            height: AppSpacing.space10,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: semantic.bgSubtle,
            ),
            child: AppIcon(
              icon,
              size: AppSize.iconSmPlus,
              color: semantic.fgMuted,
            ),
          ),
          const SizedBox(width: AppSpacing.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  activity.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: AppTypography.weightSemibold,
                    color: semantic.fgDefault,
                  ),
                ),
                Text(
                  activity.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: semantic.fgMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.space3),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              AppChip(tone: status.tone, child: Text(status.label)),
              const SizedBox(height: AppSpacing.space1),
              Text(
                activity.time,
                style: TextStyle(
                  color: semantic.fgSubtle,
                  fontSize: AppTypography.sm,
                ),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.space1),
          AppIcon(
            AppIcons.chevronRight,
            size: AppSize.iconSm,
            color: semantic.fgSubtle,
          ),
        ],
      ),
    );

    if (onTap == null) return row;
    return AppPressable(
      semanticLabel: 'Abrir atividade ${activity.title}',
      onPressed: onTap,
      minTouchTarget: false,
      child: row,
    );
  }
}
