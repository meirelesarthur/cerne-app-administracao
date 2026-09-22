# ADR 0001 — Fundação do app Flutter (F0)

**Status:** aceito · 2026-07-19

## Contexto

Execução da esteira de [`PLANO-MIGRACAO-FLUTTER.md`](../../../PLANO-MIGRACAO-FLUTTER.md), levando o
protótipo React (`cerne-app`) a um app Flutter de altíssima fidelidade, mantendo este mesmo
repositório como fonte única do design system (tokens DTCG + catálogo `ui/` + `moduleConfig.ts`).

## Decisões

| Item | Decisão | Motivo |
|---|---|---|
| Localização do código | Branch `feature/flutter-migration` neste mesmo repo, projeto em `apps/mobile/`, merge para `main` ao final da esteira | Evita duplicar histórico/repo separado; sync de tokens é trivial (mesmo filesystem); decisão do time (não a recomendação original do plano de repo separado) |
| Gerenciamento de estado | Riverpod (`flutter_riverpod` + `riverpod_annotation`/`riverpod_generator`) | Mapeia diretamente para os stores zustand existentes (`shellStore`, `fazendasStore`, …); confirma o plano F0.4 |
| Navegação | `go_router` com `ShellRoute` | Espelha `react-router-dom` em 2 níveis (`/:moduleId/*`) do protótipo |
| Ícones | `lucide_icons_flutter` | Mapa 1:1 por nome com `lucide-react`. Trocado de `lucide_icons` para `lucide_icons_flutter` — ver ADR 0003 |
| Fonte Outfit | Self-hosted (`assets/fonts/*.ttf`) | Inicialmente `google_fonts` (fetch em runtime); migrado para `.ttf` baixados e empacotados — ver ADR 0004 |
| Gráficos (`BarChart`, `DonutChart`, `SparklineArea`) | `CustomPainter` | Fidelidade 1:1 com os SVGs custom do protótipo, prioridade sobre velocidade de implementação (`fl_chart`) |
| Galeria de componentes (F2.5) | [Widgetbook](https://www.widgetbook.io/) (`widgetbook` + `widgetbook_generator`) | Substitui a "tela própria tipo storybook" cogitada no plano original; usa use-cases anotados (`@UseCase`) por widget do catálogo, com knobs para variantes/temas |
| Golden tests (F2.6) | `alchemist` | `golden_toolkit` (sugestão implícita de mercado na época do plano) está descontinuado; `alchemist` é o sucessor ativo — versão mínima ^0.14.0 (0.11.0 incompatível com o SDK Flutter instalado) |

## Toolchain local

- Flutter 3.44.6 (stable) instalado em `C:\flutter`, adicionado ao PATH do usuário.
- Alvos validados via `flutter doctor`: **Web (Chrome)** e **Windows desktop** — suficientes para o
  loop de validação visual (mitigação de risco do plano: "Flutter compila mais devagar que Vite").
- Pendente para builds mobile reais (fora do escopo do handoff F0–F4): Android SDK, Visual Studio
  completo para build Windows nativo, Modo de Desenvolvedor do Windows (symlinks de plugins).

## Consequências

- Divergência do plano original (repo separado) é aceita e registrada aqui, conforme regra de
  anti-divergência §3 do plano de migração.
- `google_fonts` introduz dependência de rede no primeiro load da fonte (mitigado pelo cache do
  pacote); reavaliar se o time mobile priorizar 100% offline-first antes do handoff.
