import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'app_icon.dart';
import '../design/generated/app_radius.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';
import 'button.dart';
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

/// Pede confirmação explícita antes de uma ação que gera histórico (iniciar,
/// pausar, entregar…). Devolve `true` só quando a pessoa toca no botão de
/// confirmar; fechar, tocar fora ou "Cancelar" devolvem `false`.
///
/// Pensado para o trabalho de campo: toque acidental é esperado (luva, mão
/// ocupada, sol na tela), então os dois botões são grandes, empilhados em
/// largura total, com o de confirmar em cima e rótulo com o verbo da ação
/// ("Iniciar execução"), nunca um "OK" genérico.
Future<bool> showAppConfirm(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  String cancelLabel = 'Cancelar',
  bool danger = false,
}) async {
  final confirmed = await showAppModal<bool>(
    context,
    title: title,
    child: Text(message),
    footer: Builder(
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppButton(
            size: AppButtonSize.lg,
            fullWidth: true,
            variant: danger
                ? AppButtonVariant.danger
                : AppButtonVariant.primary,
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmLabel),
          ),
          const SizedBox(height: AppSpacing.space2),
          AppButton(
            size: AppButtonSize.lg,
            fullWidth: true,
            variant: AppButtonVariant.subtle,
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelLabel),
          ),
        ],
      ),
    ),
  );
  return confirmed ?? false;
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
      WidgetbookUseCase(
        name: 'Confirmação de ação (showAppConfirm)',
        builder: (context) => Center(
          child: Builder(
            builder: (context) => AppButton(
              onPressed: () => showAppConfirm(
                context,
                title: 'Iniciar a OS #2201?',
                message:
                    'O início fica registrado no histórico da OS com data, '
                    'hora e o seu nome.',
                confirmLabel: 'Iniciar execução',
              ),
              child: const Text('Abrir confirmação'),
            ),
          ),
        ),
      ),
    ],
  );
}
