# ADR 0004 — Fonte Outfit self-hosted (substitui `google_fonts`)

**Status:** aceito · 2026-07-19

## Contexto

O ADR 0001 optou por `google_fonts` (fetch + cache em runtime) para a fonte Outfit, por não haver
`.ttf` disponível no pacote `@fontsource/outfit` do protótipo (só `.woff2`/`.woff`), com uma nota de
"migração futura" para self-hosted quando conveniente.

Implementando os golden tests do F2.6 (`alchemist`), o gatilho apareceu: `GoogleFonts.outfit(...)`
falha em ambiente de teste sem rede —

```
GoogleFonts.config.allowRuntimeFetching is false but font Outfit-SemiBold was not found
in the application assets.
```

Com `allowRuntimeFetching = true` (padrão), o teste falha tentando de fato baixar o arquivo via HTTP
(sem rede no ambiente de teste). Não há meio-termo documentado no pacote: ou a fonte está nos assets
locais, ou o teste depende de rede.

## Decisão

Baixados os `.ttf` oficiais da Outfit (pesos 400/500/600/700/800 — os mesmos já usados em
`app_typography.dart`) de `fonts.gstatic.com` (via `fonts.googleapis.com/css2?family=Outfit`) e
empacotados em `assets/fonts/`. `pubspec.yaml` → `flutter.fonts` declara a família `Outfit`.
`app_theme.dart` usa `TextStyle(fontFamily: AppTypography.fontFamily, ...)` direto, sem
`GoogleFonts.outfit(...)`. Dependência `google_fonts` removida do `pubspec.yaml`.

## Consequências

- **Golden tests funcionam offline** — pré-requisito para CI (`ubuntu-latest`, sem acesso à internet
  garantido no runner de teste) e para desenvolvimento sem rede.
- **App em produção não depende mais de rede para tipografia** — elimina o FOUC (flash of
  unstyled content) que `google_fonts` tem no primeiro carregamento, e o risco de fonte não carregar
  atrás de proxy/firewall corporativo.
- `test/flutter_test_config.dart` (que desligava `allowRuntimeFetching`) foi removido — não é mais
  necessário sem `google_fonts`.
- Consequência do ADR 0001 antecipada e agora resolvida; nenhuma outra migração de fonte pendente.
