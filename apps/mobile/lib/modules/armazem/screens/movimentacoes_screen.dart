import 'package:flutter/material.dart';

import '../../../design/generated/app_spacing.dart';
import '../../../ui/ui.dart';
import '../components/movimentacao_detail_sheet.dart';
import 'package:cerne_app/modules/armazem/lib/movimentacoes.dart';
import '../mocks/estoque_mocks.dart';

/// Aba "Movimentações": lista completa de entradas/saídas do armazém (spec
/// D2.2). Espelha `MovimentacoesScreen.tsx`.
class MovimentacoesScreen extends StatelessWidget {
  const MovimentacoesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.space4),
      children: [
        const AppHeading(child: Text('Movimentações')),
        const SizedBox(height: AppSpacing.space4),
        AppCard(
          padded: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4),
            child: Column(
              children: [
                for (final mov in movimentacoes)
                  AppTransactionListItem(
                    transaction: toTransactionItem(mov),
                    onTap: () =>
                        showMovimentacaoDetailSheet(context, movimentacao: mov),
                    showDivider: mov != movimentacoes.last,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
