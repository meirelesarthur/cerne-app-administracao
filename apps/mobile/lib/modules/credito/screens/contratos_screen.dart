import 'package:flutter/material.dart';

import '../../../design/generated/app_spacing.dart';
import '../../../design/generated/app_typography.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../ui/ui.dart';
import '../mocks/credito_mocks.dart';

/// Tela "Contratos" do módulo Crédito: contratos ativos do produtor com
/// progresso de parcelas pagas. Cada item abre um resumo (próxima parcela,
/// vencimento, saldo). Espelha `ContratosScreen.tsx`.
class ContratosScreen extends StatelessWidget {
  const ContratosScreen({super.key});

  void _abrirContrato(BuildContext context, Contrato contrato) {
    showAppDetailPage<void>(
      context,
      title: contrato.linha,
      child: _ContratoBottomSheetContent(contrato: contrato),
    );
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.space4),
      children: [
        const AppHeading(child: Text('Contratos')),
        const SizedBox(height: AppSpacing.space6),
        for (final contrato in contratos)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.space3),
            child: AppCard(
              interactive: true,
              onTap: () => _abrirContrato(context, contrato),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          contrato.linha,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: AppTypography.sm,
                            fontWeight: AppTypography.weightSemibold,
                            color: semantic.fgDefault,
                          ),
                        ),
                      ),
                      const AppChip(
                        tone: AppChipTone.brand,
                        child: Text('Em dia'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.space1),
                  Text(
                    contrato.valor,
                    style: TextStyle(
                      fontSize: AppTypography.lg,
                      fontWeight: AppTypography.weightBold,
                      color: semantic.fgDefault,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space3),
                  AppProgressBar(
                    value: contrato.parcelasPagas.toDouble(),
                    max: contrato.parcelasTotal.toDouble(),
                  ),
                  const SizedBox(height: AppSpacing.space1),
                  Text(
                    '${contrato.parcelasPagas} de ${contrato.parcelasTotal} parcelas pagas',
                    style: TextStyle(
                      fontSize: AppTypography.xs,
                      color: semantic.fgMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _ContratoBottomSheetContent extends StatelessWidget {
  const _ContratoBottomSheetContent({required this.contrato});

  final Contrato contrato;

  @override
  Widget build(BuildContext context) {
    return AppReviewList(
      items: [
        AppReviewItem(label: 'Próxima parcela', value: contrato.proximaParcela),
        AppReviewItem(label: 'Vencimento', value: contrato.vencimento),
        AppReviewItem(label: 'Saldo devedor', value: contrato.saldoDevedor),
      ],
    );
  }
}
