import 'package:flutter/material.dart';

import '../../ui/ui.dart';

/// Cabeçalho das páginas secundárias do shell e dos fluxos de módulo (Perfil,
/// Notificações, Pedidos, fluxos do Bank, etc.).
///
/// Hoje é só o ponto de entrada do shell para [AppPageHeaderBand], a faixa de
/// 64 px do catálogo: a anatomia (altura travada em `AppLayout.headerH`,
/// `AppTopBar` centralizado, título/voltar/ação e nada mais) mora lá, onde
/// [AppPageScaffold] e as visualizações em tela cheia leem a mesma medida.
/// Enquanto a faixa era montada aqui, o esqueleto de cada fluxo repetia a
/// composição e o 64 px era garantia de um arquivo isolado do catálogo.
///
/// Continua existindo porque telas que não usam o [AppPageScaffold] inteiro
/// (listas do Marketplace, dashboards) só precisam da faixa, e o nome já está
/// no vocabulário do shell.
///
/// Não confundir com `AppScreenHeader`: aquele é cabeçalho de página (título à
/// esquerda, descrição, rótulo "Voltar" textual) e continua servindo telas que
/// precisam de descrição; este é o cromo de navegação de altura fixa.
class SubPageHeader extends StatelessWidget {
  const SubPageHeader({
    super.key,
    required this.title,
    this.onBack,
    this.actionIcon,
    this.actionLabel,
    this.onAction,
    this.action,
  });

  final String title;
  final VoidCallback? onBack;

  /// Ação de overflow à direita do título.
  final AppIconData? actionIcon;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Conteúdo livre à direita, quando a ação não cabe num glifo (selo de
  /// acesso restrito, "Marcar lidas").
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return AppPageHeaderBand(
      title: title,
      onBack: onBack ?? () => Navigator.of(context).maybePop(),
      actionIcon: actionIcon,
      actionLabel: actionLabel,
      onAction: onAction,
      action: action,
    );
  }
}
