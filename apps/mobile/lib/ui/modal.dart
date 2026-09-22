import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'app_icon.dart';
import '../design/generated/app_radius.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';
import 'icon_button.dart';
import 'package:cerne_app/design/generated/app_colors.dart';
import '../design/generated/app_layout.dart';
import 'field_capsule.dart';

/// Espelha `Modal.tsx` (spec §6.10).
///
/// No React, `Modal` é um wrapper controlado (`open`/`onClose`) que se
/// portala para `document.body` com `role="dialog"`. O equivalente
/// idiomático em Flutter é uma função que dispara `showDialog` — é essa a
/// API pública principal: `showAppModal<T>(context, child: ...)`, seguindo
/// o mesmo padrão de `showAppBottomSheet` (`bottom_sheet.dart`). Fecha ao
/// tocar fora (barreira) ou via `Navigator.pop`/tecla Escape (desktop/web),
/// equivalentes ao `onClick` na camada de overlay e ao listener de
/// `Escape` do React.
Future<T?> showAppModal<T>(
  BuildContext context, {
  String? title,
  required Widget child,
  Widget? footer,
}) {
  return showDialog<T>(
    context: context,
    // bg-black/45 no React — valor arbitrário do Tailwind, preservado.
    barrierColor: AppColors.black.withValues(alpha: 0.45),
    builder: (context) => AppModal(title: title, footer: footer, child: child),
  );
}

/// "Chrome" visual do modal centralizado: título opcional + botão fechar,
/// corpo e rodapé de ações opcional — largura máxima de 380 (`max-w-[380px]`
/// no React).
class AppModal extends StatelessWidget {
  const AppModal({super.key, required this.child, this.title, this.footer});

  final Widget child;
  final String? title;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return Dialog(
      backgroundColor: AppColors.transparent,
      insetPadding: const EdgeInsets.all(AppSpacing.space4),
      child: Semantics(
        container: true,
        label: title,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Container(
            decoration: BoxDecoration(
              color: semantic.bgSurface,
              borderRadius: BorderRadius.circular(AppRadius.modal),
              boxShadow: semantic.shadowModal,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.space5,
                    AppSpacing.space4,
                    AppSpacing.space5,
                    AppSpacing.space1,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title ?? '',
                          style: TextStyle(
                            fontSize: AppTypography.lg,
                            fontWeight: AppTypography.weightSemibold,
                            color: semantic.fgDefault,
                          ),
                        ),
                      ),
                      AppIconButton(
                        icon: const AppIcon(
                          AppIcons.x,
                          size: AppSize.iconSmPlus,
                        ),
                        label: 'Fechar',
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.space5,
                    0,
                    AppSpacing.space5,
                    AppSpacing.space4,
                  ),
                  child: DefaultTextStyle.merge(
                    style: TextStyle(
                      fontSize: AppTypography.md,
                      color: semantic.fgDefault,
                    ),
                    child: AppInputSurface(
                      backgroundColor: semantic.bgSurface,
                      child: child,
                    ),
                  ),
                ),
                if (footer != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.space5,
                      AppSpacing.space1,
                      AppSpacing.space5,
                      AppSpacing.space5,
                    ),
                    // Alinhado à direita (`justify-end` no React) — se o
                    // rodapé tiver mais de um botão, o chamador compõe a
                    // própria `Row`/`Wrap` com `gap` equivalente.
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: footer!,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

WidgetbookComponent buildModalWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'Modal',
    useCases: [
      WidgetbookUseCase(
        name: 'Aberto (via botão)',
        builder: (context) => Center(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showAppModal<void>(
                context,
                title: 'Confirmar ação',
                child: const Text('Tem certeza de que deseja continuar?'),
                footer: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Confirmar'),
                ),
              ),
              child: const Text('Abrir modal'),
            ),
          ),
        ),
      ),
    ],
  );
}
