# Plano de Migração — Protótipo React → App Flutter (GB CERNE)

> **Plano concluído:** M0–M13 foram executadas. Flutter é o único runtime oficial; o último estado
> React está disponível apenas na tag `react-rollback-final-2026-08-17`.

**Objetivo:** levar o GB CERNE de protótipo React navegável a **app de produção em Flutter/Dart**,
aproveitando o que o protótipo já define como contrato (tokens DTCG, catálogo de componentes,
arquitetura de módulos) e entregando ao time mobile uma esteira com fases, critérios de aceite
e ordem de ataque.

> **Base:** inventário do repo em 15/07/2026 — ~10,3k LOC TS/TSX · 43 componentes de catálogo
> (~2,1k LOC) · 67 telas em 6 módulos (~6,5k LOC) · shell ~1,2k LOC · `design/tokens.ts` 388 LOC
> com export DTCG (`tokens/tokens.json`) já operacional (Lei 5).
> **Natureza do trabalho:** reescrita guiada, não conversão automática. O custo concentra no
> catálogo de widgets; as telas são composição (Lei 1) e saem rápido depois.

---

## 0. Premissas e papéis

| Item | Decisão |
|---|---|
| Papel do protótipo React | **Spec viva congelada** — referência de UX/fluxos; não recebe feature nova após o início da F2, apenas correções de spec |
| Papel do app Flutter | **Protótipo de altíssima fidelidade em Dart** — mesmo escopo do React (mocks continuam mocks); a troca de linguagem existe para facilitar o handoff ao time mobile, que evolui a partir dele |
| Contrato entre os dois | `tokens/tokens.json` (DTCG) + catálogo `src/components/ui/` (nomes e props) + `moduleConfig.ts` (mapa de navegação) |
| Fluxo de design | Inalterado (Lei 5): código define tokens → Figma/Supernova consomem. O Flutter passa a ser mais um consumidor do mesmo JSON |
| Modelo de execução | **AI-assisted (Claude Code)** — Claude escreve 100% do código; revisão humana é visual/funcional por lote. O gargalo é o loop de validação, não a digitação |
| Stack Flutter | Flutter estável · Dart 3 · `go_router` (navegação 2 níveis) · Riverpod (estado) · `style_dictionary` (tokens → Dart) · `lucide_icons` · `fl_chart` ou `CustomPainter` · Isar/Drift (offline, F6) |

**Regra de ouro da esteira:** nenhuma tela é iniciada antes de o widget de catálogo que ela usa
existir e estar aprovado (espelho da Lei 1). Toda cor/espaço/raio no Flutter vem do tema gerado
dos tokens — hardcode é violação, igual à Lei 3.

---

## 1. Mapa de equivalências (referência)

### 1.1 Fundações
| Protótipo (React) | App (Flutter) |
|---|---|
| `design/tokens.ts` → `tokens/tokens.json` | Style Dictionary target Flutter → `AppTheme`/`ThemeExtension` gerados (não editados à mão) |
| CSS vars light/gbMode (`data-theme`) | `ThemeData` claro + `ThemeExtension` GB Mode, troca via provider |
| Tailwind classes | Widgets + tema; sem equivalente direto (reescrita) |
| Fonte Outfit self-hosted | `google_fonts` pin local / asset font Outfit |
| react-router-dom 2 níveis (`/:moduleId/*`) | `go_router` com `ShellRoute` (header + module-bar persistentes) e rotas aninhadas por módulo |
| zustand (`shellStore`, `fazendasStore`, …) | Riverpod (`Notifier` por store; mesma modelagem de estado) |
| lucide-react | `lucide_icons` (mapa por nome) |
| SVG charts próprios (`BarChart`, `DonutChart`, `SparklineArea`) | `CustomPainter` (fidelidade) ou `fl_chart` (velocidade) — decidir na F2 |
| `PhoneFrame` (bezel desktop) | Não migra — é artefato de protótipo |

