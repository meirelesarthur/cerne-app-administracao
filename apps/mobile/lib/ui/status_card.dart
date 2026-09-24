import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import '../design/generated/app_layout.dart';
import '../design/generated/app_radius.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';
import 'app_icon.dart';
import 'button.dart';
import 'chip.dart';
import 'pressable.dart';

/// Par rótulo/valor exibido à direita do título de um [AppStatusCard]
/// (ex.: "Prioridade: Alta").
class AppStatusCardMeta {
  const AppStatusCardMeta({
    required this.label,
    required this.value,
    this.highlight = false,
    this.icon,
  });

  final String label;
  final String value;

  /// Na variante [AppStatusCardVariant.featured] o ícone substitui o rótulo
  /// escrito (calendário no lugar de "Prazo:"); o rótulo segue na semântica.
  final AppIconData? icon;

  /// Destaca o valor na cor de acento — para o dado que pede atenção
  /// (prioridade alta, atraso), sem virar mais um chip.
  final bool highlight;
}

/// Anatomias do [AppStatusCard]:
///
/// - [standard]: a das listas — chip no topo, título, metas à direita e
///   rodapé com situação e ação.
/// - [featured]: o registro em destaque de uma home — título grande à
///   esquerda com as linhas de apoio, chip e metas com ícone à direita, e a
///   situação numa faixa tingida ao lado do botão de ação.
/// - [compact]: o "próximo da fila" logo abaixo do destaque — título, uma
///   linha de apoio e o chip à direita, sem metas nem rodapé.
enum AppStatusCardVariant { standard, featured, compact }

/// Tom da linha de situação de um [AppStatusCard].
enum AppStatusCardTone { neutral, info, warning, danger, success }

/// Linha de situação: o que está acontecendo com o registro *agora*
/// ("Atrasada há 3 dias", "Em execução há 2h15"). Uma linha só, com ícone e
/// cor — o card mostra uma situação por vez, a mais importante.
class AppStatusCardSituation {
  const AppStatusCardSituation({
    required this.icon,
    required this.label,
    this.tone = AppStatusCardTone.neutral,
  });

  final AppIconData icon;
  final String label;
  final AppStatusCardTone tone;
}

/// Ação rápida do card: o próximo passo do registro, ao lado da situação.
/// Um botão só por card; ações que encerram o registro ficam no detalhe.
class AppStatusCardAction {
  const AppStatusCardAction({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.primary = true,
  });

  final String label;
  final AppIconData icon;
  final VoidCallback onPressed;

  /// `true` pinta o botão como CTA (iniciar, retomar); `false` como ação
  /// secundária (pausar).
  final bool primary;
}

/// Card de registro com andamento — listas de ordens, pedidos e tarefas em
/// que o **status** é a primeira coisa a ler.
///
/// Anatomia: chip de status no topo; título grande (o identificador que a
/// pessoa procura, ex.: "OS #2201") com a descrição e a legenda abaixo; à
/// direita, até dois ou três pares rótulo/valor ([meta]). Superfície
/// [AppSemanticColors.bgRaised] sem borda nem sombra e raio [AppRadius.tile]
/// — branco sobre a folha cinza (`AppContentSheet`) no tema claro e o verde
/// elevado sobre a folha escura no Modo GB. Nada é cor crua.
class AppStatusCard extends StatelessWidget {
  const AppStatusCard({
    super.key,
    required this.statusLabel,
    this.statusTone = AppChipTone.neutral,
    required this.title,
    this.subtitle,
    this.caption,
    this.meta = const [],
    this.situation,
    this.action,
    this.onTap,
    this.variant = AppStatusCardVariant.standard,
  });

  final AppStatusCardVariant variant;

  final String statusLabel;
  final AppChipTone statusTone;
  final String title;

  /// Descrição curta do registro (até duas linhas).
  final String? subtitle;

  /// Linha de apoio abafada (ex.: prazo e local).
  final String? caption;
  final List<AppStatusCardMeta> meta;

  /// Linha de situação no rodapé do card, à esquerda da [action].
  final AppStatusCardSituation? situation;

  /// Botão de ação rápida no rodapé, à direita da [situation]. Tem alvo de
  /// toque próprio: tocar nele não dispara o [onTap] do card.
  final AppStatusCardAction? action;
  final VoidCallback? onTap;

