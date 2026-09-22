import 'package:flutter/material.dart';

import '../../../design/generated/app_spacing.dart';
import '../../../ui/ui.dart';
import '../components/unidade_card.dart';
import '../components/unidade_detail_sheet.dart';
import '../mocks/estoque_mocks.dart';

/// Aba "Unidades": lista completa das unidades de armazenagem (spec D2.6).
/// Espelha `UnidadesScreen.tsx`.
class UnidadesScreen extends StatelessWidget {
  const UnidadesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.space4),
      children: [
        const AppHeading(child: Text('Unidades')),
        const SizedBox(height: AppSpacing.space3),
        for (final unidade in unidades)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.space3),
            child: UnidadeCard(
              unidade: unidade,
              onTap: () => showUnidadeDetailSheet(context, unidade: unidade),
            ),
          ),
      ],
    );
  }
}
