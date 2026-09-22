import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:widgetbook/widgetbook.dart';

import '../design/generated/app_spacing.dart';
import '../design/theme/app_theme_extension.dart';

/// Marca oficial do GB CERNE, centralizada no catálogo visual do app.
///
/// Os SVGs são os arquivos oficiais entregues em `Logos.zip`. A variante clara
/// deve ser usada sobre superfícies claras; a variante branca, sobre imagens ou
/// superfícies escuras. A proporção do arquivo é preservada pelo próprio SVG.
enum AppBrandLogoVariant { onLight, onDark }

class AppBrandLogo extends StatelessWidget {
  const AppBrandLogo({
    super.key,
    this.variant = AppBrandLogoVariant.onLight,
    this.height = AppSpacing.space8,
  });

  final AppBrandLogoVariant variant;
  final double height;

  String get _asset => switch (variant) {
    AppBrandLogoVariant.onLight => 'assets/images/Logo.svg',
    AppBrandLogoVariant.onDark => 'assets/images/Logo-white.svg',
  };

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'GB CERNE',
      image: true,
      child: SvgPicture.asset(_asset, height: height),
    );
  }
}

WidgetbookComponent buildBrandLogoWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'BrandLogo',
    useCases: [
      WidgetbookUseCase(
        name: 'Sobre superfície clara',
        builder: (context) => const Center(child: AppBrandLogo()),
      ),
      WidgetbookUseCase(
        name: 'Sobre superfície escura',
        builder: (context) {
          final semantic = Theme.of(context).extension<AppSemanticColors>()!;
          return ColoredBox(
            color: semantic.inkBg,
            child: const Center(
              child: AppBrandLogo(variant: AppBrandLogoVariant.onDark),
            ),
          );
        },
      ),
    ],
  );
}
