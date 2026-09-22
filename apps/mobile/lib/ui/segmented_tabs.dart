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
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  /// Altura do segmento no Figma.
  static const double _itemHeight = AppSpacing.space10;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.space1),
      decoration: BoxDecoration(
        color: semantic.bgTrack,
        borderRadius: BorderRadius.circular(AppRadius.tile),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++) ...[
            if (i > 0) const SizedBox(width: AppSpacing.space1),
            Expanded(
              child: AppPressable(
                semanticLabel: labels[i],
                selected: i == selectedIndex,
                onPressed: () => onChanged(i),
                borderRadius: BorderRadius.circular(AppRadius.lgPlus),
                child: Container(
                  height: _itemHeight,
                  alignment: Alignment.center,
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
              ),
            ),
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
        name: 'Abas da home ADM',
        builder: (context) =>
            const _SegmentedTabsPreview(labels: ['Início', 'Carteira', 'Apps']),
      ),
    ],
  );
}

class _SegmentedTabsPreview extends StatefulWidget {
  const _SegmentedTabsPreview({required this.labels});

  final List<String> labels;

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
      ),
    );
  }
}
