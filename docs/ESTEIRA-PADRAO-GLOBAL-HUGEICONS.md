# Esteira — Padrão global (Figma) + migração de iconografia para Hugeicons 1.2

Referência de design: `S8qJ9G8mbenqZ0Zcq3XnrE` (GB CERNE), nó `54300-2458`, seções **`operacao`**
(`54349:3294`) e **`administrativo`** (`54349:3295`).
Referências de código: `apps/mobile/lib/ui/` (catálogo), `apps/mobile/lib/shell/`,
`apps/mobile/lib/modules/` (6 módulos), `design/tokens.ts` (Lei 3/5).

## Objetivo

Duas entregas acopladas, na ordem em que se sustentam:

1. **Iconografia única.** Substituir Lucide por **Hugeicons *stroke-rounded* com traço 1.2** em todo
   o app, atrás de uma camada própria do catálogo — não trocando `IconData` por `IconData` espalhado
   em 98 arquivos.
2. **Padrão global de tela.** Elevar os 6 frames do Figma a gramática da aplicação: cabeçalho,
   busca, ladrilho de módulo, barra de ação fixa e passos. E fixar a separação **ADM × Operação**
   como dois arquétipos de home distintos, não como uma home com `if`.

**Status: E1–E9 entregues.** As seções 1–4 são auditoria e decisão (fechadas). A seção 5 traz o
estado real de cada etapa; a seção 6 registra o que ficou de fora e por quê.

---

## 1. Leitura do Figma — o que os 6 frames definem

| Frame | Nó | Papel na gramática |
|---|---|---|
| `operacao-home` | `54300:15706` | Arquétipo **Operação**: lançador de tarefas |
| `modulo-confinamento` | `54349:3009` | Arquétipo **módulo**: grade de funcionalidades |
| `Cadastro bottom fixed(sem navbar)` | `54300:16032` | Arquétipo **fluxo curto**: form + barra de ação fixa |
| `Cadastro steps(sem navbar)` | `54349:1990` | Arquétipo **fluxo longo**: passos + duas ações |
| `administrativo-home` | `54300:16069` | Arquétipo **ADM**: torre financeira |
| `Menu-rapido-admin` | `54349:2829` | Arquétipo **descoberta**: produtos, atalhos, histórico |

### 1.1 Geometria medida (frame de 402 px)

Valores extraídos de `get_design_context`, não estimados da imagem:

| Elemento | Medida |
|---|---|
| Canvas | `#f0f0f0` |
| Seletor de fazenda | topo 16, ícone 20 px, rótulo 16 px `#047857`, caret 20 px |
| Cartão de conteúdo | branco, raio **24**, topo 53, largura 402 |
| Cabeçalho de usuário | 16/29, avatar 48, "Boa tarde," 14 px `#6b7280`, nome 20 px SemiBold `#141414` |
| Bolha de notificação | 44×44, raio 22, branco, sombra `0 2px 4px rgba(0,0,0,.04)`, ícone 28 |
| Campo de busca | 370×52, `#f0f0f0`, raio **20**, `pl 12 / pr 8`, botão 40 circular branco |
| Ladrilho de módulo | **180×116**, `#f0f0f0`, raio **20**, `px 12 / py 16`, sombra `0 4px 6px rgba(0,0,0,.02)` |
| Grade | 2 colunas, **gap 8**, ícone 24 no topo-esquerda, rótulo 14 px na base |
| Ladrilho largo | 370×116, mesma anatomia |
| Preto de marca | `#023535` |

### 1.2 Achados

**A. O ladrilho de módulo é um componente novo, não uma variação de `AppQuickAction`.**
`AppQuickAction` é círculo + rótulo centralizado. O ladrilho do Figma é retângulo 180×116 com
ícone **ancorado no topo-esquerda** e rótulo **ancorado na base-esquerda** (`justify-between` numa
coluna). São leituras visuais diferentes; forçar props em `AppQuickAction` violaria a Lei 2 pela
porta dos fundos. Entra no catálogo como componente próprio.

