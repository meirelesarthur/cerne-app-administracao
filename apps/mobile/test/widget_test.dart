import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/theme_provider.dart';
import 'package:cerne_app/main.dart';

void main() {
  testWidgets('CerneApp exige sessão demonstrativa ao abrir sem exceções', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: CerneApp()));
    await tester.pumpAndSettle();

    // Porta de entrada real do protótipo: a seleção de ambiente, não a home
    // Android intermediária nem o formulário de login (ver `initialLocation`).
    expect(find.text('Administrativo'), findsOneWidget);
    expect(find.text('Operacional'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  test('ThemeVariantNotifier alterna entre light e gbMode', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(themeVariantProvider), AppThemeVariant.light);

    container.read(themeVariantProvider.notifier).toggle();
    expect(container.read(themeVariantProvider), AppThemeVariant.gbMode);
  });
}
