import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../design/generated/app_layout.dart';
import '../../../design/generated/app_radius.dart';
import '../../../design/generated/app_spacing.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../ui/ui.dart';
import 'package:cerne_app/design/generated/app_colors.dart';
import 'package:cerne_app/design/generated/app_typography.dart';

/// Card de deep-link de crédito pré-aprovado (spec §6.4) — espelha
/// `CreditoBanner.tsx`: o dado/régua vive no módulo Crédito; aqui é só um
/// ponto de entrada com deep link entre módulos.
class CreditoBanner extends StatelessWidget {
  const CreditoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return Material(
      color: semantic.accentSubtle,
      borderRadius: BorderRadius.circular(AppRadius.xl3),
      child: AppPressable(
        semanticLabel: r'Abrir crédito pré-aprovado de R$ 480.000,00',
        onPressed: () => context.go('/credito'),
        borderRadius: BorderRadius.circular(AppRadius.xl3),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.space4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.xl3),
            border: Border.all(color: semantic.borderTint),
          ),
          child: Row(
            children: [
              Container(
                width: AppSize.control,
                height: AppSize.control,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: semantic.accentDefault,
                ),
                child: const AppIcon(
                  AppIcons.handCoins,
                  size: AppSize.iconMd,
                  color: AppColors.neutral0,
                ),
              ),
              const SizedBox(width: AppSpacing.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Crédito pré-aprovado',
                      style: TextStyle(
                        fontSize: AppTypography.base,
                        color: semantic.accentDefault,
                      ),
                    ),
                    Text(
                      'R\$ 480.000,00 disponíveis',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: AppTypography.weightBold,
                        color: semantic.fgDefault,
                      ),
                    ),
                    Text(
                      'Ver no módulo Crédito',
                      style: TextStyle(
                        fontSize: AppTypography.sm,
                        color: semantic.accentDefault,
                      ),
                    ),
                  ],
                ),
              ),
              AppIcon(
                AppIcons.arrowRight,
                size: AppSize.iconSmPlus,
                color: semantic.accentDefault,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
