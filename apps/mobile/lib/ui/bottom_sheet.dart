import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import '../design/generated/app_colors.dart';
import '../design/generated/app_radius.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';
import 'button.dart';
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
  Widget? footer,
  bool dismissible = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    // Navigator raiz: dentro do `ShellRoute` o navigator mais próximo é o do
    // shell, e a dock abria *por baixo* da navbar flutuante, que é irmã do
    // conteúdo na Stack do `ShellLayout`. A dock é sempre a camada de cima.
    useRootNavigator: true,
    isScrollControlled: true,
    // Sheets com texto digitado passam `dismissible: false`: tocar fora ou
    // arrastar para baixo não descarta o que a pessoa escreveu — só os botões
    // do próprio sheet fecham.
    isDismissible: dismissible,
    enableDrag: dismissible,
    backgroundColor: AppColors.transparent,
    // bg-black/40 no React — valor arbitrário do Tailwind, não um token de
    // `tokens.ts`; preservado igual à origem.
    barrierColor: AppColors.black.withValues(alpha: 0.4),
    // O teclado empurra o sheet para cima: sem isso ele cobria o campo e o
    // botão Confirmar.
    builder: (context) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: AppBottomSheet(
        title: title,
        maxHeightFraction: maxHeightFraction,
        expand: expand,
        footer: footer,
        child: child,
      ),
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
    this.footer,
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

  /// Rodapé fixo, fora da área rolável — fica sempre ao alcance do polegar
  /// mesmo com conteúdo longo (ex.: "Adicionar" do gerenciador de coleção,
  /// [showAppCollectionManager]). `null` mantém o sheet sem rodapé.
  final Widget? footer;

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
                      color: semantic.borderStrong,
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
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.space5,
                        0,
                        AppSpacing.space5,
                        footer == null ? AppSpacing.space5 : AppSpacing.space3,
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
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.space5,
                        0,
                        AppSpacing.space5,
                        footer == null ? AppSpacing.space5 : AppSpacing.space3,
                      ),
                      child: AppInputSurface(
                        backgroundColor: semantic.bgSurface,
                        child: child,
                      ),
                    ),
                  ),
                if (footer case final footer?)
                  DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: semantic.borderSubtle),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.space5,
                        AppSpacing.space3,
                        AppSpacing.space5,
                        AppSpacing.space5,
                      ),
                      child: footer,
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
            builder: (context) => AppButton(
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
      WidgetbookUseCase(
        name: 'Com rodapé fixo (conteúdo longo)',
        builder: (context) => Center(
          child: Builder(
            builder: (context) => AppButton(
              onPressed: () => showAppBottomSheet<void>(
                context,
                title: 'Itens incluídos',
                footer: AppButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Ação principal fixa'),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 1; i <= 20; i++)
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppSpacing.space3,
                        ),
                        child: Text('Linha $i — o rodapé não rola junto.'),
                      ),
                  ],
                ),
              ),
              child: const Text('Abrir com rodapé fixo'),
            ),
          ),
        ),
      ),
    ],
  );
}
