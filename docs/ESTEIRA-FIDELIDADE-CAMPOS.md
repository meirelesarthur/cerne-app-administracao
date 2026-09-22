# Esteira — Fidelidade de campos dos cadastros (leva "fidelidade-campos")

> Leia este arquivo antes de mexer em qualquer item desta leva e atualize-o no mesmo commit
> de cada onda concluída — mesmo padrão de continuidade de
> `docs/ajustes-banco-real/00-ESTEIRA-AJUSTES-BANCO-REAL.md` e
> `docs/ESTEIRA-FRONTEIRA-OPERACIONAL.md`.

## Origem e objetivo

Esta leva nasce da auditoria de fidelidade **"Gaps de campo nos cadastros do protótipo"**
(07/09/2026): cada formulário do protótipo Flutter comparado, campo a campo, com o **Form
Request real da API** (`GB.Cerne.Api/app/Http/Requests`), por dois auditores independentes.

O resultado era ruim: dos **24 cadastros** analisados, **22 tinham campo faltando** — 14 de
severidade alta. E o diagnóstico dizia o essencial: *o protótipo não validaria submissões
conforme o contrato real*. Não é uma questão de tela incompleta; é um formulário que, ligado
ao backend, seria rejeitado.

A auditoria identificou três causas, e não 22 problemas soltos:

| # | Padrão | O que acontece |
|---|---|---|
| ① | **Coleção de itens achatada** | O cadastro real é *cabeçalho + coleção* (`items[]`, subcadastros) e o protótipo virou formulário plano — a coleção desaparece inteira. É a maior lacuna: apontamento (5 coleções), pastagens (5), sanitário, compras de animais, batidas, acasalamento. |
| ② | **Escalares obrigatórios ausentes** | `date` e `code` são `required` no contrato e faltavam em quase toda a reprodução. O formulário não submeteria como estava. |
| ③ | **Campos inventados** | O protótipo criou campos que não existem no contrato — `responsavel` (resolvido no servidor por `Auth::id()`), `marcacao.tipo/descricao`, `area.cultura`. |

**Objetivo desta leva**: fechar ① e ② nos 24 cadastros, e dar ao motor genérico de cadastros
as duas coisas que faltavam para isso caber numa tela de celular — **etapas** e **coleção
obrigatória**. O padrão ③ fica registrado e **não** é tratado aqui (ver Curadoria).

## Regras específicas desta leva

- Branch de execução: `feature/fidelidade-campos` (criada a partir de `main`).
- Prefixo de commit: `(fidelidade-campos)` dentro do tipo Conventional Commit — ex.:
  `feat(fidelidade-campos): pastagens volta ao operacional e completa`.
- Continuam valendo todas as leis do `CLAUDE.md` (component-first, tokens, push só sob pedido
  explícito).
- **Dado de exemplo é sintético**, fiel ao formato e à ordem de grandeza reais — nunca um
  registro copiado do dump de produção. Mesma regra da leva `banco-real`.
- Escopo continua frontend-only: esta leva enriquece o **contrato declarado na tela**, não
  cria backend nem persistência.

## Curadoria desta leva

Quatro decisões de escopo, tomadas antes da primeira linha de código:

1. **A leva é aditiva. Nenhum campo sai.** Os campos inventados do padrão ③ ficam. Motivo
   prático: `responsavel` aparece em `recordTitleField`/`recordDescriptionFields`, nas
   amostras semeadas e em vários testes congelados de quase todo o catálogo — removê-lo agora
   custaria uma refatoração ampla por um ganho apenas de fidelidade de contrato, que o
   backend resolve ignorando o campo. Fica como onda futura, junto da correção de `apartacao`
   (que aceita **mais** do que a API recebe).
2. **As consultas somente leitura também foram completadas.** Oito dos 24 cadastros hoje são
   consulta (`readOnly: true`) e não renderizam formulário. Os `fields` ali servem de
   documentação do contrato real — o próprio catálogo diz isso desde a Onda 1 da esteira de
   fronteira. Completá-los agora fecha os 24 cadastros de uma vez e deixa a documentação
   pronta para quando o backend for ligado. Onde havia amostra semeada, a amostra passou a
   exibir os campos novos: numa consulta, o que a pessoa vê são os `details`.
