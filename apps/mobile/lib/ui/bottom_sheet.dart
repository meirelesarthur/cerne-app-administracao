import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import '../design/generated/app_colors.dart';
import '../design/generated/app_radius.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';
import 'field_capsule.dart';

/// Espelha `BottomSheet.tsx` (spec §6.11).
///
/// No React, `BottomSheet` é um wrapper controlado (`open`/`onClose`) que se
/// portala para `document.body`. O equivalente idiomático em Flutter é uma
/// função que dispara `showModalBottomSheet` — é essa a API pública principal:
/// `showAppBottomSheet<T>(context, child: ...)`. O widget [AppBottomSheet]
/// (o "chrome" visual: handle, título, cantos, sombra) fica exposto também,
/// para quem quiser compor um modal customizado sem passar por essa função.
Future<T?> showAppBottomSheet<T>(
  BuildContext context, {
  required Widget child,
  String? title,
  double maxHeightFraction = 0.85,
  bool expand = false,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.transparent,
    // bg-black/40 no React — valor arbitrário do Tailwind, não um token de
    // `tokens.ts`; preservado igual à origem.
    barrierColor: AppColors.black.withValues(alpha: 0.4),
    builder: (context) => AppBottomSheet(
      title: title,
      maxHeightFraction: maxHeightFraction,
      expand: expand,
      child: child,
    ),
  );
}

/// "Chrome" visual do bottom sheet: handle centralizada, título opcional,
/// cantos arredondados no topo e conteúdo rolável com altura máxima em
/// fração da viewport (equivalente a `maxHeight` em vh no React).
class AppBottomSheet extends StatelessWidget {
  const AppBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.maxHeightFraction = 0.85,
    this.expand = false,
  });

  final Widget child;
  final String? title;
  final double maxHeightFraction;

  /// Quando `true`, o sheet ocupa exatamente `maxHeightFraction` da altura da
  /// tela (não só até esse limite) e `child` preenche o espaço restante via
  /// `Expanded`, em vez de rolar dentro de um `SingleChildScrollView` — usado
  /// pelo dock de busca (`AppSearchSelect`/`showAppSearchSelectDock`), cuja
  /// lista interna já rola por si e precisa de altura previsível.
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final sheetHeight = MediaQuery.sizeOf(context).height * maxHeightFraction;

    return Semantics(
      container: true,
      label: title,
      child: ConstrainedBox(
        constraints: expand
            ? BoxConstraints.tightFor(height: sheetHeight)
            : BoxConstraints(maxHeight: sheetHeight),
        child: Container(
          decoration: BoxDecoration(
            color: semantic.bgSurface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.modal),
            ),
            boxShadow: semantic.shadowModal,
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    top: AppSpacing.space3,
                    bottom: AppSpacing.space1,
                  ),
                  child: Container(
                    height: AppSpacing.space1,
                    width: AppSpacing.space10,
                    decoration: BoxDecoration(
                      color: AppColors.neutral300,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                  ),
                ),
                if (title != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.space5,
                      AppSpacing.space1,
                      AppSpacing.space5,
                      AppSpacing.space2,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        title!,
                        style: TextStyle(
                          fontSize: AppTypography.lg,
                          fontWeight: AppTypography.weightSemibold,
                          color: semantic.fgDefault,
                        ),
                      ),
                    ),
                  ),
                if (expand)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.space5,
                        0,
                        AppSpacing.space5,
                        AppSpacing.space5,
                      ),
                      child: AppInputSurface(
                        backgroundColor: semantic.bgSurface,
                        child: child,
                      ),
                    ),
                  )
                else
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.space5,
                        0,
                        AppSpacing.space5,
                        AppSpacing.space5,
                      ),
                      child: AppInputSurface(
                        backgroundColor: semantic.bgSurface,
                        child: child,
                      ),
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

WidgetbookComponent buildBottomSheetWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'BottomSheet',
    useCases: [
      WidgetbookUseCase(
        name: 'Aberto (via botão)',
        builder: (context) => Center(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showAppBottomSheet<void>(
                context,
                title: 'Detalhes',
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Conteúdo de exemplo do bottom sheet.'),
                    SizedBox(height: AppSpacing.space4),
                    Text('Mais uma linha de conteúdo rolável.'),
                  ],
                ),
              ),
              child: const Text('Abrir bottom sheet'),
            ),
          ),
        ),
      ),
    ],
  );
}
