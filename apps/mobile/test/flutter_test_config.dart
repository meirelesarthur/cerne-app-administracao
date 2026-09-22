import 'dart:async';

import 'package:alchemist/alchemist.dart';

/// Configuração global do Alchemist para os golden tests (F2.6).
///
/// Cada `goldenTest` roda em 2 variantes (doc de `AlchemistConfig`):
/// - **platform** — texto legível, pensado para inspeção visual humana local.
///   Hinting de fonte difere por SO, então só é confiável na própria máquina
///   onde o golden foi capturado (aqui, Windows — ver ADR 0004). Sem esta
///   restrição, o CI (Ubuntu) compara contra um golden "linux/" que nunca foi
///   de fato gerado/validado nesse ambiente e falha por diferença de
///   renderização de fonte, não por regressão real.
/// - **CI** — texto virado caixas sólidas via fonte Ahem + sombras
///   desligadas, desenhada pelo próprio pacote para ser estável entre
///   plataformas. É a que garante paridade real; mantemos habilitada em
///   todo host, com uma tolerância pequena para absorver ruído de
///   antialiasing entre builds do motor Skia (ver CI do workflow, que agora
///   fixa a versão exata do Flutter para não voltar a divergir).
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  return AlchemistConfig.runWithConfig(
    // Não-const: `HostPlatform` usa igualdade via Equatable (não primitiva),
    // incompatível com um `Set` literal `const`.
    config: AlchemistConfig(
      platformGoldensConfig: PlatformGoldensConfig(
        platforms: {HostPlatform.windows},
      ),
      // Tolerância de 1% — margem sobre o maior diff observado (0,68%) entre
      // o motor Skia do Windows (onde os PNGs foram capturados) e o do
      // ubuntu-latest do CI, mesmo com texto convertido em caixas (Ahem).
      // Ainda pequena o bastante para capturar uma regressão visual real.
      ciGoldensConfig: const CiGoldensConfig(diffThreshold: 0.01),
    ),
    run: testMain,
  );
}
