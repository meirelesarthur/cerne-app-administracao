# Esteira — Dashboards administrativos (auditoria de decisão + UI)

Referências: `apps/mobile/lib/modules/fazendas/admin/` (7 telas), catálogo em
`functional_catalog.dart` (15 funcionalidades administrativas), `apps/mobile/lib/ui/` (catálogo de
componentes) e a fronteira já fechada em `docs/ESTEIRA-FRONTEIRA-OPERACIONAL.md`.

## Objetivo

O app mobile é **executor**; o ADM no mobile é **leitor de decisão**. Um painel administrativo só se
justifica se responde a uma pergunta que muda uma decisão: *libero o curral? aprovo a cotação? cobro
o atraso? troco a dieta? paro a máquina?* Tela que apenas espelha uma lista não é dashboard — é
consulta, e deve ser tratada como tal.

Esta esteira aplica esse teste às 7 telas de `admin/` e define a Home ADM como torre de controle.

**Status: implementada.** Auditoria, tokens, componentes, os cinco painéis e a Home foram entregues
nos commits de `feat(tokens)` a `test(ui)`. As seções abaixo descrevem o que foi decidido **e** o que
está no código; onde a implementação divergiu da proposta original, a divergência está anotada.

---

## 1. Estado atual — o que cada tela realmente entrega

| Tela | Rota | KPIs | Gráficos | Natureza real |
|---|---|---|---|---|
| Financeiro | `dashboards/financeiro` | 4 | 1 barra | Dashboard raso (62 linhas) |
| Pecuária de Corte | `dashboards/pecuaria` | 3 + 2 desativados | 3 sparklines | **Casca** — bloco produtivo desligado |
| Confinamento | `dashboards/confinamento` | 4 | **0** | Dashboard rico (4 abas), mas sem gráfico |
| Ativos / Depreciação | `dashboards/ativos` | 3 | 0 (barras de progresso) | Lista com cabeçalho de KPI |
| Suprimentos | `dashboards/suprimentos` | **0** | 0 | **Lista filtrável**, não dashboard |
| Análise de Uso | `dashboards/uso` | **0** | 0 | **Lista expansível** de observabilidade |
| Consultas Gerenciais | `dashboards/consultas` | **0** | 0 | **Console de consulta** read-only |

### Achados que motivam a mudança

**A. Duplicação literal entre Home e Pecuária.** `screens/fazendas_home.dart` (`_HomeGerencial`)
exibe Receita `R$ 2,4 mi` / Custo `R$ 1,1 mi` / Margem `R$ 1,3 mi`, com deltas 12/-4/9 e as mesmas
sparklines de `pecuariaFinanceiro` em `mocks/dashboards_mocks.dart`. São os mesmos três números, com
os mesmos valores, em duas telas. Fere o espírito da Lei 2 (fonte única).

**B. Pecuária é uma casca.** Seu bloco financeiro é o item A; seu bloco produtivo/reprodutivo está
`disabled: true` com aviso de LACUNA; sobra uma lista de atividades que já existe em
`/fazendas/atividades`. A tela não tem conteúdo próprio.

**C. O bloco produtivo desativado já tem dado.** `confinamento/models.dart` calcula, por curral,
`gmdKg`, `gmdPrevistoKg`, `indicadorDesempenhoPct`, `pesoPrevistoPosConfinamentoKg`,
`diasConfinamento` e `diasRestantes`. O indicador que a Pecuária declara não ter existe — está no
submódulo ao lado.

**D. O catálogo de gráficos está ocioso.** Uso fora do próprio arquivo de definição:

| Componente | Usos em telas |
|---|---|
| `AppBarChart` | **1** (Financeiro) |
| `AppDonutChart` | **0** |
| `AppChartCard` | **1** |
| `AppSparklineArea` | 2 (ambos dentro de `AppDashboardCard`) |

Sete painéis administrativos sustentados por **um** gráfico.

