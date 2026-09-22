# Esteira — Squircle nos cantos do catálogo Flutter (leva "squircle")

> Leia este arquivo antes de mexer em qualquer item desta leva e atualize-o no mesmo commit de
> cada onda concluída — mesmo padrão de continuidade usado em `docs/MEMORIA-MIGRACAO-FLUTTER.md`
> e em `docs/ajustes-banco-real/00-ESTEIRA-AJUSTES-BANCO-REAL.md`.

## Origem e objetivo

Esta leva nasce de um pedido direto de UI: substituir o canto arredondado comum (arco circular)
por **squircle** (superellipse de curvatura contínua, estilo iOS/Figma) em todo quadrado e
retângulo do app, incluindo botões. A pesquisa de apoio está em
[`01-pesquisa-squircle.md`](01-pesquisa-squircle.md) e é pré-requisito de leitura — este
documento assume o que foi levantado lá.

**Objetivo desta leva**: migrar os cantos arredondados do catálogo `apps/mobile/lib/ui/`
(36 arquivos, 121 ocorrências de `BorderRadius`/`RoundedRectangleBorder`/`AppRadius` mapeadas em
18/08/2026) para `RoundedSuperellipseBorder` (nativo do Flutter SDK, sem dependência nova), por
trás de **um único** primitivo compartilhado — nunca inline por tela (Lei 1/2 do `CLAUDE.md`) —
com o valor de suavização vindo do pipeline de tokens (Lei 3/5), sem regressão de teste,
performance ou acessibilidade.

**Fora do escopo desta leva**: elementos com raio `AppRadius.full` (pílula/stadium — botões
grandes, badges, toggle, tabs) não mudam de forma (squircle e círculo convergem para o mesmo
resultado nesse raio — ver pesquisa §2). Não confundir "todo botão" do pedido original com "todo
botão pill" — os botões `sm`/`md` que hoje usam raio menor que stadium **entram** no escopo; os
que já usam `AppRadius.full` **não mudam visualmente** e por isso não exigem migração.

## Regras específicas desta leva

- Branch de execução: `feature/ui-squircle` (criada a partir de `main`), a partir da Onda 1.
  A Onda 0 (prova de conceito) roda numa branch descartável própria (`spike/squircle-web-poc`)
  que **não é mesclada** — existe só para responder ao gate, depois é apagada.
- Prefixo de commit: `(squircle)` dentro do tipo Conventional Commit — ex.:
  `feat(squircle): adiciona token de suavizacao e AppShapes`,
  `refactor(squircle): migra button e text_input para squircle`,
  `docs(squircle): atualiza esteira apos onda 2`.
- Continuam valendo todas as leis do `CLAUDE.md`: component-first (Lei 1), fonte única de
  componentes (Lei 2), tokens/tipografia (Lei 3), commit por unidade lógica + push só sob pedido
  explícito (Lei 4), pipeline DTCG imutável (Lei 5).
- **Nenhuma onda além da 0 começa sem o gate da onda anterior fechado** — squircle é uma mudança
  visual ampla e de baixo controle de blast radius (121 ocorrências); reverter no meio de uma
  migração parcial é pior do que não ter começado.
- Rebaseline de golden é esperado e não é "quebra" — mas cada lote de golden regenerado é
  revisado visualmente antes do commit, nunca aceito às cegas.

## Curadoria desta leva (ondas)

### Onda 0 — Prova de conceito e gate de decisão (bloqueante, spike descartável)

A pesquisa (§4) não resolve se `RoundedSuperellipseBorder` renderiza squircle de verdade em
**Flutter Web** (o alvo real de deploy deste projeto) ou cai para retângulo arredondado comum.
Essa dúvida é resolvida aqui, com o build real, antes de qualquer migração em massa.

- [ ] Branch descartável `spike/squircle-web-poc`: uma tela isolada no Widgetbook com 3-4
      formas lado a lado (`RoundedRectangleBorder` atual vs. `RoundedSuperellipseBorder` em 2-3
      raios representativos, incluindo o maior raio hoje usado fora de `full`: `AppRadius.xl4`).
- [ ] Rodar `flutter build web` (o mesmo comando do pipeline de deploy, não `flutter run -d
      chrome` do dev) e servir o resultado estático — validar no navegador de fato, não no modo
      debug.
- [ ] Comparar visualmente (zoom no canto) contra o mesmo widget rodando nativo
      (`flutter run -d windows` ou emulador) para confirmar se a curva é idêntica ou se a Web
      caiu para fallback circular.
- [ ] Registrar o resultado (com screenshot) nesta seção antes de prosseguir.
- [ ] Medir tempo de paint/build da tela com grid denso de cards (referência: grid 2×N de
      `ResponsibilityWorkspace` ou o grid de `GroupFeaturesScreen`) antes/depois, para descartar
      regressão perceptível de performance.

**Gate da onda (decide o caminho da Onda 1 em diante):**

| Resultado do POC | Caminho |
|---|---|
| Web renderiza squircle real, sem diferença perceptível de performance | Segue para Onda 1 como planejado, usando `RoundedSuperellipseBorder`. |
| Web cai para fallback circular (sem squircle) | **Parar e decidir com o usuário**: aceitar squircle só em builds nativos (Windows/desktop, hoje usados para dev) e manter Web com arco circular (degradação graciosa, como o próprio CSS `corner-shape` faz) — ou adotar `figma_squircle` como piso mínimo sabendo da limitação em raios grandes (pesquisa §4). Não prosseguir a migração de 121 ocorrências sem essa decisão explícita. |
| Perf perceptivelmente pior no grid denso | Investigar custo antes de migrar o catálogo inteiro; pode exigir restringir squircle a componentes de maior destaque visual (cards, botões) em vez de tudo (ex.: skeleton, divisores). |