### 1.2 Catálogo `ui/` → widgets (43 itens, esforço da F2)
| Grupo | Componentes | Equivalência Flutter |
|---|---|---|
| Ações | `Button` (5 variantes), `IconButton`, `QuickAction` | `FilledButton`/`OutlinedButton`/`TextButton` custom + tema |
| Superfícies | `Card`, `DashboardCard`, `BentoTile`, `MiniAppTile`, `ChartCard`, `KpiStatCard`, `BalanceCard` | `Container`+`InkWell` custom widgets |
| Formulário | `TextInput`, `Textarea`, `FormField`, `FormSelect`, `SearchSelect`, `Checkbox`, `ToggleSwitch`, `FileUpload`, `Stepper` | `TextFormField` custom + `showModalBottomSheet` para selects |
| Feedback | `Banner`, `EmptyState`, `ErrorState`, `SuccessPanel`, `Skeleton`/`CardSkeleton`, `Spinner`, `Tooltip`, `ProgressBar` | widgets custom + `shimmer` |
| Overlay | `Modal`, `BottomSheet`, `TransactionDetailSheet` | `showDialog`/`showModalBottomSheet` |
| Dados | `TransactionListItem`, `MenuItem`, `Badge`, `Chip`, `Tag`, `Avatar`, `Heading`/`SectionTitle`, `PageDots`, `IllustrationSlot` | `ListTile` custom + `Text` com estilos do tema |
| Gráficos | `BarChart`, `DonutChart`, `SparklineArea` | `CustomPainter`/`fl_chart` |

### 1.3 Módulos → ordem de valor (esforço da F4)
| Ordem | Módulo | Conteúdo | Peso |
|---|---|---|---|
| 1º | Shell + Início (hub) | header, module-bar, reveal menu, bottom tabs, Banking hub | M |
| 2º | Fazendas | 7 dashboards gerenciais + 6 fluxos operacionais + sync | **G** (maior módulo) |
| 3º | Bank | conta, extrato, pagamentos | M |
| 4º | Crédito | ofertas, simulador, propostas | M |
| 5º | Marketplace + Armazém | vitrine/pedidos + estoque/movimentações | M |
| 6º | Login + Onboarding | telas de entrada (artes prontas em `src/images/`) | P |

---

## 2. Esteira de desenvolvimento

Marcação `[ ]` a cada etapa concluída, com o PR correspondente. Um PR por unidade lógica.
Cada fase tem **gate de saída (DoD)** — a fase seguinte não abre sem o gate fechado.

### Fase F0 — Fundação do repositório (≈ 0,5 dia)
Preparar o terreno; nada visual ainda.

- [x] **F0.1** Criar repo `cerne-app-flutter` (ou monorepo `apps/mobile`), Flutter estável, lint
  (`very_good_analysis` ou `flutter_lints` estrito), CI (analyze + test + build por PR).
- [x] **F0.2** Estrutura de pastas espelhando o protótipo: `lib/design/`, `lib/ui/` (catálogo),
  `lib/shell/`, `lib/modules/<nome>/`.
- [x] **F0.3** Pipeline de assets: fonte Outfit, `lucide_icons`, ilustrações e logos copiadas de
  `src/images/` (onboard1-3, login_bg, logo-min-white e variantes).
- [x] **F0.4** Decisão registrada (ADR curto): Riverpod vs Bloc · fl_chart vs CustomPainter ·
  repo separado vs monorepo.

**DoD F0:** app "hello" buildando em CI para Android e iOS; ADRs commitados.

### Fase F1 — Tokens e tema (≈ 0,5 dia)
O contrato primeiro. É o espelho da Lei 3/5 no Flutter.

- [x] **F1.1** Configurar Style Dictionary consumindo `tokens/tokens.json` (DTCG) do repo do
  protótipo (git submodule, package, ou cópia versionada com script de sync).
- [x] **F1.2** Gerar `app_colors.dart`, `app_spacing.dart`, `app_radius.dart`, `app_typography.dart`,
  `app_shadows.dart` — arquivos gerados, nunca editados à mão (comentário-guarda no header).
