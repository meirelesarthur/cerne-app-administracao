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

/// Dado de apoio de um [AppStatusCard], exibido abaixo do título com ícone
/// (dois por linha). Sem ícone, o rótulo é escrito ("Prioridade: Alta").
class AppStatusCardMeta {
  const AppStatusCardMeta({
    required this.label,
    required this.value,
    this.highlight = false,
    this.icon,
  });

  final String label;
  final String value;

  /// O ícone substitui o rótulo escrito (calendário no lugar de "Prazo:");
  /// o rótulo segue na semântica.
  final AppIconData? icon;

  /// Destaca o valor na cor de acento — para o dado que pede atenção
  /// (prioridade alta, atraso), sem virar mais um chip.
  final bool highlight;
}

/// Anatomias do [AppStatusCard]:
///
/// Todas seguem o padrão global de listagem: título na largura inteira,
/// dados de apoio com ícone (dois por linha) e o chip de status embaixo —
/// nada na lateral disputando espaço com o texto.
///
/// - [standard]: a das listas — rodapé com situação e ação pequena.
/// - [featured]: o registro em destaque de uma home — título e rodapé
///   maiores, situação numa faixa tingida ao lado do botão de ação.
/// - [compact]: o "próximo da fila" logo abaixo do destaque — título, uma
///   linha de dados e o status, sem rodapé.
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
/// Anatomia: título grande na largura inteira, descrição e legenda
/// opcionais, dados de apoio com ícone ([meta], dois por linha), o chip de
/// status embaixo e o rodapé de situação e ação. Superfície
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

  /// Dados de apoio com ícone, no máximo dois por linha — o mesmo padrão de
  /// [AppRecordTile]. Meta sem ícone escreve o rótulo ("Tipo: Pecuário").
  Widget _metaGrid(AppSemanticColors semantic, List<AppStatusCardMeta> items) {
    Widget cell(AppStatusCardMeta item) {
      final color = item.highlight ? semantic.toneRedFg : semantic.fgMuted;
      return Semantics(
        label: '${item.label}: ${item.value}',
        excludeSemantics: true,
        child: Row(
          children: [
            if (item.icon != null) ...[
              AppIcon(item.icon!, size: AppSize.iconXs, color: color),
              const SizedBox(width: AppSpacing.space1),
            ],
            Flexible(
              child: Text(
                item.icon == null ? '${item.label}: ${item.value}' : item.value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: AppTypography.base,
                  fontWeight: item.highlight
                      ? AppTypography.weightSemibold
                      : AppTypography.weightNormal,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < items.length; i += 2) ...[
          if (i > 0) const SizedBox(height: AppSpacing.space1),
          Row(
            children: [
              Expanded(child: cell(items[i])),
              const SizedBox(width: AppSpacing.space3),
              Expanded(
                child: i + 1 < items.length
                    ? cell(items[i + 1])
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ],
      ],
    );
  }

  /// Rodapé: situação do momento à esquerda e ação rápida à direita. No
  /// destaque a situação vira faixa tingida e o botão é do tamanho padrão.
  Widget _footer(AppSemanticColors semantic, {required bool featured}) {
    final situation = this.situation;
    final action = this.action;
    final situationRow = situation == null
        ? const SizedBox.shrink()
        : Row(
            mainAxisAlignment: featured
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
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
                  textAlign: featured ? TextAlign.center : TextAlign.start,
                  style: TextStyle(
                    fontSize: featured ? AppTypography.base : AppTypography.sm,
                    fontWeight: AppTypography.weightSemibold,
                    color: _toneColor(semantic, situation.tone),
                  ),
                ),
              ),
            ],
          );

    return Row(
      children: [
        Expanded(
          child: featured && situation != null
              ? Container(
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
                    borderRadius: BorderRadius.circular(AppRadius.mdPlus),
                  ),
                  child: situationRow,
                )
              : situationRow,
        ),
        if (action != null) ...[
          const SizedBox(width: AppSpacing.space3),
          AppButton(
            size: featured ? AppButtonSize.md : AppButtonSize.sm,
            variant: action.primary
                ? AppButtonVariant.primary
                : AppButtonVariant.secondary,
            leftIcon: AppIcon(
              action.icon,
              size: AppSize.iconSm,
              color: action.primary ? semantic.ctaFg : semantic.fgDefault,
            ),
            onPressed: action.onPressed,
            child: Text(action.label),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final radius = BorderRadius.circular(AppRadius.tile);
    final compact = variant == AppStatusCardVariant.compact;
    final featured = variant == AppStatusCardVariant.featured;
    // O "próximo da fila" mostra só a primeira linha de dados.
    final visibleMeta = compact ? meta.take(2).toList() : meta;
    final hasFooter = !compact && (situation != null || action != null);

    final content = Container(
      padding: const EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(color: semantic.bgRaised, borderRadius: radius),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // O título usa a largura inteira: status e dados ficam embaixo,
          // nunca na lateral disputando espaço com o texto.
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: compact ? AppTypography.xl : AppTypography.xl2,
              fontWeight: AppTypography.weightMedium,
              height: compact
                  ? AppTypography.lineHeightSnug
                  : AppTypography.lineHeightTight,
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
          if (caption != null && !compact) ...[
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
          if (visibleMeta.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.space2),
            _metaGrid(semantic, visibleMeta),
          ],
          const SizedBox(height: AppSpacing.space2),
          Align(
            alignment: Alignment.centerLeft,
            child: AppChip(tone: statusTone, child: Text(statusLabel)),
          ),
          if (hasFooter) ...[
            SizedBox(height: featured ? AppSpacing.space4 : AppSpacing.space3),
            _footer(semantic, featured: featured),
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
