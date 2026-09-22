# Esteira — Ajustes do protótipo Flutter ao banco real (leva "banco-real")

> Leia este arquivo antes de mexer em qualquer item desta leva e atualize-o no mesmo commit
> de cada onda concluída — mesmo padrão de continuidade usado em
> `docs/MEMORIA-MIGRACAO-FLUTTER.md`.

## Origem e objetivo

Esta leva nasce da análise do dump de produção `init_db.sql` (schema `gbcerne`, 415 tabelas,
fornecido em 18/08/2026) contra o catálogo funcional Flutter (53 itens). Três documentos de
apoio foram produzidos antes desta esteira e continuam sendo a fonte de verdade de cada
decisão tomada aqui:

1. [`01-mapa-catalogo-banco.md`](01-mapa-catalogo-banco.md) — conferência campo a campo do
   catálogo atual contra o schema real.
2. [`02-oportunidades-banco-real.md`](02-oportunidades-banco-real.md) — o que o banco real
   sabe fazer que o app ainda nem promete (293 tabelas sem contrapartida no catálogo).
3. [`03-ajustes-ponto-a-ponto.md`](03-ajustes-ponto-a-ponto.md) — lista ponto a ponto de
   ajustes de campo, por cadastro, para reduzir a adaptação futura do time web.

**Objetivo desta leva**: aplicar no protótipo Flutter um subconjunto **enxuto e de alto
valor** desses ajustes — o suficiente para o app ficar mais fiel ao banco real e para os
cadastros novos parecerem verdadeiros (dado no formato/volume real), sem inchar o protótipo
com todos os 293 itens levantados no Documento 2. Curadoria é intencional: nem tudo que é
possível deve entrar nesta leva.

## Regras específicas desta leva

- Branch de execução: `feature/ajustes-banco-real` (criada a partir de `main`).
- Prefixo de commit: `(banco-real)` dentro do tipo Conventional Commit —
  ex.: `feat(banco-real): adiciona custo por kg em formulacoes`,
  `refactor(banco-real): corrige tabela-fonte do apontamento agricola`,
  `docs(banco-real): atualiza esteira apos onda 1`.
- Continuam valendo todas as leis do `CLAUDE.md` (component-first, tokens, push só sob pedido
  explícito).
- **Dado de exemplo não é dado real copiado do dump.** O dump tem pessoas, CPFs e valores
  financeiros de produção reais. Os cadastros novos/enriquecidos devem usar valores
  **sintéticos, mas fiéis ao formato e à distribuição real** (mesmas categorias de produto,
  mesma ordem de grandeza de custo, mesmos nomes de unidade) — nunca um registro verdadeiro
  copiado verbatim. Isso protege dado de cliente real e evita que o protótipo vaze informação
  de produção.
- Escopo continua frontend-only (mock/simulado); esta leva enriquece o **modelo de dado e a
  tela**, não cria backend nem persistência real.

## Curadoria desta leva (o que entra e o que fica para depois)

### Onda 1 — Ajustes de campo em cadastros existentes

Prioriza os itens do Bloco A do Documento 2 com maior relação valor/esforço e que corrigem
riscos concretos, sem exigir componente novo.

- [x] **Corrigir risco de tabela-fonte errada** em `transferencia-animal`: comentário
      `banco-real` fixado no código apontando `transfer_batch_farms` como fonte correta de
      "novo lote" (não `transfer_animal_farms`, que é troca entre fazendas).
- [x] **Apontamento agrícola**: comentário `banco-real` registrando `service_orders` como
      fonte real; adicionados `prazo` (date), `resultado-esperado` (textarea) e
      `criterio-sucesso` (textarea).
- [x] **Formulações**: adicionados `custo-por-kg` e `custo-estimado` (number, opcionais);
      `recordDescriptionFields` passou a mostrar `custo-estimado` em vez de `ativo`.
- [x] **Batida**: campo `quantidade` renomeado para "Quantidade prevista"; adicionado
      `quantidade-realizada` (number, opcional) — mesmo par usado no banco
      (`diet_beats.quantity` / `item_diet_beats.quantity_realized`).
