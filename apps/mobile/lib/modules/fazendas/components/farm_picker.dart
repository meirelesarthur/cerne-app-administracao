import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design/generated/app_spacing.dart';
import '../../../ui/ui.dart';
import '../state/fazendas_store.dart';
import '../types.dart';

/// Troca de fazenda (tenant) do módulo — fonte única da folha de seleção.
///
/// Existe como função de módulo, e não dentro de um widget, porque dois pontos
/// da interface abrem a mesma folha: a faixa `ContextBadge` da home legada e o
/// `AppFarmSelector` do cabeçalho das centrais. Antes a folha morava privada no
/// `ContextBadge`; o segundo consumidor teria que copiá-la (Lei 2).
void openFarmPicker(BuildContext context, WidgetRef ref) {
  final state = ref.read(fazendasStoreProvider);
  final notifier = ref.read(fazendasStoreProvider.notifier);

  showAppBottomSheet<void>(
    context,
    title: 'Trocar de fazenda',
    // fidelidade-esteira: lista de fazendas também precisa de busca — mesmo
    // padrão de "Buscar registros" da listagem do catálogo.
    child: _FarmPickerBody(
      farms: state.farms,
      activeFarmId: state.activeFarmId,
      onSelect: (farmId) {
        notifier.setActiveFarm(farmId);
        Navigator.of(context).pop();
      },
    ),
  );
}

class _FarmPickerBody extends StatefulWidget {
  const _FarmPickerBody({
    required this.farms,
    required this.activeFarmId,
    required this.onSelect,
  });

  final List<Farm> farms;
  final String activeFarmId;
  final ValueChanged<String> onSelect;

  @override
  State<_FarmPickerBody> createState() => _FarmPickerBodyState();
}

class _FarmPickerBodyState extends State<_FarmPickerBody> {
  var _query = '';

  @override
  Widget build(BuildContext context) {
    final query = _query.trim().toLowerCase();
    final filtered = query.isEmpty
        ? widget.farms
        : widget.farms
              .where(
                (farm) => [
                  farm.name,
                  farm.city,
                  farm.uf,
                ].join(' ').toLowerCase().contains(query),
              )
              .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppFormField(
          label: 'Buscar fazenda',
          child: AppTextInput(
            placeholder: 'Nome, cidade ou UF',
            prefixIcon: const AppIcon(AppIcons.search),
            onChanged: (value) => setState(() => _query = value),
          ),
        ),
        const SizedBox(height: AppSpacing.space3),
        if (filtered.isEmpty)
          const AppEmptyState(
            icon: AppIcons.search,
            title: 'Nenhuma fazenda encontrada',
            description: 'Ajuste a busca para encontrar outra fazenda.',
          )
        else
          for (final farm in filtered)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.space2),
              child: AppMenuItem(
                icon: AppIcons.mapPin,
                label: farm.name,
                description: '${farm.city} · ${farm.uf}',
                trailing: farm.id == widget.activeFarmId
                    ? const AppChip(child: Text('Ativa'))
                    : null,
                onTap: () => widget.onSelect(farm.id),
              ),
            ),
      ],
    );
  }
}