**E. Não existe série temporal.** Nenhum componente do catálogo plota evolução no tempo com eixo.
`AppSparklineArea` é decorativa (36 px, sem eixo, sem escala). Para decisão administrativa — "o custo
está subindo há quantos meses?" — essa é a lacuna mais cara do catálogo.

**F. `AppBarChart` distorce valores pequenos.** Em `ui/bar_chart.dart` a barra aplica
`barWidthPct = pct < 14 ? 14 : pct`: qualquer valor abaixo de 14% do máximo é desenhado como 14%. Um
centro de custo de R$ 5 mil ganha quase a mesma barra de um de R$ 59 mil. É erro de integridade de
dado, não de estética, e precisa cair.

**G. Nenhum painel é responsivo.** `crossAxisCount` é fixo (2, 3 ou 4) e `childAspectRatio` é
constante. Com a entrada do desktop (`shell/pages/android_home_page.dart` e `cerne_app_folder_page.dart`,
commit 983a333), os painéis seguem em duas colunas numa viewport larga, e o `childAspectRatio` fixo
estoura com escala de texto grande.

**H. `chartSeries` não é temático.** `design/generated/app_colors.dart` traz 8 cores fixas fora do par
claro/escuro — todas as demais cores do app passam por `AppSemanticColors`. Em tema escuro a série
mantém `#059669`/`#14532D`, que colidem com o fundo.

---

## 2. Decisão — 7 telas viram 5 painéis + 1 console

O corte segue as perguntas do administrador, não a organização do menu legado.

| # | Painel proposto | Origem | Pergunta que responde |
|---|---|---|---|
| D1 | **Resultado** | Financeiro ⊕ bloco financeiro da Pecuária | O ciclo está dando dinheiro? Onde vaza custo? O que está vencido? |
| D2 | **Rebanho & Confinamento** | Confinamento ⊕ bloco produtivo da Pecuária (agora com dado) | Quantas arrobas produzo, a que custo, e quando libero curral? |
| D3 | **Suprimentos** | Suprimentos, reestruturado | Aprovo esta cotação? Quanto economizei? Qual fornecedor está caro? |
| D4 | **Ativos & Manutenção** | Ativos, reestruturado | Qual máquina consome patrimônio e quando ela para? |
| D5 | **Adoção & Governança** | Uso ⊕ `exportar-log-estoque` ⊕ `exportar-log-pecuaria` | O app está sendo usado? Quem mexeu no quê? |
| — | **Consultas Gerenciais** | inalterada, reclassificada | Não é painel: é console de consulta read-only |

### Por que Financeiro + Pecuária viram um só (D1)

O próprio catálogo já chama `painel-financeiro` de *"Financeiro e operacional"*. Receita, custo e
margem são o mesmo P&L do bloco financeiro da Pecuária. Juntar elimina a duplicação (achado A),
esvazia a casca (achado B) e devolve à Home o papel de resumo, em vez de terceira cópia.

### Por que Pecuária não some, migra (D2)

O que a Pecuária prometia e não entregava — desempenho produtivo — passa a ser servido pelos
indicadores de Confinamento (achado C): GMD observado × previsto, desempenho %, curva de peso e
previsão de saída. O painel deixa de dizer "—" e passa a decidir liberação de curral.

### Por que Uso ganha as exportações (D5)

`exportar-log-estoque` e `exportar-log-pecuaria` existem no catálogo (`auditExport`) sem casa visual
própria. Adoção e auditoria são a mesma pergunta de governança; ficam sob o mesmo selo "Acesso
restrito" que a Análise de Uso já carrega.

### Por que Consultas sai da gaveta de dashboards

É 100% leitura, sem nenhum indicador e sem nenhuma ação — declarado no próprio cabeçalho da tela.
Mantê-la sob "Dashboards gerenciais" no `mais_screen.dart` ensina errado o que é painel.

**Nenhum painel novo é criado.** A resposta a "precisamos de mais um?" é não: o que falta não é tela,
é densidade de informação nas que já existem.

---

## 3. Home ADM — torre de controle

