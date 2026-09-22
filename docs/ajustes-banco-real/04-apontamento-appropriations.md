# Onda 4 — Apontamento agrícola: fonte real é `appropriations`

> Leva `banco-real` reaberta a partir de um dump de homologação mais recente
> (`init_db.sql`, schema `gbcerne`, mesmas 415 tabelas do dump de 18/08/2026,
> fornecido em 07/09/2026). As ondas 1–3 (`00-ESTEIRA-AJUSTES-BANCO-REAL.md`)
> continuam válidas; este documento cobre só o que a onda 4 mudou.

## Por que reabrir

As ondas 1–2 (`01-mapa-catalogo-banco.md`, linha 210) já suspeitavam que
`service_orders` não era a fonte real do Apontamento, mas não tinham uma
tabela candidata melhor — o dump analisado então não havia sido inspecionado
até a família `appropriation_*`. Revisando o dump completo agora, ela existe,
é rica e é claramente o modelo real:

```
appropriations                     -- cabeçalho do apontamento
├── appropriation_employee         -- Mão de obra / Serviços
├── appropriation_equipment        -- Máquinas / Implementos
├── appropriation_stock            -- Insumos
├── appropriation_occurrences      -- Ocorrências
├── appropriation_production       -- Produção (13 parâmetros de qualidade —
│                                     confirma a exclusão já decidida na
│                                     onda 2: fica só no desktop)
├── appropriation_maintenance(_preventive)  -- manutenção de equipamento
│                                     (mesmo modelo de `manutencao-frota`)
├── appropriation_supply           -- abastecimento de equipamento (mesmo
│                                     modelo de `abastecimentos`)
└── appropriation_movements        -- histórico de status (auditoria, não
                                       campo de formulário)
```

## O que mudou no app

### `apontamento` sai do motor genérico

O contrato genérico (`fields`/`sections` de `FeatureDefinition`) não
representa um cabeçalho + quatro listas de item com campo próprio — cada
"seção" virava um contador cego (`AppAddableGroupList.onAdd` só incrementava
um número, sem coletar nenhum dado do item). `apontamento` agora é um fluxo
dedicado (`ApontamentoFlow`, `/fazendas/campo/apontamento`), no mesmo padrão
de `LeituraCochoFlow`/`BateladaFlow`: cada "Adicionar" abre um formulário real
(`showAppBottomSheet`) e o item entra na lista com os campos verdadeiros
preenchidos.

### Cabeçalho — `appropriations`

| Campo Dart | Coluna real | Antes | Agora |
|---|---|---|---|
| responsavel | `employee_id`/`user_id` | select (mock) | inalterado |
| area | `area_id` | select (mock) | inalterado |
| **operacao** | `operation_id` | **campo livre** | **select — 10 operações reais de `operations`** |
| **atividade** | `activity_id` | **campo livre** | **select — 18 atividades reais de `activities`** |
| data-apontamento | `date` | date | inalterado |
| area-total / area-utilizada | `areas.total_area` / `used_area` | number | inalterado |
| cultura-variedade | `cultivation_id` | select (5 opções inventadas) | select — 10 culturas reais de `cultivations`/`cost_centers` |
| safra | `harvest_id` | select (3 opções) | select — 4 safras, mesmo formato real de `harvests.description` |
| armazem-insumo / armazem-producao | `warehouse_id` / `warehouse_production_id` | select (mock) | inalterado |
| descricao | `description` | textarea | inalterado |

`operations` e `activities` são domínios reais grandes (19 e 148 linhas
distintas no dump); curadoria aplicada — 10 e 18 itens representativos,
cobrindo o ciclo agrícola completo (preparo → plantio → tratos → colheita →
pós-colheita → transporte), mesmo critério de curadoria já usado em
`catalogoProdutos` (8 de 543.983 linhas de `products`). Uma pessoa real
(`Cintia Modenesi`) aparece misturada em `activities` no dump — excluída da
curadoria (nunca copiar dado real de pessoa para o protótipo).

### Quatro grupos — campo real por item, não mais contador

| Grupo | Tabela real | Campos do item |
|---|---|---|
| Mão de obra / Serviços | `appropriation_employee` | Função (select — 8 reais de `functions`), Colaborador/prestador, Quantidade, Unidade (select — `measurements`), Valor unitário |
| Máquinas / Implementos | `appropriation_equipment` | Equipamento (select — mesmo vocabulário de frota de Abastecimentos/Manutenção), Horímetro inicial/final, Quantidade, Unidade |
| Insumos | `appropriation_stock` | Produto (select — `catalogoProdutos`, fonte única já usada por Formulações/Batida), Quantidade, Unidade |
| Ocorrências | `appropriation_occurrences` | Prioridade (Baixa/Média/Alta — `priority` char(1), sem tabela de domínio no dump), Diagnóstico, Recomendação, Foto |

`functions` tem linhas de pessoa física (ex.: nomes de sócios lançados como
"função" para folha) e linhas puramente financeiras (`Juro de custeio`,
`Energia elétrica irrigação`) misturadas com cargos reais — curadoria manteve
só os 8 cargos agropecuários genuínos.

### Bônus de baixo risco: `pastagens`

`armazem-insumos`/`armazem-producao` eram campo livre sem lastro no banco;
viraram `select` com as mesmas opções já usadas pelos demais campos
"armazém" do catálogo (`warehouses` é tabela real de domínio). Mesmo
tratamento do cabeçalho do Apontamento, escopo mínimo.

### Fora desta onda (levantado, não implementado)

Varredura pelo catálogo encontrou outros campos livres (`raça`, `lote`,
`identificação`, `fornecedor`, nomes de estação/protocolo) que também têm
candidatos reais no dump (`breeds`, tabelas de lote, `providers`), mas exigem
inspeção própria de cada tabela — fora do escopo desta onda, que seguiu o
pedido original (Apontamento). Candidato natural para uma onda 5, se houver
interesse.

## Impacto no catálogo

- `apontamento`: -12 campos (-8 obrigatórios), -4 seções, -1 `listMode`,
  +1 `existingRoute`. 163→151 campos; 140→132 obrigatórios; 12→8 seções;
  31→30 com `listMode`; 16→17 com `existingRoute`.
- `pastagens`: sem mudança de contagem (already-required fields ganharam
  `type`/`options`, não novo campo).
- Nenhuma funcionalidade nova, nenhuma removida — `allFeatures` continua 53.

Gates: `flutter analyze --fatal-infos` limpo; `quality:functional` (42
testes) verde; suíte completa sem regressão (mesmas 13 falhas pré-existentes
de golden tests, por fonte/render entre plataformas — nada relacionado a
este trabalho).

## Registro de execução

| Item | Estado | Observações |
|---|---|---|
| Mapeamento do dump (`appropriations` + filhas, domínios `operations`/`activities`/`functions`/`measurements`/`cultivations`/`harvests`/`warehouses`) | Concluído | Ver seções acima |
| `ApontamentoFlow` (fluxo dedicado, 4 grupos com bottom sheet real) | Concluído | `apps/mobile/lib/modules/fazendas/operacional/apontamento_flow.dart` |
| Catálogo: `apontamento` vira `existingRoute`; `pastagens` ganha dropdown real | Concluído | `functional_catalog.dart` |
| Testes atualizados/criados | Concluído | `functional_catalog_test.dart`, `mapped_feature_screen_test.dart`, `apontamento_flow_test.dart` (novo, 5 casos) |
