import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_theme.dart';

export 'app_theme.dart' show AppThemeVariant;

/// Variante de tema ativa (equivalente à troca de `data-theme` em runtime no protótipo React).
/// Default `light`, alternável via [themeVariantProvider.notifier].
final themeVariantProvider =
    NotifierProvider<ThemeVariantNotifier, AppThemeVariant>(
      ThemeVariantNotifier.new,
    );

class ThemeVariantNotifier extends Notifier<AppThemeVariant> {
  @override
  AppThemeVariant build() => AppThemeVariant.light;

  void toggle() {
    state = state == AppThemeVariant.light
        ? AppThemeVariant.gbMode
        : AppThemeVariant.light;
  }

  void set(AppThemeVariant variant) => state = variant;
}
