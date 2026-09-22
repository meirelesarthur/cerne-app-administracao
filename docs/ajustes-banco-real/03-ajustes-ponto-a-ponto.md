# Documento 2 — Ajustes ponto a ponto do protótipo Flutter para alinhar ao banco real

> Frente 2 de 2. Objetivo: dizer exatamente o que mudar no protótipo Flutter — por cadastro,
> campo a campo — para que ele fique o mais aderente possível ao banco real de produção
> (`gbcerne`, 415 tabelas), reduzindo ao mínimo a adaptação que o time do sistema web/backend
> vai precisar fazer quando ligar este app ao banco de verdade. Não é um plano de arquitetura
> de API; é uma lista de ajustes de **modelo de dado e de tela** para você aplicar no
> protótipo. Parte direto do que os dois documentos anteriores levantaram —
> [mapa campo a campo](01-mapa-catalogo-banco.md) e
> [oportunidades do banco](02-oportunidades-banco-real.md).

## Critério usado em cada ajuste

Cada item abaixo segue uma das cinco ações:

- 🆕 **ADICIONAR CAMPO** — a coluna existe no banco, tem dado real, e o protótipo não pede
  essa informação hoje. Adicionar agora custa pouco e evita que o time web tenha que "inventar"
  de onde tirar o valor depois.
- ✏️ **RENOMEAR/ALINHAR CAMPO** — o campo existe no protótipo, mas com nome ou formato que não
  bate com a coluna real. Alinhar o `id` do `FeatureField` ao nome da coluna (ou a um nome
  claramente rastreável) evita retrabalho de mapeamento manual no dia da integração.
- 🔁 **TROCAR TIPO** — o campo é texto livre no protótipo, mas no banco é um enum/FK para
  tabela de domínio. Trocar para `select` com opções fixas hoje evita que o time web tenha que
  decidir sozinho quais valores existem.
- 📖 **CRIAR DICIONÁRIO** — o campo já é `select`, mas as opções foram inventadas sem base no
  banco. Preciso que alguém do time de banco confirme a lista real de valores do enum antes de
  eu fechar as opções — sinalizado onde isso se aplica.
- ➕ **NOVO CADASTRO** — não existe tela hoje; o banco tem tabela e dado maduro; vale criar do
  zero seguindo o padrão component-first já existente.

---

## A) Ajustes em cadastros que já existem no protótipo

### `cadastrar-area` (Áreas)

| Ação | Detalhe |
|---|---|
| ✏️ | `area-total` → manter, mas o dump não tem campo de unidade (ver abaixo); considerar fixar hectare como unidade única em vez de campo `select`. |
| 🆕 | Adicionar **Área produtiva** e **Área não produtiva** (`productive_area`, `unproductive_area`) — o dump guarda os dois separados de `total_area`; hoje o protótipo só pede o total. |
| 🆕 | Adicionar **Carga animal** (`animal_load`) — numérico, já usado no dashboard pecuário do banco real; falta no cadastro de área. |
| 🔁 | `tipo` (uso da área) → é `type smallint` no banco, sem tabela de domínio no dump. **Preciso que o time web confirme os valores possíveis** antes de travar as opções do `select` — hoje o protótipo pode ter opções que não batem 1:1. |
| ✏️ | `localizacao` → o banco guarda coordenada como `coordinates`/`kml` (texto de geometria), não endereço textual. Se a intenção é permitir desenhar/colar polígono no mapa, o campo deveria virar um componente de geometria, não `text` simples — se a intenção é só texto livre, deixar como está e avisar o time web que não há endereço estruturado por trás. |
| ❌→manter mock | `unidade` — não existe no banco (a coluna `total_area` já assume uma unidade fixa do tenant). Não adicionar essa pergunta ao usuário; ela não tem onde ser persistida sem uma decisão de produto separada. |

### `formulacoes` (Formulações)

