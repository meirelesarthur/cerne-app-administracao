import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'app_icon.dart';
import 'pressable.dart';
import '../design/generated/app_layout.dart';
import '../design/generated/app_radius.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';

/// Espelha `Heading.tsx` — evita uso de `<h1>`–`<h6>` cru em páginas (Lei 1).
/// `level` equivale à prop `level: 1 | 2 | 3 | 4` do React; o próprio widget
/// se anuncia como cabeçalho via `Semantics(header: true)`.
///
/// A escala é a do padrão global do Figma (`54300-2458`), bem mais contida que
/// a anterior: 20 (título de tela, 54349:2379), 18 (título de bloco,
/// 54349:2084), 16 (grupo de formulário, 54349:2097) e 14 (título de card,
/// 54349:3206) — todos SemiBold, porque a referência não usa Bold em nenhum
/// cabeçalho de conteúdo.
enum AppHeadingLevel { h1, h2, h3, h4 }

class AppHeading extends StatelessWidget {
  const AppHeading({
    super.key,
    this.level = AppHeadingLevel.h2,
    required this.child,
    this.style,
  });

  final AppHeadingLevel level;
  final Widget child;
  final TextStyle? style;

  double get _fontSize => switch (level) {
    AppHeadingLevel.h1 => AppTypography.xlPlus2,
    AppHeadingLevel.h2 => AppTypography.xlPlus,
    AppHeadingLevel.h3 => AppTypography.xl,
    AppHeadingLevel.h4 => AppTypography.md,
  };

  Color _color(AppSemanticColors semantic) => switch (level) {
    AppHeadingLevel.h1 => semantic.fgDefault,
    AppHeadingLevel.h2 || AppHeadingLevel.h3 => semantic.fgHeading,
    AppHeadingLevel.h4 => semantic.fgDefault,
  };

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return Semantics(
      header: true,
      child: DefaultTextStyle.merge(
        style: TextStyle(
          fontSize: _fontSize,
          fontWeight: AppTypography.weightSemibold,
          height: AppTypography.lineHeightHeading,
          color: _color(semantic),
        ).merge(style),
        child: child,
      ),
    );
  }
}

/// Cabeçalho de seção do padrão global — as duas leituras do Figma:
/// `54349:3164` (seta de voltar à esquerda + rótulo) e `54333:422` (rótulo +
/// chevron de "ver tudo" à direita).
///
/// Rótulo de 16 px **Medium** com altura 1.42 — não Bold. A referência
/// distingue seção de cabeçalho justamente pelo peso: o título de bloco é
/// SemiBold (`AppHeading`), a seção é Medium.
class AppSectionTitle extends StatelessWidget {
  const AppSectionTitle({
    super.key,
    required this.child,
    this.leading,
    this.trailing,
    this.onTap,
    this.semanticLabel,
  });

  final Widget child;

  /// Ícone de 24 px à esquerda do rótulo — no Figma, o voltar do módulo.
  final AppIconData? leading;

  /// Ícone de 24 px à direita, alinhado à borda — o "ver tudo".
  final AppIconData? trailing;

  /// Torna a linha inteira tocável. Exigido quando há [trailing].
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    final label = DefaultTextStyle.merge(
      style: TextStyle(
        fontSize: AppTypography.xl,
        fontWeight: AppTypography.weightMedium,
        height: AppTypography.lineHeightSection,
        color: semantic.fgSection,
      ),
      child: child,
    );

    // Sem `trailing` a linha encolhe no conteúdo: o cabeçalho de seção também
    // é usado dentro de linhas que não dão largura finita (o `Row` de um
    // cabeçalho de bloco, por exemplo), e `Expanded` ali estoura o layout.
    // Com `trailing`, o ícone precisa encostar na borda direita — aí a linha
    // ocupa a largura toda e o rótulo é quem cede.
    final hasTrailing = trailing != null;
    final row = Row(
      mainAxisSize: hasTrailing ? MainAxisSize.max : MainAxisSize.min,
      children: [
        if (leading != null) ...[
          AppIcon(leading!, size: AppSize.iconLg, color: semantic.fgSection),
          const SizedBox(width: AppSpacing.space2),
        ],
        if (hasTrailing) Expanded(child: label) else Flexible(child: label),
        if (hasTrailing) ...[
          const SizedBox(width: AppSpacing.space2),
          AppIcon(trailing!, size: AppSize.iconLg, color: semantic.fgSection),
        ],
      ],
    );

    final header = Semantics(header: true, child: row);
    if (onTap == null) return header;

    return AppPressable(
      semanticLabel: semanticLabel ?? '',
      onPressed: onTap,
      minTouchTarget: false,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: header,
    );
  }
}

WidgetbookComponent buildHeadingWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'Heading',
    useCases: [
      WidgetbookUseCase(
        name: 'Níveis',
        builder: (context) => const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppHeading(
                level: AppHeadingLevel.h1,
                child: Text('Título nível 1'),
              ),
              SizedBox(height: AppSpacing.space3),
              AppHeading(child: Text('Título nível 2')),
              SizedBox(height: AppSpacing.space3),
              AppHeading(
                level: AppHeadingLevel.h3,
                child: Text('Título nível 3'),
              ),
              SizedBox(height: AppSpacing.space3),
              AppHeading(
                level: AppHeadingLevel.h4,
                child: Text('Título nível 4'),
              ),
            ],
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'SectionTitle',
        builder: (context) => const Padding(
          padding: EdgeInsets.all(AppSpacing.space4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppSectionTitle(child: Text('Acesso rápido')),
              SizedBox(height: AppSpacing.space4),
              AppSectionTitle(
                leading: AppIcons.chevronLeft,
                child: Text('Confinamento'),
              ),
            ],
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'SectionTitle com "ver tudo"',
        builder: (context) => Padding(
          padding: const EdgeInsets.all(AppSpacing.space4),
          child: AppSectionTitle(
            trailing: AppIcons.chevronRight,
            onTap: () {},
            semanticLabel: 'Ver todos os parceiros de crédito',
            child: const Text('Parceiros de crédito'),
          ),
        ),
      ),
    ],
  );
}
