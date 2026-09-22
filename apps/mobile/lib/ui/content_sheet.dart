import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'farm_selector.dart';
import 'field_capsule.dart';
import 'search_field.dart';
import '../design/generated/app_radius.dart';
import '../design/generated/app_spacing.dart';
import '../design/theme/app_theme_extension.dart';

/// A folha de conteúdo do padrão global — o `action-card` do Figma
/// (`54300-2458`), presente em **todos** os seis frames de referência.
///
/// Anatomia medida: superfície [AppSemanticColors.bgSheet] com raio
/// [AppRadius.surface] (20) **apenas nas quinas de cima**, ocupando a largura
/// inteira e assentando sobre o canvas. O que fica acima dela é a faixa de
/// contexto ([header]) — no Figma, o seletor de fazenda.
///
/// Por que é um componente e não `AppCard`: o cartão é um bloco de conteúdo
/// dentro da tela, com raio nos quatro cantos, margem lateral e sombra. Esta é
/// a **estrutura** da tela: sangra nas laterais e na base, não tem sombra e o
/// raio é assimétrico. Tratá-la como variante de `AppCard` colocaria duas
/// responsabilidades num widget (Lei 2) e faria toda tela repetir o mesmo
/// `ClipRRect` à mão — que é exatamente a duplicação que o padrão veio fechar.
class AppContentSheet extends StatelessWidget {
  const AppContentSheet({
    super.key,
    required this.child,
    this.header,
    this.padded = true,
    this.color,
  });

  /// Corpo da folha.
  final Widget child;

  /// Faixa de contexto branca acima da folha cinza. No Figma é o
  /// [AppFarmSelector]; em telas sem fazenda ativa, fica nulo e a folha começa
  /// no topo da área segura.
  final Widget? header;

  /// Aplica a margem lateral de 16 px do Figma ao [child]. Desligue quando o
  /// conteúdo precisa sangrar (trilhos horizontais, listas com divisor).
  final bool padded;

  /// Superfície da folha. Padrão [AppSemanticColors.bgSheet] — o cinza das
  /// telas de listagem, onde os blocos de conteúdo aparecem como `AppCard`
  /// branco por cima.
  ///
  /// As telas fundas passam [AppSemanticColors.bgSurface]: no arquétipo de
  /// cadastro a folha **é** a superfície branca, e os campos assentam direto
  /// nela em vez de num cartão interno com margem própria. Ver
  /// `AppPageScaffold`.
  final Color? color;

  /// Margem lateral do padrão global: conteúdo de 370 px num frame de 402.
  static const double contentInset = AppSpacing.space4;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final surface = color ?? semantic.bgSheet;

    final sheet = Container(
      width: double.infinity,
      // Recorta o conteúdo no raio: blocos que sangram nas laterais (a faixa de
      // contexto de fazenda, um banner, um trilho horizontal) desenham por cima
      // das quinas e apagam o arredondamento que define a folha.
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.surface),
        ),
      ),
      padding: padded
          ? const EdgeInsets.symmetric(horizontal: contentInset)
          : EdgeInsets.zero,
      child: AppInputSurface(backgroundColor: surface, child: child),
    );

    if (header == null) return sheet;

    // `ColoredBox` externo: sem ele, a quina arredondada da folha revela o
    // que quer que o widget-pai pinte atrás (o `bgCanvas` do Shell) — e no
    // tema claro esse cinza é quase idêntico ao `bgSheet`, o raio ficava
    // opticamente invisível, lendo como uma quina reta. A referência do
    // Figma mostra a quina revelando branco (a mesma faixa do seletor de
    // fazenda), criando o "detalhe" de camada — não uma terceira cor de
    // fundo. No gbMode, porém, `bgSurface` é idêntico a `bgSheet` (mesmo
    // verde escuro) — o branco do Figma não existe nesse tema, então a
    // faixa precisa da própria cor que o comentário acima descreve como
    // fallback natural (`bgCanvas`, mais escura) para não se fundir com a
    // folha abaixo.
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headerBg = isDark ? semantic.bgCanvas : semantic.bgSurface;

    return ColoredBox(
      color: headerBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppInputSurface(
            backgroundColor: headerBg,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                contentInset,
                AppSpacing.space2,
                contentInset,
                AppSpacing.space3,
              ),
              child: header!,
            ),
          ),
          Flexible(child: sheet),
        ],
      ),
    );
  }
}

WidgetbookComponent buildContentSheetWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'ContentSheet',
    useCases: [
      WidgetbookUseCase(
        name: 'Com faixa de contexto',
        builder: (context) => AppContentSheet(
          header: const AppFarmSelector(farmName: 'Fazenda Agro Pillatti'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.space4),
              AppSearchField(onTap: () {}),
              const SizedBox(height: AppSpacing.space4),
              const Text('Corpo da folha'),
              const SizedBox(height: AppSpacing.space20),
            ],
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Sem faixa (tela funda)',
        builder: (context) => const AppContentSheet(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: AppSpacing.space4),
              Text('Conteúdo de uma tela sem contexto de fazenda'),
              SizedBox(height: AppSpacing.space20),
            ],
          ),
        ),
      ),
    ],
  );
}