**B. O Figma mistura Outfit e Montserrat.** Rótulos de ladrilho e placeholder de busca vêm como
`Montserrat`; cabeçalho e seletor vêm como `Outfit`. A **Lei 3 do projeto prevalece**: Outfit é a
única família de apresentação. Divergência deliberada e registrada — não é lacuna de implementação.

**C. Raio 20/24 não existe na escala atual.** `radius` tem `xl: 18` e `2xl: 22`; o Figma pede 20
(ladrilho, busca) e 24 (cartão de conteúdo). Valores novos entram em `design/tokens.ts` primeiro
(Lei 5), como `radius.tile` e `radius.surface`.

**D. A separação ADM × Operação já existe no código, mas não como arquétipo.**
`FazendasHome` ramifica em `_HomeCampo` / `_HomeGerencial` por `UserAccessProfile`. O Figma confirma
a divisão e a torna mais forte: as duas homes não compartilham **nenhum** bloco de conteúdo —
Operação é lançador de tarefa, ADM é torre financeira com abas. O que elas compartilham é o
**cabeçalho** (seletor de fazenda + saudação + busca), e só ele.

**E. Dois ícones do Figma não são Hugeicons.** As camadas `confinamento` (34×28) e a de Pecuária
(33.9×28) são vetores autorais multi-path, não pertencem ao set. Ver decisão em §3.3.

---

## 2. Auditoria da iconografia atual

| Métrica | Valor |
|---|---|
| Referências `LucideIcons.*` em `lib/` | **384** |
| Ícones Lucide distintos em uso | **119** |
| Arquivos que importam `lucide_icons_flutter` | **98** |
| Usos de `Icon(` | 174 |
| Componentes de `lib/ui/` com `IconData` na assinatura | **12** |
| Ícone Material remanescente | 1 (`Icons.info_outline`) |

Componentes do catálogo com `IconData` na API pública: `alert_strip`, `app_icon_tile`, `bento_tile`,
`dashboard_card`, `empty_state`, `hardware_simulator`, `illustration_slot`, `menu_item`,
`mini_app_tile`, `quick_action`, `stepper`, `success_panel`.

---

## 3. Decisões técnicas

### 3.1 Pacote: `hugeicons` 1.1.7 — e por que traço 1.2 é atingível

Verificado no código-fonte do pacote (não na documentação):

- Os ícones **não são `IconData`**. São `List<List<dynamic>>` — estrutura JSON de tags + atributos
  SVG, montada em runtime e desenhada por `flutter_svg`.
- `HugeIcon` expõe `strokeWidth`, e o builder **sobrescreve** o atributo `strokeWidth` do JSON
  (`lib/hugeicons.dart`, `_buildSvgFromJson`). O set gratuito nasce em `1.5`; **1.2 é aplicável
  exatamente**, sem redesenhar nada.
- Cobertura: **5 159** ícones *stroke-rounded*.

Isso descarta a alternativa de gerar uma fonte de ícones: converter traço em contorno congelaria o
1.2 no binário e perderia o override. O caminho SVG mantém a espessura como **token**.

### 3.2 A camada `AppIcon` — consequência da Lei 1 e da Lei 2

Como o ícone deixa de ser `IconData`, a API pública do catálogo muda. Em vez de espalhar
`HugeIcon(...)` por 98 arquivos:

```dart
typedef AppIconData = List<List<dynamic>>;   // tipo do projeto, não do pacote
class AppIcons { static const AppIconData confinamento = ...; }   // catálogo semântico
class AppIcon extends StatelessWidget { ... }                     // único renderizador
```

Três consequências desejadas:

1. **A espessura 1.2 é definida em um lugar só** — `AppIcon` lê o token, nenhuma tela passa
   `strokeWidth`.
2. **O catálogo é semântico, não gráfico.** Telas pedem `AppIcons.confinamento`, não
   `HugeIcons.strokeRoundedBarns`. Trocar o desenho de "confinamento" vira uma linha.