3. **`lotes-reproducao` volta, mas como consulta administrativa.** A avaliação de `360f0f8`
   continua valendo (vincular lote à estação de monta é organização estrutural, não execução
   de campo); o que se perdeu ao tirá-la do catálogo foi a **documentação** do contrato
   `/breeding-batches`, que esta auditoria audita. Como consulta somente leitura em
   "Consultas e auditoria", o vínculo volta a ser visível no app sem reabrir o cadastro no
   celular.
4. **Etapas só nos formulários longos** — 11 campos ou mais. Abaixo disso, uma tela só é mais
   rápida em campo do que quatro (`abastecimentos`, com 10 campos, ficou de fora de
   propósito). São 8 telas em etapas no motor genérico, mais o `ApontamentoFlow`, que é fluxo
   dedicado.

Uma decisão adicional, no meio da onda 3: **os três valores recalculados pelo servidor**
(`price_arroba_alive`, `value_unitary`, `unity_animal_ua`) entram **opcionais**, embora o Form
Request os marque `required`. O servidor os recalcula, e pedir "UA" a quem está no brete seria
exigir conta de escritório em pé no curral. A divergência está anotada no catálogo, no ponto.

---

## Onda 0 — Motor: etapas e coleções obrigatórias

Sem tela nova. O motor genérico (`MappedFeatureScreen`) ganha o que só os fluxos dedicados de
campo tinham.

- [x] `FeatureFormStep` em `functional_catalog.dart`: uma etapa nomeia um subconjunto dos
      `fields` (por `id`) e/ou das `sections` (por nome). Etapa **sem** campos e sem coleções é
      a revisão. `steps` vazio mantém o comportamento anterior — nenhuma tela muda sem
      declarar etapas.
- [x] `FeatureDefinition.requiredSections`: coleções que o contrato exige com `min:1`. Antes
      toda coleção era opcional no protótipo, e um cadastro cujo conteúdo real **é** a coleção
      podia ser salvo vazio.
- [x] `functional_journey_engine.dart`: `advanceStep`/`retreatStep`, validação por etapa,
      `isFeatureFieldRequired` (obrigatoriedade condicional — o XOR de destino da pastagem) e
      `submit` que volta para a **primeira etapa com pendência** em vez de falhar em silêncio
      numa tela que a pessoa não está vendo.
- [x] `AppReviewList` em `lib/ui/` (+ caso no Widgetbook): a régua de etapas resolve *onde
      estou*, não *o que já respondi* — quebrar um cadastro de 12 campos em quatro telas
      esconde as três primeiras no momento de salvar.
- [x] `MappedFeatureScreen`: `AppStepProgress` no topo da folha, título e orientação da etapa
      no lugar de "Dados do registro", CTA "Continuar" até a última etapa, "Voltar" no rodapé
      **e no cabeçalho** (recuar em vez de abandonar o preenchimento) e o erro de coleção
      obrigatória no lugar certo.

Duas invariantes novas em `functional_catalog_test.dart` protegem o motor:

- **as etapas alcançam todo campo e toda coleção.** Um campo fora de qualquer etapa fica
  invisível para sempre — e o motor não percebe, porque o campo continua no contrato e
  continua sendo validado no `submit`: a pessoa levaria um erro sobre um campo que a tela
  nunca mostrou. O teste também exige revisão única e última, e campo-alvo de simulação na
  primeira etapa.
- **coleção obrigatória existe entre as coleções da tela** — e são exatamente duas no
  catálogo.

## Onda 1 — Pastagens volta ao operacional

- [x] Reverte a terceira decisão de `360f0f8`. Registrar recursos e serviços aplicados na
      pastagem é o mesmo gênero de lançamento do apontamento agrícola — data, local, operação
      e o que foi consumido no dia. Quem faz isso está de pé no campo; o app é o executor.
- [x] Volta **completa**: era o cadastro mais incompleto da auditoria (responsável e dois
      armazéns contra um contrato de 6 escalares e 5 coleções). Entram `data`, o XOR de
      destino (`area_uuid` **ou** `grazing_uuid`, um select "Local do manejo" que decide qual
      dos dois passa a ser exigido), `operacao`, `atividade`, `lote`, `animal`, `observacao` e
      as 5 coleções de lançamento.
- [x] Primeiro formulário do motor a usar etapas: Identificação → Manejo → Estoque →
      Lançamentos → Revisão.

## Onda 2 — Agricultura

