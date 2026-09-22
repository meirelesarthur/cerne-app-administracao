import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import '../design/generated/app_colors.dart';
import '../design/generated/app_radius.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';

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

  ({Color bg, Color fg, Color border}) _colors() => switch (tone) {
    AppBannerTone.info => (
      bg: AppColors.blue50,
      fg: AppColors.blue700,
      border: AppColors.blue200,
    ),
    AppBannerTone.warning => (
      bg: AppColors.amber50,
      fg: AppColors.amber700,
      border: AppColors.amber200,
    ),
    AppBannerTone.success => (
      bg: AppColors.brand50,
      fg: AppColors.brand700,
      border: AppColors.brand200,
    ),
    AppBannerTone.error => (
      bg: AppColors.red50,
      fg: AppColors.red700,
      border: AppColors.red200,
    ),
    AppBannerTone.offline => (
      bg: AppColors.amber100,
      fg: AppColors.amber800,
      border: AppColors.amber300,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final colors = _colors();

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