3. **O pacote fica isolado.** Nenhum `import 'package:hugeicons/...'` fora de `lib/ui/`.

### 3.3 Os dois vetores autorais do Figma

`confinamento` e `pecuária` não existem no set gratuito (não há bovino em Hugeicons free — a busca
por `Cow`/`Cattle`/`Bull` retorna vazio). O caminho foi em duas etapas:

- **E1–E5 (migração):** mapeados para o equivalente semântico mais próximo do set (`Barns` e
  `Steak`), mantendo a app inteira numa família só.
- **E8 (fidelidade, feito):** os SVGs autorais entregues pelo designer vivem em `assets/icons/` e
  são servidos pela **mesma** API `AppIcon` — o consumidor não sabe a origem. Isso obrigou
  `AppIconData` a virar classe com duas origens (`.glyph` e `.asset`); como as 384 chamadas passam
  `AppIcons.xxx`, só o **tipo** mudou, e nenhuma delas foi tocada.

**Normalização do traço.** O desenho vive num viewBox de 34 de largura e é encaixado numa caixa de
24, ou seja, sofre escala `24/34`. Para que o traço *renderizado* seja 1.2, a fonte precisa de
`1.2 × 34/24 = 1.7` — é o valor gravado nos arquivos, e há teste guardando a conta.

**Ressalva real, medida no arquivo:** `pecuaria.svg` tem **4 caminhos preenchidos e 0 traços** —
foi exportado com o contorno já vetorizado. A espessura está embutida na geometria e **não segue**
`AppSize.iconStroke`. `confinamento.svg` é misto (4 preenchidos + 9 traçados): a estrutura do curral
acompanha o token, a cabeça do bovino não. Uma reexportação do Figma com o traço preservado
resolveria; há um teste que falha no dia em que isso mudar, para tirar a ressalva daqui.

### 3.4 Mapa Lucide → Hugeicons

**132 entradas, validadas programaticamente contra os 5 159 nomes do pacote; 0 inválidas; cobertura
de 119/119 ícones em uso.** O mapa é a fonte da migração e vive versionado em
`scripts/icon-map.json`. Escolhas guiadas, quando existe, pelo **nome de camada do Figma** —
`BarnsIcon`, `TractorIcon`, `ScanHeartIcon`, `BookSearchIcon`, `CloudSyncIcon`, `BankIcon`,
`EyeOffIcon`, `CreditCardAcceptIcon`, `ArrowRight01Icon`, `FilterHorizontalIcon`, `AiSearch01Icon`,
`Store02Icon`, `ConnectIcon`, `Cash02Icon`, `SaveAllIcon`, `GreenHouseIcon`.

Substituições que mudam o desenho e merecem atenção em revisão visual:

| Lucide | Hugeicons | Motivo |
|---|---|---|
| `beef` | `Steak` | não há bovino no set gratuito |
| `boxes` | `Cube` | `BoxesIcon` do Figma é Pro |
| `eyeOff` | `ViewOff` | nomenclatura do set |
| `partyPopper` | `Party` | nomenclatura do set |
| `cloudSync` | `CloudSavingDone01` | não há nuvem+refresh no set gratuito |
| `handshake` | `Agreement01` | não há aperto de mão no set gratuito |
| `sprout` | `Plant01` | não há broto no set gratuito |
| `heartCrack` | `Sad02` | não há coração partido no set gratuito |

---

## 4. Arquétipos de home — ADM × Operação

O que separa as duas não é conteúdo: é **a pergunta que a tela responde**.

| | Operação | ADM |
|---|---|---|
| Pergunta | "o que eu executo agora?" | "o que precisa da minha decisão?" |
| Corpo | grade de ladrilhos de módulo | abas + cartão financeiro + listas |
| Densidade | 1 nível, sem rolagem longa | multi-seção, rolagem |
| Ação terminal | abrir um fluxo de registro | abrir um painel de leitura |
| Compartilhado | \multicolumn — cabeçalho (seletor + saudação + busca) e nada mais ||

