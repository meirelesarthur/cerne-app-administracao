import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import '../design/generated/app_layout.dart';
import '../design/theme/app_theme_extension.dart';
import 'package:cerne_app/design/generated/app_colors.dart';

/// Espelha `Spinner.tsx` — indicador de carregamento circular, cor herdada do contexto
/// (`currentColor` no React) via [color] explícito ou `IconTheme`/`DefaultTextStyle` do pai.
class AppSpinner extends StatelessWidget {
  const AppSpinner({super.key, this.size = AppSize.iconMd, this.color});

  final double size;
  final Color? color;

  /// Espessura do traço — a mesma do sistema de ícones, para o indicador não
  /// destoar do glifo que ele costuma substituir dentro de um botão.
  static const double _strokeWidth = AppSize.iconStroke;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: _strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ??
              IconTheme.of(context).color ??
              DefaultTextStyle.of(context).style.color ??
              AppColors.black,
        ),
      ),
    );
  }
}

WidgetbookComponent buildSpinnerWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'Spinner',
    useCases: [
      WidgetbookUseCase(
        name: 'Tamanhos',
        builder: (context) {
          final semantic = Theme.of(context).extension<AppSemanticColors>()!;
          return Center(
            child: Wrap(
              spacing: 16,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                AppSpinner(size: 16, color: semantic.accentDefault),
                AppSpinner(color: semantic.accentDefault),
                AppSpinner(size: 32, color: semantic.accentDefault),
              ],
            ),
          );
        },
      ),
    ],
  );
}