- [x] **Apontamento agrícola**: entra `appropriation_production`, a quinta coleção do
      contrato e a única que faltava — sem ela um apontamento de colheita não registrava
      colheita nenhuma. O armazém volta a ser **do item** em Insumos e Produção (opcional,
      herdando o do cabeçalho). O contrato exige ao menos um lançamento entre as cinco
      coleções; agora a tela também.
- [x] **Apontamento em três etapas** (Identificação, Operação, Lançamentos). Eram 12 campos de
      cabeçalho e 5 coleções em três telas de altura de rolagem, com o CTA longe do primeiro
      campo. Detalhe que só aparece com etapas: as entradas de texto precisaram de
      `initialValue`, senão o valor digitado desaparecia da tela ao voltar uma etapa.
- [x] **Marcação**: a tela era quase inteiramente presumida. Entram os 8 campos reais de
      `/markings` (data, safra, variedade, semana da safra, quantidade, cor no mapa,
      funcionário, centro de custo). Quatro etapas.

## Onda 3 — Pecuária: animais, áreas e manejos

- [x] **registrar-animal** (5→18 campos, 1 coleção, 5 etapas): espécie e data de entrada
      (required) e o bloco inteiro de identificação, genealogia, pelagem e valores.
- [x] **rebanho-inicial** (8→16, 1 coleção, 5 etapas): grava no mesmo `/animals` — não é
      importação de planilha, `/inventoried-animals` não tem `store`.
- [x] **cadastrar-area** (10→16, 1 coleção): `color` required, matrícula, atividade,
      proprietário, área de recreio, ativa e `infrastructure[]`.
- [x] **lote-animais** (4→7, 1 coleção): `date` required, curral, parâmetro de peso e
      `animal_uuids[]` — a coleção que diferencia `/animal-batches` de `/batches`.
- [x] **sanitario** (3 coleções, 4 etapas): a quais animais o manejo se aplica (sem isso não
      há rastreabilidade de carência), os itens de estoque e a mão de obra.
- [x] **desmama**: `date` required e o lote de destino dos bezerros.
- [x] **transferencia-lote-area**: `date` required e o curral, terceiro destino em XOR.
- [x] **transferencia-animal**: `same_batch`, a flag required que decide se todos vão para um
      lote só ou cada um para o seu.

## Onda 4 — Reprodução

- [x] **estacao-monta**: `codigo` e a data do lançamento (distinta do início do período).
- [x] **material-reprodutivo**: os quatro required de `/bull-seed-season` (código, data,
      descrição, estação) e a coleção `products[]`.
- [x] **protocolos-estacao**: `codigo` required, descrição, e `items[]` como coleção
      **obrigatória** — a agenda do protocolo é o protocolo.
- [x] **acasalamento** (6→12, 2 coleções, 5 etapas): `type` e `launch_type`, os dois required
      que definem o modo do registro; e as **vacas** — a tela tinha o touro e não as fêmeas
      cobertas. Resolve o `TODO(banco-real)` sobre `breeding_matings.type`: os valores são os
      métodos reprodutivos, os mesmos de `estacao-monta.metodo`.
- [x] **diagnostico-gestacao** (6→9, 1 coleção obrigatória, 4 etapas): técnica de diagnóstico
      (required), dias de gestação e touro. O contrato é um array de animais, um por linha —
      a coleção é o registro em si.
- [x] **lotes-reproducao** volta como consulta administrativa somente leitura, já com `codigo`
      e `data`, e com amostra semeada (sem ela a lista ficaria vazia para sempre).

## Onda 5 — Nutrição, frota e compras

- [x] **compras-animais** (8→15, 2 coleções): os cinco required financeiros de
      `/movement-purchases`, o valor unitário, o vendedor, os itens e as parcelas. Antes, a
      consulta mostrava um valor total que nada explicava.
- [x] **batidas** (7→10, 1 coleção): a tela misturava DietBeat e FoodBeat. Entram os três
      required do DietBeat (dieta, vagão, data) e a coleção de itens, onde o desvio da batida
      aparece.
- [x] **formulacoes** (11→15): data (required), unidade da matéria-prima, objetivo e
      observação. Custo por kg e estimado seguem como leitura — o servidor os calcula.