Regra derivada: **nenhum bloco de conteúdo pode ser compartilhado entre as duas homes.** O que for
comum sobe para o cabeçalho global; o que for específico fica no arquétipo.

---

## 5. Esteira de execução

| Etapa | Escopo | Critério de aceite | Estado |
|---|---|---|---|
| **E1** | Fundação: `hugeicons` no pubspec; tokens de ícone e `radius.tile/surface` em `design/tokens.ts` → DTCG → Dart; `AppIcon` + `AppIconData` + `AppIcons` em `lib/ui/` | `tokens:verify` limpo; `AppIcon` no Widgetbook | **feito** |
| **E2–E5** | Catálogo, shell, 6 módulos e suíte; remoção do `lucide_icons_flutter`; gate anti-regressão | `analyze --fatal-infos` limpo; suíte verde; `quality:functional` 34/34 | **feito** |
| **E6** | `AppModuleTile`/`AppModuleTileGrid`, `AppFarmSelector`, `AppSearchField` | casos no Widgetbook; 18 testes novos | **feito** |
| **E7** | Home de Operação no arquétipo: `ResponsibilityWorkspace` adota a grade do padrão e o seletor de fazenda | nenhum cartão de módulo reimplementado na tela | **feito** |
| **E8** | Busca global (`/busca`) e os dois SVGs autorais de §3.3 | busca nos dois perfis; ícones autorais servidos pela mesma `AppIcon` | **feito** |
| **E9** | Barra de ação fixa e régua de passos dos frames de cadastro; extensão do vocabulário às telas sem frame próprio | `FlowShell` e `BankFlowShell` consomem `AppTopBar`, `AppStepProgress`, `AppContentSheet` e `AppActionBar`; suíte e capturas canônicas verdes | **feito** |

### Números da entrega

| Medida | Antes | Depois |
|---|---|---|
| Referências de ícone | 384 `LucideIcons.*` | 384 `AppIcons.*` |
| Famílias de ícone no app | 2 (Lucide + 1 Material) | **1** (Hugeicons 1.2) |
| Espessura de traço | do glifo do pacote, não controlável | `AppSize.iconStroke` = **1.2** |
| Testes | 447 | **497** |
| `main.dart.js` (release) | 3 116 932 B | 3 383 979 B (**+8,6 %**) |

O crescimento de 267 KB responde ao risco de bundle levantado abaixo: os 8 MB de dados do pacote
**não** vão para o binário — o *tree-shaking* leva apenas os ~132 ícones referenciados, mais o
renderizador SVG. Medido com `flutter build web --release` nos dois lados do commit.

### Gates permanentes adicionados

- `component_first_test.dart` proíbe `import 'package:lucide_icons_flutter/...'` em qualquer lugar e
  `import 'package:hugeicons/...'` fora de `lib/ui/app_icon.dart`.
- O gate de espessura previsto foi **descartado**: seria redundante. `AppIcon` não expõe
  `strokeWidth`, então o compilador já impede um consumidor de definir a sua; e chamar `HugeIcon`
  direto já esbarra no gate de import. A regex ampla que restaria só acertava `Paint..strokeWidth`
  dos gráficos, que nada tem a ver com iconografia.
- `test/helpers/app_icon_finder.dart` é o substituto de `find.byIcon` na suíte.

### Riscos

| Risco | Mitigação |
|---|---|
| `HugeIcon` é `StatefulWidget` + `flutter_svg`; custo por ícone maior que um glifo de fonte | **aberto.** O widget cacheia o SVG montado por (ícone, cor, traço), e nada foi observado no protótipo; falta medir em lista longa real |
| Tamanho do bundle web (8 MB de dados no pacote) | **fechado: +8,6 %** (267 KB) no `main.dart.js`, medido nos dois lados do commit — o *tree-shaking* funciona |
| Goldens quebram em massa | **fechado:** um único golden dependia de ícone (`AppTransactionListItem`), regravado após inspeção nos dois temas |

---

## 6. O que ficou aberto — e por quê

