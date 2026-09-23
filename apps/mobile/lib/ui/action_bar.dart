import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'app_icon.dart';
import 'button.dart';
import 'progress_bar.dart';
import '../design/generated/app_layout.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';

/// Barra de ação fixa do rodapé — os dois frames de cadastro do Figma
/// (`Cadastro bottom fixed` `54300:16033` e `Cadastro steps` `54349:2060`).
///
/// Anatomia: **sem superfície própria** — nem fundo nem sombra —, `px 16 /
/// py 8`, gap 8, e um ou dois botões-pílula ocupando a largura inteira. Os
/// botões flutuam sobre o fundo que estiver atrás (a folha da tela, branca ou
/// cinza); a faixa cinza com sombra do Figma original foi descartada porque
/// criava uma caixa destacada da folha em toda tela com rodapé fixo. O frame *bottom fixed*
/// acrescenta acima dos botões uma linha de resumo com dois pares
/// rótulo/valor e uma barra de progresso ("Fornecido 250kg — Faltam 250kg").
///
/// Os rótulos entram como `String`, não como `Widget`: é o único lugar do
/// sistema onde a referência pede caixa alta, e a transformação precisa
/// acontecer em algum lugar. Fazê-la aqui mantém `AppButton` genérico e evita
/// que cada tela lembre (ou esqueça) de escrever o CTA em maiúsculas.
class AppActionBar extends StatelessWidget {
  const AppActionBar({
    super.key,
    required this.primaryLabel,
    this.onPrimary,
    this.primaryIcon,
    this.primaryLoading = false,
    this.secondaryLabel,
    this.onSecondary,
    this.summary,
    this.primarySize = AppButtonSize.lg,
  });

  final String primaryLabel;
  final VoidCallback? onPrimary;

  /// `lg` é o CTA padrão de formulário; listagens (fidelidade-esteira) usam
  /// `xl` — 56px, raio `AppRadius.tile` — para o botão flutuante fixo no
  /// rodapé.
  final AppButtonSize primarySize;

  /// Ícone à direita do rótulo — o `SaveAllIcon` do Figma (54349:2070).
  final AppIconData? primaryIcon;
  final bool primaryLoading;

  /// Ação de escape. No Figma é "Cancelar", em contorno vermelho.
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  /// Faixa acima dos botões. No frame *bottom fixed* é um
  /// [AppActionBarSummary]; o app também usa para o aviso de fila offline.
  /// Widget e não tipo fechado porque a referência define a *posição*, não o
  /// conteúdo — e o que cabe ali varia por fluxo.
  final Widget? summary;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return SizedBox(
      width: double.infinity,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space4,
            vertical: AppSpacing.space2,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (summary != null) ...[
                summary!,
                const SizedBox(height: AppSpacing.space2),
              ],
              // A caixa alta é decisão visual da referência, não do conteúdo:
              // o `Semantics` mantém o rótulo em caixa natural para que o
              // leitor de tela não soletre a palavra letra a letra.
              Semantics(
                label: primaryLabel,
                child: AppButton(
                  size: primarySize,
                  fullWidth: true,
                  loading: primaryLoading,
                  onPressed: onPrimary,
                  rightIcon: primaryIcon == null
                      ? null
                      : AppIcon(
                          primaryIcon!,
                          size: AppSize.iconMd,
                          color: semantic.ctaFg,
                        ),
                  child: ExcludeSemantics(
                    child: Text(primaryLabel.toUpperCase()),
                  ),
                ),
              ),
              if (secondaryLabel != null) ...[
                const SizedBox(height: AppSpacing.space2),
                Semantics(
                  label: secondaryLabel,
                  child: AppButton(
                    size: AppButtonSize.lg,
                    fullWidth: true,
                    variant: AppButtonVariant.dangerOutline,
                    onPressed: onSecondary,
                    child: ExcludeSemantics(
                      child: Text(secondaryLabel!.toUpperCase()),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Resumo de progresso acima do CTA (Figma `54300:16057`): dois pares
/// rótulo/valor nas extremidades e a barra preenchida logo abaixo.
class AppActionBarSummary extends StatelessWidget {
  const AppActionBarSummary({
    super.key,
    required this.leadingLabel,
    required this.leadingValue,
    required this.trailingLabel,
    required this.trailingValue,
    required this.value,
    this.max = 100,
  });

  final String leadingLabel;
  final String leadingValue;
  final String trailingLabel;
  final String trailingValue;
  final double value;
  final double max;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    final label = TextStyle(
      fontSize: AppTypography.md,
      color: semantic.fgMuted,
    );
    final strong = TextStyle(
      fontSize: AppTypography.md,
      fontWeight: AppTypography.weightSemibold,
      color: semantic.fgDefault,
    );

    Widget pair(String caption, String amount) => Text.rich(
      TextSpan(
        children: [
          TextSpan(text: '$caption ', style: label),
          TextSpan(text: amount, style: strong),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(child: pair(leadingLabel, leadingValue)),
            const SizedBox(width: AppSpacing.space2),
            Flexible(child: pair(trailingLabel, trailingValue)),
          ],
        ),
        const SizedBox(height: AppSpacing.space1),
        AppProgressBar(value: value, max: max),
      ],
    );
  }
}

WidgetbookComponent buildActionBarWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'ActionBar',
    useCases: [
      WidgetbookUseCase(
        name: 'Fluxo longo (duas ações)',
        builder: (context) => Align(
          alignment: Alignment.bottomCenter,
          child: AppActionBar(
            primaryLabel: 'Próximo',
            primaryIcon: AppIcons.saveAll,
            onPrimary: () {},
            secondaryLabel: 'Cancelar',
            onSecondary: () {},
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Fluxo curto (com resumo)',
        builder: (context) => Align(
          alignment: Alignment.bottomCenter,
          child: AppActionBar(
            primaryLabel: 'Finalizar trato',
            primaryIcon: AppIcons.saveAll,
            onPrimary: () {},
            summary: const AppActionBarSummary(
              leadingLabel: 'Fornecido',
              leadingValue: '250kg',
              trailingLabel: 'Faltam',
              trailingValue: '250kg',
              value: 50,
            ),
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Salvando',
        builder: (context) => const Align(
          alignment: Alignment.bottomCenter,
          child: AppActionBar(primaryLabel: 'Salvar', primaryLoading: true),
        ),
      ),
      WidgetbookUseCase(
        name: 'Listagem (CTA flutuante)',
        builder: (context) => Align(
          alignment: Alignment.bottomCenter,
          child: AppActionBar(
            primaryLabel: 'Adicionar registro',
            primaryIcon: AppIcons.plus,
            primarySize: AppButtonSize.xl,
            onPrimary: () {},
          ),
        ),
      ),
    ],
  );
}