- [x] **abastecimentos** (7→10, 1 coleção): a unidade é required e faltava; `/supplies` é
      multi-item. E o "medidor" cobria horímetro e hodômetro no mesmo campo — quem lia o
      número não sabia qual estava informando; o tipo agora é explícito.
- [x] **manutencao-frota** (8→11, 1 coleção, 4 etapas): faltava toda a parte de peça e insumo
      — o real é cabeçalho + itens e o protótipo achatou.

## Onda 6 — Testes congelados

- [x] Contagens do catálogo atualizadas com a aritmética de cada onda no comentário, no padrão
      das levas anteriores.
- [x] Invariantes novas do motor de etapas e das coleções obrigatórias.
- [x] `estacao-monta` deixou de ter `fim` no índice 3 (entraram `codigo` e `data` depois de
      `nome`): a busca no teste virou por `id`, que não se move quando o contrato cresce.
- [x] `pastagens` volta à Onda B dos contratos executáveis; o `ApontamentoFlow` ganhou testes
      de navegação por etapa, da coleção de produção e do bloqueio sem lançamento nenhum.

## Onda 8 — Coleção com item real no motor genérico

Era a primeira pendência que esta esteira registrou, e fecha o padrão ① da
auditoria de verdade: até aqui a coleção existia na tela mas não guardava o que
continha. "Adicionar" incrementava um número — documentava que `items[]`
existe, sem registrar nenhum item.

- [x] **`FeatureCollection`** no catálogo: nome, rótulo do item, os campos **de
      um item**, `isRequired` (o `min:1` do contrato), o campo que titula a
      linha e os que compõem o resumo. `FeatureDefinition.sections` e
      `requiredSections` passam a ser **derivados** de `collections`, então
      etapas, motor e testes congelados continuam lendo o que sempre leram, com
      uma fonte só.
- [x] **`FunctionalFormState.groupItems`**: os itens de cada coleção, cada um um
      mapa `id do campo → valor`. `groupCounts` continua existindo, derivado.
      Entram `itemsOf` e `removeGroupItem`.
- [x] **`AppCollectionList`** no catálogo de UI: compõe `AppAddableGroupList`
      (a faixa é o mesmo pixel) e acrescenta o que faltava — as linhas do que
      foi adicionado, cada uma removível. Era o pedaço que o
      `apontamento_flow` reimplementava por conta em `_ItemRow`.
- [x] **`MappedFeatureScreen`**: cada "Adicionar" abre o formulário do item na
      folha inferior, com os campos do contrato, validação dos obrigatórios do
      item e nenhum botão em beco sem saída. A revisão da última etapa e o
      detalhe do registro passam a citar **o que** foi lançado, não só quantos.
      `_FeatureFieldControl` passou a receber valor, erro e obrigatoriedade
      resolvidos: serve o formulário do cadastro e o do item, que não tem
      jornada por trás.
- [x] **93 campos de item em 24 coleções** — de `equipments[]`/`inputs[]` da
      pastagem a `animals[]` do diagnóstico. Sete domínios de item ficam em
      constante única (unidades, armazéns, centros de custo, responsáveis, modo
      de identificação, categorias animais, equipamentos), mesmo critério de
      `catalogoProdutos`; os literais que já se repetiam nos campos de
      cabeçalho passaram a apontar para elas — 28 ocorrências deixaram de ser
      lista solta.

As duas "seções" de `processamentos` (Pendentes/Concluídos) seguem como
contador de propósito: são rótulos de agrupamento, não coleções de item — e o
motor preserva esse comportamento para coleção sem campos declarados.

Invariantes novas: a coleção com campos declara `itemLabel`, tem
`titleField`/`subtitleFields` existentes, ids de item únicos e **ao menos um
campo obrigatório** (sem isso um item entraria vazio na lista). Em teste de
widget, o caminho inteiro: pastagem → etapa de lançamentos → folha do insumo →
linha com o dado verdadeiro → revisão citando o item → registro salvo.

## Onda 9 — Resíduos da re-auditoria de 11/09

A re-auditoria **"Gaps de campo — Cadastros CERNE"** (11/09/2026, três auditores
paralelos) comparou o catálogo pós-onda 8 outra vez contra o `rules()` atual dos Form
Requests — não contra o autorrelato desta esteira. Resultado: de 22 cadastros com gap em
07/09, 9 ainda tinham resíduo, nenhum mais de severidade alta. Três padrões, de novo:

