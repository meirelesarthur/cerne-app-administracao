import 'package:flutter/material.dart';

import '../../../design/generated/app_spacing.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../ui/ui.dart';
import '../mocks/estoque_mocks.dart';
import 'package:cerne_app/design/generated/app_typography.dart';

const Map<UnidadeStatus, ({AppChipTone tone, String label})> _statusChip = {
  UnidadeStatus.ok: (tone: AppChipTone.brand, label: 'Ok'),
  UnidadeStatus.atencao: (tone: AppChipTone.amber, label: 'Atenção'),
  UnidadeStatus.critico: (tone: AppChipTone.red, label: 'Crítico'),
};

const Map<UnidadeStatus, AppProgressBarTone> _progressTone = {
  UnidadeStatus.ok: AppProgressBarTone.brand,
  UnidadeStatus.atencao: AppProgressBarTone.amber,
  UnidadeStatus.critico: AppProgressBarTone.red,
};

/// Aba "Estoque": itens armazenados por unidade, com filtro por unidade
/// (spec D2.1). Aceita `unidadeId` inicial para chegar já filtrada a partir
/// do CTA do `UnidadeDetailSheet` (equivalente a `?unidade=<id>` na URL do
/// React). Espelha `EstoqueScreen.tsx`.
class EstoqueScreen extends StatefulWidget {
  const EstoqueScreen({super.key, this.initialUnidadeId});

  final String? initialUnidadeId;

  @override
  State<EstoqueScreen> createState() => _EstoqueScreenState();
}

class _EstoqueScreenState extends State<EstoqueScreen> {
  late String _unidadeId = widget.initialUnidadeId ?? '';

  String _unidadeNome(String id) {
    for (final u in unidades) {
      if (u.id == id) return u.nome;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final options = [
      const AppFormSelectOption(value: '', label: 'Todas as unidades'),
      for (final u in unidades) AppFormSelectOption(value: u.id, label: u.nome),
    ];

    final itens = _unidadeId.isEmpty
        ? itensEstoque
        : itensEstoque.where((it) => it.unidadeId == _unidadeId).toList();

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.space4),
      children: [
        const AppHeading(child: Text('Estoque')),
        const SizedBox(height: AppSpacing.space4),
        AppFormSelect(
          options: options,
          value: _unidadeId.isEmpty ? '' : _unidadeId,
          onChanged: (value) => setState(() => _unidadeId = value ?? ''),
        ),
        const SizedBox(height: AppSpacing.space4),
        if (itens.isEmpty)
          const AppEmptyState(
            icon: AppIcons.boxes,
            title: 'Nenhum item',
            description: 'Não há itens de estoque para esta unidade.',
          )
        else
          for (final it in itens)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.space3),
              child: _ItemEstoqueCard(
                item: it,
                unidadeNome: _unidadeNome(it.unidadeId),
              ),
            ),
      ],
    );
  }
}

class _ItemEstoqueCard extends StatelessWidget {
  const _ItemEstoqueCard({required this.item, required this.unidadeNome});

  final ItemEstoque item;
  final String unidadeNome;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final chip = _statusChip[item.status]!;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.produto,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: AppTypography.weightSemibold,
                    color: semantic.fgDefault,
                  ),
                ),
              ),
              AppChip(tone: chip.tone, child: Text(chip.label)),
            ],
          ),
          const SizedBox(height: AppSpacing.half),
          Text(
            unidadeNome,
            style: TextStyle(
              fontSize: AppTypography.sm,
              color: semantic.fgMuted,
            ),
          ),
          const SizedBox(height: AppSpacing.space3),
          Row(
            children: [
              Expanded(
                child: AppProgressBar(
                  value: item.ocupacaoPct.toDouble(),
                  tone: _progressTone[item.status]!,
                ),
              ),
              const SizedBox(width: AppSpacing.space3),
              Text(
                '${item.quantidadeLabel} / ${item.capacidadeLabel}',
                style: TextStyle(
                  fontSize: AppTypography.sm,
                  fontWeight: AppTypography.weightMedium,
                  color: semantic.fgMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
