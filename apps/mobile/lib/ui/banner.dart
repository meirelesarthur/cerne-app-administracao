import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'chip.dart';
import '../design/generated/app_radius.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';

/// Espelha `Banner.tsx` — faixa fina no topo do conteúdo (spec §6.10),
/// usada para avisos offline/sync e contextuais.
enum AppBannerTone { info, warning, success, error, offline }

class AppBanner extends StatelessWidget {
  const AppBanner({
    super.key,
    required this.child,
    this.tone = AppBannerTone.info,
    this.icon,
    this.action,
  });

  final Widget child;
  final AppBannerTone tone;
  final Widget? icon;
  final Widget? action;

  // Tons theme-aware (auditoria de UX): no modo GB o banner deixa de ser um
  // bloco pastel claro. "offline" usa o âmbar, como o aviso.
  ({Color bg, Color fg, Color border}) _colors(AppSemanticColors s) =>
      appToneColors(s, switch (tone) {
        AppBannerTone.info => AppChipTone.blue,
        AppBannerTone.warning => AppChipTone.amber,
        AppBannerTone.success => AppChipTone.brand,
        AppBannerTone.error => AppChipTone.red,
        AppBannerTone.offline => AppChipTone.amber,
      });

  @override
  Widget build(BuildContext context) {
    final colors = _colors(Theme.of(context).extension<AppSemanticColors>()!);

    return Semantics(
      liveRegion: true,
      child: Container(
        margin: const EdgeInsets.fromLTRB(
          AppSpacing.space4,
          AppSpacing.space2,
          AppSpacing.space4,
          0,
        ),
        // `py-2.5` (10px) do React não tem token exato em AppSpacing — derivado da média
        // entre space2 (8) e space3 (12), preservando a fonte única de tokens.
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space4,
          vertical: (AppSpacing.space2 + AppSpacing.space3) / 2,
        ),
        decoration: BoxDecoration(
          color: colors.bg,
          borderRadius: BorderRadius.circular(AppRadius.xl2),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              IconTheme.merge(
                data: IconThemeData(color: colors.fg),
                child: icon!,
              ),
              const SizedBox(width: AppSpacing.space2),
            ],
            Expanded(
              child: DefaultTextStyle(
                style: TextStyle(
                  fontSize: AppTypography.sm,
                  fontWeight: AppTypography.weightMedium,
                  color: colors.fg,
                ),
                child: child,
              ),
            ),
            if (action != null) ...[
              const SizedBox(width: AppSpacing.space2),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

WidgetbookComponent buildBannerWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'Banner',
    useCases: [
      WidgetbookUseCase(
        name: 'Tons',
        builder: (context) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppBanner(child: Text('Informação contextual.')),
              const SizedBox(height: AppSpacing.space2),
              const AppBanner(
                tone: AppBannerTone.warning,
                child: Text('Atenção: revise os dados.'),
              ),
              const SizedBox(height: AppSpacing.space2),
              const AppBanner(
                tone: AppBannerTone.success,
                child: Text('Operação concluída com sucesso.'),
              ),
              const SizedBox(height: AppSpacing.space2),
              const AppBanner(
                tone: AppBannerTone.error,
                child: Text('Falha ao processar a solicitação.'),
              ),
              const SizedBox(height: AppSpacing.space2),
              AppBanner(
                tone: AppBannerTone.offline,
                action: TextButton(
                  onPressed: () {},
                  child: const Text('Tentar novamente'),
                ),
                child: const Text('Você está offline. Sincronizando...'),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
