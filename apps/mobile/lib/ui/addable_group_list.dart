import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'app_icon.dart';
import '../design/generated/app_radius.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';
import 'button.dart';
import 'chip.dart';

class AppAddableGroupList extends StatelessWidget {
  const AppAddableGroupList({
    super.key,
    required this.groups,
    required this.counts,
    required this.onAdd,
  });

  final List<String> groups;
  final Map<String, int> counts;
  final ValueChanged<String> onAdd;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < groups.length; index++) ...[
          _GroupRow(
            group: groups[index],
            count: counts[groups[index]] ?? 0,
            onAdd: () => onAdd(groups[index]),
          ),
          if (index < groups.length - 1)
            const SizedBox(height: AppSpacing.space2),
        ],
      ],
    );
  }
}

class _GroupRow extends StatelessWidget {
  const _GroupRow({
    required this.group,
    required this.count,
    required this.onAdd,
  });

  final String group;
  final int count;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final description = count == 0
        ? 'Nenhum item adicionado'
        : '$count item(ns) adicionado(s)';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.space3),
      decoration: BoxDecoration(
        color: semantic.bgSubtle,
        borderRadius: BorderRadius.circular(AppRadius.xl2),
        border: Border.all(color: semantic.borderDefault),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final info = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                group,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: AppTypography.sm,
                  fontWeight: AppTypography.weightSemibold,
                  color: semantic.fgDefault,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: AppTypography.xs,
                  color: semantic.fgMuted,
                ),
              ),
            ],
          );
          final action = AppButton(
            size: AppButtonSize.sm,
            variant: AppButtonVariant.secondary,
            leftIcon: const AppIcon(AppIcons.plus, size: AppSpacing.space4),
            onPressed: onAdd,
            child: const Text('Adicionar'),
          );
          final compact = constraints.maxWidth < AppSpacing.space20 * 4;

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                info,
                if (count > 0) ...[
                  const SizedBox(height: AppSpacing.space2),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: AppChip(
                      tone: AppChipTone.brand,
                      child: Text('$count'),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.space2),
                action,
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: info),
              if (count > 0) ...[
                const SizedBox(width: AppSpacing.space2),
                AppChip(tone: AppChipTone.brand, child: Text('$count')),
              ],
              const SizedBox(width: AppSpacing.space2),
              action,
            ],
          );
        },
      ),
    );
  }
}

WidgetbookComponent buildAddableGroupListWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'AddableGroupList',
    useCases: [
      WidgetbookUseCase(
        name: 'Grupos repetíveis',
        builder: (context) => const _AddableGroupListUseCase(),
      ),
    ],
  );
}

class _AddableGroupListUseCase extends StatefulWidget {
  const _AddableGroupListUseCase();

  @override
  State<_AddableGroupListUseCase> createState() =>
      _AddableGroupListUseCaseState();
}

class _AddableGroupListUseCaseState extends State<_AddableGroupListUseCase> {
  final _counts = <String, int>{};

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: AppSpacing.space20 * 5,
        child: AppAddableGroupList(
          groups: const ['Matérias-primas', 'Máquinas'],
          counts: _counts,
          onAdd: (group) =>
              setState(() => _counts[group] = (_counts[group] ?? 0) + 1),
        ),
      ),
    );
  }
}