1. **Campo de item ainda achatado no cabeçalho ou ausente da coleção** —
   `pastagens.inputs.*.stock_uuid`, `pastagens.services.*.measurement_uuid`,
   `sanitario.items.*.stock_uuid`, `compras-animais.items.*.amount`,
   `batidas.items.*.quantity_realized`, `manutencao-frota.items.*.equipment_uuid`.
   Entram como campo do item, na coleção correspondente — o mesmo padrão da onda 8, sem
   mexer no motor. `stock_uuid` (lote de estoque, distinto do produto) vira domínio
   compartilhado `catalogoItensEstoque`, mesmo critério de `catalogoUnidades`/
   `catalogoArmazens`.
2. **Escalar obrigatório residual** — `lotes-reproducao.description` (o único required
   que a onda 4 não fechou), `rebanho-inicial.price_kilo_alive` (já declarado em
   `registrar-animal`, faltava aqui) e `cadastrar-area.coordinates`/`farm_uuid`
   (geometria de mapa e contexto de fazenda — a tela é readOnly, então documentam o
   contrato, mesmo critério da decisão 2 da curadoria original).
3. **Coleção genérica sem os itens do contrato** — único caso, `monta-natural`: a coleção
   "Animais por linha" cobria o lançamento por animal com quatro campos genéricos, mas o
   contrato tem **duas** coleções distintas ali — `simplified_animals[]` (lançamento
   direto: armazém, estoque, unidade, quantidade) e `protocol_animals[]` (lançamento por
   protocolo: hora, elegibilidade). Vira duas `FeatureCollection`, cada uma com os campos
   required do seu array.

Decisões desta onda:

- **`preco-kg` entra opcional em `rebanho-inicial`**, espelhando exatamente o campo já
  existente em `registrar-animal` — mesmo `id`, mesmo rótulo, mesma fonte real
  (`/animals`). Não é um dos três valores recalculados da curadoria original
  (`price_arroba_alive`/`value_unitary`/`unity_animal_ua`), mas os dois cadastros do
  mesmo contrato devem tratar o campo do mesmo jeito.
- **`fazenda`/`coordenadas` em `cadastrar-area` documentam, não editam** — a tela
  continua `readOnly` (cadastro no desktop, onda 1 da esteira de fronteira); a amostra
  semeada ganhou os dois campos, mesmo critério da decisão 2 da curadoria original.
- **Padrão ③ (campos inventados) continua fora de escopo** — nenhuma remoção nesta onda,
  mesma curadoria da leva original.

---

## Cadastro a cadastro

A coluna Situação registra o estado ao fim da leva original (onda 6). Onde a
re-auditoria de 11/09 (onda 9) achou resíduo, a nota `[onda 9]` diz o que fechou depois.

| Cadastro | Sev. | O que faltava | Situação |
|---|---|---|---|
| `apontamento` | alta | as 5 coleções de lançamento | 5ª coleção (Produção) + armazém por item + ≥1 lançamento; 3 etapas |
| `pastagens` | alta | 6 escalares e as 5 coleções | completo; volta ao operacional; 5 etapas. `[onda 9]` + `stock_uuid` do insumo, `measurement_uuid` do serviço |
| `registrar-animal` | alta | espécie, entrada, identificação, genealogia, valores | completo; 5 etapas |
| `cadastrar-area` | alta | cor (req), matrícula, vínculos, infraestrutura | completo (consulta). `[onda 9]` + `farm_uuid`, `coordinates` |
| `compras-animais` | alta | bloco financeiro, itens, parcelas | completo (consulta). `[onda 9]` + `items.*.amount` |
| `batidas` | alta | dieta, vagão, data, itens | completo (consulta). `[onda 9]` + `items.*.quantity_realized` |
| `marcacao` | alta | os 8 campos reais de `/markings` | completo; 4 etapas |
| `manutencao-frota` | alta | peça/insumo por item, medidores, horas | completo; 4 etapas. `[onda 9]` + `items.*.equipment_uuid` |
| `sanitario` | alta | animais alvo, itens de estoque, mão de obra | completo; 4 etapas. `[onda 9]` + `items.*.stock_uuid` |
| `material-reprodutivo` | alta | code, date, descrição, estação, produtos | completo (consulta) |
| `protocolos-estacao` | alta | code e `items[] min:1` | completo (consulta); coleção obrigatória |
| `acasalamento` | alta | type, launch_type, as vacas, linhas por animal | completo; 5 etapas. `[onda 9]` "Animais por linha" genérica virou `simplified_animals[]`/`protocol_animals[]` reais |
| `diagnostico-gestacao` | alta | animal, técnica, dias; array por linha | completo; coleção obrigatória; 4 etapas |
| `rebanho-inicial` | alta | raça, nascimento, identificação, valores, genealogia | completo; 5 etapas. `[onda 9]` + `price_kilo_alive` |
| `lote-animais` | média | data, animais, curral, parâmetro de peso | completo (consulta) |
| `desmama` | média | data, lote de destino | completo |
| `transferencia-lote-area` | média | data, curral | completo |
| `estacao-monta` | média | code, date | completo (consulta) |
| `lotes-reproducao` | média | code, date | de volta ao catálogo como consulta ADM, com os dois. `[onda 9]` + `description`, o required residual |
| `formulacoes` | baixa | data, unidade da matéria-prima | completo (consulta) |
| `abastecimentos` | baixa | unidade, observação, multi-item | completo; sem etapas (10 campos) |
| `transferencia-animal` | baixa | `same_batch` | completo |
| `perdas` | fiel | — | sem mudança |
| `apartacao` | fiel | aceita **mais** do que a API recebe | sem mudança (remoção fora do escopo aditivo) |