  Color _toneColor(AppSemanticColors semantic, AppStatusCardTone tone) =>
      switch (tone) {
        AppStatusCardTone.neutral => semantic.fgMuted,
        AppStatusCardTone.info => semantic.toneBlueFg,
        AppStatusCardTone.warning => semantic.toneAmberFg,
        AppStatusCardTone.danger => semantic.toneRedFg,
        AppStatusCardTone.success => semantic.accentDefault,
      };

  Color _toneBg(AppSemanticColors semantic, AppStatusCardTone tone) =>
      switch (tone) {
        AppStatusCardTone.neutral => semantic.bgInset,
        AppStatusCardTone.info => semantic.toneBlueBg,
        AppStatusCardTone.warning => semantic.toneAmberBg,
        AppStatusCardTone.danger => semantic.toneRedBg,
        AppStatusCardTone.success => semantic.accentSubtle,
      };

  /// O que o leitor de tela anuncia: título, status, situação e metas — antes
  /// era só "título, status" e o prazo/prioridade sumiam.
  String get _semanticSummary => [
    title,
    statusLabel,
    ?situation?.label,
    for (final m in meta) '${m.label}: ${m.value}',
  ].join('. ');

  Widget _wrap(Widget content, BorderRadius radius) {
    if (onTap == null) return content;
    return AppPressable(
      semanticLabel: _semanticSummary,
      onPressed: onTap,
      borderRadius: radius,
      // Com ação rápida, os filhos continuam na árvore para o botão
      // (Iniciar/Retomar) seguir alcançável pelo leitor de tela.
      excludeSemantics: action == null,
      child: content,
    );
  }