- [x] **F1.3** Montar `ThemeData` light + `ThemeExtension` GB Mode a partir dos gerados; troca de
  tema em runtime (equivalente ao `data-theme`).
- [x] **F1.4** Tela interna de auditoria de tema (grid de cores/espaços/tipografia) para validação
  visual com o design. _Auditoria técnica pronta (Widgetbook); validação visual pelo time de design ainda pendente._

**DoD F1:** mudança de valor em `tokens.ts` → `npm run tokens:export` → regeneração Dart reflete
no app sem edição manual; validado pelo design nas duas variantes de tema.

### Fase F2 — Catálogo de widgets (≈ 1,5–2 dias) ← maior investimento
Reescrever os 43 componentes de `ui/` como package interno, mesmos nomes e props (§1.2).

- [x] **F2.1** Lote Ações + Superfícies (Button, IconButton, Card, tiles, KPI).
- [x] **F2.2** Lote Formulário (inputs, selects, checkbox, toggle, stepper, upload).
- [x] **F2.3** Lote Feedback + Overlay (banners, estados, skeleton, modal, bottom sheets).
- [x] **F2.4** Lote Dados + Gráficos (list items, badges, avatar, charts, page dots, illustration slot).
- [x] **F2.5** Galeria de componentes (rota interna tipo storybook: `widgetbook` ou tela própria)
  com todas as variantes de cada widget.
- [x] **F2.6** Golden tests dos widgets críticos (Button, Card, inputs, list items) nas 2 variantes
  de tema.

**DoD F2:** 42/42 no ar na galeria (`flutter build web -t lib/widgetbook_app.dart`); goldens verdes
localmente (`flutter test`, 123 testes incluindo 8 golden) — **CI (GitHub Actions) ainda não rodou
de verdade** (workflow criado no F0, mas sem push/PR real neste momento); **aprovação visual do
design comparando lado a lado com o protótipo React ainda pendente** — trabalho técnico completo,
falta o ritual de revisão humana (§3 do plano).

### Fase F3 — Shell e navegação (≈ 0,5–1 dia)
- [x] **F3.1** `ShellRoute` com header global (gradiente, saudação, pílula de crédito, sino) +
  module-bar (cantos arredondados sobrepostos, indicador full-width) — réplica do `ShellLayout`.
- [x] **F3.2** Bottom tab bar por módulo lida de um `moduleConfig` Dart (portar o `moduleConfig.ts`).
- [x] **F3.3** Reveal menu (app encolhe como cartão, menu verde desliza) com as mesmas curvas/spring
  tokenizadas; respeitar `MediaQuery.disableAnimations`.
- [x] **F3.4** Stores do shell (usuário, notificações, online/offline, menu) em Riverpod.

**DoD F3:** trocar de módulo preserva header/estado como no protótipo (validado por teste de
integração e verificação visual manual); deep-link `/:module/:tab` funciona via `go_router`
(validado). Conteúdo real dos módulos é `ModulePlaceholderScreen` — chega na F4. Aprovação visual do
design ainda pendente (mesma ressalva do F2).

### Fase F4 — Módulos por valor (≈ 2–3 dias)
Ordem do §1.3. Cada módulo é um trilho independente da esteira — com 2 devs, rodar 2 trilhos em
paralelo após o 1º.

- [x] **F4.1** Início/hub (Banking central, bento de mini-apps).
- [x] **F4.2** Fazendas — gerencial: 7 dashboards (charts prontos na F2).
- [x] **F4.3** Fazendas — operacional: 6 fluxos de campo + fila de sync (ainda mock, como no protótipo).
- [x] **F4.4** Bank (extrato, pagamentos, cartões).
- [x] **F4.5** Crédito (oferta, simulador, propostas).
- [x] **F4.6** Marketplace + Armazém.
- [x] **F4.7** Login + Onboarding (artes e logo já em assets; carrossel com `PageView` + dots).

