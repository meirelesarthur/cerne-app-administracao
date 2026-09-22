import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design/generated/app_radius.dart';
import '../../../design/generated/app_spacing.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../shared/rise_in.dart';
import '../../../ui/ui.dart';
import '../state/fazendas_store.dart';
import 'package:cerne_app/design/generated/app_colors.dart';
import 'package:cerne_app/design/generated/app_typography.dart';
import '../../../design/generated/app_layout.dart';

/// Aba "Fazendas" — espelha `FarmListScreen.tsx`: lista de fazendas vinculadas;
/// toque troca o tenant ativo.
class FarmListScreen extends ConsumerWidget {
  const FarmListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final farms = ref.watch(fazendasStoreProvider.select((s) => s.farms));
    final activeFarmId = ref.watch(
      fazendasStoreProvider.select((s) => s.activeFarmId),
    );
    final notifier = ref.read(fazendasStoreProvider.notifier);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.space4),
      children: [
        const RiseIn(child: AppHeading(child: Text('Minhas fazendas'))),
        const SizedBox(height: AppSpacing.space3),
        for (var i = 0; i < farms.length; i++)
          RiseIn(
            index: i + 1,
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.space2),
              child: _FarmRow(
                active: farms[i].id == activeFarmId,
                name: farms[i].name,
                city: farms[i].city,
                uf: farms[i].uf,
                onTap: () => notifier.setActiveFarm(farms[i].id),
                semantic: semantic,
              ),
            ),
          ),
      ],
    );
  }
}

class _FarmRow extends StatelessWidget {
  const _FarmRow({
    required this.active,
    required this.name,
    required this.city,
    required this.uf,
    required this.onTap,
    required this.semantic,
  });

  final bool active;
  final String name;
  final String city;
  final String uf;
  final VoidCallback onTap;
  final AppSemanticColors semantic;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? semantic.accentSubtle : semantic.bgSurface,
      borderRadius: BorderRadius.circular(AppRadius.xl3),
      child: AppPressable(
        semanticLabel: active
            ? '$name, fazenda ativa'
            : 'Selecionar fazenda $name',
        selected: active,
        onPressed: onTap,
        borderRadius: BorderRadius.circular(AppRadius.xl3),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.space3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.xl3),
            border: Border.all(
              color: active ? semantic.accentDefault : semantic.borderDefault,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: AppSpacing.space10 + AppSpacing.space1,
                height: AppSpacing.space10 + AppSpacing.space1,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: semantic.accentDefault,
                ),
                child: const AppIcon(
                  AppIcons.leaf,
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
                      name,
                      style: TextStyle(
                        fontWeight: AppTypography.weightSemibold,
                        color: semantic.fgDefault,
                      ),
                    ),
                    Text(
                      '$city/$uf',
                      style: TextStyle(
                        fontSize: AppTypography.base,
                        color: semantic.fgMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (active)
                const AppChip(
                  tone: AppChipTone.brand,
                  icon: AppIcon(AppIcons.check),
                  child: Text('Ativa'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
