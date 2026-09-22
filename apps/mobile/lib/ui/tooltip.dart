import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'app_icon.dart';
import '../design/generated/app_colors.dart';
import '../design/generated/app_radius.dart';
import '../design/generated/app_shadows.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';

/// Espelha `Tooltip.tsx` — tooltip leve por hover/foco/toque, sem dependência
/// externa. Usa `OverlayPortal` + `CompositedTransformFollower` para posicionar
/// a bolha acima-à-direita do gatilho (equivalente a `bottom-full right-0 mb-1`).
class AppTooltip extends StatefulWidget {
  const AppTooltip({super.key, required this.content, required this.child});

  final String content;
  final Widget child;

  @override
  State<AppTooltip> createState() => _AppTooltipState();
}

class _AppTooltipState extends State<AppTooltip> {
  final _link = LayerLink();
  final _overlayController = OverlayPortalController();

  void _show() => _overlayController.show();

  void _hide() => _overlayController.hide();

  void _toggle() => _overlayController.toggle();

  @override
  void dispose() {
    if (_overlayController.isShowing) _overlayController.hide();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: _overlayController,
        overlayChildBuilder: (context) => CompositedTransformFollower(
          link: _link,
          targetAnchor: Alignment.topRight,
          followerAnchor: Alignment.bottomRight,
          offset: const Offset(0, -AppSpacing.space1),
          child: _TooltipBubble(content: widget.content),
        ),
        child: MouseRegion(
          onEnter: (_) => _show(),
          onExit: (_) => _hide(),
          child: Focus(
            onFocusChange: (hasFocus) => hasFocus ? _show() : _hide(),
            child: GestureDetector(onTap: _toggle, child: widget.child),
          ),
        ),
      ),
    );
  }
}

class _TooltipBubble extends StatelessWidget {
  const _TooltipBubble({required this.content});

  final String content;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.transparent,
      child: Container(
        // 200px é um valor arbitrário já hardcoded no React (`max-w-[200px]`),
        // não um token de `tokens.ts` — preservado igual à origem.
        constraints: const BoxConstraints(maxWidth: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space2,
          vertical: AppSpacing.space1,
        ),
        decoration: BoxDecoration(
          color: AppColors.neutral900,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppShadows.modal,
        ),
        child: Text(
          content,
          style: const TextStyle(
            fontSize: AppTypography.sm,
            fontWeight: AppTypography.weightMedium,
            color: AppColors.neutral0,
          ),
        ),
      ),
    );
  }
}

WidgetbookComponent buildTooltipWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'Tooltip',
    useCases: [
      WidgetbookUseCase(
        name: 'Padrão',
        builder: (context) => const Center(
          child: Padding(
            padding: EdgeInsets.only(top: AppSpacing.space15),
            child: AppTooltip(
              content: 'Informação adicional sobre este item.',
              child: AppIcon(AppIcons.info),
            ),
          ),
        ),
      ),
    ],
  );
}
