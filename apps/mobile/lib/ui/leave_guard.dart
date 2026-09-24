import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import '../design/generated/app_spacing.dart';
import 'button.dart';
import 'modal.dart';

/// A pergunta de [AppLeaveGuard] avulsa, para saídas que não passam pelo
/// Navigator (ex.: voltar do formulário para a lista dentro da mesma rota).
/// Devolve `true` quando a pessoa escolhe sair sem salvar.
Future<bool> confirmAppLeave(
  BuildContext context, {
  String title = 'Sair sem salvar?',
  String message = 'O que você preencheu nesta tela será perdido.',
  String confirmLabel = 'Descartar',
  String cancelLabel = 'Continuar',
}) => showAppConfirm(
  context,
  title: title,
  message: message,
  confirmLabel: confirmLabel,
  cancelLabel: cancelLabel,
  danger: true,
);

/// Protege uma tela com dados preenchidos contra a saída acidental: com
/// [active] ligado, voltar (botão da barra, gesto ou botão do sistema)
/// pergunta antes de descartar o que a pessoa digitou.
///
/// Só intercepta saídas que passam por `Navigator.maybePop` — é o que o botão
/// voltar da faixa, o gesto e o botão do sistema usam. Saídas que trocam de
/// estado dentro da mesma rota usam [confirmAppLeave] direto.
class AppLeaveGuard extends StatelessWidget {
  const AppLeaveGuard({
    super.key,
    required this.active,
    required this.child,
    this.title = 'Sair sem salvar?',
    this.message = 'O que você preencheu nesta tela será perdido.',
    this.confirmLabel = 'Descartar',
    this.cancelLabel = 'Continuar',
  });

  /// `true` quando há algo preenchido que ainda não foi salvo.
  final bool active;
  final Widget child;
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: !active,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final leave = await confirmAppLeave(
          context,
          title: title,
          message: message,
          confirmLabel: confirmLabel,
          cancelLabel: cancelLabel,
        );
        // `pop` direto (e não `maybePop`) para não reabrir a pergunta.
        if (leave && context.mounted) Navigator.of(context).pop(result);
      },
      child: child,
    );
  }
}

WidgetbookComponent buildLeaveGuardWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'LeaveGuard',
    useCases: [
      WidgetbookUseCase(
        name: 'Formulário preenchido',
        builder: (context) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.space4),
            child: AppButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => AppLeaveGuard(
                    active: true,
                    child: Scaffold(
                      body: Center(
                        child: AppButton(
                          variant: AppButtonVariant.secondary,
                          onPressed: () => Navigator.of(context).maybePop(),
                          child: const Text('Voltar'),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              child: const Text('Abrir formulário preenchido'),
            ),
          ),
        ),
      ),
    ],
  );
}