| Ação | Detalhe |
|---|---|
| 🆕 | Adicionar **Custo por kg** (`cost_per_kg`) e **Custo estimado** (`estimated_cost`) — o banco calcula os dois na dieta; o protótipo hoje não mostra custo nenhum, e é provavelmente o dado mais cobrado pelo usuário final numa tela de formulação. |
| 🆕 | Adicionar **Matéria seca (%)** (`dry_matter`) — existe tanto em `diets` quanto em `ingredients`; falta como campo em ambos os níveis (cabeçalho e item de matéria-prima). |
| ✏️ | `porcentagem` → não existe como coluna própria; o banco guarda `quantity` por matéria-prima e a % é sempre calculada. Ajustar o rótulo/lógica do campo para deixar claro que é **derivado** (não editável diretamente), ou manter editável só na UI e calcular `quantity` a partir dele antes de qualquer integração futura. |
| 🆕 | Adicionar **Objetivo** (`objective`, char 2) — o banco separa objetivo de tipo; hoje só existe `tipo` no protótipo. Vale como `select` novo — **preciso confirmar com o time web os valores possíveis de `objective`**. |

### `batidas` (Batida)

| Ação | Detalhe |
|---|---|
| 🆕 | Adicionar **Quantidade realizada** (`quantity_realized`) separada de **Quantidade prevista** (`quantity`) — o banco já separa as duas; o protótipo só tem uma "quantidade de referência". Esse é provavelmente o campo mais valioso a acrescentar no grupo Misturador (mostra desvio de batida real vs. planejada). |
| 🆕 | Adicionar **Diferença** (`difference`) — o banco já calcula o desvio entre previsto/realizado; poupa o time web de recalcular isso na tela. |
| ✏️ | `armazem` → hoje aponta para "armazém de destino" direto; no banco o vínculo é indireto via `stock_id` → `stocks.warehouse_id`. Se o protótipo simular como campo direto, documentar essa indireção para o time web não estranhar a ausência de FK direta. |

### `carga` / `descarga` (Misturador) — ⚠️ maior ajuste estrutural do grupo Misturador

| Ação | Detalhe |
|---|---|
| ➕ | O banco **não tem** uma tabela "carga/descarga de misturador vinculada a equipamento" — o mais próximo é `input_entries`/`stock_writeoffs`, genéricos, sem `equipment_id`. Se o time web for construir o backend, esta é a lacuna que **eles vão te perguntar primeiro**: registrar aqui, no protótipo, a decisão de produto de que "carga"/"descarga" do misturador precisam de uma tabela própria com `equipment_id`, `warehouse_id origem/destino`, `quantity`, `unit` — hoje isso não existe em lugar nenhum do banco atual. |
| 🆕 (se optarem por reaproveitar tabela genérica) | Ao menos os campos `origem`/`destino` deveriam virar FK explícita para `warehouse_id`, e `equipamento` para `equipment_id` — hoje são texto livre no protótipo e não existem nessa forma em `input_entries`. |

### `nota-cocho` (Nota de cocho)

| Ação | Detalhe |
|---|---|
| ➕ | As tabelas de vínculo área↔cocho (`area_trough`, `troughs_area`) estão **vazias** no dump — ou seja, mesmo o time web não tem exemplo real de uso para calibrar esse relacionamento. Recomendo tratar esta tela como candidata a **redesenho conjunto** com o time web antes de codificar mais — não é um ajuste pontual, é uma lacuna de modelagem dos dois lados. |
| 🆕 | Se mantiver o conceito, adicionar `trough_id`/`feedlot_corral_id` explícitos (existem em `item_nutritions`) em vez de um campo único "lote/curral" combinado. |

### `apontamento` (Apontamento agrícola)

| Ação | Detalhe |
|---|---|
| ✏️ | Trocar a tabela-fonte de referência de `planning_activities` para `service_orders` — é lá que o banco guarda responsável, execução e resultado. Ajustar `dataSourceId` no catálogo Dart quando for integrar, para não montar a tela em cima da tabela errada. |
| 🆕 | Adicionar **Data prevista de execução**, **Prazo** (`deadline`), **Resultado esperado** (`expected_result_description`) e **Critério de sucesso** (`success_criteria_description`) — o banco (`service_orders`) já tem esses campos ricos que nenhuma tela do app usa hoje. |
| 🆕 | Adicionar **Avaliação** (`assessment_grade`) e **Feedback** — permitiria fechar o ciclo planejamento→execução→avaliação, hoje ausente. |

### `rebanho-inicial` (Rebanho inicial)