Hoje a Home gerencial é: título, 5 atalhos, banner de crédito, 3 cards duplicados e lista de
atividades. Passa a ser o melhor gráfico de cada painel, em ordem de urgência decrescente.

| Ordem | Bloco | Componente | Vem de | Toque leva a |
|---|---|---|---|---|
| 1 | Faixa de contexto | fazenda · safra · período | sessão | seletor |
| 2 | **Faixa de alertas** | chips acionáveis: vencidos, ocorrências abertas, currais > 90%, manutenção vencida | D1/D2/D4 | painel de origem, já filtrado |
| 3 | **Resultado — 6 meses** | `AppLineChart` (receita × custo, área de margem) | D1 | D1 |
| 4 | **Ocupação & GMD** | `AppGauge` de ocupação + GMD real × meta | D2 | D2 |
| 5 | **Despesa por centro de custo** | `AppBarChart` corrigido | D1 | D1 |
| 6 | **Patrimônio por categoria** | `AppDonutChart` (primeiro uso real) | D4 | D4 |
| 7 | **Economia em cotações** | `AppBulletChart` realizado × meta | D3 | D3 |
| 8 | **Adoção por fazenda** | barras compactas | D5 | D5 |
| 9 | Atividades recentes | lista existente | — | `/fazendas/atividades` |

Regra: **cada bloco da Home é o mesmo widget do painel de origem, com `compact: true`** — nunca uma
segunda implementação (Lei 2). Se o gráfico mudar no painel, muda na Home.

---

## 4. Catálogo (Lei 1 — nascem em `lib/ui/`)

Sete componentes entraram no barrel `ui.dart` e no `widgetbook_app.dart`:

| Componente | Papel |
|---|---|
| `AppLineChart` | série temporal com eixo, grade, área e múltiplas séries — a lacuna do achado E |
| `AppStackedBar` | composição de um total ao longo do tempo |
| `AppGauge` | arco de 270° com marca de meta: ocupação, GMD × previsto |
| `AppBulletChart` | realizado × meta em um traço, uma linha por indicador |
| `AppChartLegend` | legenda compartilhada (antes só o donut tinha, embutida) |
| `AppMetricGrid` | grade de métrica responsiva — substitui `GridView.count` de coluna fixa |
| `AppAlertStrip` | faixa de alertas acionáveis do topo da Home |

Os três primeiros compartilham `ui/chart_scale.dart`, que escolhe o eixo redondo. É um arquivo
interno: não é exportado por `ui.dart`, logo não precisa de caso de Widgetbook — é matemática, não
widget.

Correções nos existentes:

- `AppBarChart`: caiu o piso de 14% (achado F) — a largura é estritamente proporcional e o rótulo
  sai para fora da barra quando ela é curta demais para contê-lo. Ganhou grade e escala redonda.
- `AppDonutChart`: percentual na legenda, estado vazio e legenda compartilhada.
- `AppChartCard`: ganhou `period`, `footnote`, `compact` e `onExpand` — por props, não por cópia.
- `AppSparklineArea`: permanece decorativa; não substitui `AppLineChart`.

**Divergência da proposta.** `AppMetricGrid` e `AppAlertStrip` não estavam na lista original e
entraram por necessidade: o primeiro porque a grade responsiva aparece nos cinco painéis, o segundo
porque a faixa de alertas da Home precisava de um controle acionável reutilizável.

### Verificação de render

`test/golden/charts_golden_test.dart` desenha cada gráfico em **light e gbMode**. Dois defeitos que
só apareceram ali:

- `chart.track` no tema claro era `neutral[100]`, o mesmo tom do canvas — o trilho do gauge e da
  barra sumia. Passou a `neutral[200]`, com a grade descendo para `neutral[150]`.
- `ChartScale` arredondava um único passo a partir da média e desperdiçava altura: com valores até
  1004 o eixo subia a 1500 e um terço do gráfico ficava em branco. Passou a testar os passos
  redondos plausíveis e escolher o menor topo com contagem de marcas legível.

