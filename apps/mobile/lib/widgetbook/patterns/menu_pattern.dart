import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import '../../design/generated/app_spacing.dart';
import '../../design/theme/app_theme_extension.dart';
import '../../ui/ui.dart';

/// Padrão de tela "Menu" (Widgetbook → Padrões).
///
/// Documenta a composição já usada em
/// `modules/fazendas/screens/mais_screen.dart`: grupos com `AppSectionTitle`
/// e linhas de navegação — mas reutilizando `AppMenuItem` (já catalogado em
/// `ui/menu_item.dart`) em vez de recriar a linha do zero, reforçando a Lei 1
/// do CLAUDE.md (reuso de componente já catalogado).
class _MenuGroup {
  const _MenuGroup({required this.title, required this.items});
  final String title;
  final List<_MenuLink> items;
}

class _MenuLink {
  const _MenuLink({
    required this.icon,
    required this.label,
    this.description,
    this.tone = AppMenuItemTone.standard,
  });

  final AppIconData icon;
  final String label;
  final String? description;
  final AppMenuItemTone tone;
}

const _groups = [
  _MenuGroup(
    title: 'Painéis',
    items: [
      _MenuLink(
        icon: AppIcons.wallet,
        label: 'Financeiro',
        description: 'Fluxo de caixa e contas',
      ),
      _MenuLink(
        icon: AppIcons.beef,
        label: 'Pecuária',
        description: 'Rebanho e ciclos',
      ),
      _MenuLink(
        icon: AppIcons.boxes,
        label: 'Suprimentos',
        description: 'Estoque e insumos',
      ),
    ],
  ),
  _MenuGroup(
    title: 'Conta',
    items: [
      _MenuLink(
        icon: AppIcons.user,
        label: 'Perfil',
        description: 'Dados pessoais e documentos',
      ),
      _MenuLink(
        icon: AppIcons.logOut,
        label: 'Sair',
        tone: AppMenuItemTone.danger,
      ),
    ],
  ),
];

class _MenuPatternExample extends StatelessWidget {
  const _MenuPatternExample();

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
          const AppHeading(child: Text('Mais')),
          const SizedBox(height: AppSpacing.space4),
          for (final group in _groups)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.space5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSectionTitle(child: Text(group.title)),
                  const SizedBox(height: AppSpacing.space2),
                  for (final item in group.items)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.space2),
                      child: AppMenuItem(
                        icon: item.icon,
                        label: item.label,
                        description: item.description,
                        tone: item.tone,
                        onTap: () {},
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

WidgetbookComponent buildMenuPatternWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'Menu',
    useCases: [
      WidgetbookUseCase(
        name: 'Exemplo',
        builder: (context) => const _MenuPatternExample(),
      ),
    ],
  );
}