| Ação | Detalhe |
|---|---|
| 🆕 | Adicionar **Data de entrada** (`entry_date`) — já existe em `animals`, falta como campo explícito (hoje só "Data de referência", que pode não ser a mesma coisa). |
| ✏️ | `area` → hoje texto/select solto; no banco não é campo direto de `animals` — vincula via `batch_animals`/`transfer_animal_farms`. Ajustar para exigir primeiro um lote (`batch_id`), e a área vir do lote, não do animal direto. |

### `transferencia-animal` (hardware, mas com campos de contexto)

| Ação | Detalhe |
|---|---|
| ⚠️ | **Risco de nome errado de tabela-fonte**: a funcionalidade se chama "Transferência animal/lote", mas a tabela `transfer_animal_farms` no banco é transferência **entre fazendas**, não entre lotes. A tabela certa para "novo lote"/"lote atual" é `transfer_batch_farms`. Ajustar o `dataSourceId` antes do time web montar a API, ou eles vão implementar o endpoint errado. |

### `sanitario` (Sanitário)

| Ação | Detalhe |
|---|---|
| 🆕 | Adicionar **Controle por tempo** (`time_control`, boolean) — existe em `sanitaries`, indica se o manejo tem intervalo/carência a respeitar (relevante para compliance de retirada de leite/carne pós-medicamento); ausente no protótipo hoje e é um dado sensível de rastreabilidade. |
| ✏️ | `tipo` → hoje é `select` genérico; o banco distingue vacina (`item_sanitary_vaccines`, quase sem dado — só 1 linha) de procedimento geral (`item_sanitaries`). Não vale over-engenheirar por uma tabela quase vazia; manter `tipo` genérico é a decisão certa por ora. |

### `apartacao` (Apartação)

| Ação | Detalhe |
|---|---|
| 🆕 | Adicionar coluna/tabela de **critério de apartação** — não existe no banco hoje (nem no protótipo). Se este campo for mantido no protótipo, sinalizar ao time web que precisarão criar uma coluna nova (`criterio` ou similar) em `separations` — hoje o app estaria "na frente" do banco aqui, o que é o inverso do resto do documento e vale registrar explicitamente. |
| ✏️ | `lote-destino` → o banco só liga lote↔separação (`batches_separations`), sem distinguir origem/destino explicitamente. Ajustar para gravar **duas linhas** de vínculo (uma por lote envolvido) em vez de um campo único "destino", para bater com o formato real de N:N. |

### `estacao-monta` / `lotes-reproducao` / `material-reprodutivo` / `monta-natural` / `diagnostico-gestacao`

| Ação | Detalhe |
|---|---|
| ➕ | **Método da estação** (`metodo`), **finalidade do lote** (`finalidade`), **raça do material reprodutivo** e **fornecedor** não têm coluna própria no banco — hoje ficam "escondidos" atrás de joins (ex.: raça vem de `animals.breed_id` só se for touro vivo). Se o protótipo mantiver esses campos como pergunta direta ao usuário, o time web vai precisar decidir se cria coluna nova ou infere por join — registrar a decisão aqui evita que cada lado resolva diferente. |
| 🆕 | Adicionar **Resultado do diagnóstico de gestação** como campo explícito por animal — hoje `pregnancy_diagnosis_animals` não parece ter uma coluna de resultado direta (a categoria fica em `diagnosis_pregnancies`, tabela de domínio com só 3 linhas); vale um `select` alimentado por esse dicionário pequeno. |
| ⚠️ | `ultrasounds` está **vazia** no dump — se "Diagnóstico de gestação" depender de imagem/laudo de ultrassom, não há exemplo real para validar o formato; tratar como decisão em aberto, não como ajuste mecânico. |

### `minhas-os` (Minhas OS)

| Ação | Detalhe |
|---|---|
| 🆕 | O protótipo hoje não declara campos para esta tela — o banco (`service_orders`) tem um dos schemas mais ricos do dump: prazo, requisitos climáticos (`minimum_temperature`/`maximum_temperature`), restrição ambiental, avaliação e feedback. Vale desenhar a tela com esses campos desde já, porque é exatamente o formato que o backend real vai entregar — menos trabalho de adaptação depois. |

---

## B) Novos cadastros a criar no protótipo (dado maduro, zero tela hoje)

Ordenados pelo mesmo critério de prioridade do Documento 1.