## 5. Tokens (Lei 5 — `design/tokens.ts` primeiro)

`ThemePalette` ganhou um grupo `chart` por tema, exportado por DTCG e consumido via
`AppSemanticColors`:

- `series` — paleta categórica com par claro/escuro (achado H). Em gbMode cada matiz sobe de tom
  (400/300 em vez de 600/700): sobre `bg.surface` #0e2a1d o verde #059669 e o verde-floresta
  #14532d praticamente desapareciam;
- `grid`, `axis`, `track` — antes improvisados com `bgSubtle`/`borderDefault`;
- `positive` / `negative` — leitura financeira.

O exportador DTCG passou a aceitar valor de array dentro da paleta de tema (o exportador Dart já
materializava esse caso como `List<Color>`). Nenhum gráfico lê mais `AppColors.chartSeries` direto.

## 6. Responsividade

As grades dos painéis passam a derivar colunas da largura (`LayoutBuilder`), com `mainAxisExtent` em
vez de `childAspectRatio` fixo (achado G). Alvo: 2 colunas em telefone, 3 em tablet, 4 no desktop CERNE
ADM — sem tela nova, mesmo widget.

---

## 7. O que mudou no código

| Arquivo | O que aconteceu |
|---|---|
| `admin/dash_financeiro.dart` + `admin/dash_pecuaria.dart` | removidos; fundiram em `admin/dash_resultado.dart` |
| `admin/dash_confinamento.dart` | ganhou GMD observado × previsto, GMD por curral, situação dos currais |
| `admin/dash_suprimentos.dart`, `dash_ativos.dart`, `dash_uso.dart` | topo de KPI + gráficos; Uso absorveu a trilha de auditoria |
| `admin/admin_dashboard.dart` | `resultado` \|\| `financeiro` \|\| `pecuaria` resolvem no mesmo painel — links antigos não caem em tela vazia |
| `fazendas_module.dart`, `router/app_router.dart` | Consultas saiu de `dashboards/` para `/fazendas/consultas`, com a política de acesso ajustada |
| `screens/mais_screen.dart` | "Painéis de decisão" × "Consultas e auditoria" × "Operacional" |
| `screens/fazendas_home.dart` | `_HomeGerencial` virou torre de controle |
| `functional_catalog.dart` | `painel-pecuario` fundiu em `painel-financeiro`; títulos e rotas atualizados |
| `mocks/dashboards_mocks.dart` | ver abaixo |
| `lib/ui/` + `widgetbook_app.dart` | 7 componentes novos, 3 corrigidos |
| `design/tokens.ts` → DTCG → Dart | grupo `chart` por tema |
| `test/` | `dash_resultado_test`, `charts_golden_test` e contagens congeladas atualizadas |

### Números que passaram a ser derivados

Três conjuntos de literais escritos à mão não fechavam entre si e agora saem de uma fonte só:

| Antes | Depois |
|---|---|
| Receita/custo/margem literais na Home **e** em Pecuária | derivados de `resultadoMeses` |
| `centrosCusto` somava 1.230, mas o custo do mês era 1.100 | derivado do último `ResultadoMes`, fecha com o custo |
| `AtivosResumo` dizia depreciação de 720 mil; a lista dá ~810 mil | derivado de `ativos` via `aquisicaoMil` |
| `Cotacao.total` era string | derivado de `totalValor` |

### Contagens congeladas

`adminFeatures` 15 → 14, `allFeatures` 58 → 57, `ready` 51 → 50, `existingRoute` 20 → 19. Os números
são congelados de propósito; esta alteração é deliberada e fica registrada aqui.

## 8. O que não foi feito

- A responsividade entrou via `AppMetricGrid` nos topos de KPI. As grades internas de Confinamento
  (mapa de currais) continuam com `GridView.count` de coluna fixa — não foram tocadas nesta rodada.
- Os painéis seguem sobre mock: o produto continua exclusivamente frontend.
- O filtro de período da Home e dos painéis é decorativo, como já era em Análise de Uso.
