import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import '../design/generated/app_colors.dart';
import '../design/generated/app_layout.dart';
import '../design/generated/app_radius.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';
import 'code_preview.dart';
import 'spinner.dart';

/// Espelha `Button.tsx` do protótipo React (§1.2 do PLANO-MIGRACAO-FLUTTER.md).
/// Mesmos nomes/variantes — screens compõem este widget, nunca `ElevatedButton`/`TextButton`
/// direto (Lei 1 do CLAUDE.md, espelhada aqui: catálogo primeiro).
/// `dangerOutline` é o "Cancelar" do padrão global (Figma 54349:2089):
/// contorno e rótulo vermelhos sobre superfície transparente. Distinto de
/// `danger`, que é o vermelho sólido de uma ação destrutiva confirmada.
enum AppButtonVariant {
  primary,
  secondary,
  ghost,
  danger,
  dangerOutline,
  link,

  /// Bolha translúcida sobre fundo escuro/arte (ex.: CTA secundário na tela
  /// de login, sobre a foto de fundo) — mesmos tokens `inkBubble`/`inkFg` já
  /// usados por `AppIconButton` (variant `onDark`), agora também disponíveis
  /// como botão de texto.
  onDark,

  /// Preenchimento neutro leve (`bgCanvas`, o mesmo tom de fundo de input) —
  /// para uma ação secundária lado a lado com um `primary`, quando `ghost`
  /// (sem preenchimento algum) deixa esse lado sem "corpo" e desequilibra o
  /// par visualmente (ex.: "Pular" ao lado de "Próximo" no onboarding).
  subtle,
}

enum AppButtonSize { sm, md, lg, xl }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.child,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.md,
    this.loading = false,
    this.fullWidth = false,
    this.leftIcon,
    this.rightIcon,
    this.width,
    this.height,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool loading;
  final bool fullWidth;
  final Widget? leftIcon;
  final Widget? rightIcon;

  /// Sobrescreve a largura do botão (padrão: intrínseca, ou `double.infinity`
  /// com [fullWidth]). Para telas com medida fixa no Figma que não coincide
  /// com nenhum breakpoint de largura total.
  final double? width;

  /// Sobrescreve a altura do botão (padrão: a de [size]).
  final double? height;

  bool get _disabled => onPressed == null || loading;

  double get _height => switch (size) {
    AppButtonSize.sm => AppSize.btnSm,
    AppButtonSize.md => AppSize.btnMd,
    AppButtonSize.lg => AppSize.btnLg,
    AppButtonSize.xl => AppSpacing.space14,
  };

  // fidelidade-esteira: raio "squircle" (quadrado-arredondado), não mais
  // pílula (`AppRadius.full`) — pedido do usuário para todo o catálogo.
  // Escala com a altura do botão em vez de um valor único, mesma proporção
  // já usada por `AppAppIconTile`/`field_capsule` (~0.32–0.36 do lado).
  double get _borderRadius => switch (size) {
    AppButtonSize.sm => AppRadius.lg,
    AppButtonSize.md => AppRadius.lg,
    AppButtonSize.lg => AppRadius.lgPlus,
    AppButtonSize.xl => AppRadius.tile,
  };

  double get _horizontalPadding => switch (size) {
    AppButtonSize.sm => AppSpacing.space4,
    AppButtonSize.md => AppSpacing.space5,
    AppButtonSize.lg => AppSpacing.space6,
    AppButtonSize.xl => AppSpacing.space6,
  };

  /// `lg` é o CTA do padrão global (Figma 54349:2068): 48 px de altura e
  /// rótulo de 14 px SemiBold — não um `md` ampliado. Quem quiser o rótulo em
  /// caixa alta da referência passa o texto já em caixa alta; o widget não
  /// transforma conteúdo (`child` é `Widget`, não `String`).
  double get _fontSize => switch (size) {
    AppButtonSize.sm => AppTypography.sm,
    AppButtonSize.md => AppTypography.md,
    AppButtonSize.lg => AppTypography.md,
    AppButtonSize.xl => AppTypography.md,
  };

  double get _spinnerSize =>
      size == AppButtonSize.lg || size == AppButtonSize.xl
      ? AppSize.iconMd
      : AppSize.iconSm;

  ({Color bg, Color fg, Color? border}) _colors(AppSemanticColors s) =>
      switch (variant) {
        AppButtonVariant.primary => (bg: s.ctaBg, fg: s.ctaFg, border: null),
        AppButtonVariant.secondary => (
          bg: s.bgSurface,
          fg: s.fgDefault,
          border: s.borderDefault,
        ),
        AppButtonVariant.ghost => (
          bg: AppColors.transparent,
          fg: s.fgDefault,
          border: null,
        ),
        AppButtonVariant.danger => (
          bg: AppColors.red600,
          fg: AppColors.neutral0,
          border: null,
        ),
        AppButtonVariant.dangerOutline => (
          bg: AppColors.transparent,
          fg: AppColors.feedbackErrorText,
          border: AppColors.feedbackErrorText,
        ),
        AppButtonVariant.link => (
          bg: AppColors.transparent,
          fg: s.accentDefault,
          border: null,
        ),
        AppButtonVariant.onDark => (
          bg: s.inkBubble,
          fg: s.inkFg,
          border: AppColors.neutral0.withValues(alpha: 0.3),
        ),
        AppButtonVariant.subtle => (
          bg: s.bgCanvas,
          fg: s.fgDefault,
          border: null,
        ),
      };

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final colors = _colors(semantic);

    final content = Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading)
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.space2),
            child: AppSpinner(size: _spinnerSize, color: colors.fg),
          )
        else if (leftIcon != null)
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.space2),
            child: leftIcon,
          ),
        if (fullWidth)
          Flexible(
            child: _ButtonLabel(style: _labelStyle(colors.fg), child: child),
          )
        else
          _ButtonLabel(style: _labelStyle(colors.fg), child: child),
        if (!loading && rightIcon != null)
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.space2),
            child: rightIcon,
          ),
      ],
    );

    if (variant == AppButtonVariant.link) {
      return Opacity(
        opacity: _disabled && !loading ? 0.7 : 1,
        child: Material(
          color: AppColors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.full),
          child: InkWell(
            onTap: _disabled ? null : onPressed,
            canRequestFocus: !_disabled,
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: AppSize.btnMd,
                minWidth: AppSize.btnMd,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.space1,
                ),
                child: Center(child: content),
              ),
            ),
          ),
        ),
      );
    }

    return Opacity(
      opacity: _disabled && !loading ? 0.7 : 1,
      child: Material(
        color: colors.bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
          side: colors.border != null
              ? BorderSide(color: colors.border!)
              : BorderSide.none,
        ),
        child: InkWell(
          onTap: _disabled ? null : onPressed,
          canRequestFocus: !_disabled,
          borderRadius: BorderRadius.circular(_borderRadius),
          child: Container(
            height: height ?? _height,
            width: width ?? (fullWidth ? double.infinity : null),
            padding: EdgeInsets.symmetric(horizontal: _horizontalPadding),
            alignment: Alignment.center,
            child: content,
          ),
        ),
      ),
    );
  }

  TextStyle _labelStyle(Color color) => TextStyle(
    fontSize: variant == AppButtonVariant.link ? AppTypography.sm : _fontSize,
    fontWeight: AppTypography.weightSemibold,
    color: color,
    decoration: variant == AppButtonVariant.link
        ? TextDecoration.underline
        : null,
  );
}

