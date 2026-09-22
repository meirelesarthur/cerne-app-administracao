import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'app_icon.dart';
import 'field_capsule.dart';
import 'pressable.dart';
import '../design/generated/app_layout.dart';
import '../design/generated/app_radius.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';

/// Campo de busca global do cabeçalho (Figma `54300-2458`) — presente nas duas
/// homes e no topo de cada módulo.
///
/// Anatomia do Figma: 52 px de altura, fundo abafado, raio [AppRadius.tile]
/// (20), `pl 12 / pr 8`, e um botão circular de 40 px em superfície clara com
/// o ícone de busca à direita.
///
/// Não usa `AppFieldCapsule`: a cápsula de formulário é raio-total (`pill`) e
/// 48 px, porque é a geometria dos campos de cadastro. Este é o campo de
/// **navegação** do cabeçalho, com raio e altura próprios — e é ele que o
/// padrão global repete em toda tela.
///
/// A busca é uma porta de entrada, não um editor: o widget é um alvo de toque
/// que [onTap] leva à tela de busca. Edição de texto no lugar é trabalho do
/// `AppTextInput`, que já existe no catálogo — duplicar um editor aqui criaria
/// dois campos de texto com regras de foco diferentes (Lei 2).
class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    this.placeholder = 'Procurando por algo?',
    this.onTap,
  });

  final String placeholder;

  /// Abre a tela de busca.
  final VoidCallback? onTap;

  /// Altura do Figma.
  static const double height = 52;

  /// Aresta do botão circular à direita.
  static const double _actionSize = 40;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final inputColors = appInputColors(context);

    final content = Text(
      placeholder,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(fontSize: AppTypography.xl, color: inputColors.muted),
    );

    final capsule = Container(
      height: height,
      padding: const EdgeInsets.only(
        left: AppSpacing.space3,
        right: AppSpacing.space2,
      ),
      decoration: BoxDecoration(
        color: inputColors.fill,
        borderRadius: BorderRadius.circular(AppRadius.tile),
      ),
      child: Row(
        children: [
          Expanded(child: content),
          const SizedBox(width: AppSpacing.space1),
          Container(
            width: _actionSize,
            height: _actionSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: semantic.accentSubtle,
              shape: BoxShape.circle,
            ),
            child: AppIcon(
              AppIcons.aiSearch,
              size: AppSize.iconLg,
              color: semantic.accentDefault,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return capsule;

    return AppPressable(
      semanticLabel: placeholder,
      onPressed: onTap,
      minTouchTarget: false,
      borderRadius: BorderRadius.circular(AppRadius.tile),
      child: capsule,
    );
  }
}

WidgetbookComponent buildSearchFieldWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'SearchField',
    useCases: [
      WidgetbookUseCase(
        name: 'Atalho para a busca',
        builder: (context) => Padding(
          padding: const EdgeInsets.all(AppSpacing.space4),
          child: AppSearchField(onTap: () {}),
        ),
      ),
      WidgetbookUseCase(
        name: 'Placeholder de módulo',
        builder: (context) => Padding(
          padding: const EdgeInsets.all(AppSpacing.space4),
          child: AppSearchField(
            placeholder: 'Buscar em Confinamento',
            onTap: () {},
          ),
        ),
      ),
    ],
  );
}
