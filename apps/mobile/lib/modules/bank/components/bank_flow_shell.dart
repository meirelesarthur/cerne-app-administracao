import 'package:flutter/material.dart';

import '../../../ui/ui.dart';

/// Esqueleto comum dos fluxos de pagamento do GB Bank: o mesmo arquétipo
/// *Cadastro* do padrão global que o `FlowShell` de Fazendas usa, e agora pela
/// mesma peça — [AppPageScaffold]. O que este wrapper acrescenta é só o
/// vocabulário do Bank (rótulo do CTA, estado desabilitado, ação do header);
/// a anatomia da tela não é mais decidida aqui.
///
/// [totalSteps] desenha a régua do frame `Cadastro steps` (`54349:1990`): o Pix
/// é um fluxo de quatro passos e a referência resolve isso com a régua, não com
/// o texto "Passo 2 de 4" no canto do cabeçalho.
class BankFlowShell extends StatelessWidget {
  const BankFlowShell({
    super.key,
    required this.title,
    required this.onBack,
    required this.child,
    this.primaryLabel,
    this.onPrimary,
    this.primaryDisabled = false,
    this.headerAction,
    this.totalSteps,
    this.currentStep = 0,
  });

  final String title;
  final VoidCallback onBack;
  final Widget child;

  /// Rótulo do botão primário; ocultado se ausente.
  final String? primaryLabel;
  final VoidCallback? onPrimary;
  final bool primaryDisabled;

  /// Ação opcional no canto do header (ex.: passo atual).
  final Widget? headerAction;

  /// Quantidade de etapas do fluxo, quando há mais de uma.
  final int? totalSteps;
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      title: title,
      onBack: onBack,
      headerAction: headerAction,
      totalSteps: totalSteps,
      currentStep: currentStep,
      actionBar: primaryLabel == null
          ? null
          : AppActionBar(
              primaryLabel: primaryLabel!,
              primaryIcon: AppIcons.saveAll,
              onPrimary: primaryDisabled ? null : onPrimary,
            ),
      child: child,
    );
  }
}
