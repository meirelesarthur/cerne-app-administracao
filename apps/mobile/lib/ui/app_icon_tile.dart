import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'app_icon.dart';
import '../design/generated/app_radius.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';

/// Tamanhos do tile: [large] para a área de trabalho/pasta (ícone de app real),
/// [small] para o dock (mesma proporção do Android, sem rótulo por padrão).
enum AppAppIconTileSize { large, small }

/// Ícone de app estilo launcher Android — quadrado arredondado ("squircle") +
/// rótulo abaixo.
///
/// Deriva do mesmo padrão de [AppQuickAction] (círculo + rótulo, ação do hub),
/// mas com forma de "squircle" — a leitura visual precisa ser "ícone de app",
/// não "ação rápida".
class AppAppIconTile extends StatelessWidget {
  const AppAppIconTile({
    super.key,
    required this.icon,
    required this.label,
    this.size = AppAppIconTileSize.large,
    this.showLabel = true,
    this.iconColor,
    this.tileColor,
    this.labelColor,
    this.onTap,
  });

  /// Ícone do app — sempre uma entrada de `AppIcons`.
  final AppIconData icon;
  final String label;
  final AppAppIconTileSize size;

  /// Quando falso, o rótulo some visualmente mas continua disponível via
  /// `Semantics` (ex.: ícones decorativos do dock, que no Android real também
  /// não mostram texto).
  final bool showLabel;
  final Color? iconColor;
  final Color? tileColor;

  /// Sobrescreve a cor do rótulo — padrão `fgInverse` (área de trabalho/dock,
  /// sempre sobre fundo escuro). Telas com o tile sobre cartão claro (pasta
  /// "CERNE App" em vidro fosco) passam `fgDefault`.
  final Color? labelColor;
  final VoidCallback? onTap;

  double get _tileSize => switch (size) {
    AppAppIconTileSize.large => AppSpacing.space16,
    AppAppIconTileSize.small => AppSpacing.space14,
  };

  double get _iconSize => switch (size) {
    AppAppIconTileSize.large => 28,
    AppAppIconTileSize.small => 22,
  };

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return Semantics(
      button: onTap != null,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: _tileSize,
              height: _tileSize,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: tileColor ?? semantic.bgSurface,
                borderRadius: BorderRadius.circular(AppRadius.xl2),
                boxShadow: semantic.shadowCard,
              ),
              child: AppIcon(
                icon,
                size: _iconSize,
                color: iconColor ?? semantic.accentDefault,
              ),
            ),
            if (showLabel) ...[
              const SizedBox(height: AppSpacing.space2),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: AppTypography.xs,
                  fontWeight: AppTypography.weightSemibold,
                  color: labelColor ?? semantic.fgInverse,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

WidgetbookComponent buildAppIconTileWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'AppIconTile',
    useCases: [
      WidgetbookUseCase(
        name: 'Área de trabalho / pasta',
        builder: (context) => Container(
          color: Theme.of(context).extension<AppSemanticColors>()!.inkBg,
          padding: const EdgeInsets.all(AppSpacing.space6),
          child: const Wrap(
            spacing: AppSpacing.space6,
            runSpacing: AppSpacing.space6,
            children: [
              AppAppIconTile(icon: AppIcons.layoutGrid, label: 'CERNE App'),
              AppAppIconTile(icon: AppIcons.shieldCheck, label: 'CERNE ADM'),
              AppAppIconTile(icon: AppIcons.tractor, label: 'CERNE Operação'),
            ],
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Dock (decorativo, sem rótulo)',
        builder: (context) => Container(
          color: Theme.of(context).extension<AppSemanticColors>()!.inkBg,
          padding: const EdgeInsets.all(AppSpacing.space6),
          child: const Wrap(
            spacing: AppSpacing.space4,
            children: [
              AppAppIconTile(
                icon: AppIcons.phone,
                label: 'Telefone',
                size: AppAppIconTileSize.small,
                showLabel: false,
              ),
              AppAppIconTile(
                icon: AppIcons.camera,
                label: 'Câmera',
                size: AppAppIconTileSize.small,
                showLabel: false,
              ),
              AppAppIconTile(
                icon: AppIcons.messageCircle,
                label: 'Mensagens',
                size: AppAppIconTileSize.small,
                showLabel: false,
              ),
              AppAppIconTile(
                icon: AppIcons.globe,
                label: 'Navegador',
                size: AppAppIconTileSize.small,
                showLabel: false,
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
