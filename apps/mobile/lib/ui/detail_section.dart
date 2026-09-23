import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'app_icon.dart';
import '../design/generated/app_colors.dart';
import '../design/generated/app_layout.dart';
import '../design/generated/app_radius.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';

/// Tom do bloco de uma [AppDetailSection]: [neutral] é o cinza de leitura;
/// [warning] destaca o que protege a pessoa (instruções de segurança);
/// [danger], o que encerra ou refaz o trabalho (cancelamento, retrabalho).
enum AppDetailSectionTone { neutral, warning, danger }

/// Agrupador de dados de uma visualização em tela cheia (detalhe da OS e
/// afins): ícone em bolha + título de 16 px acima de um bloco cinza
/// ([AppSemanticColors.bgSheet]) que assenta sobre a folha branca.
///
/// Pensado para quem lê no campo, com pouca familiaridade com telas densas:
/// cada grupo tem um ícone que o identifica sem ler, o título é maior que os
/// rótulos e o conteúdo fica num bloco próprio — em vez de uma coluna única de
/// linhas pequenas e iguais. `count` mostra quantos itens o grupo tem ("3")
/// para listas de recursos.
class AppDetailSection extends StatelessWidget {
  const AppDetailSection({
    super.key,
    required this.icon,
    required this.title,
    required this.child,
    this.count,
    this.tone = AppDetailSectionTone.neutral,
  });

  /// Sempre uma entrada de `AppIcons` (Hugeicons, a família do app).
  final AppIconData icon;
  final String title;
  final Widget child;
  final int? count;
  final AppDetailSectionTone tone;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final (
      Color iconColor,
      Color bubble,
      Color block,
      Color? border,
    ) = switch (tone) {
      AppDetailSectionTone.neutral => (
        semantic.accentDefault,
        semantic.accentSubtle,
        semantic.bgSheet,
        null,
      ),
      AppDetailSectionTone.warning => (
        AppColors.feedbackWarningText,
        AppColors.feedbackWarningBg,
        AppColors.feedbackWarningBg,
        AppColors.feedbackWarningBorder,
      ),
      AppDetailSectionTone.danger => (
        AppColors.feedbackErrorText,
        AppColors.feedbackErrorBg,
        AppColors.feedbackErrorBg,
        AppColors.feedbackErrorBorder,
      ),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              width: AppSpacing.space9,
              height: AppSpacing.space9,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: bubble, shape: BoxShape.circle),
              child: AppIcon(icon, size: AppSize.iconMd, color: iconColor),
            ),
            const SizedBox(width: AppSpacing.space3),
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: AppTypography.xl,
                    fontWeight: AppTypography.weightSemibold,
                    height: AppTypography.lineHeightHeading,
                    color: semantic.fgHeading,
                  ),
                ),
              ),
            ),
            if (count != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.twoHalf,
                  vertical: AppSpacing.half,
                ),
                decoration: BoxDecoration(
                  color: semantic.bgSheet,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: AppTypography.md,
                    fontWeight: AppTypography.weightSemibold,
                    color: semantic.fgMuted,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.space3),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space4,
            vertical: AppSpacing.space1,
          ),
          decoration: BoxDecoration(
            color: block,
            borderRadius: BorderRadius.circular(AppRadius.surface),
            border: border == null ? null : Border.all(color: border),
          ),
          child: child,
        ),
      ],
    );
  }
}

/// Um par rótulo/valor dentro de [AppDetailFields]: rótulo pequeno acima,
/// valor grande abaixo e, opcionalmente, uma linha de apoio (data e hora).
class AppDetailField {
  const AppDetailField({
    required this.label,
    required this.value,
    this.caption,
  });

  final String label;
  final String value;
  final String? caption;
}

/// Campos de leitura empilhados dentro de uma [AppDetailSection], separados
/// por uma linha fina. `columns: 2` põe pares curtos lado a lado (prazo e
/// prioridade, fazenda e talhão) — o último campo de uma contagem ímpar ocupa
/// a linha inteira.
class AppDetailFields extends StatelessWidget {
  const AppDetailFields({super.key, required this.fields, this.columns = 1});

