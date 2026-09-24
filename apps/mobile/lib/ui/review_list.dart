import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:widgetbook/widgetbook.dart';

import 'app_icon.dart';
import 'field_capsule.dart';
import 'form_field.dart';
import 'icon_button.dart';
import '../design/generated/app_layout.dart';
import '../design/generated/app_radius.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';

/// Um par rótulo/valor de uma visualização em modo leitura — revisão de
/// cadastro ou o detalhe de um registro já gravado.
class AppReviewItem {
  const AppReviewItem({
    required this.label,
    required this.value,
    this.emphasis = false,
    this.copyable = true,
  });

  final String label;

  /// Valor já formatado para leitura — a revisão não converte nada.
  final String value;

  /// Destaca a linha: usado para as coleções ("3 item(ns)"), que são o
  /// conteúdo que a pessoa mais precisa conferir antes de salvar.
  final bool emphasis;

  /// Mostra o botão de copiar ao lado do valor. `false` para valores curtos
  /// de estado ("Ativo", "Sim") onde copiar não agrega nada — a maioria dos
  /// campos de um registro real (código, descrição, responsável...) se
  /// beneficia de poder colar em outro lugar, então o padrão é `true`.
  final bool copyable;
}

/// Como [AppReviewList] desenha cada [AppReviewItem].
enum AppReviewStyle {
  /// Cartão abafado, rótulo em versalete acima do valor em negrito — o
  /// padrão histórico, usado no detalhe de um registro já gravado.
  card,

  /// Cápsula de input desabilitado (mesma forma/cor de [AppFieldCapsule],
  /// rótulo acima como em [AppFormField]) — o step de Revisão de um
  /// cadastro em andamento, onde o valor deve parecer o mesmo campo que a
  /// pessoa acabou de preencher, só travado, em vez de virar um resumo em
  /// outro formato visual.
  inputCapsule,
}

/// Campos de leitura de uma visualização — revisão final de um cadastro em
/// etapas (arquétipo `Cadastro steps` do Figma, `54349:1990`) **e** o detalhe
/// de um registro já gravado (`_showRecord` em `mapped_feature_screen.dart`,
/// `AppTransactionDetailSheet` e as demais fichas de detalhe do app —
/// fonte única, Lei 2).
///
/// [AppReviewStyle.card] (padrão): cada campo é seu próprio cartão — fundo
/// abafado, raio [AppRadius.xl2], rótulo em versalete pequeno acima do
/// valor, que aparece maior e mais legível abaixo — em vez de rótulo e valor
/// lado a lado. Uma linha de registro real pode ter um valor longo (um
/// endereço, um ID de operação); empilhar deixa os dois sempre legíveis, sem
/// truncar nem depender da largura disponível.
///
/// Quando o cadastro de origem declarou etapas
/// ([FeatureFormStep]/`FeatureDefinition.steps`), a visualização do registro
/// não usa esta lista sozinha: agrupa os campos por etapa e usa
/// [AppReviewTabs], que reaproveita [AppReviewList] por trás de cada aba.
class AppReviewList extends StatelessWidget {
  const AppReviewList({
    super.key,
    required this.items,
    this.emptyLabel,
    this.style = AppReviewStyle.card,
  });

  final List<AppReviewItem> items;

  /// Texto quando nada foi preenchido — em etapas anteriores tudo era
  /// opcional, e uma lista vazia sem explicação parece defeito.
  final String? emptyLabel;

  final AppReviewStyle style;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    if (items.isEmpty) {
      return Text(
        emptyLabel ?? 'Nada preenchido até aqui.',
        style: TextStyle(fontSize: AppTypography.sm, color: semantic.fgMuted),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < items.length; index++) ...[
          _ReviewRow(item: items[index], style: style),
          if (index < items.length - 1)
            const SizedBox(height: AppSpacing.space2),
        ],
      ],
    );
  }
}

class _ReviewRow extends StatefulWidget {
  const _ReviewRow({required this.item, required this.style});

  final AppReviewItem item;
  final AppReviewStyle style;

  @override
  State<_ReviewRow> createState() => _ReviewRowState();
}

