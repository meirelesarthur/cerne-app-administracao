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
    this.excludeSemantics = true,
  });

  final Widget child;
  final String semanticLabel;
  final VoidCallback? onPressed;
  final BorderRadius? borderRadius;
  final bool minTouchTarget;
  final bool? selected;
  final bool? toggled;
  final bool showVisualFeedback;

  /// `true` (padrão) funde a superfície num único nó acessível com
  /// [semanticLabel]. `false` preserva os controles internos — use quando a
  /// superfície inteira é clicável **e** abriga outro botão real (ex.: o "+"
  /// de adição rápida dentro do card de [AppSquareGroupGrid]); textos
  /// decorativos internos devem então vir em `ExcludeSemantics`.
  final bool excludeSemantics;

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
        // Com `minTouchTarget`, o `ConstrainedBox` abaixo força um alvo de
        // 48dp mesmo quando `child` é um glifo menor (ex.: o "?" do
        // `AppHelpButton`, 16px). Sem este `Center`, a constraint mínima de
        // 48 cascateia pelo `SizedBox` interno do ícone (`enforce`) e o
        // desenho é esticado para preencher os 48px — o ícone "cresce" em
        // vez de só ganhar uma área de toque maior ao redor. `Center` corta
        // essa cascata: solta o mínimo para o filho, que volta a desenhar no
        // seu tamanho real, centralizado dentro do alvo de toque.
        //
        // `widthFactor`/`heightFactor: 1` importam aqui: um `Center()` puro
        // (sem fator) se expande para preencher todo o espaço disponível, o
        // que faria o alvo de toque estourar para o tamanho do container ao
        // redor em vez de ficar travado nos 48px — o mesmo defeito, só que no
        // layout em vez do desenho. Com o fator, a caixa volta a se ajustar
        // ao conteúdo (aqui, ao mínimo de 48).
        child: minTouchTarget
            ? Center(widthFactor: 1, heightFactor: 1, child: child)
            : child,
      ),
    );

    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: semanticLabel,
      selected: selected,
      toggled: toggled,
      container: !excludeSemantics,
      excludeSemantics: excludeSemantics,
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
