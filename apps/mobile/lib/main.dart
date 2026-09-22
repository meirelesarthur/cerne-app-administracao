import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'design/theme/app_theme.dart';
import 'design/theme/theme_provider.dart';
import 'router/app_router.dart';
import 'shared/url_strategy.dart';

void main() {
  // Web: URLs sem `#` (`/fazendas` em vez de `/#/fazendas`) — necessário para o
  // roteamento por path funcionar corretamente atrás do Cloudflare Pages
  // (ver `web/_redirects` e `tool/cf_pages_build.sh`). No-op fora da web.
  configureUrlStrategy();
  runApp(const ProviderScope(child: CerneApp()));
}

/// Raiz do app — o roteador é criado no mesmo escopo Riverpod da sessão.
class CerneApp extends ConsumerWidget {
  const CerneApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final variant = ref.watch(themeVariantProvider);
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'GB CERNE',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(variant),
      routerConfig: router,
      // pt-BR é o único idioma do produto (datas DD/MM/AAAA, calendário do
      // `AppDateInput` com nomes de mês/dia em português).
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