  Widget _buildCompact(AppSemanticColors semantic, BorderRadius radius) {
    final line = subtitle ?? caption;
    return _wrap(
      Container(
        padding: const EdgeInsets.all(AppSpacing.space4),
        decoration: BoxDecoration(
          color: semantic.bgRaised,
          borderRadius: radius,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: AppTypography.xl,
                      fontWeight: AppTypography.weightMedium,
                      height: AppTypography.lineHeightSnug,
                      color: semantic.fgHeading,
                    ),
                  ),
                  if (line != null) ...[
                    const SizedBox(height: AppSpacing.space1),
                    Text(
                      line,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: AppTypography.base,
                        color: semantic.fgSubtle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.space3),
            AppChip(tone: statusTone, child: Text(statusLabel)),
          ],
        ),
      ),
      radius,
    );
  }

  Widget _buildFeatured(AppSemanticColors semantic, BorderRadius radius) {
    final lines = [?subtitle, ?caption];
    final situation = this.situation;
    final action = this.action;
    return _wrap(
      Container(
        padding: const EdgeInsets.all(AppSpacing.space4),
        decoration: BoxDecoration(
          color: semantic.bgRaised,
          borderRadius: radius,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: AppTypography.xl2,
                          fontWeight: AppTypography.weightMedium,
                          height: AppTypography.lineHeightTight,
                          color: semantic.fgHeading,
                        ),
                      ),
                      for (var i = 0; i < lines.length; i++) ...[
                        const SizedBox(height: AppSpacing.space1),
                        Text(
                          lines[i],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: AppTypography.base,
                            fontWeight: i == 0
                                ? AppTypography.weightMedium
                                : AppTypography.weightNormal,
                            color: i == 0
                                ? semantic.fgDefault
                                : semantic.fgSubtle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.space3),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppChip(tone: statusTone, child: Text(statusLabel)),
                    for (final item in meta) ...[
                      const SizedBox(height: AppSpacing.space2),
                      Semantics(
                        label: '${item.label}: ${item.value}',
                        excludeSemantics: true,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (item.icon != null) ...[
                              AppIcon(
                                item.icon!,
                                size: AppSize.iconSm,
                                color: item.highlight
                                    ? semantic.toneRedFg
                                    : semantic.fgMuted,
                              ),
                              const SizedBox(width: AppSpacing.space1),
                            ] else
                              Text(
                                '${item.label}: ',
                                style: TextStyle(
                                  fontSize: AppTypography.md,
                                  color: semantic.fgMuted,
                                ),
                              ),
                            Text(
                              item.value,
                              style: TextStyle(
                                fontSize: AppTypography.md,
                                fontWeight: AppTypography.weightMedium,
                                color: item.highlight
                                    ? semantic.toneRedFg
                                    : semantic.fgDefault,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            if (situation != null || action != null) ...[
              const SizedBox(height: AppSpacing.space4),
              Row(
                children: [
                  Expanded(
                    child: situation == null
                        ? const SizedBox.shrink()
                        : Container(
                            constraints: const BoxConstraints(
                              minHeight: AppSpacing.space10,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.space3,
                              vertical: AppSpacing.space2,
                            ),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _toneBg(semantic, situation.tone),
                              borderRadius: BorderRadius.circular(
                                AppRadius.mdPlus,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AppIcon(
                                  situation.icon,
                                  size: AppSize.iconSm,
                                  color: _toneColor(semantic, situation.tone),
                                ),
                                const SizedBox(width: AppSpacing.oneHalf),
                                Flexible(
                                  child: Text(
                                    situation.label,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: AppTypography.base,
                                      fontWeight: AppTypography.weightSemibold,
                                      color: _toneColor(
                                        semantic,
                                        situation.tone,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                  if (action != null) ...[
                    const SizedBox(width: AppSpacing.space3),
                    AppButton(
                      variant: action.primary
                          ? AppButtonVariant.primary
                          : AppButtonVariant.secondary,
                      leftIcon: AppIcon(
                        action.icon,
                        size: AppSize.iconSm,
                        color: action.primary
                            ? semantic.ctaFg
                            : semantic.fgDefault,
                      ),
                      onPressed: action.onPressed,
                      child: Text(action.label),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
      radius,
    );
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final radius = BorderRadius.circular(AppRadius.tile);
    switch (variant) {
      case AppStatusCardVariant.featured:
        return _buildFeatured(semantic, radius);
      case AppStatusCardVariant.compact:
        return _buildCompact(semantic, radius);
      case AppStatusCardVariant.standard:
        break;
    }

    final content = Container(
      padding: const EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(color: semantic.bgRaised, borderRadius: radius),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppChip(tone: statusTone, child: Text(statusLabel)),
          const SizedBox(height: AppSpacing.space2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: AppTypography.xl2,
                        fontWeight: AppTypography.weightMedium,
                        height: AppTypography.lineHeightTight,
                        color: semantic.fgHeading,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: AppSpacing.space1),
                      Text(
                        subtitle!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: AppTypography.base,
                          fontWeight: AppTypography.weightMedium,
                          color: semantic.fgDefault,
                        ),
                      ),
                    ],
                    if (caption != null) ...[
                      const SizedBox(height: AppSpacing.space1),
                      Text(
                        caption!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: AppTypography.sm,
                          color: semantic.fgSubtle,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (meta.isNotEmpty) ...[
                const SizedBox(width: AppSpacing.space3),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final item in meta)
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppSpacing.space1,
                        ),
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '${item.label}: ',
                                style: TextStyle(color: semantic.fgMuted),
                              ),
                              TextSpan(
                                text: item.value,
                                style: TextStyle(
                                  fontWeight: AppTypography.weightSemibold,
                                  color: item.highlight
                                      ? semantic.accentDefault
                                      : semantic.fgDefault,
                                ),
                              ),
                            ],
                          ),
                          style: const TextStyle(fontSize: AppTypography.sm),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
          if (situation != null || action != null) ...[
            const SizedBox(height: AppSpacing.space3),
            Row(
              children: [
                Expanded(
                  child: situation == null
                      ? const SizedBox.shrink()
                      : Row(
                          children: [
                            AppIcon(
                              situation!.icon,
                              size: AppSize.iconSm,
                              color: _toneColor(semantic, situation!.tone),
                            ),
                            const SizedBox(width: AppSpacing.space1),
                            Expanded(
                              child: Text(
                                situation!.label,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: AppTypography.sm,
                                  fontWeight: AppTypography.weightSemibold,
                                  color: _toneColor(semantic, situation!.tone),
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
                if (action != null) ...[
                  const SizedBox(width: AppSpacing.space2),
                  AppButton(
                    size: AppButtonSize.sm,
                    variant: action!.primary
                        ? AppButtonVariant.primary
                        : AppButtonVariant.secondary,
                    leftIcon: AppIcon(
                      action!.icon,
                      size: AppSize.iconSm,
                      color: action!.primary
                          ? semantic.ctaFg
                          : semantic.fgDefault,
                    ),
                    onPressed: action!.onPressed,
                    child: Text(action!.label),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );

    return _wrap(content, radius);
  }
}

WidgetbookComponent buildStatusCardWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'StatusCard',
    useCases: [
      WidgetbookUseCase(
        name: 'Lista de ordens de serviço',
        builder: (context) => ListView(
          padding: const EdgeInsets.all(AppSpacing.space4),
          children: [
            AppStatusCard(
              statusLabel: 'Em execução',
              statusTone: AppChipTone.blue,
              title: 'OS #2198',
              subtitle: 'Vacinação contra aftosa — Lote 12',
              caption: 'Prazo 20/09/2026 · Curral de manejo 2',
              meta: const [
                AppStatusCardMeta(label: 'Tipo', value: 'Pecuário'),
                AppStatusCardMeta(label: 'Prioridade', value: 'Média'),
              ],
              situation: const AppStatusCardSituation(
                icon: AppIcons.clock,
                label: 'Em execução há 2h15',
                tone: AppStatusCardTone.info,
              ),
              action: AppStatusCardAction(
                label: 'Pausar',
                icon: AppIcons.pause,
                primary: false,
                onPressed: () {},
              ),
              onTap: () {},
            ),
            const SizedBox(height: AppSpacing.space3),
            AppStatusCard(
              statusLabel: 'Aguardando',
              title: 'OS #2201',
              subtitle: 'Reparo de cerca do Talhão 04',
              caption: 'Prazo 25/09/2026 · Talhão 04',
              meta: const [
                AppStatusCardMeta(label: 'Tipo', value: 'Infraestrutura'),
                AppStatusCardMeta(
                  label: 'Prioridade',
                  value: 'Alta',
                  highlight: true,
                ),
              ],
              situation: const AppStatusCardSituation(
                icon: AppIcons.alertTriangle,
                label: 'Atrasada há 4 dias',
                tone: AppStatusCardTone.danger,
              ),
              action: AppStatusCardAction(
                label: 'Iniciar',
                icon: AppIcons.play,
                onPressed: () {},
              ),
              onTap: () {},
            ),
            const SizedBox(height: AppSpacing.space3),
            const AppStatusCard(
              statusLabel: 'Refeita',
              statusTone: AppChipTone.red,
              title: 'OS #2160',
              subtitle: 'Contenção emergencial de gado solto — Estrada vicinal',
            ),
          ],
        ),
      ),
      WidgetbookUseCase(
        name: 'Destaque e próximo da home',
        builder: (context) => ListView(
          padding: const EdgeInsets.all(AppSpacing.space4),
          children: [
            AppStatusCard(
              variant: AppStatusCardVariant.featured,
              statusLabel: 'Em execução',
              statusTone: AppChipTone.blue,
              title: 'Vacinação contra aftosa',
              subtitle: 'Curral de manejo 2',
              caption: 'João Oliveira · OS #2198',
              meta: const [
                AppStatusCardMeta(
                  label: 'Prazo',
                  value: '18/09',
                  icon: AppIcons.calendar,
                ),
                AppStatusCardMeta(
                  label: 'Prioridade',
                  value: 'Média',
                  icon: AppIcons.alertCircle,
                ),
              ],
              situation: const AppStatusCardSituation(
                icon: AppIcons.alertTriangle,
                label: 'Atrasada há 5 dias',
                tone: AppStatusCardTone.danger,
              ),
              action: AppStatusCardAction(
                label: 'Pausar',
                icon: AppIcons.pause,
                primary: false,
                onPressed: () {},
              ),
              onTap: () {},
            ),
            const SizedBox(height: AppSpacing.space3),
            AppStatusCard(
              variant: AppStatusCardVariant.compact,
              statusLabel: 'Aguardando',
              title: 'Reparo de cerca do Talhão 04',
              subtitle: 'Talhão 04',
              onTap: () {},
            ),
          ],
        ),
      ),
    ],
  );
}
