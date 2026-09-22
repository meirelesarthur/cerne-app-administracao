import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'app_icon.dart';
import '../design/generated/app_spacing.dart';
import '../design/theme/app_theme_extension.dart';
import 'heading.dart';
import 'icon_button.dart';
import '../design/generated/app_layout.dart';

/// Cabeçalho padrão de toda tela do app: título no topo, voltar **à esquerda do
/// título** (não numa linha própria acima dele) e descrição opcional abaixo.
///
/// É a fonte única do topo de tela (Lei 2): antes cada tela montava o seu — umas
/// com um botão fantasma "Voltar ao ambiente" acima do título, outras com o
/// título centralizado — e o app não tinha um padrão único de cabeçalho.
///
/// `onBack` nulo omite o botão: telas que são destino de aba inferior não têm
/// pilha para voltar, mas continuam usando este componente para herdar a mesma
/// tipografia e o mesmo espaçamento do topo.
class AppScreenHeader extends StatelessWidget {
  const AppScreenHeader({
    super.key,
    required this.title,
    this.description,
    this.onBack,
    this.backLabel = 'Voltar',
    this.leading,
    this.action,
  });

  final String title;

  /// Linha de apoio abaixo do título (ex.: o objetivo da funcionalidade).
  /// Ocupa a largura inteira, sem recuo: descrições de 2–3 linhas ficam legíveis
  /// em tela estreita em vez de comprimidas ao lado do botão de voltar.
  final String? description;
  final VoidCallback? onBack;

  /// Rótulo acessível do botão de voltar — descreva o destino quando ele não
  /// for óbvio (ex.: 'Voltar aos registros').
  final String backLabel;

  /// Elemento à esquerda do título, depois do voltar (ex.: ícone do módulo).
  final Widget? leading;

  /// Ação à direita do título (ex.: um `AppIconButton`).
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (onBack != null) ...[
              AppIconButton(
                label: backLabel,
                variant: AppIconButtonVariant.solid,
                size: AppIconButtonSize.lg,
                onPressed: onBack,
                icon: const AppIcon(AppIcons.arrowLeft, size: AppSize.iconMd),
              ),
              const SizedBox(width: AppSpacing.space3),
            ],
            if (leading != null) ...[
              leading!,
              const SizedBox(width: AppSpacing.space3),
            ],
            Expanded(child: AppHeading(child: Text(title))),
            if (action != null) ...[
              const SizedBox(width: AppSpacing.space3),
              action!,
            ],
          ],
        ),
        if (description != null) ...[
          const SizedBox(height: AppSpacing.space2),
          Text(description!, style: TextStyle(color: semantic.fgMuted)),
        ],
      ],
    );
  }
}

WidgetbookComponent buildScreenHeaderWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'ScreenHeader',
    useCases: [
      WidgetbookUseCase(
        name: 'Variações',
        builder: (context) => ListView(
          padding: const EdgeInsets.all(AppSpacing.space4),
          children: [
            AppScreenHeader(
              title: 'Áreas',
              description: 'Cadastrar áreas usadas nos processos da fazenda.',
              onBack: () {},
            ),
            const SizedBox(height: AppSpacing.space8),
            AppScreenHeader(
              title: 'Fila de sincronização',
              onBack: () {},
              action: AppIconButton(
                label: 'Atualizar',
                icon: const AppIcon(AppIcons.refreshCw, size: AppSize.iconMd),
                onPressed: () {},
              ),
            ),
            const SizedBox(height: AppSpacing.space8),
            const AppScreenHeader(
              title: 'Cartões',
              description: 'Sem voltar: destino de aba inferior.',
            ),
          ],
        ),
      ),
    ],
  );
}
