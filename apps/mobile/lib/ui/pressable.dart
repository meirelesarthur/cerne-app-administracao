import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import '../design/generated/app_layout.dart';
import '../design/generated/app_radius.dart';
import '../design/generated/app_spacing.dart';
import 'package:cerne_app/design/generated/app_colors.dart';

/// Superfície interativa sem aparência própria, com semântica, foco, ripple e
/// alvo mínimo centralizados no catálogo.
class AppPressable extends StatelessWidget {
  const AppPressable({
    super.key,
    required this.child,
    required this.semanticLabel,
    this.onPressed,
    this.borderRadius,
    this.minTouchTarget = true,
    this.selected,
    this.toggled,
    this.showVisualFeedback = true,
  });

  final Widget child;
  final String semanticLabel;
  final VoidCallback? onPressed;
  final BorderRadius? borderRadius;
  final bool minTouchTarget;
  final bool? selected;
  final bool? toggled;
  final bool showVisualFeedback;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(AppRadius.xl2);
    final content = Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: radius,
        canRequestFocus: onPressed != null,
        overlayColor: showVisualFeedback
            ? null
            : const WidgetStatePropertyAll(AppColors.transparent),
        child: child,
      ),
    );

    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: semanticLabel,
      selected: selected,
      toggled: toggled,
      excludeSemantics: true,
      child: minTouchTarget
          ? ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: AppSize.control,
                minHeight: AppSize.control,
              ),
              child: content,
            )
          : content,
    );
  }
}

WidgetbookComponent buildPressableWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'Pressable',
    useCases: [
      WidgetbookUseCase(
        name: 'Superfície acessível',
        builder: (context) => Center(
          child: AppPressable(
            semanticLabel: 'Abrir detalhe da fazenda',
            onPressed: () {},
            child: const Padding(
              padding: EdgeInsets.all(AppSpacing.space4),
              child: Text('Toque, Enter ou Espaço'),
            ),
          ),
        ),
      ),
    ],
  );
}
