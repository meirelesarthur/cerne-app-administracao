import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import '../../design/generated/app_colors.dart';
import '../../design/generated/app_radius.dart';
import '../../design/generated/app_spacing.dart';
import '../../design/generated/app_typography.dart';
import '../../design/theme/app_theme_extension.dart';
import '../../ui/ui.dart';
import '../../design/generated/app_layout.dart';

/// Padrão de tela "Listagem" (Widgetbook → Padrões).
///
/// Documenta a composição já usada em
/// `modules/fazendas/screens/farm_list_screen.dart`: linhas selecionáveis com
/// `AppPressable`, indicação do item ativo via `AppChip`, e o par de estados
/// que toda listagem real deveria tratar — populada e vazia (`AppEmptyState`).
class _ListingItem {
  const _ListingItem({required this.name, required this.subtitle});
  final String name;
  final String subtitle;
}

const _mockItems = [
  _ListingItem(name: 'Fazenda Santa Rita', subtitle: 'Uberaba/MG'),
  _ListingItem(name: 'Fazenda Boa Vista', subtitle: 'Rio Verde/GO'),
  _ListingItem(name: 'Fazenda Água Limpa', subtitle: 'Barreiras/BA'),
];

class _ListingPatternExample extends StatefulWidget {
  const _ListingPatternExample();

  @override
  State<_ListingPatternExample> createState() => _ListingPatternExampleState();
}

class _ListingPatternExampleState extends State<_ListingPatternExample> {
  int _activeIndex = 0;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return Container(
      color: semantic.bgCanvas,
      padding: const EdgeInsets.all(AppSpacing.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppHeading(child: Text('Minhas fazendas')),
          const SizedBox(height: AppSpacing.space3),
          for (var i = 0; i < _mockItems.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.space2),
              child: _ListingRow(
                active: i == _activeIndex,
                name: _mockItems[i].name,
                subtitle: _mockItems[i].subtitle,
                onTap: () => setState(() => _activeIndex = i),
                semantic: semantic,
              ),
            ),
        ],
      ),
    );
  }
}

class _ListingRow extends StatelessWidget {
  const _ListingRow({
    required this.active,
    required this.name,
    required this.subtitle,
    required this.onTap,
    required this.semantic,
  });

  final bool active;
  final String name;
  final String subtitle;
  final VoidCallback onTap;
  final AppSemanticColors semantic;

  @override
  Widget build(BuildContext context) {
    return AppPressable(
      semanticLabel: active ? '$name, item ativo' : 'Selecionar $name',
      selected: active,
      onPressed: onTap,
      borderRadius: BorderRadius.circular(AppRadius.xl3),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.space3),
        decoration: BoxDecoration(
          color: active ? semantic.accentSubtle : semantic.bgSurface,
          borderRadius: BorderRadius.circular(AppRadius.xl3),
          border: Border.all(
            color: active ? semantic.accentDefault : semantic.borderDefault,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: AppSpacing.space10,
              height: AppSpacing.space10,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: semantic.accentDefault,
              ),
              child: const AppIcon(
                AppIcons.leaf,
                size: AppSize.iconSmPlus,
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
                  Text(subtitle, style: TextStyle(color: semantic.fgMuted)),
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
    );
  }
}

WidgetbookComponent buildListingPatternWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'Listagem',
    useCases: [
      WidgetbookUseCase(
        name: 'Populada',
        builder: (context) => const _ListingPatternExample(),
      ),
      WidgetbookUseCase(
        name: 'Vazia',
        builder: (context) => Container(
          color: Theme.of(context).extension<AppSemanticColors>()!.bgCanvas,
          child: const Center(
            child: AppEmptyState(
              icon: AppIcons.tractor,
              title: 'Nenhuma fazenda cadastrada',
              description:
                  'Cadastre a primeira fazenda para começar a operar por aqui.',
            ),
          ),
        ),
      ),
    ],
  );
}
