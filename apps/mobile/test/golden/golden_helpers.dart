import 'package:flutter/material.dart';

import 'package:cerne_app/design/theme/app_theme.dart';

/// Envolve um widget no `ThemeData` real do app (sem `MaterialApp`/`Scaffold`,
/// para o golden não expandir para o tamanho de tela inteira) — os goldens
/// exercitam exatamente o tema/`AppSemanticColors` usado em produção.
Widget themedGolden(AppThemeVariant variant, Widget child) {
  final theme = buildAppTheme(variant);
  return Theme(
    data: theme,
    child: DefaultTextStyle(
      style: theme.textTheme.bodyMedium!,
      child: Material(color: theme.scaffoldBackgroundColor, child: child),
    ),
  );
}
