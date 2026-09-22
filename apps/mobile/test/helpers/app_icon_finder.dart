import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/ui/app_icon.dart';

/// Localiza um [AppIcon] por entrada do catálogo.
///
/// Substitui `find.byIcon(...)` na suíte. `byIcon` só sabe comparar `IconData`,
/// e os ícones do sistema deixaram de ser glifos de fonte: agora são estruturas
/// de SVG (`AppIconData`) desenhadas por [AppIcon] — ver
/// `docs/ESTEIRA-PADRAO-GLOBAL-HUGEICONS.md`, §3.1.
///
/// A comparação é por identidade: as entradas de `AppIcons` são `static const`,
/// então dois usos do mesmo ícone são o mesmo objeto, e ícones distintos nunca
/// colidem — o que igualdade estrutural sobre listas aninhadas não garantiria.
Finder findAppIcon(AppIconData icon) => find.byWidgetPredicate(
  (widget) => widget is AppIcon && identical(widget.icon, icon),
  description: 'AppIcon do catálogo',
);