  final List<AppDetailField> fields;
  final int columns;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final rows = <List<AppDetailField>>[
      for (var i = 0; i < fields.length; i += columns)
        fields.sublist(i, (i + columns).clamp(0, fields.length)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var r = 0; r < rows.length; r++) ...[
          if (r > 0) Divider(height: 1, color: semantic.borderDefault),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.space3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var c = 0; c < rows[r].length; c++) ...[
                  if (c > 0) const SizedBox(width: AppSpacing.space4),
                  Expanded(child: _FieldCell(field: rows[r][c])),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _FieldCell extends StatelessWidget {
  const _FieldCell({required this.field});

  final AppDetailField field;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          field.label,
          style: TextStyle(
            fontSize: AppTypography.base,
            color: semantic.fgMuted,
          ),
        ),
        const SizedBox(height: AppSpacing.half),
        Text(
          field.value,
          style: TextStyle(
            fontSize: AppTypography.xl,
            fontWeight: AppTypography.weightSemibold,
            height: AppTypography.lineHeightSnug,
            color: semantic.fgDefault,
          ),
        ),
        if (field.caption != null) ...[
          const SizedBox(height: AppSpacing.half),
          Text(
            field.caption!,
            style: TextStyle(
              fontSize: AppTypography.base,
              color: semantic.fgMuted,
            ),
          ),
        ],
      ],
    );
  }
}

/// Lista simples dentro de uma [AppDetailSection] — um item por linha, com
/// marcador e separador, no lugar de "· item" em texto corrido.
class AppDetailList extends StatelessWidget {
  const AppDetailList({
    super.key,
    required this.items,
    this.emptyLabel = 'Nada informado.',
  });

  final List<String> items;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final style = TextStyle(
      fontSize: AppTypography.lg,
      height: AppTypography.lineHeightSnug,
      color: semantic.fgDefault,
    );

    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.space3),
        child: Text(emptyLabel, style: style.copyWith(color: semantic.fgMuted)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) Divider(height: 1, color: semantic.borderDefault),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.space3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.threeQuarter),
                  child: AppIcon(
                    AppIcons.checkCircle2,
                    size: AppSize.iconSm,
                    color: semantic.accentDefault,
                  ),
                ),
                const SizedBox(width: AppSpacing.space3),
                Expanded(child: Text(items[i], style: style)),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Texto corrido dentro de uma [AppDetailSection] (instruções, motivos).
class AppDetailText extends StatelessWidget {
  const AppDetailText(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.space3),
      child: Text(
        text,
        style: TextStyle(
          fontSize: AppTypography.lg,
          height: AppTypography.lineHeightNormal,
          color: semantic.fgDefault,
        ),
      ),
    );
  }
}

WidgetbookComponent buildDetailSectionWidgetbookComponent() {
  Widget sheet(Widget child) => ColoredBox(
    color: AppColors.neutral0,
    child: Center(
      child: SizedBox(
        width: 360,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space4),
          child: child,
        ),
      ),
    ),
  );

  return WidgetbookComponent(
    name: 'DetailSection',
    useCases: [
      WidgetbookUseCase(
        name: 'Campos',
        builder: (context) => sheet(
          const AppDetailSection(
            icon: AppIcons.fileSignature,
            title: 'Solicitação e autorização',
            child: AppDetailFields(
              fields: [
                AppDetailField(
                  label: 'Solicitado por',
                  value: 'Marina Costa',
                  caption: '18/09/2026 às 07:40',
                ),
                AppDetailField(
                  label: 'Autorizado por',
                  value: 'Paulo Henrique',
                  caption: '18/09/2026 às 09:15',
                ),
                AppDetailField(label: 'Responsável', value: 'João Batista'),
              ],
            ),
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Duas colunas',
        builder: (context) => sheet(
          const AppDetailSection(
            icon: AppIcons.ordemServico,
            title: 'Serviço',
            child: AppDetailFields(
              columns: 2,
              fields: [
                AppDetailField(label: 'Prazo', value: '25/09/2026'),
                AppDetailField(label: 'Prioridade', value: 'Alta'),
                AppDetailField(label: 'Fazenda', value: 'Santa Rita'),
                AppDetailField(label: 'Área / talhão', value: 'Talhão 7'),
                AppDetailField(label: 'Tipo de serviço', value: 'Pulverização'),
              ],
            ),
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Lista com contagem',
        builder: (context) => sheet(
          const AppDetailSection(
            icon: AppIcons.tractor,
            title: 'Máquinas',
            count: 2,
            child: AppDetailList(
              items: ['Trator John Deere 6110J', 'Pulverizador Jacto 2000 L'],
            ),
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Tons',
        builder: (context) => sheet(
          const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppDetailSection(
                icon: AppIcons.shieldAlert,
                title: 'Instruções de segurança',
                tone: AppDetailSectionTone.warning,
                child: AppDetailText(
                  'Use máscara e luvas. Não aplicar com vento acima de 10 km/h.',
                ),
              ),
              SizedBox(height: AppSpacing.space6),
              AppDetailSection(
                icon: AppIcons.alertCircle,
                title: 'Motivo do cancelamento',
                tone: AppDetailSectionTone.danger,
                child: AppDetailText('Chuva prevista para a semana toda.'),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
