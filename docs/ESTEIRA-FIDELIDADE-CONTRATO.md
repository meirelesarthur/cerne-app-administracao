# Esteira — Fidelidade de contrato dos formulários (leva "fidelidade-contrato")

> Leia este arquivo antes de mexer em qualquer item desta leva e atualize-o no mesmo commit
> de cada onda concluída — mesmo padrão de continuidade de
> `docs/ESTEIRA-FIDELIDADE-CAMPOS.md` e `docs/ajustes-banco-real/00-ESTEIRA-AJUSTES-BANCO-REAL.md`.

## Origem e objetivo

Esta leva nasce da auditoria **"Fidelidade de contrato dos formulários do protótipo"**
(14/09/2026, 53 agentes paralelos): as 53 funcionalidades do catálogo, uma a uma, contra o
`rules()` real da API (`GB.Cerne.Api/app/Http/Requests`) — não perguntando só *"o campo
aparece?"* (isso a leva `fidelidade-campos` já fechou quase por completo), mas
**"o formulário submeteria e seria aceito?"**: obrigatoriedade, enum/valor, FK (UUID × rótulo),
cardinalidade (array × escalar / campo por item) e condicionalidade (`required_if`/XOR).

O resultado é mais rigoroso que o da leva anterior de propósito: dos 27 formulários com
contrato de entrada auditável, **nenhum é 100% fiel sob este critério** — 16 de alta
divergência, 9 de média, 2 de baixa (quase fiéis). Presença de campo não é fidelidade de
contrato: um campo pode estar na tela, com o rótulo certo, e o `rules()` ainda assim rejeitar
a submissão com **422** — por um `isRequired:false` onde é `required`, por um enum de rótulos
que não bate com o código do contrato, por um texto livre onde o contrato exige UUID de
catálogo, ou por uma coleção achatada num escalar.

