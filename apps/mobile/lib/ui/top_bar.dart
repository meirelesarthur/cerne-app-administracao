import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'app_icon.dart';
import 'pressable.dart';
import '../design/generated/app_layout.dart';
import '../design/generated/app_radius.dart';
import '../design/generated/app_spacing.dart';
import '../design/theme/app_theme_extension.dart';

/// Barra superior das telas fundas do padrão global — o `Back Button` dos
/// frames de cadastro do Figma (`54349:2081`, `54300:16063`).
///
/// Anatomia medida: três posições fixas — voltar de 32 px à esquerda, título de
/// 18 px SemiBold **centralizado** e ação de 32 px à direita. Quando não há
/// ação, a coluna da direita permanece reservada para o título não sair do
/// centro.
///
/// Por que não é uma variante de `AppScreenHeader`: aquele é um cabeçalho de
/// **página** — título à esquerda, descrição abaixo, botão "Voltar" com rótulo
/// textual e altura livre. Este é um cromo de **navegação** de altura fixa e
/// título centralizado. Mesmo critério que separou `AppModuleTile` de
/// `AppQuickAction` na esteira do padrão global (§1.2-A).
///
/// O título usa `NavigationToolbar` (o mesmo layout que centraliza o título do
/// `AppBar` do Material) em vez de um `Row` com `Expanded` no meio: com
/// `Expanded`, o título fica centralizado *entre* as duas colunas laterais,
/// não na barra inteira — se elas tiverem larguras diferentes (ex.: o botão
/// "Marcar lidas" de `trailing` X o glifo fixo de voltar), o título se desloca
/// visualmente. Isso reproduzia de fato: a barra de Notificações descentrava o
/// título enquanto havia não lidas e recentrava ao marcar todas como lidas
/// (`trailing` sumindo). `NavigationToolbar(centerMiddle: true)` mede as duas
/// colunas e mantém o título no centro geométrico da barra sempre que cabe.
class AppTopBar extends StatelessWidget {
  const AppTopBar({
    super.key,
    required this.title,
    this.onBack,
    this.backLabel = 'Voltar',
    this.actionIcon,
    this.actionLabel,
    this.onAction,
    this.trailing,
  });

  final String title;

  /// Ausente em telas que são raiz de uma pilha; o espaço continua reservado.
  final VoidCallback? onBack;
  final String backLabel;

  /// Ação de overflow à direita (o `DotsThreeVertical` do Figma).
  final AppIconData? actionIcon;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Substitui a coluna da direita por um widget qualquer. A referência só tem
  /// o ícone de overflow, mas o app coloca ali um selo de acesso restrito e um
  /// "Marcar lidas" — conteúdo que não cabe num glifo. Quando presente, tem
  /// precedência sobre [actionIcon]. O título continua centralizado na barra
  /// mesmo quando esta coluna é mais larga que a de voltar (ver nota de classe
  /// sobre `NavigationToolbar`).
  final Widget? trailing;

  /// Altura do glifo no Figma. O alvo de toque é maior — ver [_slotSize].
  static const double glyphSize = AppSize.iconXxl;

  /// Alvo de toque mínimo acessível. O glifo de 32 do Figma fica centralizado
  /// dentro dele: fidelidade visual sem perder a área de 44 px.
  static const double _slotSize = AppSize.control;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    Widget slot({AppIconData? icon, String? label, VoidCallback? onPressed}) {
      if (icon == null) {
        return const SizedBox(width: _slotSize, height: _slotSize);
      }
      // `Tooltip` como em `AppIconButton`: botão só-ícone precisa expor o
      // rótulo por toque longo e por hover, não apenas ao leitor de tela.
      return Tooltip(
        message: label ?? '',
        child: AppPressable(
          semanticLabel: label ?? '',
          onPressed: onPressed,
          borderRadius: BorderRadius.circular(AppRadius.full),
          child: SizedBox(
            width: _slotSize,
            height: _slotSize,
            child: Center(
              child: AppIcon(icon, size: glyphSize, color: semantic.fgHeading),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.space1),
      child: SizedBox(
        height: _slotSize,
        // `NavigationToolbar` (o mesmo layout por trás do `AppBar` do
        // Material) mede as colunas laterais e mantém o título no centro
        // geométrico da barra — diferente de um `Row` com `Expanded` no meio,
        // que centraliza o título *entre* as colunas e o desloca quando elas
        // têm larguras diferentes (ver nota de classe).
        child: NavigationToolbar(
          // `centerMiddle` já é `true` por padrão no `NavigationToolbar`.
          middleSpacing: AppSpacing.space2,
          leading: slot(
            icon: onBack == null ? null : AppIcons.arrowLeft,
            label: backLabel,
            onPressed: onBack,
          ),
          middle: Semantics(
            header: true,
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          trailing: trailing ?? slot(
            icon: actionIcon,
            label: actionLabel,
            onPressed: onAction,
          ),
        ),
      ),
    );
  }
}

WidgetbookComponent buildTopBarWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'TopBar',
    useCases: [
      WidgetbookUseCase(
        name: 'Com voltar e overflow',
        builder: (context) => Padding(
          padding: const EdgeInsets.all(AppSpacing.space4),
          child: AppTopBar(
            title: 'Trato diário',
            onBack: () {},
            actionIcon: AppIcons.moreVertical,
            actionLabel: 'Mais opções',
            onAction: () {},
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Só voltar',
        builder: (context) => Padding(
          padding: const EdgeInsets.all(AppSpacing.space4),
          child: AppTopBar(title: 'Modelo Steps', onBack: () {}),
        ),
      ),
      WidgetbookUseCase(
        name: 'Raiz de pilha (sem voltar)',
        builder: (context) => const Padding(
          padding: EdgeInsets.all(AppSpacing.space4),
          child: AppTopBar(title: 'Notificações'),
        ),
      ),
    ],
  );
}
