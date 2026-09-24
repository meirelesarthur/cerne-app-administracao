import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'app_icon.dart';
import '../design/generated/app_radius.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';
import 'chip.dart';
import '../design/generated/app_layout.dart';

/// Espelha o selo de estado opcional de `MiniAppTile.tsx`
/// (`badge?: 'novo' | 'breve'`).
enum AppMiniAppTileBadge { novo, breve }

/// Espelha `MiniAppTile.tsx` — tile de mini-app do hub agregador (New-UI).
/// Contrato visual único para injeção contínua de novos apps sem quebrar a
/// arquitetura da informação: ícone tokenizado + nome + descrição + selo.
class AppMiniAppTile extends StatelessWidget {
  const AppMiniAppTile({
    super.key,
    required this.icon,
    required this.name,
    this.description,
    this.badge,
    this.disabled = false,
    this.onTap,
  });

  /// Ícone do mini-app — sempre uma entrada de `AppIcons`.
  final AppIconData icon;
  final String name;
  final String? description;
  final AppMiniAppTileBadge? badge;
  final bool disabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return Opacity(
      opacity: disabled ? 0.5 : 1,
      child: Material(
        color: semantic.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.xl2),
        // shadow-card do React — sombra semântica do tema.
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.xl2),
            border: Border.all(color: semantic.borderSubtle),
            boxShadow: semantic.shadowCard,
          ),
          child: InkWell(
            onTap: disabled ? null : onTap,
            borderRadius: BorderRadius.circular(AppRadius.xl2),
            child: Container(
              constraints: const BoxConstraints(minHeight: 96),
              padding: const EdgeInsets.all(AppSpacing.space3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: AppSpacing.space10,
                        height: AppSpacing.space10,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          color: semantic.accentSubtle,
                          border: Border.all(color: semantic.borderTint),
                        ),
                        // O traço é o do sistema (`AppSize.iconStroke`),
                        // aplicado por `AppIcon`; aqui só o tamanho é local.
                        child: AppIcon(
                          icon,
                          size: AppSize.iconMd,
                          color: semantic.accentDefault,
                        ),
                      ),
                      if (badge == AppMiniAppTileBadge.novo)
                        const AppChip(
                          tone: AppChipTone.brand,
                          child: Text('Novo'),
                        ),
                      if (badge == AppMiniAppTileBadge.breve)
                        const AppChip(child: Text('Em breve')),
                    ],
                  ),
                  Padding(
                    // gap-2 (space2) do React entre o cabeçalho e o texto.
                    padding: const EdgeInsets.only(top: AppSpacing.space2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: AppTypography.sm,
                            fontWeight: AppTypography.weightSemibold,
                            color: semantic.fgDefault,
                          ),
                        ),
                        if (description != null)
                          Padding(
                            // mt-0.5 (2px) do React — valor fixo fora da escala
                            // de espaçamento, igual ao padrão de `chip.dart`.
                            padding: const EdgeInsets.only(
                              top: AppSpacing.half,
                            ),
                            child: Text(
                              description!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: AppTypography.sm,
                                height: AppTypography.lineHeightSnug,
                                color: semantic.fgMuted,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

WidgetbookComponent buildMiniAppTileWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'MiniAppTile',
    useCases: [
      WidgetbookUseCase(
        name: 'Estados',
        builder: (context) => Center(
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: 160,
                child: AppMiniAppTile(
                  icon: AppIcons.landmark,
                  name: 'GB Bank',
                  description: 'Conta digital do produtor rural',
                  onTap: () {},
                ),
              ),
              SizedBox(
                width: 160,
                child: AppMiniAppTile(
                  icon: AppIcons.handshake,
                  name: 'Crédito',
                  description: 'Linhas de crédito sob medida',
                  badge: AppMiniAppTileBadge.novo,
                  onTap: () {},
                ),
              ),
              const SizedBox(
                width: 160,
                child: AppMiniAppTile(
                  icon: AppIcons.store,
                  name: 'Marketplace',
                  description: 'Compra e venda de insumos',
                  badge: AppMiniAppTileBadge.breve,
                  disabled: true,
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
