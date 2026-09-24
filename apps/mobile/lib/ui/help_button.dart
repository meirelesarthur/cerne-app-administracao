import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import '../design/generated/app_layout.dart';
import '../design/generated/app_radius.dart';
import '../design/generated/app_spacing.dart';
import '../design/theme/app_theme_extension.dart';
import 'app_icon.dart';
import 'bottom_sheet.dart';
import 'pressable.dart';

/// "O que é este número?" — um ícone de informação discreto ao lado do
/// título de uma métrica que abre uma folha curta com a definição.
///
/// Existe para o painel dispensar suporte: siglas e cálculos (GMD, custo
/// médio por kg, adoção, vida útil consumida) ficam explicados onde aparecem,
/// sem poluir o card com texto. O glifo é pequeno, mas o alvo de toque é o
/// mínimo de 48dp do [AppPressable].
class AppHelpButton extends StatelessWidget {
  const AppHelpButton({super.key, required this.title, required this.text});

  /// Título da folha — normalmente o nome da métrica.
  final String title;

  /// Definição em uma a três frases: o que é, como se calcula e o que é bom.
  final String text;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    return AppPressable(
      semanticLabel: 'O que é $title?',
      borderRadius: BorderRadius.circular(AppRadius.full),
      onPressed: () => showAppHelpSheet(context, title: title, text: text),
      child: AppIcon(
        AppIcons.helpCircle,
        size: AppSize.iconSm,
        color: semantic.fgMuted,
      ),
    );
  }
}

/// A folha do [AppHelpButton], avulsa para quem precisar abrir a mesma
/// explicação a partir de outro gatilho.
Future<void> showAppHelpSheet(
  BuildContext context, {
  required String title,
  required String text,
}) {
  final semantic = Theme.of(context).extension<AppSemanticColors>()!;
  return showAppBottomSheet<void>(
    context,
    title: title,
    child: Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.space4),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: semantic.fgDefault),
      ),
    ),
  );
}

WidgetbookComponent buildHelpButtonWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'HelpButton',
    useCases: [
      WidgetbookUseCase(
        name: 'Ao lado de uma métrica',
        builder: (context) => const Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('GMD médio'),
              SizedBox(width: AppSpacing.space1),
              AppHelpButton(
                title: 'GMD médio',
                text:
                    'Ganho médio diário: quantos quilos cada animal ganha por '
                    'dia, em média. Acima do previsto é bom.',
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