- [x] **Áreas**: adicionados `area-produtiva`, `area-nao-produtiva` e `carga-animal`
      (number, opcionais).
- [x] **Sanitário**: adicionado `controle-por-tempo` (select Sim/Não, opcional).
- [x] **Rebanho inicial**: adicionado `data-entrada` (date, opcional), separado de "Data de
      referência".

Todos os 11 campos novos são opcionais — nenhum novo campo obrigatório foi introduzido.
Catálogo passou de 168 para **179 campos totais** (156 obrigatórios, inalterado); teste
`preserva as invariantes estruturais do catálogo congelado` atualizado no mesmo commit.
Gates rodados: `dart analyze --fatal-infos` limpo; suíte `quality:functional` (31 testes)
verde.

Gate da onda: todos os campos acima existem no Dart com o `id` alinhado ao nome da coluna
real (facilita o de-para do time web); nenhum campo novo exige tabela de domínio ainda não
confirmada (isso é onda 3).

### Onda 2 — Dois cadastros novos, com dado sintético realista

Curadoria deliberada: dos quatro cadastros novos possíveis (Documento 2, Bloco B), **só dois
entram nesta leva** — os de menor esforço e maior efeito de "app parece vivo":

- [x] **Consulta de Produtos** (perfil Administração, grupo Consultas e auditoria) — nova
      `FeatureDefinition` (`consulta-produtos`), reaproveitando 100% o padrão de "Saldo de
      estoque" (`listMode: true`, roteamento e menu genéricos por catálogo — nenhum
      componente novo, nenhuma rota manual). Populada com 8 produtos sintéticos cobrindo
      4 categorias reais do dump (Nutrição, Sanitário, Combustível, Agrícola/Peça de
      equipamento) — número reduzido de propósito para não pesar o protótipo.
- [x] **Central de notificações** — **já existia** no shell (`NotificacoesPage` +
      `shellStoreProvider`, ícone de sino já implementado); o ajuste real desta onda foi
      **enriquecer** o mock com 2 tipos de alerta reais do dump (estoque abaixo do mínimo,
      cotação pendente de aprovação) em vez de construir do zero — corrige a premissa do
      Documento 2 de que a tela não existia.

Ficam **fora desta leva** (backlog, não implementar agora): Cadastro de Clientes e Linha do
tempo/evolução do animal — maior esforço relativo, revisitar em leva futura se esta entregar
valor.

Catálogo passou de 12 para **13 funcionalidades administrativas** (54 no total); ready
47/47, listMode 33/33. Gates: `dart analyze --fatal-infos` limpo; suíte `quality:functional`
+ `mapped_feature_wave_d_test` + `shell_store_test` + `notificacoes_page_test` verdes
(43 testes).

Gate da onda: os dois cadastros novos nascem em `apps/mobile/lib/ui/` antes da tela (Lei 1),
têm caso no Widgetbook, e usam tokens/tipografia gerados — nenhuma cor, espaçamento ou fonte
literal.

### Onda 3 — Registrar dicionários pendentes (sem travar valores)

Não é implementação de tela — é documentação explícita dentro do próprio código (comentário +
TODO rastreável) nos `select` que hoje têm opções inventadas, para o time web saber que
precisa confirmar:

- [x] `areas.tipo` (`cadastrar-area`), `diets.objective`/`tipo` (`formulacoes` e `batidas` —
      duas telas usam o mesmo par de colunas), `sales.payment_method`/`movement_sales.type_payment`
      (`condPagamento` em `mocks/operacional.dart`) — marcados com `TODO(banco-real)` direto
      acima do `options: [...]` real, com o campo do banco citado.
- [x] `service_orders.category`/`status` (`minhas-os`), `breeding_matings.type`
      (`monta-natural`), `stocks.type`/`stock_movements.classification` (`saldo-estoque`) —
      **estas três telas ainda não têm o campo correspondente no catálogo** (são consultas
      sem formulário ou o campo simplesmente não existe hoje). Marcados com comentário
      preventivo na própria `FeatureDefinition`, para o time web achar o aviso quando o
      campo for adicionado no futuro — não há `select` fabricado sem necessidade real.

