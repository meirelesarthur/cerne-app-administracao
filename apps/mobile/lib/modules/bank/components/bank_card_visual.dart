import 'package:flutter/material.dart';

import '../../../design/generated/app_colors.dart';
import '../../../design/generated/app_spacing.dart';
import '../../../design/generated/app_typography.dart';
import '../../../mocks/bank_mocks.dart';

/// Espelha `BankCardVisual.tsx` — face do cartão corporativo GB: gradiente
/// premium (tokens `component.hub.bankCard`), reutilizado por `BankHome` e
/// `CartoesScreen` (fonte única, Lei 2). Sem raio de borda próprio — o
/// arredondamento/clip fica a cargo do `AppCard(padded: false)` que o envolve,
/// espelhando o `overflow-hidden` do `Card` pai no React.
class BankCardVisual extends StatelessWidget {
  const BankCardVisual({super.key, this.showNumber = true});

  /// Exibe o número do cartão (mascarado além dos 4 finais); default true.
  final bool showNumber;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppComponentColors.hubBankCardFrom,
            AppComponentColors.hubBankCardTo,
          ],
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.space5),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -32,
            top: -56,
            child: IgnorePointer(
              child: Container(
                width: 160,
                height: 160,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppComponentColors.hubBankCardGlow,
                      AppColors.transparent,
                    ],
                    stops: [0.0, 0.7],
                  ),
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          Cartao.tipo,
                          style: TextStyle(
                            fontSize: AppTypography.xs,
                            fontWeight: AppTypography.weightMedium,
                            color: AppComponentColors.hubBankCardFgMuted,
                          ),
                        ),
                        SizedBox(height: AppSpacing.half),
                        Text(
                          Cartao.titular,
                          style: TextStyle(
                            fontSize: AppTypography.sm,
                            fontWeight: AppTypography.weightSemibold,
                            color: AppColors.neutral0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    Cartao.bandeira,
                    style: TextStyle(
                      fontSize: AppTypography.sm,
                      fontWeight: AppTypography.weightBold,
                      fontStyle: FontStyle.italic,
                      color: AppColors.neutral0,
                    ),
                  ),
                ],
              ),
              if (showNumber)
                const Padding(
                  padding: EdgeInsets.only(top: AppSpacing.space6),
                  child: Text(
                    '•••• •••• •••• ${Cartao.finalNumero}',
                    style: TextStyle(
                      fontSize: AppTypography.lg,
                      fontWeight: AppTypography.weightSemibold,
                      color: AppColors.neutral0,
                      letterSpacing: 2,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              const Padding(
                padding: EdgeInsets.only(top: AppSpacing.space4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'VALIDADE',
                            style: TextStyle(
                              fontSize: AppTypography.xs,
                              color: AppComponentColors.hubBankCardFgMuted,
                              letterSpacing: 0.4,
                            ),
                          ),
                          Text(
                            Cartao.validade,
                            style: TextStyle(
                              fontSize: AppTypography.sm,
                              fontWeight: AppTypography.weightSemibold,
                              color: AppColors.neutral0,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Final ${Cartao.finalNumero}',
                      style: TextStyle(
                        fontSize: AppTypography.xs,
                        fontWeight: AppTypography.weightMedium,
                        color: AppComponentColors.hubBankCardFgMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