_(Resultado a preencher quando a onda rodar.)_

### Onda 1 — Fundação: token de suavização + primitivo compartilhado

Só começa com o gate da Onda 0 fechado e decisão registrada.

- [ ] Adicionar grupo de token em `design/tokens.ts` (ex. `shape.cornerSmoothing`, valor inicial
      `0.6` — calibração Apple/Figma, ver pesquisa §2) — nunca um literal solto em Dart.
- [ ] Rodar pipeline completo: `npm run tokens:export` → `npm run tokens:export:flutter` →
      commitar `tokens/tokens.json` e o Dart gerado na mesma unidade lógica (Lei 5).
- [ ] Criar **um único** arquivo novo no catálogo, ex. `apps/mobile/lib/ui/app_shape.dart`,
      expondo algo como `AppShapes.border(double radius, {BorderSide side})` que decide
      internamente squircle vs. círculo (e cobre o caso `radius >= stadium` retornando o
      comportamento atual sem squircle, conforme escopo). Nenhuma tela ou componente decide isso
      sozinho — só chama `AppShapes`.
- [ ] Caso público → entra no barrel `ui.dart` e ganha caso no Widgetbook (grade comparativa
      antes/depois, todos os `AppRadius.*`).
- [ ] Nenhum componente de tela ainda é migrado nesta onda — só a fundação.

**Gate da onda**: `AppShapes` existe, testado isoladamente (widget test simples comparando
`Path`/bounds), com caso no Widgetbook; `tokens:verify` limpo.

### Onda 2 — Migração do catálogo `ui/` (component-first, sem telas)

- [ ] Migrar por família, do maior impacto visual para o menor (evita revisar 121 ocorrências
      de uma vez):
      1. `button.dart` (botões não-pill) + `icon_button.dart`
      2. `text_input.dart`, `textarea.dart`, `form_select.dart`, `search_select.dart`,
         `field_capsule.dart`
      3. `card.dart`, `dashboard_card.dart`, `chart_card.dart`, `bento_tile.dart`,
         `mini_app_tile.dart`, `kpi_stat_card.dart`, `balance_card.dart`
      4. `modal.dart`, `bottom_sheet.dart`, `transaction_detail_sheet.dart`, `tooltip.dart`
      5. Demais 20+ arquivos restantes (chips, badges não-pill, skeleton, banners, etc.)
- [ ] Cada arquivo migrado: trocar `BorderRadius.circular(AppRadius.x)` /
      `RoundedRectangleBorder(borderRadius: ...)` por `AppShapes.border(AppRadius.x)` — nunca
      inline `RoundedSuperellipseBorder` direto na tela/componente fora de `app_shape.dart`.
- [ ] Regenerar goldens do lote (`apps/mobile/test/golden/goldens/ci/*.png`), revisar
      visualmente cada diff antes de commitar.
- [ ] Um commit por família (não um commit gigante com as 121 ocorrências).

**Gate da onda**: as 121 ocorrências mapeadas foram revisadas (migradas ou explicitamente
marcadas como fora de escopo — `AppRadius.full`); zero `RoundedRectangleBorder`/
`BorderRadius.circular` inline fora de `app_shape.dart` no diretório `ui/`.

### Onda 3 — Verificação de qualidade

- [ ] `npm run lint` (flutter analyze --fatal-infos) limpo.
- [ ] `npm test` — suíte completa; goldens da variante CI revisados e verdes; falhas
      pré-existentes da variante Windows (ver `docs/ajustes-banco-real`, commit `5d3057b`) não
      pioram em quantidade.
- [ ] `npm run quality:functional` verde (gates de arquitetura/acesso/catálogo).
- [ ] Revisão visual por Widgetbook: cada componente migrado, nos dois temas (light/GB Mode).
- [ ] Checagem de acessibilidade: foco visível (`:focus-visible`/`AppPressable`) e alvo de toque
      mínimo não mudam com a troca de forma (squircle não deve alterar bounds de hit-test).

**Gate da onda**: todos os itens acima verdes antes de considerar a leva pronta para revisão
final.

### Onda 4 — Documentação e fechamento

- [ ] Se a migração se provar estável, avaliar registrar uma nova regra no `CLAUDE.md`
      (ex. "Regra G — nunca usar `BorderRadius.circular`/`RoundedRectangleBorder` direto num
      componente; sempre `AppShapes`") para travar o padrão contra regressão futura.
      **Decisão do usuário, não automática** — mudar as leis do projeto é deliberado.
- [ ] Fechar este documento marcando todas as ondas, com data e commit de referência de cada
      uma.

## Riscos e decisões em aberto (a confirmar com o usuário antes da onda seguinte)

1. **Resultado do gate da Onda 0** — se Web cair para fallback, a leva inteira muda de forma
   (ver tabela da Onda 0).
2. **Valor de suavização** (`0.6` sugerido, calibração Apple/Figma) — vale revisão visual do
   time antes de virar token definitivo; é fácil de ajustar depois porque fica centralizado em
   um único token (Onda 1), mas o *default* inicial é uma escolha de produto, não só técnica.
3. **Volume de rebaseline de golden** — decidir se todo o lote da Onda 2 entra num PR grande ou
   se cada família (Onda 2, itens 1-5) vira PR/commit separado para revisão mais leve.
4. **Escopo de "todo botão"** — confirmar entendimento de que botões pill (`AppRadius.full`)
   ficam de fora por não terem efeito visual (pesquisa §2), para não gerar expectativa de
   mudança que matematicamente não existe nesses casos.