### 1. Consulta/cadastro de Produtos ➕

- Fonte: `products` (543.983 linhas — a maior tabela do banco).
- Campo mínimo sugerido, já no nome da coluna real (facilita o de-para futuro):
  `description`, `category_id`, `measurement_id`, `average_cost`, `purchase_price`,
  `market_price`, `min_stock`, `is_enabled`, `has_lot`.
- Padrão de tela: igual ao já usado em "Saldo de estoque" (`listMode: true`), sem necessidade
  de criar componente novo.

### 2. Cadastro de Clientes ➕

- Fonte: `clients` + `people` (3.247 / 25.234 linhas).
- Campo mínimo sugerido: `contact`, `contact_phone`, `state_registration`, `taxpayer`,
  `final_costumer`, mais os dados de pessoa (`person_id` → nome/documento).
- Complementa "Vendas", que já existe e tem 1.262 registros reais — hoje o app trata cliente
  como texto solto dentro da venda.

### 3. Central de notificações ➕

- Fonte: `notifications` (457.416 linhas).
- Campo mínimo sugerido: `type`, `data` (payload), `read_at` (para marcar lida/não lida).
- Padrão de tela: lista com badge de não lidas no shell — reaproveita o ícone de sino já
  previsto em qualquer shell padrão do design system.

### 4. Linha do tempo / evolução do animal ➕

- Fonte: `evolutions` (159.859 linhas).
- Campo mínimo sugerido: `date`, `category_old_id`, `category_next_id`.
- Encaixa como nova aba dentro da ficha de animal já existente (`registrar-animal`), não como
  tela isolada — menor esforço de UX, maior densidade de dado histórico exibido.

---

## C) Dicionários de domínio pendentes de confirmação com o time web

Estes campos são `smallint`/`char` no banco **sem tabela de domínio correspondente no dump** —
ou seja, mesmo o time web precisa de outra fonte (código legado, documentação interna) para
saber os valores possíveis. Sinalizar isso agora evita que o protótipo trave um `select` com
opções inventadas que depois não batem com a realidade:

- `areas.type` (tipo de uso da área)
- `diets.objective` / `diets.type`
- `sales.payment_method`, `movement_sales.type`
- `service_orders.category`, `service_orders.status`
- `breeding_matings.type` (natural vs. IATF vs. outro)
- `stocks`/`stock_movements.type` e `.classification`

Recomendação prática: antes de travar as opções desses `select` no protótipo, pedir ao time
web a lista de valores válidos de cada enum — é mais barato perguntar agora do que descobrir
depois que as opções do protótipo não correspondem a nenhum valor real aceito pelo banco.

---

## D) Resumo de esforço

| Bloco | Esforço estimado | Observação |
|---|---|---|
| A) Ajustes em cadastros existentes | Baixo–Médio por item | Maioria é adicionar campo ou renomear `id`; nenhum exige componente novo |
| B) Novos cadastros | Baixo (Produtos, Notificações) / Médio (Clientes, Evolução do animal) | Todos reaproveitam padrões de tela já existentes no catálogo |
| C) Dicionários pendentes | Não é esforço de código — é uma pergunta a fazer ao time web antes de codificar os `select` | Bloqueante para travar opções corretamente |
| Carga/Descarga do misturador, Nota de cocho, Apartação (critério) | Alto | Únicos três pontos onde o banco realmente não tem modelo pronto — exigem decisão de produto conjunta com o time web, não só ajuste de campo |

---

## Como aplicar

Sugestão de ordem de trabalho no protótipo, para não gerar dois PRs conflitantes:

1. Rodar o bloco **A** primeiro (são edições em arquivos que já existem — menor risco).
2. Criar os **novos cadastros do bloco B** um de cada vez, seguindo a Lei 1 do projeto
   (component-first: nascer em `apps/mobile/lib/ui/` antes da tela).
3. Levar o bloco **C** para uma conversa com o time web antes de travar qualquer `select` —
   não é algo para decidir sozinho no protótipo.
4. Os três itens de "Alto esforço" (carga/descarga do misturador, nota de cocho, critério de
   apartação) merecem uma reunião de modelagem conjunta, não uma implementação isolada — são
   os únicos casos deste documento em que o protótipo já pensa algo que o banco real ainda não
   tem.
