# ADR 0002 — Tokens e tema (F1)

**Status:** aceito · 2026-07-19

## Contexto

F1 do [`PLANO-MIGRACAO-FLUTTER.md`](../../../PLANO-MIGRACAO-FLUTTER.md): levar `tokens/tokens.json`
(DTCG) a um tema Flutter completo, sem hardcode (Lei 3/5).

## Decisões

| Item | Decisão |
|---|---|
| Gerador tokens → Dart | Script bespoke em [`scripts/export-tokens-flutter.ts`](../../../scripts/export-tokens-flutter.ts), não Style Dictionary genérico. Motivo: os valores de `shadow` em `tokens.json` são strings CSS cruas (bug conhecido em `export-tokens-dtcg.ts`, ver tarefa em aberto), e um transform Style Dictionary padrão não parseia esse formato — o parser próprio cobre isso (e migra sem atrito quando o bug upstream for corrigido, pois lê o mesmo `tokens.json`) |
| Naming dos campos gerados | camelCase completo do path do token (ex.: `core.color.brand.600` → `AppColors.brand600`; `light.fg.default` → `AppColorsLight.fgDefault`); grupos com risco de colisão (`font.weight.normal` vs `font.lineHeight.normal`, `animation.easing.in` que colide com a palavra reservada `in` do Dart) usam prefixo fixo (`weightNormal`, `lineHeightNormal`, `easingIn`) |
| Semântica de tema | `AppThemeVariant { light, gbMode }` — **não** é o `ThemeMode` do Flutter (light/dark/system); `gbMode` é identidade de marca, não modo escuro genérico |
| Cores/sombras semânticas | `ThemeExtension<AppSemanticColors>` (não `ColorScheme` do Material) — mapeia 1:1 as CSS vars trocadas via `data-theme` no protótipo (`fg*`, `bg*`, `border*`, `accent*`, `ink*`, `cta*`, `nav*` + shadows) |
| Widgetbook para auditoria (F1.4) | `MaterialThemeAddon` com as duas variantes como opções — permite ao design trocar tema direto na UI do Widgetbook, sem precisar de build separado por variante |

## Verificação

- `flutter analyze`, `flutter test`, `flutter build web` (app) e `flutter build web -t lib/widgetbook_app.dart` (galeria) — todos limpos.
- **Limitação registrada:** a verificação visual via screenshot automatizado (Browser pane) apresentou
  instabilidade nesta sessão (timeouts recorrentes na captura, sem erros de console/rede — os builds
  carregam e title da aba confirma). Uma captura anterior do app principal confirmou visualmente as
  cores corretas (`bgCanvas`, `accentDefault`) antes da instabilidade começar. Recomenda-se ao próximo
  ciclo (F2, galeria de 43 widgets) validar com captura de tela real antes de fechar os gates visuais,
  já que testes automatizados (`flutter test`) não substituem a aprovação visual do design exigida
  pelo DoD do plano.

## Consequências

- O bug de `parseShadow` em `export-tokens-dtcg.ts` (regex exige `px` no offsetX) permanece aberto —
  ver task registrada separadamente. O parser Dart já lida com o formato atual (string CSS), então a
  correção upstream não quebra o pipeline Flutter quando acontecer.