class _ReviewRowState extends State<_ReviewRow> {
  bool _copied = false;
  Timer? _copiedTimer;

  @override
  void dispose() {
    _copiedTimer?.cancel();
    super.dispose();
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.item.value));
    if (!mounted) return;
    setState(() => _copied = true);
    _copiedTimer?.cancel();
    _copiedTimer = Timer(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  Widget? _copyButton(AppSemanticColors semantic) {
    if (!widget.item.copyable) return null;
    return AppIconButton(
      icon: AppIcon(
        _copied ? AppIcons.check : AppIcons.copy,
        size: AppSize.iconXs,
        color: _copied ? semantic.accentDefault : null,
      ),
      label: _copied
          ? '${widget.item.label} copiado'
          : 'Copiar ${widget.item.label}',
      size: AppIconButtonSize.sm,
      onPressed: _copy,
    );
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    return switch (widget.style) {
      AppReviewStyle.card => _buildCard(semantic),
      AppReviewStyle.inputCapsule => _buildInputCapsule(context, semantic),
    };
  }

  Widget _buildCard(AppSemanticColors semantic) {
    final item = widget.item;
    final copyButton = _copyButton(semantic);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.space3),
      decoration: BoxDecoration(
        color: semantic.bgSubtle,
        borderRadius: BorderRadius.circular(AppRadius.xl2),
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
                  item.label.toUpperCase(),
                  style: TextStyle(
                    fontSize: AppTypography.sm,
                    fontWeight: AppTypography.weightBold,
                    color: semantic.fgSubtle,
                    letterSpacing: 0.4,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.half),
                  child: Text(
                    item.value,
                    style: TextStyle(
                      fontSize: AppTypography.base,
                      fontWeight: AppTypography.weightSemibold,
                      color: item.emphasis
                          ? semantic.accentDefault
                          : semantic.fgDefault,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (copyButton != null) ...[
            const SizedBox(width: AppSpacing.space2),
            copyButton,
          ],
        ],
      ),
    );
  }

  /// Mesma cápsula/rótulo de um campo real (`AppFormField` + `AppFieldCapsule`),
  /// só com o valor como texto estático em vez de editor — o "input
  /// desabilitado" que a revisão do cadastro em andamento pede, para o campo
  /// parecer o mesmo que a pessoa acabou de preencher, travado, e não um
  /// resumo em outro formato visual.
  Widget _buildInputCapsule(BuildContext context, AppSemanticColors semantic) {
    final item = widget.item;
    final inputColors = appInputColors(context);

    return AppFormField(
      label: item.label,
      child: AppFieldCapsule(
        trailing: _copyButton(semantic),
        child: Text(
          item.value,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: AppTypography.xl,
            color: item.emphasis ? semantic.accentDefault : inputColors.muted,
          ),
        ),
      ),
    );
  }
}

WidgetbookComponent buildReviewListWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'ReviewList',
    useCases: [
      WidgetbookUseCase(
        name: 'Revisão de cadastro (input desabilitado)',
        builder: (context) => const Padding(
          padding: EdgeInsets.all(AppSpacing.space4),
          child: AppReviewList(
            style: AppReviewStyle.inputCapsule,
            items: [
              AppReviewItem(label: 'Responsável', value: 'João Oliveira'),
              AppReviewItem(label: 'Data', value: '08/09/2026'),
              AppReviewItem(label: 'Área', value: 'Pasto Norte'),
            ],
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Detalhe de registro (com cópia)',
        builder: (context) => const Padding(
          padding: EdgeInsets.all(AppSpacing.space4),
          child: AppReviewList(
            items: [
              AppReviewItem(label: 'Código', value: '1.01'),
              AppReviewItem(label: 'Descrição', value: 'Adubação de cobertura'),
              AppReviewItem(label: 'Status', value: 'Ativo', copyable: false),
            ],
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Nada preenchido',
        builder: (context) => const Padding(
          padding: EdgeInsets.all(AppSpacing.space4),
          child: AppReviewList(items: []),
        ),
      ),
    ],
  );
}
