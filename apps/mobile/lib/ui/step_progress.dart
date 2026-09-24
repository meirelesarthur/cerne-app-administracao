import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import '../design/generated/app_radius.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';

/// Régua de etapas do padrão global — o indicador do frame
/// `Cadastro steps (sem navbar)` do Figma (`54349:2076`).
///
/// Anatomia medida: N segmentos de largura igual e 6 px de altura, separados
/// por `gap 8`; os concluídos em [AppSemanticColors.accentDefault], os
/// pendentes na mesma cor rebaixada. Acima da régua, "Etapa 2 de 4 · Nome" em
/// texto (auditoria de UX): só a régua não dizia onde a pessoa estava.
/// [label] é o nome da etapa atual, opcional.
///
/// **Não confundir com `AppStepper`**, que é o incrementador numérico
/// (`− valor +`) dos formulários de campo. Nomes próximos, papéis opostos: um
/// é navegação de fluxo, o outro é entrada de dado.
class AppStepProgress extends StatelessWidget {
  const AppStepProgress({
    super.key,
    required this.total,
    required this.current,
    this.label,
  }) : assert(total > 0, 'a régua precisa de ao menos uma etapa'),
       assert(current >= 0, 'a etapa atual não pode ser negativa');

  /// Quantidade de etapas do fluxo.
  final int total;

  /// Etapas já concluídas — índice 1 pinta o primeiro segmento. Valores acima
  /// de [total] são tratados como fluxo completo.
  final int current;

  /// Nome da etapa atual ("Área e armazéns"), exibido depois do contador.
  final String? label;

  /// Altura do segmento no Figma.
  static const double trackHeight = 6;

  /// `gap 8` entre segmentos.
  static const double gap = AppSpacing.space2;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final done = current.clamp(0, total);

    final counter = 'Etapa $done de $total';
    final text = label == null ? counter : '$counter · $label';

    return Semantics(
      label: text,
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: AppTypography.md,
              fontWeight: AppTypography.weightSemibold,
              color: semantic.fgSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.space2),
          Row(
            children: [
              for (var i = 0; i < total; i++) ...[
                if (i > 0) const SizedBox(width: gap),
                Expanded(
                  child: Container(
                    height: trackHeight,
                    decoration: BoxDecoration(
                      color: i < done
                          ? semantic.accentDefault
                          : semantic.accentSubtle,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

WidgetbookComponent buildStepProgressWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'StepProgress',
    useCases: [
      WidgetbookUseCase(
        name: 'Segunda de quatro etapas',
        builder: (context) => const Padding(
          padding: EdgeInsets.all(AppSpacing.space4),
          child: AppStepProgress(
            total: 4,
            current: 2,
            label: 'Área e armazéns',
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Início do fluxo',
        builder: (context) => const Padding(
          padding: EdgeInsets.all(AppSpacing.space4),
          child: AppStepProgress(total: 3, current: 0),
        ),
      ),
      WidgetbookUseCase(
        name: 'Fluxo completo',
        builder: (context) => const Padding(
          padding: EdgeInsets.all(AppSpacing.space4),
          child: AppStepProgress(total: 3, current: 3),
        ),
      ),
    ],
  );
}
