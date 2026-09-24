import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import '../design/generated/app_layout.dart';
import '../design/generated/app_radius.dart';
import '../design/generated/app_shadows.dart';
import '../design/generated/app_spacing.dart';
import '../design/theme/app_theme_extension.dart';
import 'package:cerne_app/design/generated/app_colors.dart';
import 'field_capsule.dart';

/// Espelha `Card.tsx` do protótipo React. `variant: ink` é a superfície escura
/// de destaque (hero da referência) — permanece escura nos dois temas.
///
/// Geometria do padrão global: raio [AppRadius.surface] (24), sem borda e com
/// a sombra quase imperceptível `AppShadows.tile`. A borda de 1px saiu porque
/// no Figma nenhuma superfície de conteúdo tem contorno — a separação vem só
/// da diferença entre a folha e o cartão.
/// Quando `interactive` e `onTap` estão presentes, o toque dispara ripple e o
/// widget é focável/ativável via teclado (Enter/Espaço), espelhando o
/// `role="button"` + `onKeyDown` do React.
///
/// `variant: inset` inverte a camada: bloco cinza [AppSemanticColors.bgSheet]
/// **sem elevação**, para conteúdo que vive sobre a folha branca das telas
/// fundas. `surface` (branco + sombra) só se lê contra o cinza da folha de
/// listagem; sobre o branco do cadastro ele vira branco-no-branco e a sombra
/// sozinha não sustenta a separação. O cinza sobre branco já é o idioma dos
/// campos do app (a cápsula de input é exatamente isso), então o bloco entra
/// no vocabulário que o usuário já lê, em vez de inventar um terceiro nível.
///
/// `glass` é o vidro fosco do formulário de login (Figma T003, node 6:100):
/// branco translúcido (`AppComponentColors.loginCardFill`) com blur do que
/// está atrás (`AppLayout.loginCardBlur`) — só faz sentido flutuando sobre
/// uma arte de fundo, nunca sobre a folha lisa das telas de cadastro.
enum AppCardVariant { surface, ink, inset, glass }

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.interactive = false,
    this.padded = true,
    this.variant = AppCardVariant.surface,
    this.onTap,
  });

  final Widget child;
  final bool interactive;
  final bool padded;
  final AppCardVariant variant;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final isInk = variant == AppCardVariant.ink;
    final isInset = variant == AppCardVariant.inset;
    final isGlass = variant == AppCardVariant.glass;
    final bg = switch (variant) {
      AppCardVariant.ink => semantic.inkBg,
      AppCardVariant.inset => semantic.bgInset,
      AppCardVariant.surface => semantic.bgRaised,
      AppCardVariant.glass => AppComponentColors.loginCardFill,
    };
    final fg = isInk ? semantic.inkFg : null;

    Widget content = AppInputSurface(
      backgroundColor: bg,
      child: Padding(
        padding: padded
            ? const EdgeInsets.all(AppSpacing.space5)
            : EdgeInsets.zero,
        child: child,
      ),
    );

    if (fg != null) {
      content = DefaultTextStyle.merge(
        style: TextStyle(color: fg),
        child: content,
      );
    }

    final radius = BorderRadius.circular(AppRadius.surface);

    final material = Material(
      color: isGlass ? bg : AppColors.transparent,
      child: interactive && onTap != null
          ? InkWell(onTap: onTap, child: content)
          : content,
    );

    return Container(
      decoration: BoxDecoration(
        color: isGlass ? null : bg,
        borderRadius: radius,
        boxShadow: isInset ? null : AppShadows.tile,
      ),
      child: ClipRRect(
        borderRadius: radius,
        // Vidro fosco: o blur precisa ficar dentro do clip, senão vaza para
        // fora do raio do cartão.
        child: isGlass
            ? BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: AppComponentMetrics.loginCardBlur,
                  sigmaY: AppComponentMetrics.loginCardBlur,
                ),
                child: material,
              )
            : material,
      ),
    );
  }
}

WidgetbookComponent buildCardWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'Card',
    useCases: [
      WidgetbookUseCase(
        name: 'Variantes',
        builder: (context) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 280,
                child: AppCard(child: Text('Card padrão (surface)')),
              ),
              const SizedBox(height: AppSpacing.space4),
              const SizedBox(
                width: 280,
                child: AppCard(
                  variant: AppCardVariant.ink,
                  child: Text('Card ink (hero)'),
                ),
              ),
              const SizedBox(height: AppSpacing.space4),
              SizedBox(
                width: 280,
                child: AppCard(
                  interactive: true,
                  onTap: () {},
                  child: const Text('Card interativo (toque)'),
                ),
              ),
              const SizedBox(height: AppSpacing.space4),
              // O `inset` só faz sentido lido sobre branco — é a camada que
              // as telas fundas usam, onde a folha é a superfície clara.
              const ColoredBox(
                color: AppColors.neutral0,
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.space4),
                  child: SizedBox(
                    width: 280,
                    child: AppCard(
                      variant: AppCardVariant.inset,
                      child: Text('Card inset (sobre folha branca)'),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.space4),
              // `glass` só faz sentido sobre uma arte de fundo (login, seleção
              // de ambiente) — aqui um gradiente simula essa arte.
              Container(
                width: 280,
                padding: const EdgeInsets.all(AppSpacing.space4),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.brand700, AppColors.amber600],
                  ),
                ),
                child: const AppCard(
                  variant: AppCardVariant.glass,
                  child: Text('Card glass (vidro fosco sobre arte)'),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