## Contagens do catálogo

| | Antes (`360f0f8`) | Onda 6 | Onda 9 (atual) |
|---|---|---|---|
| Funcionalidades | 52 (15 adm · 37 op) | 53 (15 adm · 38 op) | **53** (15 adm · 38 op) |
| Ready | 46 | 47 | **47** |
| Campos | 146 | 242 | **246** |
| Campos obrigatórios | 127 | 169 | **172** |
| Coleções (`sections`) | 5 | 26 | **27** |
| Coleções obrigatórias | 0 | 2 | **2** |
| Formulários em etapas | 0 (no motor genérico) | 8 (+ `ApontamentoFlow`) | **8** (+ `ApontamentoFlow`) |
| Coleções com item real | 0 | 24 de 26 | **25** de 27 |
| Campos de item | 0 | 93 | **103** |

## Pendências conhecidas

- **Padrão ③ (campos inventados) não foi tratado** — decisão 1 da curadoria. Inclui
  `responsavel` em quase todo o catálogo, `marcacao.tipo/descricao/referencia`,
  `area.cultura/unidade/carga-animal` e o excesso de `apartacao`. Onda futura, com refatoração
  de `recordTitleField`/`recordDescriptionFields`, amostras e testes.
- ~~**Coleções no motor genérico continuam contadores.**~~ Fechado na onda 8.
- **O `ApontamentoFlow` continua com item próprio.** Ele já tinha formulário real por item
  antes do motor genérico ter, e a linha de ocorrência carrega uma chip de prioridade que a
  linha genérica não tem. Migrá-lo para `AppCollectionList` é consolidação pendente, não
  lacuna funcional.
- **Os itens não sobrevivem ao registro.** `groupItems` vive no formulário; ao salvar, o
  registro guarda o resumo da coleção em `details` (`'2 item(ns) · Milho moído, Farelo de
  soja'`), não as linhas estruturadas. Guardar item a item exige mudar
  `PrototypeRecord.details`, que é `Map<String, String>` — vale quando houver tela que leia
  isso de volta.
- **`TODO(banco-real)` aberto** em `marcacao.semana-safra`: `week_vintage_uuid` é FK e o dump
  não traz a tabela de domínio; hoje o protótipo pede o número da semana.
- **`flutter analyze`, `flutter test` e `dart format` não foram executados nesta leva** — o
  ambiente em que ela foi produzida não tem o SDK Flutter. As invariantes estruturais do
  catálogo (contagens, unicidade de id, referências de `recordTitleField`/
  `recordDescriptionFields`, cobertura das etapas) foram conferidas por um verificador
  equivalente escrito à parte, mas **a suíte precisa rodar antes do merge**:
  `npm run lint && npm test && npm run quality:functional`. A onda 9 (mesmo ambiente sem
  SDK) repetiu o critério: verificador equivalente reconferiu as mesmas invariantes contra
  as 246 declarações de campo e 27 coleções resultantes — mesma pendência de rodar a suíte
  real antes do merge.
