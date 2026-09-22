import 'package:flutter_web_plugins/flutter_web_plugins.dart'
    show usePathUrlStrategy;

/// Implementação web: URLs sem `#` (`/fazendas` em vez de `/#/fazendas`).
/// Necessário para o roteamento por path funcionar atrás do Cloudflare Pages
/// (ver `web/_redirects` e `tool/cf_pages_build.sh`).
void configureUrlStrategy() => usePathUrlStrategy();