**A. ~~A busca global não tem destino.~~ Fechado na E8.** `/busca` é tela cheia fora do
`ShellRoute` (como `/perfil` e `/notificacoes`), procura nas **57 funções dos dois perfis** por
nome, objetivo e módulo, e ignora acento e caixa — ninguém digita acento de bota, no curral.

Uma decisão de produto ficou embutida e merece revisão sua: a busca **acha** nos dois perfis, mas
só **abre** o do perfil da sessão. Uma função do outro ambiente aparece marcada e não é tocável,
porque `redirectForSession` a desviaria de volta para a home sem explicar nada — achar é diferente
de poder abrir, e a tela diz qual dos dois está acontecendo. Se a intenção for permitir a abertura
cruzada, o que muda é a política de acesso, não a busca.

**B. ~~Os frames de cadastro não foram tocados.~~ Fechado na E9.** `FlowShell` e `BankFlowShell`
passaram a montar o mesmo arquétipo dos dois frames: `AppTopBar` fixa sobre o canvas,
`AppContentSheet` para o formulário, `AppStepProgress` nos fluxos longos e `AppActionBar` fixa para
uma ou duas ações. Os nove fluxos operacionais, Pix, pagamentos simples e as jornadas mapeadas
herdam a gramática por esses shells; `AppStepper` continua exclusivamente como entrada numérica.

**C. ~~Os dois vetores autorais continuam mapeados por aproximação.~~ Fechado na E8**, com uma
ressalva de origem e uma observação ótica:

- `pecuaria.svg` veio com o contorno vetorizado, sem traço — não acompanha o token (ver §3.3).
- Os dois desenhos têm folga interna no próprio viewBox e, encaixados na caixa de 24 px como todo
  ícone do sistema, leem **menores** que os do Hugeicons ao lado. No Figma isso não aparecia porque
  lá eles ocupavam 34 px, e não 24. Apertar o viewBox ao conteúdo real resolveria sem número
  mágico; fica como refinamento.

**D. `ContextBadge` e `AppFarmSelector` mostram a mesma informação.** São dois componentes de
propósito diferente: a faixa dentro dos fluxos é mitigação de IDOR ("você está lançando *nesta*
fazenda"), o seletor do cabeçalho é contexto de leitura. A folha de troca, que era duplicável,
virou `openFarmPicker` e hoje é única. Fundir os dois visuais é decisão de design, não de código.

**E. Divergências deliberadas do Figma, já no código:**

| Figma | GB CERNE | Motivo |
|---|---|---|
| Montserrat no hero, ladrilhos, abas, rótulos, placeholders e textos secundários | Outfit nos mesmos tamanhos/pesos/line-heights | Lei 3 — família única de apresentação |
| Ladrilho cinza sobre cartão branco | Ladrilho `bgSurface` sobre o canvas | Não existe o cartão branco intermediário; no tema claro `bgSubtle` **é** a cor do canvas, e as fileiras sumiriam |
| Home de Operação com 9 módulos fixos | Grupos do `functional_catalog.dart` | Os grupos do catálogo já são, um a um e na mesma ordem, os ladrilhos do Figma — e cada um tem destino real |

**F. Telas sem frame próprio.** A extensão deliberada usa sempre o arquétipo mais próximo, sem
criar uma segunda linguagem visual:

- dashboards administrativos usam a moldura de `administrativo-home` sem as abas, com
  `AppTopBar`, folha, `AppSectionTitle`, `AppChartCard` e `AppKpiStatCard`;
- detalhes usam a leitura *bottom fixed*, com conteúdo em folha e ação primária no rodapé quando
  existe decisão terminal;
- Perfil e Mais seguem `Menu-rapido-admin`; bottom sheets e modais herdam `bg.sheet` e raio superior
  `surface`;
- Android Home, pasta CERNE, login e onboarding preservam a arte de tela cheia, mas usam Outfit e os
  controles tokenizados do catálogo. São as únicas exceções estruturais à `AppContentSheet`.
