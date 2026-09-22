/// Configura a estratégia de URL do app (sem `#` na web) sem quebrar builds
/// não-web — `package:flutter_web_plugins` não compila para o alvo `vm` usado
/// por `flutter test` nem para plataformas nativas (Android/iOS/Windows), daí
/// o import condicional: `dart.library.html` só existe em builds web.
library;

export 'url_strategy_stub.dart' if (dart.library.html) 'url_strategy_web.dart';
