import 'package:flutter/material.dart';

import '../../../design/generated/app_radius.dart';
import '../../../design/generated/app_spacing.dart';
import '../../../design/generated/app_typography.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../shared/rise_in.dart';
import '../../../ui/ui.dart';
import '../components/activity_detail_sheet.dart';
import '../components/activity_list_item.dart';
import '../mocks/atividades.dart';
import '../types.dart';

/// Aba "Atividades" — lista cronológica completa (spec §6.7). Espelha
/// `AtividadesScreen.tsx`.
class AtividadesScreen extends StatefulWidget {
  const AtividadesScreen({super.key});

  @override
  State<AtividadesScreen> createState() => _AtividadesScreenState();
}

class _AtividadesScreenState extends State<AtividadesScreen> {
  static const _pageSize = 4;
  var _page = 0;

  int get _pageCount => (atividades.length / _pageSize).ceil();

  List<Activity> get _currentActivities {
    final start = _page * _pageSize;
    final end = (start + _pageSize).clamp(0, atividades.length);
    return atividades.sublist(start, end);
  }

  void _setPage(int page) {
    if (page < 0 || page >= _pageCount || page == _page) return;
    setState(() => _page = page);
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final pageActivities = _currentActivities;
    final firstItem = pageActivities.isEmpty ? 0 : _page * _pageSize + 1;
    final lastItem = _page * _pageSize + pageActivities.length;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.space4),
      children: [
        const RiseIn(child: AppHeading(child: Text('Atividades'))),
        const SizedBox(height: AppSpacing.space3),
        RiseIn(
          index: 1,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space3),
            decoration: BoxDecoration(
              color: semantic.bgSurface,
              borderRadius: BorderRadius.circular(AppRadius.xl3),
              border: Border.all(color: semantic.borderDefault),
            ),
            child: Column(
              children: [
                for (final a in pageActivities)
                  ActivityListItem(
                    activity: a,
                    showDivider: a != pageActivities.last,
                    onTap: () => showActivityDetailSheet(context, activity: a),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.space3),
        Semantics(
          container: true,
          label: 'Paginação das atividades',
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Exibindo $firstItem–$lastItem de ${atividades.length}',
                  style: TextStyle(
                    fontSize: AppTypography.sm,
                    color: semantic.fgMuted,
                  ),
                ),
              ),
              Text(
                'Página ${_page + 1} de $_pageCount',
                style: TextStyle(
                  fontSize: AppTypography.sm,
                  fontWeight: AppTypography.weightSemibold,
                  color: semantic.fgDefault,
                ),
              ),
              const SizedBox(width: AppSpacing.space1),
              AppIconButton(
                label: 'Página anterior',
                icon: const AppIcon(AppIcons.chevronLeft),
                onPressed: _page > 0 ? () => _setPage(_page - 1) : null,
              ),
              AppIconButton(
                label: 'Próxima página',
                icon: const AppIcon(AppIcons.chevronRight),
                onPressed: _page + 1 < _pageCount
                    ? () => _setPage(_page + 1)
                    : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
