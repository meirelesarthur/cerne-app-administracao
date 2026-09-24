import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import '../design/generated/app_colors.dart';
import '../design/generated/app_radius.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';
import 'pressable.dart';

/// Seletor de seção dentro de uma mesma tela (ex.: abas de um dashboard) sem
/// trocar de rota. Diferente de uma bottom navigation: é um controle local,
/// usado quando várias visões somente-leitura precisam conviver numa única
/// tela em vez de fragmentar em N rotas.
///
/// Anatomia do padrão global (Figma `54333:417`): trilho
/// [AppSemanticColors.bgTrack] com raio [AppRadius.tile] (20) e `p 4`, gap 4;
/// cada segmento com 40 px de altura e raio [AppRadius.lgPlus] (16); o ativo em
/// [AppSemanticColors.accentDefault] com rótulo na cor de contraste, os demais
/// transparentes com rótulo abafado. Rótulo de 14 px SemiBold nos dois estados
/// — a referência não muda o peso ao selecionar, só a cor.
///
/// Usa `AppPressable` para o alvo de toque/foco/semântica de cada segmento
/// (Lei 1 — nenhuma superfície interativa nova fora do catálogo).
class AppSegmentedTabs extends StatelessWidget {
  const AppSegmentedTabs({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
    this.scrollable = false,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  /// `true` para filtros de listagem: cada segmento ganha a largura do
  /// próprio rótulo e o trilho rola na horizontal, em vez de dividir a
  /// largura em partes iguais — rótulos longos ("Em execução") não truncam
  /// numa tela estreita. O padrão preserva o seletor de seções igualitário.
  final bool scrollable;

  /// Altura do segmento no Figma.
  static const double _itemHeight = AppSpacing.space10;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    Widget segment(int i) => AppPressable(
      semanticLabel: labels[i],
      selected: i == selectedIndex,
      onPressed: () => onChanged(i),
      borderRadius: BorderRadius.circular(AppRadius.lgPlus),
      child: Container(
        height: _itemHeight,
        alignment: Alignment.center,
        padding: scrollable
            ? const EdgeInsets.symmetric(horizontal: AppSpacing.space4)
            : EdgeInsets.zero,
        decoration: BoxDecoration(
          color: i == selectedIndex
              ? semantic.accentDefault
              : AppColors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.lgPlus),
        ),
        child: Text(
          labels[i],
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: AppTypography.md,
            fontWeight: AppTypography.weightSemibold,
            color: i == selectedIndex
                ? semantic.accentContrast
                : semantic.fgMuted,
          ),
        ),
      ),
    );

    final decoration = BoxDecoration(
      color: semantic.bgTrack,
      borderRadius: BorderRadius.circular(AppRadius.tile),
    );

    if (scrollable) {
      return Container(
        decoration: decoration,
        clipBehavior: Clip.antiAlias,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(AppSpacing.space1),
          child: Row(
            children: [
              for (var i = 0; i < labels.length; i++) ...[
                if (i > 0) const SizedBox(width: AppSpacing.space1),
                segment(i),
              ],
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.space1),
      decoration: decoration,
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++) ...[
            if (i > 0) const SizedBox(width: AppSpacing.space1),
            Expanded(child: segment(i)),
          ],
        ],
      ),
    );
  }
}

WidgetbookComponent buildSegmentedTabsWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'SegmentedTabs',
    useCases: [
      WidgetbookUseCase(
        name: 'Quatro seções',
        builder: (context) => const _SegmentedTabsPreview(
          labels: ['Visão geral', 'Mapa', 'Nutrição', 'Relatórios'],
        ),
      ),
      WidgetbookUseCase(
        name: 'Filtros roláveis',
        builder: (context) => const _SegmentedTabsPreview(
          labels: ['Todas', 'Aguardando', 'Em execução', 'Finalizadas'],
          scrollable: true,
        ),
      ),
      WidgetbookUseCase(
        name: 'Três períodos',
        builder: (context) =>
            const _SegmentedTabsPreview(labels: ['Hoje', 'Semana', 'Mês']),
      ),
    ],
  );
}

class _SegmentedTabsPreview extends StatefulWidget {
  const _SegmentedTabsPreview({required this.labels, this.scrollable = false});

  final List<String> labels;
  final bool scrollable;

  @override
  State<_SegmentedTabsPreview> createState() => _SegmentedTabsPreviewState();
}

class _SegmentedTabsPreviewState extends State<_SegmentedTabsPreview> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.space4),
      child: AppSegmentedTabs(
        labels: widget.labels,
        selectedIndex: _index,
        onChanged: (i) => setState(() => _index = i),
        scrollable: widget.scrollable,
      ),
    );
  }
}