As outras 26 funcionalidades do catálogo (53 no total) não têm contrato de escrita para
auditar sob este critério — são consulta, ponteiro para fluxo sem `fields` próprios, simulação
de hardware, ou gap de backend (endpoint que não existe). Ver [Pendências](#pendências-fora-do-escopo-desta-esteira).

## As cinco categorias de divergência (e o padrão ③ que continua fora)

| # | Categoria | O que é | Onde mora a correção |
|---|---|---|---|
| A | **Obrigatoriedade divergente** | Campo presente, `isRequired:false`, contrato exige `required` | `functional_catalog.dart` — só o flag/campo |
| B | **Enum/valor incompatível** | `options` do select não batem com o enum-código real do contrato | `functional_catalog.dart` — a lista de `options` |
| C | **FK como texto livre** | Contrato exige UUID de catálogo (`exists` tenant-scoped); o campo é texto livre | `functional_catalog.dart` — texto vira `select` sobre um domínio |
| D | **Array × escalar / item no cabeçalho** | Contrato pede coleção (`x[]`) ou campo **por item**; a tela usa escalar único ou achata no cabeçalho | `functional_catalog.dart` — campo migra para dentro de uma `FeatureCollection` |
| E | **Condicionalidade não modelada** | O contrato inverte obrigatoriedade por `required_if`/XOR; a tela trata tudo como obrigatório ou opcional fixo | `functional_journey_engine.dart` — `isFeatureFieldRequired`/`featureFieldError`, mesmo padrão do XOR de `pastagens` |
| ③ | **Inventados** (mantidos) | Campo sem correspondente no contrato — o backend ignora | Nenhuma — decisão de curadoria da leva anterior, reafirmada abaixo |

## Curadoria desta leva

Cinco decisões de escopo, tomadas antes da primeira linha de código — a leitura errada de
qualquer uma delas either sobre-engenheira um protótipo frontend-only, either trava um valor
que ninguém confirmou.

1. **A leva continua aditiva e frontend-only.** Nenhum campo inventado (padrão ③) sai — mesma
   decisão 1 da curadoria de `ESTEIRA-FIDELIDADE-CAMPOS.md`, e pelo mesmo motivo:
   `responsavel` e companhia estão espalhados por `recordTitleField`/`recordDescriptionFields`,
   amostras semeadas e testes congelados de quase todo o catálogo. O produto continua
   exclusivamente frontend (`CLAUDE.md`, "Limites do protótipo") — nada aqui liga a uma API
   real, então "a submissão seria aceita" é sempre contrafactual: o ganho é **fidelidade de
   documentação e de forma**, para quando o backend for ligado, não correção de um bug em
   produção.
2. **Categoria B (enum) só fecha com o código real confirmado.** Trocar rótulos por um enum
   errado é pior do que deixar o enum antigo — documentaria uma mentira nova. Fecho direto
   **só** os casos em que o próprio relatório entrega o enum inteiro (contrato tem N valores e
   diz quais são os N); onde o relatório só diz *"não bate"* sem listar o domínio completo
   (ex.: `AreaColor`, 14 hex), a onda correspondente vira `TODO(banco-real)` — mesmo padrão já
   usado em `areas.type`/`diets.type` no catálogo — com nota do que falta confirmar com o time
   web, e removo só o valor que o relatório afirma **não existir** (ex.: `Roxo`).
3. **Categoria C (FK como texto livre) vira `select` sobre um domínio, não um UUID sintético.**
   O protótipo não tem UUID de verdade (sem persistência real) — inventar um esconderia o
   problema em vez de documentá-lo. A correção é de **forma**: o campo deixa de ser texto livre
   e passa a `type: select` com `options` sobre o catálogo real correspondente
   (`catalogoResponsaveis`-style), a mesma fidelidade que `stock_uuid`/`farm_uuid` já
   receberam na onda 9. Onde o catálogo de opções ainda não existe no arquivo (ex.: fornecedor,
   prestador), a onda cria a constante compartilhada, seguindo o critério da onda 8 (domínio
   usado em mais de uma coleção mora num lugar só).
4. **Categoria D usa exatamente o padrão de item real da onda 8/onda 9** — nenhuma novidade de
   motor: o campo por-item que hoje está achatado no cabeçalho migra para dentro da
   `FeatureCollection` correspondente (ou a coleção nasce, se ainda não existir).
5. **Categoria E generaliza o XOR de `pastagens`.** `isFeatureFieldRequired`/
   `featureFieldError` em `functional_journey_engine.dart` já tratam um caso condicional
   (`area` XOR `piquete`); esta leva acrescenta os outros quatro (`acasalamento`,
   `transferencia-lote-area`, `pastagens.executor`, `protocolos-estacao`) como mais `if
   (feature.id == '...')` no mesmo par de funções — não um motor de regras genérico, que seria
   over-engineering para 5 casos conhecidos.
6. **Fluxos dedicados (`apontamento`, `producao-batelada`, `leitura-cocho-confinamento`) ficam
   fora do escopo de `functional_catalog.dart`.** Os três têm tela própria
   (`apontamento_flow.dart`, `batelada_flow.dart`, `leitura_cocho_flow.dart`), não o motor
   genérico — corrigi-los exige editar Dart de fluxo, não declaração de catálogo. Entram como
   ondas próprias, à parte, depois das ondas do motor genérico (ver Onda 8).
7. **`consulta-produtos` fica documentado, não expandido.** É consulta `readOnly` com 4 campos
   mostrados; o contrato de escrita real tem ~40 campos fiscais. Mesmo critério da leva
   anterior (decisão 2): registrar o gap, sem inflar uma tela de consulta com um formulário de
   criação que o protótipo não oferece.

## Pendências fora do escopo desta esteira

- **Gap de backend real** (`leitura-cocho-confinamento`, `trato-diario`, `sincronizacao`): o
  endpoint ou não cobre a funcionalidade (leitura de cocho) ou não existe (distribuição de
  batelada entre currais, sincronização offline). Nada de campo a ajustar — é arquitetura de
  backend, fora do que este repositório resolve (`CLAUDE.md`, "Limites do protótipo").
- **`producao-batelada`**: o fluxo dedicado nunca chama a API (mock local). Adicionar os
  campos que faltam (`date`, `warehouse_uuid`, os 5 required de `feedstocks[]`) documenta o
  contrato mas não muda o comportamento — entra como onda de baixo valor imediato, priorizada
  por último.
- **Referência "Ver 🚜"** nas notas do relatório: não existe em nenhum arquivo deste
  repositório — é uma referência externa ao rastreador da própria auditoria, não a um doc do
  CERNE. Ignorada aqui.

## Status desta execução (ondas 1-9)

| Onda | Categoria | Status |
|---|---|---|
| 1 | A — obrigatoriedade | ✅ fechada |
| 2 / 2b | B — enum/valor | ✅ fechada (2 `TODO(banco-real)` honestos) |
| 3 | C — FK como texto | ✅ fechada |
| 4 | D — array × escalar / item | ✅ quase completa (`material-reprodutivo.animals[]` fica de fora — contrato não especificado) |
| 5 | D — cardinalidade fechada em coleção | ✅ fechada (`transferencia-animal` fica de fora — conflito com simulação de RFID) |
| 6 | E — condicionalidade | ✅ fechada (4 casos, matriz de `monta-natural` simplificada) |
| 7 | Resíduo estrutural de `pastagens` | ✅ quase completa (coleção de imagens geo fica de fora — motor + câmera simulada) |
| 8 | Fluxos dedicados | ⏸️ não iniciada — ver justificativa na própria onda |
| 9 | `consulta-produtos` | ✅ documentação registrada |
| 10 | Revisão manual fechada com dado real (`estacao-monta`/`abastecimentos`/`compras-animais`) | ✅ fechada |
| 11 | Cor: `FeatureFieldType.color` + `AppColorInput` | ✅ fechada |
| 12 | `material-reprodutivo.animals[]` | ✅ fechada |
| 13 | `transferencia-animal`: captura RFID empilhada em coleção | ✅ fechada |
| 14 | Fluxos dedicados (`apontamento`/`batelada`/`leitura-cocho`) | ✅ fechada (inequívoco); matriz de qualidade e máquina de estados de mão de obra ficam de fora por decisão |
| 15 | `consulta-produtos`: expansão fiscal completa (~40 campos) + `FeatureFieldType.boolean` | ✅ fechada |
| 16 | `formulacoes.tipo` (P/U) — rótulo confirmado pelo usuário | ✅ fechada |

Catálogo ao fim da onda 7: **248 campos de cabeçalho** (187 obrigatórios), **31 coleções** (29
com item real), **118 campos de item**, **5 coleções obrigatórias** — 53 funcionalidades sem
mudança de contagem.

Catálogo ao fim da onda 10: **246 campos de cabeçalho** (184 obrigatórios), **31 coleções** (29
com item real), **117 campos de item**. Delta desde a onda 7: `compras-animais` perde
`categoria`/`quantidade`/`valor-unitario` do cabeçalho (-3/-3, ficam só em "Itens da compra"),
`estacao-monta` ganha `descricao` obrigatório (+1/+1), `abastecimentos` troca
`tipo-medidor`+`medidor` por `horimetro`+`hodometro` opcionais no cabeçalho (+0/-1) e perde o
`medidor` duplicado da coleção "Itens do abastecimento" (-1 campo de item).

**Verificação real, não só estrutural**: o SDK Flutter (3.44.6, a versão do `CLAUDE.md`) foi
baixado nesta sessão e `npm run lint`/`npm run test`/`npm run quality:functional` rodaram de
verdade. Isso pegou 3 bugs que a checagem estrutural (sem compilar) não via — dois testes que
não preenchiam campo novo, um teste que checava obrigatoriedade por posição em vez de por id —
todos corrigidos. A primeira rodada completa (544 testes) tinha **10 falhas, nenhuma desta
leva**: 6 golden tests (diferença de renderização de fonte neste ambiente) e 4 já quebradas em
`main` sem nenhuma mudança desta esteira (`Bluetooth exige descoberta`, `scanner SISBOV`,
`TratoDiarioFlow`, `LoginPage login sinalizado como operacional`) — confirmado revertendo para
`main` e rodando os mesmos testes lá.

Das quatro falhas de `main`, duas eram simulação de hardware (Bluetooth, scanner SISBOV) — e a
causa raiz acabou sendo um bug real em `mapped_feature_screen.dart`, não uma questão de
simulação: nenhuma funcionalidade sem `listMode` (hardware simulado incluído) conseguia
mostrar a barra de ação com o CTA, porque a tela só entrava em "modo formulário" pela via de
uma listagem que essas telas não têm. Corrigido (`showingForm` no lugar de `isForm` nos quatro
pontos que precisavam concordar com o que já era renderizado). Segunda rodada completa: **546
testes, 8 falhas** — as 6 golden mais `TratoDiarioFlow`/`LoginPage`, que continuam de `main`,
sem relação com hardware simulado ou com esta esteira. `functional_catalog_test.dart` e
`functional_journey_engine_test.dart`: **verdes**.

---

## Onda 1 — Categoria A: obrigatoriedade divergente (fechamento direto)

Sem ambiguidade de valor — é inverter `isRequired` ou declarar o campo que falta. Fecha nos
quatro cadastros que o relatório aponta, mais três achados durante a execução (registrado
abaixo do checklist original).

- [x] `marcacao` — 5 required voltam a `isRequired: true`: `safra`, `variedade`,
      `semana-safra`, `quantidade`, `cor`.
- [x] `rebanho-inicial` — required voltam a `isRequired: true`: `data-entrada` (mapeia
      `entry_date` — é o campo de `banco-real` já reconhecido como o candidato certo, distinto
      de `data`, a data de referência do levantamento), `raca` (`breed_id`), `peso-medio`
      (`weight`), `preco-kg` (`price_kilo_alive`). **Não** reverte a decisão da curadoria
      original: `preco-arroba`/`valor-unitario`/`ua` (os três valores recalculados pelo
      servidor) continuam opcionais de propósito.
- [x] `registrar-animal` — `preco-kg` (`price_kilo_alive`) volta a `isRequired: true`, mesma
      correção espelhada de `rebanho-inicial` — achado extra durante a execução, o relatório o
      lista como issue própria (severidade baixa) deste cadastro.
- [ ] `apontamento` — 11 inversões de obrigatoriedade no `ApontamentoFlow` (não no motor
      genérico — ver Onda 8): `operation`, `used_area` e o armazém por item, entre outros.
      Levantamento campo a campo fica para o início da Onda 8.
- [x] `cadastrar-area` — 4 required voltam a `isRequired: true`: `area-produtiva`
      (`productive_area`), `area-nao-produtiva` (`unproductive_area`), `area-recreio`
      (`recreation_area`), `ativo` (`is_enabled`).
- [x] `sanitario` — `controle-por-tempo` (`time_control`) volta a `isRequired: true`.
- [x] `monta-natural` (acasalamento) — `bull_seed_season_uuid` estava ausente por completo;
      entra como campo novo `bull-seed-season` (select sobre os códigos `BSS-*` do próprio
      catálogo de `material-reprodutivo`), distinto do texto livre `material-reprodutivo`
      (que documenta o insumo, não o vínculo à estação).
- [x] `material-reprodutivo` — `products.*.armazem` tinha o sentido invertido: a leva anterior
      o travou `isRequired: true`, mas o contrato real o marca opcional. Reverte para opcional
      (é a única correção desta onda que **remove** um `isRequired`, não adiciona).

## Onda 2 — Categoria B: enum/valor incompatível (onde o relatório dá o domínio inteiro)

- [x] `acasalamento` (`monta-natural`) — campo `tipo`: novo domínio
      `['Monta natural', 'IATF', 'FIV']` — `Inseminação artificial`/`Transferência de embrião`
      não existiam no enum real; `estacao-monta.metodo` **não** foi tocado (a auditoria não o
      aponta como divergente).
- [x] `desmama` — campo `tipo`: novo domínio `['Recria', 'Venda']` (`WeaningTypeEnum`).
- [x] `cadastrar-area` — campo `tipo`: novo domínio `['Produtiva', 'Reserva']` (`AreaType`) — a
      classificação setorial (agricultura/pecuária/…) já mora em "Atividade", campo distinto.
      Amostras semeadas (`area-1`/`area-2`) atualizadas.
- [x] `sanitario` — `labor.func_type`: novo domínio `['Empregado', 'Função', 'Prestador']`.
      **TODO(banco-real) permanece**: rótulos em português não confirmados pelo time web —
      anotado no ponto.

### Onda 2b — Categoria B com domínio incompleto (`TODO(banco-real)`, não fecha nesta leva)

- [x] `cadastrar-area` — campo `cor`: removido `Roxo` (confirmado inexistente); os 5 restantes
      ficam com `TODO(banco-real)` pedindo a lista completa de 14 cores/hex ao time web.
- [x] `formulacoes` — campo `tipo`: valores **não alterados** (`Estoque`/`Formulação`) —
      `TODO(banco-real)` anotado no ponto pedindo o rótulo real de `P`/`U` antes de trocar.

## Onda 3 — Categoria C: FK como texto livre → `select` sobre domínio

- [x] `lote-animais` — item da coleção "Animais do lote": ganha `tipo-identificacao` (select
      sobre `catalogoIdentificacaoAnimal`) ao lado da `identificacao` (número/brinco em texto)
      — mesmo padrão de `identifications[]` de `registrar-animal` (modo + número, não um UUID
      sintético de uma lista fechada de animais, que misrepresentaria a realidade pior do que
      o texto livre).
- [x] `transferencia-animal` — **não** convertido: `identificacao` é o campo-alvo da simulação
      de RFID (`simulationTargetField`) — virar `select` quebraria a captura por hardware
      simulado. `lote-atual`/`novo-lote` migraram para `select` sobre `catalogoLotes` (ver
      abaixo); a cardinalidade de `identificacao` (escalar → `animal_uuids[]`) fica para a
      Onda 5.
- [x] `desmama` — campo `lote` e `lote-destino`: `select` sobre o novo domínio compartilhado
      `catalogoLotes` (nasce aqui, critério da onda 8: reusado por `desmama`, `apartacao` e
      `transferencia-animal`).
- [x] `apartacao` — campos `lote-origem` e `lote-destino`: mesma migração para `catalogoLotes`.
- [x] `compras-animais` — campos `fornecedor`/`vendedor`: migram de texto livre para `select`
      sobre novo domínio `catalogoFornecedores` (sintético, mesmo critério de dado de exemplo
      da leva anterior — nunca copiado de produção; inclui `Fazenda Boa Vista`, já usado na
      amostra semeada como `fornecedor`).

## Onda 4 — Categoria D: array × escalar / campo por item

- [x] `manutencao-frota` — nova coleção "Mão de obra" (`tipo` Empregado/Prestador, `executor`,
      `quantidade` em horas, `total`) — o form só tinha `horas-mao-de-obra` no cabeçalho, um
      total sem executor. `hour_meter`/`mileage` (`horimetro`/`hodometro`) migraram para
      dentro de "Peças / Insumos" (`equipment_uuid` por item já tinha entrado na onda 9).
- [x] `batidas` — `items.*.measurement_uuid` (`unidade`) entrou na coleção "Itens da batida";
      os 3 required por item (`materia-seca`, `custo`, `porcentagem`) voltam a
      `isRequired: true`.
- [x] `diagnostico-gestacao` — `provider_uuid` (`veterinario`) required por item entrou na
      coleção "Animais diagnosticados". **Não fechado por completo**: os campos planos do
      topo (`veterinario`/`lote`/`quantidade`) continuam — removê-los exigiria redesenhar
      `recordTitleField` (hoje `lote`, um campo de cabeçalho) e as etapas, fora do escopo desta
      onda. Nuance registrada, não é pattern ③ (não são inventados, duplicam algo real).
- [x] `lotes-reproducao` — nova coleção obrigatória "Lotes vinculados" (`batch_uuids[]`,
      min:1, select sobre `catalogoLotes`). O escalar `lote` **permanece** pelo mesmo motivo de
      `diagnostico-gestacao`: é o `recordTitleField` desta consulta. Amostras semeadas
      atualizadas.
- [ ] `material-reprodutivo` — coleção `animals[]` do contrato continua **ausente**: o
      relatório não lista os campos reais de `animals.*` em `/bull-seed-season`, e inventá-los
      seria advinhar contrato, não documentá-lo. Fica para quando alguém puxar o Form Request
      real.
- [x] `protocolos-estacao` — `items.*.service` (`servico`, texto — `TODO(banco-real)`: enum
      real não confirmado) e `items.*.measurement_uuid` (`unidade`) entraram na coleção "Etapas
      do protocolo"; `items.*.quantity` volta a `isRequired: true`.

## Onda 5 — Categoria D (continuação): cardinalidade de identificação/lote em array

Decisão de arquitetura tomada nesta onda: **nenhum componente novo**. Um `category_uuids[]`/
`batches[]` (array de valores de um domínio fechado, min:1) é modelado como uma
`FeatureCollection` de um campo só — o mesmo motor de coleção da onda 8, reaproveitado. Não é
um multi-select disfarçado; é literalmente a mesma forma de dado (`array<FK>`) que o resto do
catálogo já representa como coleção.

- [x] `lote-animais` — nova coleção obrigatória "Categorias do lote" (`category_uuids[]`,
      min:1). O escalar `categoria` permanece (usado em `recordDescriptionFields`), mesma
      nuance de duplicação da Onda 4.
- [x] `apartacao` — nova coleção obrigatória "Lotes de origem" (`batches[]`, min:1). O escalar
      `lote-origem` permanece (é o `recordTitleField`); os outros 4 campos
      (`criterio`/`lote-destino`/`quantidade`/`responsavel`) continuam como inventados mantidos
      (padrão ③, decisão 1).
- [ ] `transferencia-animal` — **não fechado, de propósito**. `identificacao` é o campo-alvo
      da simulação de RFID (`simulationTargetField`): a captura por hardware simulado hoje é
      "escaneie um, preencha um campo", não "escaneie vários, monte uma lista". Converter para
      `animal_uuids[]` de verdade (mesmo truque de coleção acima) exigiria também redesenhar a
      simulação de captura para adicionar itens a uma coleção a cada "leitura" — trabalho de
      fluxo de UI, não só de catálogo, mesmo tipo de esforço da Onda 8. O par correlacionado
      `batch_uuids[]` por índice (quando `same_batch = Não`) tem o mesmo problema e fica junto.
      Registrado como pendência (ver seção de Pendências).

## Onda 6 — Categoria E: condicionalidade não modelada

Estende `isFeatureFieldRequired`/`featureFieldError` em `functional_journey_engine.dart` para os
casos de cabeçalho, mesmo padrão do XOR de `pastagens.destino`. Para os dois casos de **item de
coleção** (produto⊕serviço, executor), nasceram duas funções irmãs — `isCollectionItemFieldRequired`/
`collectionItemFieldError` — porque `featureItemFieldError` não recebe `feature`/`collection` no
contexto; `mapped_feature_screen.dart` passou a usá-las nas duas coleções afetadas.

- [x] `acasalamento` (`monta-natural`) — modelagem mínima: `protocolo` vira obrigatório quando
      `tipo = IATF`; `material-reprodutivo` vira obrigatório quando `tipo-lancamento = Por
      lote`. Não cobre a matriz inteira do relatório (ex.: `estacao-monta` continua sempre
      opcional) — os dois casos mais claros primeiro, resto fica de nota.
- [x] `transferencia-lote-area` — novo campo `destino` (select Área/Módulo/Curral) resolve o
      XOR; `area`/`modulo` deixam de ser `required` fixos.
- [x] `pastagens` — coleção "Serviços" recomposta na Onda 7 (`tipo-executor` + `executor`);
      XOR aqui: `executor` é obrigatório só quando `tipo-executor` é "Empregado" ou
      "Prestador" — "Função" já é a resposta em si.
- [x] `protocolos-estacao` — XOR `produto` ⊕ `servico` por item de "Etapas do protocolo",
      conforme `tipo` do item (`Produto`/`Serviço`).

Testes novos em `functional_journey_engine_test.dart` cobrem o XOR de `transferencia-lote-area`
e o XOR de item de `protocolos-estacao` — os dois com lógica nova, verificados linha a linha
contra a implementação já que a suíte real não roda neste ambiente.

## Onda 7 — Resíduo de coleção mal modelada em `pastagens`

Fora das cinco categorias por ser mais estrutural — a coleção "Serviços" de `/pastures` estava
**quase incompatível** com o contrato real, não só faltando um campo:

- [x] Recomposta a coleção "Serviços": `prestador` (texto livre) virou `tipo-executor` +
      `executor` (Onda 6 cuida do XOR de obrigatoriedade); `servico`/`valor` já cobriam
      nome/valor. Ver commit da Onda 6 — as duas mudanças saíram juntas por dependência direta
      (o XOR de obrigatoriedade não existe sem os campos).
- [x] Inversão `required`↔`nullable` corrigida: `produto` (`product_uuid`) volta a opcional em
      `pastagens."Insumos"` — é `estoque` (`stock_uuid`) o obrigatório, a onda 9 tinha travado
      o sentido errado.
- [ ] Nova coleção de **imagens geo** para `occurrences[]` — `lat`/`long`/`foto`, máximo 3 —
      **não entra nesta leva**. Não existe tipo de campo de imagem no catálogo
      (`FeatureFieldType` só tem `text`/`number`/`date`/`select`/`textarea`); um campo de
      captura de foto se aproxima de "hardware simulado" (câmera), que o próprio `CLAUDE.md`
      lista como limite do protótipo ("Limites do protótipo": não apresentar câmera como
      integração nativa concluída). Decisão de arquitetura — motor + eventual simulação de
      câmera — que pede revisão própria antes de codar, não uma correção de catálogo.

## Onda 8 — Fluxos dedicados (fora do motor genérico)

Cada um é um arquivo Dart próprio, não uma entrada de `functional_catalog.dart` — maior custo
de engenharia por item, e testado por conta.

**Decisão desta execução: nenhum dos três foi editado.** A justificativa original (sem SDK
Flutter neste ambiente para compilar depois de editar) deixou de valer — o SDK 3.44.6 foi
baixado durante esta mesma sessão e `flutter test` roda de verdade agora (ver "Verificação
real" no topo deste arquivo). O que continua de pé, e por isso a decisão não muda: boa parte do
que falta em `apontamento_flow.dart`/`batelada_flow.dart` é **semântica de negócio que a
auditoria não detalha** (os valores reais de `percentage`/`difference`/`amount`/`total` de
`feedstocks[]`, as 13 colunas da matriz de
qualidade) — inventar a forma exata seria o mesmo erro que a curadoria já vetou para enums sem
domínio completo (Onda 2b), agora em código de tela em vez de `options`.

- [x] `apontamento_flow.dart` — ~~as 11 inversões de obrigatoriedade da Onda 1~~ (já corrigidas
      numa leva anterior a esta sessão — conferido contra o código, os cinco campos citados no
      texto original já estavam `required`) ~~e o bloco de mão de obra~~ (mantido como está, por
      decisão — ver Onda 14). Armazém por item corrigido na Onda 14 (era o sentido invertido do
      gap). Matriz de qualidade segue de fora, por decisão.
- [x] `batelada_flow.dart` (`producao-batelada`) — `warehouse_uuid` de cabeçalho e `percentage`
      por ingrediente fechados na Onda 14. `date` continua de fora (decisão de UX válida — ver
      Onda 14). `quantity`/`difference`/`amount`/`total` continuam sem campo (não confirmados).
- [x] `leitura_cocho_flow.dart` — bloco `diet_id`/`feed_intake` fechado na Onda 14. Núcleo
      (escore/sobras/aspecto/comportamento/ocorrências) continua fora — gap de backend, não de
      campo.

## Onda 9 — `consulta-produtos` (documentação, sem expandir a tela)

**Correção de premissa**: o relatório descreve `consulta-produtos` como consulta `readOnly`,
mas o catálogo já a declara como criação de verdade desde a onda 2 do banco-real
(`createAction: 'Novo produto'`, sem `readOnly`). O tratamento de "documentar, não expandir"
desta onda vale mesmo assim — a tela é editável, mas o contrato real (~40 campos fiscais) é
grande demais para entrar de uma vez sem decisão de produto.

- [x] Registrado no catálogo, em comentário, os ~40 campos fiscais do contrato de escrita real
      e os 6 required ausentes (`group_uuid`, `has_lot`, `is_equipment`, `is_enabled`,
      `control_stock`, `las_price`) — três deles booleanos, que `FeatureFieldType` não modela
      hoje (mesma lacuna de motor da coleção de imagens da Onda 7). Sem criar os campos nesta
      onda: 4 campos → ~44 é decisão de escopo de produto, não uma correção pontual de
      fidelidade.
- [x] Campos `categoria`/`unidade`: mesma nota de categoria C (FK como rótulo onde o contrato
      quer `category_uuid`/`measurement_uuid`) registrada no ponto — correção real fica para
      quando/se a expansão de campos acontecer.

## Onda 10 — Revisão manual fechada com dado real (`functional_catalog.dart`)

As três divergências marcadas "revisão manual" nas ondas 1-9 (sem Form Request real disponível)
foram fechadas com base num dump real do Postgres de produção (schema `gbcerne`), streamado sem
extrair os 2GB pro disco. `NOT NULL` no dump é o piso de evidência mais forte disponível — não é
100% equivalente ao `rules()` real do Laravel, mas substitui a suposição por dado.

- [x] `estacao-monta`: `breeding_seasons.description` é `varchar(191) NOT NULL` no dump — campo
      real e obrigatório, distinto de `observacao` (textarea opcional, que já existia). Adicionado
      `FeatureField(id: 'descricao', ...)`.
- [x] `abastecimentos`: `appropriation_supply` no dump é um evento só, com `hour_meter`
      (horímetro) e `mileage` (hodômetro) como dois campos numéricos independentes no mesmo
      nível — não um par `tipo-medidor`+`medidor` genérico, nem um `medidor` por item de coleção.
      Colapsados os dois campos de cabeçalho (`tipo-medidor`/`medidor`) em `horimetro`/
      `hodometro` (escalares, opcionais — o dump não confirma qual dos dois é sempre exigido).
      `medidor` também removido da coleção "Itens do abastecimento" (era o mesmo dado duplicado);
      os demais campos da coleção (`veiculo`, `combustivel`, `quantidade`, `unidade`,
      `observacao`) continuam — mapeiam a campos reais de item (equipamento/produto/quantidade
      por abastecimento múltiplo), não são artefato do `medidor`.
- [x] `compras-animais`: `movement_purchases` (cabeçalho real) só tem campos de nota fiscal/
      pagamento — nenhum `category`/`quantity`/`value_unit`. Esses três vivem só em
      `item_movement_purchases` (coleção "Itens da compra", que já os tinha). Removidos
      `categoria`, `quantidade` e `valor-unitario` do cabeçalho; `recordDescriptionFields` trocado
      para `especie`/`forma-pagamento`/`data` (nenhum dos três campos removidos era o
      `recordTitleField`, que é `fornecedor`).

## Onda 11 — Cor: campo hex real, não select de rótulo

`gbcerne.areas.color` no dump de produção (`varchar(7)`, `DEFAULT '#f6c23e'`) devolveu mais de
150 valores hex distintos em uso real — não é um enum fechado, é um seletor de cor livre. Isso
supera de vez o `TODO(banco-real)` de "paleta incompleta" da fidelidade-contrato (onda 2b).

- [x] Novo `FeatureFieldType.color` no motor (`functional_catalog.dart`).
- [x] Novo componente `AppColorInput` em `apps/mobile/lib/ui/color_input.dart` — swatch circular
      (preview ao vivo do hex, toque abre uma grade de atalho com a paleta 500 do design system)
      + campo de texto com prefixo `#` e máscara hexadecimal, mesma `AppFieldCapsule` dos demais
      campos. Registrado no barrel `ui.dart` e com caso próprio no Widgetbook
      (`buildColorInputWidgetbookComponent`, pasta Catálogo/Formulário) — Lei 1 do `CLAUDE.md`.
- [x] `cadastrar-area.cor` e `marcacao.cor` trocam `select` com lista de rótulo por
      `FeatureFieldType.color`, eliminando a inconsistência entre as duas telas ('Roxo' existia
      só numa). `#f6c23e` documentado como o `DEFAULT` do banco (comentário — o motor genérico não
      semeia valor inicial em nenhum tipo de campo).
- [x] `case FeatureFieldType.color` novo em `mapped_feature_screen.dart` (`_FeatureFieldControl`).
- [x] Amostras semeadas (`area-1`/`area-2`) atualizadas para hex (`#22C55E`/`#F59E0B`).
- [x] Verificado visualmente em build release + servidor estático: hex digitado formata em
      maiúsculas, o swatch reflete a cor ao vivo, e a grade de atalho (toque no swatch) aplica o
      preset e fecha a folha.
- [x] `npm run tokens:verify` rodado (Onda 11 toca a família de campos do design system) — sem
      diff: nenhum token novo foi necessário, `AppColorInput` reaproveita `AppColors`/`AppRadius`/
      `AppSpacing`/`AppTypography` gerados.

## Onda 12 — `material-reprodutivo.animals[]` (antes bloqueado, agora resolvido)

`animal_bull_seed_season` no dump é uma tabela pivô pura (`animal_id`, `bull_seed_season_id`,
timestamps) — confirma que o contrato real é só um array de referências a animal, sem campo
extra por item.

- [x] Nova `FeatureCollection` "Animais" em `material-reprodutivo`, `isRequired: true` (o vínculo
      não existe sem pelo menos um animal).
- [x] **Ambiguidade resolvida**: o plano original previa "campo único `animal_uuids` (select
      sobre o catálogo de animais existente)", mesmo padrão de coleção de um campo só da Onda 5
      (`category_uuids[]`/`batches[]`). Esse padrão funciona quando o domínio é uma lista fechada
      e pequena (categorias, lotes) — mas não existe, neste protótipo, nenhum catálogo de animais
      individuais como lista fechada (são muitos e cada um é único), então um `select` de campo
      único inventaria uma lista falsa. Em vez disso a coleção reusa o padrão real já em uso em
      todo o catálogo para referenciar **um animal específico sem UUID sintético**
      (`tipo-identificacao` + `identificacao`, o mesmo par de `lote-animais`."Animais do lote" e
      `registrar-animal`."Identificações", fidelidade-contrato Onda 3) — dois campos, não um, mas
      é o padrão consistente já estabelecido no resto do catálogo para este exato problema.

## Onda 13 — `transferencia-animal`: identificação em array + destino por índice

`animal_transfer_animal_farm` no dump também é pivô puro (`animal_id`, `transfer_animal_farm_id`)
— confirma que o contrato real aceita destino por animal, não um destino único para o lote
inteiro. Maior risco de UI desta esteira: mexe na simulação de captura por RFID.

- [x] Campo escalar `identificacao` (alvo antigo da simulação de RFID) sai do cabeçalho; nova
      `FeatureCollection` "Animais transferidos" (`isRequired: true`) o substitui, com
      `identificacao` e `novo-lote` por item.
- [x] Novo campo `FeatureDefinition.simulationCollectionName`: quando preenchido, a captura de
      hardware deixa de sobrescrever um campo escalar (`onValueChanged`) e passa a empilhar um
      item na coleção (`addGroupItem`) a cada leitura — cada toque em "Simular leitura RFID"
      agora é um animal novo na lista, não a substituição do único valor capturado.
      `featureSimulationError` passa a checar a contagem da coleção (`>= 1`) em vez do valor de um
      campo. A simulação de hardware em si (`AppHardwareSimulator`) não muda de arquivo — só o
      destino do valor capturado, como o plano pedia.
- [x] Novo `multiCapture` em `AppHardwareSimulator` (`apps/mobile/lib/ui/hardware_simulator.dart`):
      a entrada manual deixa de disparar `onCapture` a cada tecla (que empilharia um item por
      caractere) — um botão "Adicionar leitura manual" ao lado do campo confirma a leitura
      inteira, mesmo padrão de "captura, empilha, pronta para a próxima" do botão principal (que
      em `multiCapture` nunca entra no estado "pronto" preso na tela — cada toque já sai direto
      para a lista). Caso novo no Widgetbook (`rfid-multi-capture`) documentando o comportamento.
- [x] `novo-lote` de cabeçalho (usado quando `destino-unico` = "Sim", um lote para todos) e
      `novo-lote` por item (usado quando "Não", um lote por animal) formam um XOR — mesmo padrão
      de `isFeatureFieldRequired`/`isCollectionItemFieldRequired` da Onda 6, com um parâmetro novo
      (`formValues`) em `isCollectionItemFieldRequired`/`collectionItemFieldError`/
      `isCollectionItemValidFor` para o item de coleção conseguir ler um campo do **cabeçalho**
      (`destino-unico`), não só de outro campo do próprio item (os dois casos anteriores desta
      família eram sempre XOR interno ao item).
- [x] Verificação: suíte completa (555 testes) inclui o fluxo de ponta a ponta —
      `mapped_feature_wave_c_test.dart` ("RFID oferece alternativa manual no próprio fluxo" e "os
      seis contratos bloqueiam sem hardware e concluem com simulação") tapa em "Nova transferência
      de animal", confirma o simulador, valida a mensagem de coleção vazia, digita uma
      identificação manual, confirma pelo botão, e submete — sem exceções
      (`tester.takeException()` nulo). A verificação visual manual em navegador (build release +
      servidor estático) ficou bloqueada por uma limitação do ambiente de preview: a navegação por
      `context.push()` (usada pela busca global) trava com tela em branco (0 `<canvas>` no DOM,
      nenhum erro JS) — reproduzido de forma idêntica navegando para `registrar-animal` (feature
      não tocada nesta onda) pelo mesmo caminho, confirmando que não é uma regressão desta
      mudança. A navegação por toque direto no grid de módulo (`context.go`) funciona normalmente
      neste mesmo ambiente.

## Onda 14 — Fluxos dedicados (fecha a Onda 8 do arquivo original)

Grounded em `appropriations` + `appropriation_employee/equipment/stock/production/occurrences` e
`food_feedstocks`/`appropriation_supply` do dump. Só o inequívoco — nada de fórmula de negócio
não confirmada (matriz de qualidade, máquina de estados de mão de obra).

- [x] `apontamento_flow.dart`: as inversões de obrigatoriedade citadas na Onda 1 original
      (`area_id`/`operation_id`/`activity_id`/`used_area`) já estavam `required: true` no
      código — conferidas, nenhuma mudança necessária ali. O gap real, na direção oposta à
      descrita originalmente: `appropriation_stock`/`appropriation_production` **não têm**
      `warehouse_uuid` próprio no dump — o formulário pedia um campo "Armazém de origem"/
      "Armazém de destino" por item de Insumo/Produção que não existe no contrato; removido.
      Os dois grupos passam a herdar sempre o armazém de insumo/produção do cabeçalho, como o
      dado real exige. Mão de obra e matriz de qualidade da produção não mudam, por decisão do
      Contexto (fórmula de negócio/rótulo não confirmados).
- [x] `batelada_flow.dart`: `warehouse_uuid` (novo campo "Armazém de retirada" no cabeçalho,
      `required`) e `percentage` por ingrediente (exibido junto do previsto, derivado da
      proporção já cadastrada na dieta — `food_feedstocks.percentage` não pede dado novo da
      pessoa). `date` continua fora (decisão de UX válida — nenhum fluxo dedicado do módulo tem
      campo de data hoje). `quantity`/`difference`/`amount`/`total` continuam sem campo —
      `food_feedstocks` só confirma `percentage` como campo de negócio real no dump.
- [x] `leitura_cocho_flow.dart`: bloco `diet_id`/`feed_intake` fechado — novos campos "Dieta"
      (`required`, select sobre o catálogo real de dietas do confinamento) e "Consumo (kg)"
      (`required`) por curral avaliado. `AvaliacaoCurral` ganha `dietaId`/`consumoKg` opcionais
      no model (para não quebrar as amostras de `mocks.dart`); a tela de captura exige os dois
      via validação própria. Núcleo (escore/sobras/aspecto/comportamento/ocorrências) continua
      fora — gap de backend, não de campo.
- [x] Verificação: `npm run lint` limpo e suíte completa (555 testes) sem regressão, incluindo
      os testes de ponta a ponta dos três fluxos (`apontamento_flow_test.dart`,
      `batelada_flow_test.dart`, `leitura_cocho_flow_test.dart`) — dois casos que verificavam a
      presença do campo de armazém por item foram invertidos para `findsNothing`, refletindo a
      correção do gap.

## Onda 15 — `consulta-produtos`: expansão completa (~40 campos fiscais)

Fecha o que a Onda 9 só documentou. `gbcerne.products` no dump tem 72 colunas; 35 campos novos
(6 `required`, confirmados na Onda 9) organizados em 4 etapas + revisão (arquétipo `Cadastro
steps`), mesmo padrão dos fluxos dedicados — 39 campos numa rolagem só esconderia o fim do
formulário.

- [x] Novo `FeatureFieldType.boolean` no motor (`functional_catalog.dart`) + `case` em
      `mapped_feature_screen.dart` (`_FeatureFieldControl`), usando o componente já existente
      `AppToggleSwitch` — nenhum componente novo de `ui/` foi necessário, a lacuna era só de
      motor. Usado por `has-lot`/`is-equipment`/`is-enabled`/`control-stock` (os 4 dos 6
      required que são booleanos — `control_stock` é `smallint`, mesma família) e
      `allow-pointing` (opcional).
- [x] Os outros 2 required não booleanos: `group-uuid` (select sobre `catalogoGruposProdutos`,
      nova FK distinta de `categoria` — classificação contábil/fiscal, não operacional) e
      `las-price` (número).
- [x] Restante dos ~40 campos fiscais, agrupados em blocos: "Dados básicos" (nome, grupo,
      categoria, unidade, código de barras, referência, princípio ativo), "Estoque e controle"
      (os 5 booleanos, armazém/centro de custo padrão, estoque mínimo, custo médio, preços),
      "Tributação" (NCM, categoria financeira, CFOP, CST/CSOSN, percentuais de ICMS/PIS/COFINS/
      IPI, origem, CEST) e "Reforma tributária" (IBS/CBS/Imposto Seletivo, curadoria mínima —
      campos recentes e numerosos no dump). Novos domínios curados (`catalogoGruposProdutos`,
      `catalogoNcm`, `catalogoCategoriasFinanceiras`, `catalogoCstCsosn`,
      `catalogoCstPisCofins`, `catalogoCstIpi`, `catalogoCfop`, `catalogoOrigemMercadoria`,
      `catalogoCstIbsCbs`) — mesmo critério de curadoria representativa das listas já existentes
      (`catalogoProdutos`, `catalogoFornecedores`...), não o domínio federal/tributário inteiro.
- [x] `categoria`/`unidade` já eram `select` sobre um domínio (fechado antes desta onda) —
      nenhuma mudança de tipo necessária, só a nova FK `group-uuid` ao lado.
- [x] Verificado visualmente em build release + servidor estático: a etapa "Dados básicos"
      mostra os 7 campos e o `select` "Grupo do produto" com o domínio novo; avançando para
      "Estoque e controle", os 4 switches booleanos aparecem desligados por padrão e alternam
      corretamente ao toque (`AppToggleSwitch` já existente, sem regressão visual).

## Onda 16 — Pendências que continuavam `TODO(banco-real)`

- [x] `formulacoes.tipo` (P/U) — **fechado nesta sessão**: o usuário confirmou o rótulo em
      português (`P` = "Porcentagem", `U` = "Unidade") depois que o plano original foi escrito
      (que mantinha `TODO(banco-real)` por falta dessa confirmação). `options` do campo `tipo`
      em `formulacoes` trocado de `['Estoque', 'Formulação']` (conflate de `diets.type`/
      `diets.objective`, nunca foi o campo `FoodTypeEnum` de verdade) para `['Porcentagem',
      'Unidade']`; amostras seedadas (`formulacao-1`/`formulacao-2`) atualizadas. O `tipo` de
      `batidas` (mesma anotação "mesmo campo tipo de formulacoes" no código, mas outra coluna —
      `item_diet_beats.type`) não foi tocado: a confirmação do usuário nomeou especificamente
      `formulacoes.tipo`, e o comentário original já registrava os dois como conflates
      distintos, não o mesmo enum replicado.
- [x] Qualquer campo que dependa do Form Request PHP real (não presente no dump) para saber a
      obrigatoriedade exata continua marcado como inferido de `NOT NULL`, não confirmado 1:1 —
      nenhuma mudança nesta esteira.

---

## Cadastro a cadastro (referência completa da auditoria de 14/09)

Tabela de trabalho — cada linha é uma issue do relatório, com a onda que a fecha.

| Cadastro | Sev. | Issue | Onda |
|---|---|---|---|
| `leitura-cocho-confinamento` | alta | núcleo sem backend | fora de escopo |
| `leitura-cocho-confinamento` | alta | `diet_id`/`feed_intake` ausentes | 8 |
| `producao-batelada` | alta | `date`/`warehouse_uuid` ausentes | 8 |
| `producao-batelada` | alta | 5 required de `feedstocks[]` ausentes | 8 |
| `acasalamento` | alta | enum `type` 4×3, falta FIV | 2 |
| `acasalamento` | alta | condicionalidade `type`/`launch_type` | 6 |
| `acasalamento` | alta | `bull_seed_season_uuid` ausente | 1 (adicionar campo) |
| `diagnostico-gestacao` | alta | `provider_uuid` por item ausente | 4 |
| `diagnostico-gestacao` | alta | campos planos duplicam a coleção | 4 |
| `apontamento` | alta | 11 inversões de obrigatoriedade | 1 / 8 |
| `apontamento` | alta | modelo de mão de obra | 8 |
| `apontamento` | alta | matriz de qualidade (13 col. → 4) | 8 |
| `pastagens` | alta | coleção "Serviços" incompatível | 7 |
| `pastagens` | alta | imagens geo em `occurrences[]` | 7 |
| `pastagens` | alta | inversões required↔nullable | 7 |
| `sanitario` | alta | `func_type` 2×3 | 2 |
| `sanitario` | alta | `time_control`/`labor.measurement_uuid` | 1 / 6 |
| `rebanho-inicial` | alta | 7 required marcados opcionais | 1 |
| `marcacao` | alta | 5 required marcados opcionais | 1 |
| `cadastrar-area` | alta | `tipo`/`cor` enum errado | 2 / 2b |
| `cadastrar-area` | alta | 4 required marcados opcionais | 1 |
| `manutencao-frota` | alta | executor por item ausente | 4 |
| `manutencao-frota` | alta | leituras por item achatadas | 4 |
| `material-reprodutivo` | alta | coleção `animals[]` ausente | 4 |
| `material-reprodutivo` | alta | estação texto × FK; `products.armazem` | 3 / 1 |
| `protocolos-estacao` | alta | `items.*.service`/`measurement_uuid` ausentes | 4 |
| `protocolos-estacao` | alta | XOR produto⊕serviço | 6 |
| `desmama` | alta | enum `tipo` incompatível | 2 |
| `desmama` | alta | `animal_uuids[]`/`lote` UUID | 3 / 5 |
| `apartacao` | alta | `batches[]` × escalar | 5 |
| `consulta-produtos` | alta | contrato de escrita maior; FK como rótulo | 9 |
| `compras-animais` | media | `fornecedor`/`vendedor` texto × FK | 3 |
| `compras-animais` | media | duplicação cabeçalho×item | 10 (fechada) |
| `compras-animais` | media | fiscais/`has_financial` ausentes | backlog (baixo valor) |
| `batidas` | media | 3 required por item opcionais | 4 |
| `batidas` | media | `items.*.measurement_uuid` ausente | 4 |
| `formulacoes` | media | enum `tipo` P/U | 2b → 16 (fechada) |
| `abastecimentos` | media | `medidor` funde dois campos do contrato | 10 (fechada) |
| `abastecimentos` | media | required de cabeçalho × nullable | 10 (fechada) |
| `lote-animais` | media | categoria escalar × array | 5 |
| `lote-animais` | media | item por texto × `animal_uuids[]` | 3 |
| `transferencia-animal` | media | identificação escalar × array | 5 |
| `transferencia-animal` | media | destino por índice não modelado | 5 |
| `transferencia-lote-area` | media | XOR três destinos | 6 |
| `transferencia-lote-area` | media | curral rótulo × FK | 3 |
| `estacao-monta` | media | `description` mapeado a campo opcional | 10 (fechada) |
| `lotes-reproducao` | media | `lote` escalar × `batch_uuids[]` | 4 |
| `registrar-animal` | baixa | `preco-kg` opcional | 1 |
| `perdas` | baixa | `lote` required no form × nullable no contrato | revisão manual (form mais estrito — ok manter) |

## Contagens de referência (auditoria 14/09)

| | Valor |
|---|---|
| Funcionalidades totais | 53 |
| Formulários com contrato de entrada auditável | 27 |
| Fiéis sob este critério | 0 |
| Alta divergência | 16 |
| Média divergência | 9 |
| Baixa divergência (quase fiéis) | 2 |
| Sem formulário a auditar (leitura/ponteiro/hardware/gap) | 26 |

## Pendências conhecidas desta esteira

- ~~**Enums sem domínio completo no relatório** (`AreaColor` 14 hex, `FoodTypeEnum` P/U) ficam
  `TODO(banco-real)` — não travar rótulo sem confirmar com o time web (Onda 2b).~~ — os dois
  fechados: `AreaColor` virou campo de cor real na Onda 11 (o dump mostra hex livre, não um
  enum de 14 nomes); `FoodTypeEnum` teve o rótulo confirmado pelo usuário na Onda 16
  (`P` = "Porcentagem", `U` = "Unidade").
- **Tipo de campo "imagem" não existe no catálogo** (`FeatureFieldType`) — necessário para a
  coleção geo de `pastagens.occurrences[]` (Onda 7). É decisão de motor, não só de dado;
  revisar antes de codar.
- **`transferencia-animal` continua com identificação escalar.** A Onda 5 fechou
  `category_uuids[]`/`batches[]` reaproveitando o motor de coleção (nenhum componente novo
  necessário — ver a decisão de arquitetura no início da Onda 5), mas `identificacao` é o
  campo-alvo da simulação de RFID: convertê-lo para `animal_uuids[]` exige redesenhar a
  captura por hardware simulado para empilhar leituras numa coleção, não só declarar o campo.
  Mesmo tipo de esforço da Onda 8 (fluxo dedicado), fica para lá ou para uma onda própria.
- ~~**`compras-animais`/`abastecimentos`/`estacao-monta`** têm issues marcadas "revisão manual"
  na tabela — o relatório aponta a divergência mas não dá dado suficiente (enum completo, nome
  exato do campo-destino) para fechar sem olhar o Form Request real; não incluídas em onda
  numerada até essa confirmação.~~ — fechadas na Onda 10 com dado real de um dump do Postgres de
  produção (schema `gbcerne`).
- ~~**`flutter analyze`/`flutter test` não rodam neste ambiente**~~ — resolvido nesta sessão:
  SDK Flutter 3.44.6 baixado, `npm run lint`/`npm run quality:functional`/`npm test`
  (544 testes) rodaram de verdade. 3 bugs reais corrigidos (ver "Verificação real" no topo).
  10 falhas continuam de pé, nenhuma desta leva — 6 golden tests (fonte do ambiente) e 4 já
  quebradas em `main` sem relação com fidelidade de contrato.
