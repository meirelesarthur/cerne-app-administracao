import 'package:flutter/material.dart';

import '../../design/generated/app_colors.dart';
import '../../design/generated/app_radius.dart';
import '../../design/generated/app_spacing.dart';
import '../../design/generated/app_typography.dart';
import '../../design/theme/app_theme_extension.dart';
import '../../ui/ui.dart';
import '../module_config.dart';
import '../state/prototype_session_store.dart';

/// Abas de contexto do módulo ativo: o segmented control do padrão global
/// (Figma `54333:417`) — trilho [AppSemanticColors.bgTrack] com raio
/// [AppRadius.tile] (20) e `p 4`, aba ativa com raio [AppRadius.lgPlus] (16),
/// rótulo de contraste, inativas transparentes com rótulo abafado, 14 px
/// SemiBold nos dois estados.
///
/// As abas sempre dividem a largura do trilho em partes iguais (`Expanded`),
/// em todos os módulos — nunca ficam encolhidas pelo conteúdo deixando trilho
/// vazio de um lado. Antes essa regra valia só para Fazendas/Administração; a
/// contagem de abas por módulo (2 a 4, sempre nomes curtos) nunca justificou a
/// exceção, e o trilho parcialmente vazio lia como estado quebrado.
///
/// A ação "Mais" não entra (vira bolha no header, ver `AppShellHeader`).
///
/// Sem `useLocation()`/go_router acoplado: quem chama calcula [activePath] a
/// partir da rota atual e recebe o toque em [onTabSelected] (path relativo,
/// ex.: '' ou 'atividades') para navegar.
class AppContextTabs extends StatelessWidget {
  const AppContextTabs({
    super.key,
    required this.module,
    required this.activePath,
    required this.onTabSelected,
    this.profile,
  });

  final ModuleDef module;
  final String activePath;
  final ValueChanged<String> onTabSelected;
  final UserAccessProfile? profile;

  /// Aba de 40 px do Figma mais os 4 px de respiro do trilho em cima e embaixo.
  static const double _trackHeight = AppSpacing.space12;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final tabs = visibleBottomTabs(
      module,
      profile,
    ).where((tab) => tab.action == null).toList();

    return Semantics(
      container: true,
      label: 'Navegação do módulo ${module.label}',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.space2),
        child: Container(
          height: _trackHeight,
          decoration: BoxDecoration(
            color: semantic.bgTrack,
            borderRadius: BorderRadius.circular(AppRadius.tile),
          ),
          padding: const EdgeInsets.all(AppSpacing.space1),
          child: Row(
            children: [
              for (var i = 0; i < tabs.length; i++) ...[
                if (i > 0) const SizedBox(width: AppSpacing.space1),
                Expanded(
                  child: _ContextTab(
                    tab: tabs[i],
                    activePath: activePath,
                    onTabSelected: onTabSelected,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ContextTab extends StatelessWidget {
  const _ContextTab({
    required this.tab,
    required this.activePath,
    required this.onTabSelected,
  });

  final BottomTab tab;
  final String activePath;
  final ValueChanged<String> onTabSelected;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final active = tab.path == activePath;

    return AppPressable(
      semanticLabel: tab.label,
      selected: active,
      onPressed: () => onTabSelected(tab.path),
      minTouchTarget: false,
      borderRadius: BorderRadius.circular(AppRadius.lgPlus),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? semantic.accentDefault : AppColors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.lgPlus),
        ),
        child: Text(
          tab.label,
          style: TextStyle(
            fontSize: AppTypography.md,
            fontWeight: AppTypography.weightSemibold,
            color: active ? semantic.accentContrast : semantic.fgMuted,
          ),
        ),
      ),
    );
  }
}