7 marcadores `TODO(banco-real)`/`banco-real` cobrindo os 6 itens do Documento 2, seção C —
nenhum a mais, nenhum a menos. Gates: `dart analyze --fatal-infos` limpo; `quality:functional`
(37 testes, incluindo `mapped_feature_wave_d_test`) verde. Nenhuma mudança de contagem de
campos (comentários não alteram `FeatureField`).

Gate da onda: busca por esse marcador no código retorna exatamente os campos listados no
Documento 2, seção C — nenhum a mais, nenhum a menos.

### Fora de escopo desta leva (decisão de modelagem, não ajuste de código)

Carga/Descarga do misturador, Nota de cocho, critério de Apartação — o banco real não tem
modelo pronto para esses três (Documento 2, item "Alto esforço"). Não implementar enquanto não
houver uma sessão de modelagem conjunta com o time web; forçar um campo agora só criaria
dívida técnica dupla.

## Protocolo de retomada para uma nova sessão

1. Ler este arquivo e os três documentos de apoio antes de tocar em qualquer tela.
2. Confirmar branch ativa: `feature/ajustes-banco-real`.
3. Rodar `git log --oneline -10` e localizar o último item marcado concluído aqui.
4. Implementar uma unidade lógica por vez, seguindo a ordem das ondas (1 → 2 → 3).
5. Rodar `npm run lint`, `npm test` e `npm run quality:functional` antes de fechar cada item.
6. Marcar o checkbox, registrar o commit na tabela abaixo e commitar imediatamente
   (`(banco-real)` no escopo). Push só mediante pedido explícito do usuário.

## Registro de execução

| Item | Estado | Commit | Observações |
|---|---|---|---|
| Criação da esteira e reorganização dos documentos | Concluído | `6056e63` | Pasta `docs/ajustes-banco-real/` criada; branch `feature/ajustes-banco-real` aberta |
| Onda 1 | Concluída | `4ed6dad` | 7 ajustes de campo aplicados; 11 campos novos (todos opcionais); catálogo 168→179 campos; gates verdes |
| Onda 2 | Concluída | `1a2448d` | Consulta de Produtos criada (8 produtos sintéticos); Central de notificações enriquecida (2 alertas reais do dump); catálogo 53→54 funcionalidades |
| Onda 3 | Concluída | _preencher no commit desta onda_ | 7 marcadores `TODO(banco-real)` cobrindo os 6 dicionários pendentes do Documento 2; gates verdes |
| Onda 4 | Concluída | _preencher no commit desta onda_ | `apontamento` migrado para fluxo dedicado com fonte real `appropriations`; `pastagens` ganha dropdown real de armazém. Ver `04-apontamento-appropriations.md` |

## Leva reaberta — Onda 4

A leva foi reaberta em 07/09/2026 a partir de um novo dump de homologação (`init_db.sql`,
mesmo schema `gbcerne`), que permitiu inspecionar a família `appropriation_*` — não
analisada nas ondas 1–3. Ela é a fonte real do Apontamento agrícola (a hipótese anterior,
`service_orders`, ficou obsoleta). Detalhes completos em
[`04-apontamento-appropriations.md`](04-apontamento-appropriations.md); resumo: `apontamento`
saiu do motor genérico para um fluxo dedicado com campo real por item nos quatro grupos
(Mão de obra, Máquinas, Insumos, Ocorrências), Operação/Atividade viraram dropdown real, e
`pastagens` ganhou dropdown de armazém. Próximos passos possíveis (avaliar com o usuário
antes de iniciar): estender a mesma curadoria a outros campos livres com candidato real
identificado nesta onda (raça, lote, identificação, fornecedor — ver seção "Fora desta
onda" do documento 4), revisitar Cadastro de Clientes e Linha do tempo do animal (backlog
da Onda 2), ou abrir a sessão de modelagem conjunta com o time web para os três itens de
alto esforço (carga/descarga do misturador, nota de cocho, critério de apartação).
