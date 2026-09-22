import 'package:flutter/material.dart';

import '../design/generated/app_colors.dart';
import '../design/generated/app_layout.dart';
import '../design/generated/app_radius.dart';
import '../design/generated/app_spacing.dart';
import '../design/theme/app_theme_extension.dart';

/// Contexto de superfície para campos de entrada.
///
/// O Flutter não expõe a cor já composta atrás de um widget. Os contêineres
/// compartilhados do catálogo informam sua própria cor por este contexto, para
/// que todo campo aplique a mesma regra de contraste: sobre branco, cinza; em
/// qualquer outra superfície (cinza ou escura), branco.
class AppInputSurface extends InheritedWidget {
  const AppInputSurface({
    super.key,
    required this.backgroundColor,
    required super.child,
  });

  final Color backgroundColor;

  static Color? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<AppInputSurface>()
      ?.backgroundColor;

  @override
  bool updateShouldNotify(AppInputSurface oldWidget) =>
      oldWidget.backgroundColor != backgroundColor;
}

/// Cores adaptadas da entrada para a superfície em que ela aparece.
@immutable
class AppInputColors {
  const AppInputColors({
    required this.fill,
    required this.foreground,
    required this.muted,
    required this.placeholder,
    required this.focus,
  });

  final Color fill;
  final Color foreground;
  final Color muted;
  final Color placeholder;
  final Color focus;
}

/// Resolve o preenchimento e a legibilidade do campo a partir da superfície
/// mais próxima. Sem um [AppInputSurface] ancestral, o canvas do tema é a
/// referência segura.
///
/// Antes esta função respondia só à luminância da superfície e devolvia
/// literais fixos (`AppColors.neutral100`/`neutral0`/`neutral800`...) —
/// corretos no tema claro, mas alheios ao gbMode: como nenhuma superfície
/// escura tem luminância "quase branca", o campo sempre caía no branco puro
/// (`neutral0`) e virava um retângulo branco quebrando o tema escuro (campo
/// de busca, entre outros). Os tokens `fieldOnSurface`/`fieldOnCanvas` já
/// resolvem os dois papéis por tema — em gbMode nenhuma superfície é branca e
/// os dois convergem para o mesmo verde elevado (`bgRaised`); o restante lê
/// direto da paleta semântica, que já é theme-aware.
AppInputColors appInputColors(BuildContext context) {
  final semantic = Theme.of(context).extension<AppSemanticColors>()!;
  final background = AppInputSurface.maybeOf(context) ?? semantic.bgCanvas;
  final isOnSurface = background.computeLuminance() >= 0.98;

  return AppInputColors(
    fill: isOnSurface ? semantic.fieldOnSurface : semantic.fieldOnCanvas,
    foreground: semantic.fgDefault,
    muted: semantic.fgMuted,
    placeholder: semantic.fgPlaceholder,
    focus: semantic.accentDefault,
  );
}

/// Cápsula visual compartilhada de todos os campos de formulário do catálogo
/// (`AppTextInput`, `AppFormSelect`, `AppSearchSelect`). Fonte única da altura,
/// do fundo, do raio e do anel de foco — os campos só entregam o conteúdo.
///
/// Por que a cápsula é pintada aqui e não pelo `InputDecoration`: o
/// `InputDecorator` do Material pinta `fillColor`/`border` num container
/// dimensionado pelo **conteúdo** (`_BorderContainer`), não pelas constraints
/// recebidas. Com `isCollapsed: true` + `contentPadding` só-horizontal esse
/// container fica com a altura do texto (~21px) e é alinhado ao topo: o
/// `SizedBox(height: 48)` externo media 48px em teste, mas o pixel visível era
/// uma pílula de 21px — exatamente o "campo fino" reportado. Pintando a cápsula
/// num `Container` nosso, a altura medida e a altura vista são a mesma coisa.
class AppFieldCapsule extends StatelessWidget {
  const AppFieldCapsule({
    super.key,
    required this.child,
    this.focused = false,
    this.invalid = false,
    this.height = AppSize.controlLg,
    this.horizontalPadding = AppSpacing.space3,
    this.leading,
    this.trailing,
  });

  /// Conteúdo do campo (o editor/label). É centralizado verticalmente e ocupa
  /// a largura restante entre `leading` e `trailing`.
  final Widget child;
  final bool focused;
  final bool invalid;

  /// Altura fixa da cápsula. Padrão: 52px (`AppSize.controlLg`), a altura do
  /// campo no padrão global do Figma (54349:2014). Passe outro token apenas em
  /// campos com semântica diferente.
  final double height;
  final double horizontalPadding;
  final Widget? leading;
  final Widget? trailing;

  /// A borda é sempre desenhada com a mesma espessura (mudando só a cor) para
  /// que foco/erro não deslochem o conteúdo em 1px.
  static const double _borderWidth = 2;

  @override
  Widget build(BuildContext context) {
    final inputColors = appInputColors(context);

    final Color borderColor;
    if (invalid) {
      borderColor = AppColors.red500;
    } else if (focused) {
      borderColor = inputColors.focus;
    } else {
      borderColor = AppColors.transparent;
    }

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: inputColors.fill,
        // Raio 20 do Figma, não pílula: o campo do padrão global é um
        // retângulo arredondado, e a pílula anterior encurtava visualmente o
        // texto nas duas pontas em campos de conteúdo longo.
        borderRadius: BorderRadius.circular(AppRadius.tile),
        border: Border.all(color: borderColor, width: _borderWidth),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding - _borderWidth,
      ),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: AppSpacing.space2),
          ],
          Expanded(child: child),
          if (trailing != null) ...[
            const SizedBox(width: AppSpacing.space2),
            trailing!,
          ],
        ],
      ),
    );
  }
}
