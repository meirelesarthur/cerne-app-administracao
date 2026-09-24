import 'package:flutter/material.dart';

import '../../ui/ui.dart';
import '../module_config.dart';

/// Navegação global do ADM — os módulos disponíveis aparecem como ícones, e o
/// módulo ativo sobe num hexágono verde enquanto a ondulação da barra o segue.
/// Este app não inclui ação central de adição rápida.
///
/// O `ShellLayout` posiciona a barra na base da tela e soma a safe area do
/// aparelho ao respiro inferior.
class AppBottomTabBar extends StatelessWidget {
  const AppBottomTabBar({
    super.key,
    required this.activeId,
    required this.onModuleSelected,
    this.visibleModules,
  });

  final String activeId;
  final ValueChanged<String> onModuleSelected;
  /// Se omitido, o hub Início fica fora da navegação global por enquanto.
  final List<ModuleDef>? visibleModules;

  @override
  Widget build(BuildContext context) {
    // O módulo Início repete parte dos destinos financeiros do Bank e está
    // desativado temporariamente na navbar. Mantemos sua rota registrada.
    final modulesToShow = visibleModules ?? globalNavigationModules;

    return AppTabBar(
      activeId: activeId,
      items: [
        for (final module in modulesToShow)
          AppTabBarItem(
            id: module.id,
            label: module.label,
            icon: module.icon,
          ),
      ],
      onSelected: (item) => onModuleSelected(item.id),
    );
  }
}
