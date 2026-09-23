import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'app_icon.dart';
import 'button.dart';
import '../design/generated/app_colors.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';
import 'heading.dart';
import '../design/generated/app_layout.dart';

/// Tom da arte do estado vazio — diz, antes do texto, se o vazio é bom
/// (em dia, tudo concluído), neutro (nada ainda) ou um aviso (sem conexão,
/// acesso restrito).
enum AppEmptyStateTone { neutral, brand, success, info, warning, danger }

/// `regular` ocupa a área de uma tela ou aba; `compact` cabe numa folha,
/// num seletor ou num card (arte 64 px, título de 16 px, respiro menor).
enum AppEmptyStateSize { regular, compact }

/// Espelha `EmptyState.tsx` — estado vazio (lista/dado ausente).
///
/// Anatomia, de cima para baixo:
/// 1. **Arte** (opcional, com [icon]): halo circular no tom do cenário, o
///    ícone Hugeicons grande no centro e, com [badgeIcon], um selo sólido no
///    canto inferior direito que diz o "porquê" do vazio — check para "em
///    dia", x para "nada encontrado", nuvem riscada para "sem conexão".
/// 2. **Título** e **descrição** centralizados.
/// 3. **Ação** (opcional) — o CTA que resolve o vazio ("Nova OS").
/// 4. **Ajuda** (opcional) — pergunta curta em [hint] e um link
///    ([hintActionLabel] + [onHintAction]) para o lugar onde o conteúdo pode
///    estar ("Procurando uma antiga? Ver histórico").
///
/// As variações por cenário (busca, filtro, primeiro uso, offline…) estão em
/// Widgetbook → Padrões → Estados vazios.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.title,
    this.icon,
    this.badgeIcon,
    this.tone = AppEmptyStateTone.neutral,
    this.size = AppEmptyStateSize.regular,
    this.description,
    this.action,
    this.hint,
    this.hintActionLabel,
    this.onHintAction,
  });

  final AppIconData? icon;

  /// Selo no canto da arte. Só é desenhado junto com [icon].
  final AppIconData? badgeIcon;
  final AppEmptyStateTone tone;
  final AppEmptyStateSize size;
  final String title;
  final String? description;
  final Widget? action;

  /// Pergunta de apoio acima do link ("Procurando uma notificação antiga?").
  final String? hint;
  final String? hintActionLabel;
  final VoidCallback? onHintAction;

  static Color toneColor(AppSemanticColors semantic, AppEmptyStateTone tone) =>
      switch (tone) {
        AppEmptyStateTone.neutral => semantic.fgSubtle,
        AppEmptyStateTone.brand => semantic.ctaBg,
        AppEmptyStateTone.success => semantic.accentDefault,
        AppEmptyStateTone.info => AppColors.feedbackInfoSolid,
        AppEmptyStateTone.warning => AppColors.feedbackNotice,
        AppEmptyStateTone.danger => AppColors.feedbackErrorSolid,
      };

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final compact = size == AppEmptyStateSize.compact;
    final hasHintLink = hintActionLabel != null && onHintAction != null;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? AppSpacing.space4 : AppSpacing.space6,
        vertical: compact ? AppSpacing.space6 : AppSpacing.space12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Padding(
              padding: EdgeInsets.only(
                bottom: compact ? AppSpacing.space3 : AppSpacing.space6,
              ),
              child: _EmptyStateArt(
                icon: icon!,
                badgeIcon: badgeIcon,
                color: toneColor(semantic, tone),
                compact: compact,
              ),
            ),
          AppHeading(
            level: compact ? AppHeadingLevel.h3 : AppHeadingLevel.h2,
            child: Text(title, textAlign: TextAlign.center),
          ),
          if (description != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.space2),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 280),
                child: Text(
                  description!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: compact ? AppTypography.base : AppTypography.md,
                    height: AppTypography.lineHeightNormal,
                    color: semantic.fgMuted,
                  ),
                ),
              ),
            ),
          if (action != null)
            Padding(
              padding: EdgeInsets.only(
                top: compact ? AppSpacing.space4 : AppSpacing.space6,
              ),
              child: action,
            ),
          if (hint != null || hasHintLink)
            Padding(
              padding: EdgeInsets.only(
                top: compact ? AppSpacing.space4 : AppSpacing.space8,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hint != null)
                    Text(
                      hint!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: AppTypography.md,
                        fontWeight: AppTypography.weightMedium,
                        color: semantic.fgDefault,
                      ),
                    ),
                  if (hasHintLink)
                    AppButton(
                      variant: AppButtonVariant.link,
                      size: AppButtonSize.sm,
                      onPressed: onHintAction,
                      child: Text(hintActionLabel!),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Arte do estado vazio: halo em gradiente radial no tom (o mesmo idioma da
/// bolha de [AppNotificationTile]), ícone grande no centro e selo sólido com
/// anel da cor da folha, para "recortar" o halo como na referência.
class _EmptyStateArt extends StatelessWidget {
  const _EmptyStateArt({
    required this.icon,
    required this.color,
    required this.compact,
    this.badgeIcon,
  });

  final AppIconData icon;
  final AppIconData? badgeIcon;
  final Color color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final art = compact
        ? AppComponentMetrics.emptyStateArtCompact
        : AppComponentMetrics.emptyStateArt;
    final artIcon = compact
        ? AppComponentMetrics.emptyStateArtIconCompact
        : AppComponentMetrics.emptyStateArtIcon;
    final badge = compact
        ? AppComponentMetrics.emptyStateBadgeCompact
        : AppComponentMetrics.emptyStateBadge;
    final badgeGlyph = compact
        ? AppComponentMetrics.emptyStateBadgeIconCompact
        : AppComponentMetrics.emptyStateBadgeIcon;

    return ExcludeSemantics(
      child: SizedBox(
        width: art,
        height: art,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      color.withValues(alpha: 0.22),
                      color.withValues(alpha: 0.06),
                    ],
                  ),
                ),
              ),
            ),
            Center(
              child: AppIcon(icon, size: artIcon, color: color),
            ),
            if (badgeIcon != null)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: badge,
                  height: badge,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: semantic.bgSheet,
                      width: AppSpacing.threeQuarter,
                    ),
                  ),
                  child: AppIcon(
                    badgeIcon,
                    size: badgeGlyph,
                    color: semantic.fgInverse,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

WidgetbookComponent buildEmptyStateWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'EmptyState',
    useCases: [
      WidgetbookUseCase(
        name: 'Padrão',
        builder: (context) => const Center(
          child: AppEmptyState(
            icon: AppIcons.inbox,
            title: 'Nenhum lançamento encontrado',
            description: 'Ajuste os filtros ou tente novamente mais tarde.',
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Com selo, ação e ajuda',
        builder: (context) => Center(
          child: AppEmptyState(
            icon: AppIcons.bell,
            badgeIcon: AppIcons.check,
            tone: AppEmptyStateTone.success,
            title: 'Você está em dia',
            description: 'Suas notificações aparecem aqui assim que chegarem.',
            action: AppButton(
              onPressed: () {},
              child: const Text('Recarregar'),
            ),
            hint: 'Procurando uma notificação antiga?',
            hintActionLabel: 'Ver histórico',
            onHintAction: () {},
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Tons',
        builder: (context) => SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.space4),
          child: Wrap(
            alignment: WrapAlignment.center,
            children: [
              for (final (tone, icon, badge) in const [
                (AppEmptyStateTone.neutral, AppIcons.inbox, null),
                (AppEmptyStateTone.brand, AppIcons.sprout, AppIcons.plus),
                (AppEmptyStateTone.success, AppIcons.bell, AppIcons.check),
                (AppEmptyStateTone.info, AppIcons.search, AppIcons.x),
                (AppEmptyStateTone.warning, AppIcons.cloudOff, AppIcons.x),
                (AppEmptyStateTone.danger, AppIcons.lock, AppIcons.x),
              ])
                SizedBox(
                  width: 200,
                  child: AppEmptyState(
                    size: AppEmptyStateSize.compact,
                    icon: icon,
                    badgeIcon: badge,
                    tone: tone,
                    title: tone.name,
                  ),
                ),
            ],
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Compacto',
        builder: (context) => const Center(
          child: AppEmptyState(
            size: AppEmptyStateSize.compact,
            icon: AppIcons.search,
            badgeIcon: AppIcons.x,
            tone: AppEmptyStateTone.info,
            title: 'Nada encontrado',
            description: 'Tente outro termo de busca.',
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Sem ícone',
        builder: (context) =>
            const Center(child: AppEmptyState(title: 'Sem dados no período')),
      ),
    ],
  );
}