class _ButtonLabel extends StatelessWidget {
  const _ButtonLabel({required this.style, required this.child});

  final TextStyle style;
  final Widget child;

  @override
  Widget build(BuildContext context) => DefaultTextStyle(
    style: style,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    child: child,
  );
}

/// Use-cases da galeria (F2.5) — agregado em `widgetbook_app.dart`.
/// Convenção: toda unidade de `lib/ui/` expõe `buildXxxWidgetbookComponent()`.
WidgetbookComponent buildButtonWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'Button',
    useCases: [
      WidgetbookUseCase(
        name: 'Variantes',
        builder: (context) => Padding(
          padding: const EdgeInsets.all(AppSpacing.space4),
          child: AppCodePreview(
            code: '''
AppButton(onPressed: () {}, child: Text('Primary'))

AppButton(
  variant: AppButtonVariant.secondary,
  onPressed: () {},
  child: Text('Secondary'),
)

AppButton(variant: AppButtonVariant.ghost, ...)
AppButton(variant: AppButtonVariant.subtle, ...)
AppButton(variant: AppButtonVariant.danger, ...)
AppButton(variant: AppButtonVariant.link, ...)''',
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                AppButton(onPressed: () {}, child: const Text('Primary')),
                AppButton(
                  variant: AppButtonVariant.secondary,
                  onPressed: () {},
                  child: const Text('Secondary'),
                ),
                AppButton(
                  variant: AppButtonVariant.ghost,
                  onPressed: () {},
                  child: const Text('Ghost'),
                ),
                AppButton(
                  variant: AppButtonVariant.subtle,
                  onPressed: () {},
                  child: const Text('Subtle'),
                ),
                AppButton(
                  variant: AppButtonVariant.danger,
                  onPressed: () {},
                  child: const Text('Danger'),
                ),
                AppButton(
                  variant: AppButtonVariant.link,
                  onPressed: () {},
                  child: const Text('Link'),
                ),
              ],
            ),
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Tamanhos',
        builder: (context) => Padding(
          padding: const EdgeInsets.all(AppSpacing.space4),
          child: AppCodePreview(
            code:
                "AppButton(size: AppButtonSize.sm, onPressed: () {}, child: Text('Small'))\n"
                "AppButton(onPressed: () {}, child: Text('Medium')) // padrão: md\n"
                "AppButton(size: AppButtonSize.lg, onPressed: () {}, child: Text('Large'))\n"
                "AppButton(size: AppButtonSize.xl, onPressed: () {}, child: Text('Extra large')) // CTA flutuante de listagem",
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                AppButton(
                  size: AppButtonSize.sm,
                  onPressed: () {},
                  child: const Text('Small'),
                ),
                AppButton(onPressed: () {}, child: const Text('Medium')),
                AppButton(
                  size: AppButtonSize.lg,
                  onPressed: () {},
                  child: const Text('Large'),
                ),
                AppButton(
                  size: AppButtonSize.xl,
                  onPressed: () {},
                  child: const Text('Extra large'),
                ),
              ],
            ),
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Estados',
        builder: (context) => Padding(
          padding: const EdgeInsets.all(AppSpacing.space4),
          child: AppCodePreview(
            code: '''
const AppButton(child: Text('Disabled')) // sem onPressed = desabilitado

AppButton(
  loading: true,
  onPressed: () {},
  child: Text('Loading'),
)

AppButton(
  fullWidth: true,
  onPressed: () {},
  child: Text('Full width'),
)''',
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    const AppButton(child: Text('Disabled')),
                    AppButton(
                      loading: true,
                      onPressed: () {},
                      child: const Text('Loading'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space3),
                SizedBox(
                  width: 280,
                  child: AppButton(
                    fullWidth: true,
                    onPressed: () {},
                    child: const Text('Full width'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}
