import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'review_list.dart';
import 'segmented_tabs.dart';
import '../design/generated/app_spacing.dart';

/// Os campos de leitura de uma etapa do cadastro original, sob uma aba de
/// [AppReviewTabs].
class AppReviewTabGroup {
  const AppReviewTabGroup({required this.label, required this.items});

  /// Rótulo da aba — o título da etapa ([FeatureFormStep.title]) que originou
  /// este grupo de campos.
  final String label;
  final List<AppReviewItem> items;
}

/// Visualização de um registro cujo cadastro nasceu em etapas
/// (`FeatureDefinition.steps`, arquétipo `Cadastro steps` do Figma
/// `54349:1990`): em vez de despejar todo campo numa lista só, cada etapa
/// vira uma aba do [AppSegmentedTabs] — a mesma divisão que orientou o
/// preenchimento orienta também a leitura, e uma ficha de doze campos deixa
/// de ser uma rolagem só para virar três ou quatro telas curtas.
///
/// A etapa de revisão (sem campos nem coleções — [FeatureFormStep] vazia,
/// usada só durante o preenchimento) nunca vira aba: quem monta os grupos
/// (`_recordStepGroups` em `mapped_feature_screen.dart`) já a descarta.
/// Cadastros sem etapas nunca chegam a montar [AppReviewTabGroup]s — quem
/// chama usa [AppReviewList] direto, como sempre.
class AppReviewTabs extends StatefulWidget {
  const AppReviewTabs({super.key, required this.groups});

  final List<AppReviewTabGroup> groups;

  @override
  State<AppReviewTabs> createState() => _AppReviewTabsState();
}

class _AppReviewTabsState extends State<AppReviewTabs> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final groups = widget.groups;
    if (groups.isEmpty) return const SizedBox.shrink();
    final index = _index.clamp(0, groups.length - 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSegmentedTabs(
          labels: [for (final group in groups) group.label],
          selectedIndex: index,
          onChanged: (next) => setState(() => _index = next),
        ),
        const SizedBox(height: AppSpacing.space3),
        AppReviewList(items: groups[index].items),
      ],
    );
  }
}

WidgetbookComponent buildReviewTabsWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'ReviewTabs',
    useCases: [
      WidgetbookUseCase(
        name: 'Registro de cadastro em etapas',
        builder: (context) => const Padding(
          padding: EdgeInsets.all(AppSpacing.space4),
          child: AppReviewTabs(
            groups: [
              AppReviewTabGroup(
                label: 'Identificação',
                items: [
                  AppReviewItem(label: 'Responsável', value: 'João Oliveira'),
                  AppReviewItem(label: 'Área', value: 'Pasto Norte'),
                ],
              ),
              AppReviewTabGroup(
                label: 'Marcação',
                items: [
                  AppReviewItem(label: 'Tipo de marcação', value: 'Amostragem'),
                  AppReviewItem(label: 'Descrição', value: 'Foco de erosão'),
                ],
              ),
              AppReviewTabGroup(
                label: 'Safra e custo',
                items: [
                  AppReviewItem(
                    label: 'Centro de custo',
                    value: 'Centro Agrícola',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