**DoD F4 (por módulo):** paridade de telas e navegação com o protótipo (checklist por tela);
zero hardcode de estilo (audit de lint próprio); revisão do guardião da spec.
**Estado real:** 313 testes verdes, `flutter analyze` sem apontamentos, `dart format` limpo,
todos os 6 módulos roteados (`app_router.dart`) e com cobertura própria (Armazém fechou o gap
que faltava). Revisão visual lado a lado com o protótipo React (checklist por tela, mesma
ressalva do F2/F3) ainda pendente — único item aberto da fase.

### Fase F5 — Hardening e qualidade (**escopo do time mobile, pós-handoff**)
- [ ] **F5.1** Acessibilidade: semantics, tamanhos de toque ≥ 48dp, contraste nas 2 variantes.
- [ ] **F5.2** Performance: rebuilds (DevTools), imagens (`cacheWidth`), jank nos springs do menu.
- [ ] **F5.3** Testes de fluxo (integration_test): onboarding→login→hub, lançamento de campo,
  simulação de crédito.
- [ ] **F5.4** Build assinado + distribuição interna (TestFlight / Play Internal).

**DoD F5:** paridade total navegável em aparelho físico, aprovada por design + produto.

### Fase F6 — Além do protótipo (**backlog do time mobile, pós-handoff**)
O que o protótipo apenas simula e vira implementação real no app:

- [ ] **F6.1** Autenticação real (o login é mock).
- [ ] **F6.2** Offline-first de verdade: fila de sync com Isar/Drift + retry/conflitos
  (hoje `isOnline` é um toggle de demonstração).
- [ ] **F6.3** Notificações push (o sino é mock).
- [ ] **F6.4** Integração com APIs de negócio (tudo hoje é mock em `mocks/`).

---

## 3. Governança e anti-divergência

1. **Fonte única de design:** mudança visual entra primeiro em `tokens.ts` (+ export DTCG) e/ou
   no catálogo — nunca direto numa tela Flutter. Mesma disciplina das Leis 1–3, agora nos dois repos.
2. **Protótipo congelado a partir da F2:** ajustes de UX aprovados geram issue espelho no repo
   Flutter; o protótipo só muda para corrigir a spec (e o commit referencia a issue).
3. **Ritual de handoff:** 1 review semanal design + devs comparando galeria Flutter × protótipo.
4. **Definition of Done global:** paridade não é "parecido" — é mesma hierarquia, mesmos tokens,
   mesmos fluxos; divergência intencional exige registro no ADR.

## 4. Resumo executivo de esforço

Execução **AI-assisted (Claude Code)** com paridade de protótipo — mesmo modelo que produziu o
protótipo React em <2 semanas. F5/F6 saem do cronograma (viram backlog do time mobile após o
handoff). Duração medida em **dias de sessão** (o calendário depende do ritmo de validação):

| Fase | Duração (Claude + revisão visual) | Acumulado |
|---|---|---|
| F0 Fundação (setup Flutter, projeto, assets) | ~0,5 dia | 0,5 dia |
| F1 Tokens/tema (DTCG → Dart gerado) | ~0,5 dia | 1 dia |
| F2 Catálogo (43 widgets + galeria) | 1,5–2 dias | ~3 dias |
| F3 Shell | 0,5–1 dia | ~4 dias |
| F4 Módulos (67 telas de composição) | 2–3 dias | ~6–7 dias |
| Polimento (animações, charts, ajustes finos) | 0,5–1 dia | **~6–8 dias → paridade** |
| F5–F6 (produção real) | time mobile | pós-handoff |

> Referência para o time mobile em planejamento próprio: os mesmos passos executados por um time
> humano de 2 devs com DoD de produção (CI, golden tests, hardening) foram estimados em 9–11
> semanas. A diferença é o modelo de execução e o DoD, não o escopo visual.

**Riscos principais:** loop de validação visual (Flutter compila mais devagar que Vite — mitigar
com Flutter web/hot reload e validação por lote); fidelidade dos charts custom (mitigação: spike
CustomPainter × fl_chart no F0); divergência protótipo×app (mitigação: §3).
