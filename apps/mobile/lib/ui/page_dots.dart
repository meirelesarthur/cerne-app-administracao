import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import '../design/generated/app_motion.dart';
import '../design/generated/app_layout.dart';
import '../design/generated/app_radius.dart';
import '../design/generated/app_spacing.dart';
import '../design/theme/app_theme_extension.dart';
import 'package:cerne_app/design/generated/app_colors.dart';

/// Espelha `PageDots.tsx` — indicador de páginas (carrossel/onboarding): dots
/// pequenos, o ativo alonga em pílula na cor accent. Interativo quando
/// [onSelect] é fornecido.
class AppPageDots extends StatelessWidget {
  const AppPageDots({
    super.key,
    required this.count,
    required this.active,
    this.onSelect,
  });

  /// Total de páginas.
  final int count;

  /// Índice da página ativa (0-based).
  final int active;

  /// Callback ao tocar num dot — se ausente, os dots são apenas indicativos.
  final ValueChanged<int>? onSelect;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    final dots = List.generate(count, (i) {
      final isActive = i == active;
      final dot = AnimatedContainer(
        duration: AppMotion.slow,
        curve: Curves.easeOut,
        height: AppSpacing.space2,
        width: isActive ? AppSpacing.space6 : AppSpacing.space2,
        decoration: BoxDecoration(
          color: isActive ? semantic.accentDefault : semantic.borderDefault,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
      );

      return Semantics(
        selected: isActive,
        button: onSelect != null,
        label: 'Página ${i + 1} de $count',
        child: onSelect != null
            ? Material(
                color: AppColors.transparent,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: () => onSelect!(i),
                  customBorder: const CircleBorder(),
                  child: SizedBox(
                    width: AppSize.control,
                    height: AppSize.control,
                    child: Center(child: dot),
                  ),
                ),
              )
            : dot,
      );
    });

    return Semantics(
      label: 'Páginas',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < dots.length; i++) ...[
            if (i > 0 && onSelect == null)
              const SizedBox(width: AppSpacing.space2),
            dots[i],
          ],
        ],
      ),
    );
  }
}

WidgetbookComponent buildPageDotsWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'PageDots',
    useCases: [
      WidgetbookUseCase(
        name: 'Interativo',
        builder: (context) => const Center(child: _PageDotsDemo()),
      ),
      WidgetbookUseCase(
        name: 'Apenas indicativo',
        builder: (context) =>
            const Center(child: AppPageDots(count: 4, active: 1)),
      ),
    ],
  );
}

class _PageDotsDemo extends StatefulWidget {
  const _PageDotsDemo();

  @override
  State<_PageDotsDemo> createState() => _PageDotsDemoState();
}

class _PageDotsDemoState extends State<_PageDotsDemo> {
  int _active = 0;

  @override
  Widget build(BuildContext context) {
    return AppPageDots(
      count: 5,
      active: _active,
      onSelect: (i) => setState(() => _active = i),
    );
  }
}
