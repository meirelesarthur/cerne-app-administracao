# Documento 1 — O que o banco real permite incrementar no GB CERNE

> Frente 1 de 2 solicitadas pelo usuário em 18/08/2026. Objetivo: analisar o dump de produção
> `init_db.sql` (schema `gbcerne`, 415 tabelas) por inteiro — não só as 53 funcionalidades já
> catalogadas — e apontar cadastros, campos e módulos que podem refinar o app Flutter para
> atender ao banco real da melhor forma possível. Este documento não implementa nada; é
> insumo de decisão. O Documento 2 (a segunda frente) será definido pelo usuário na sequência.

## 1. Panorama

Das **415 tabelas** do schema, o [mapa campo a campo](01-mapa-catalogo-banco.md) já
cobriu **122** (~29%) contra as 53 funcionalidades atuais do catálogo Flutter. As **293
tabelas restantes (~71%)** representam capacidade real do backend de produção que o app hoje
**não expõe de forma alguma** — nem como tela, nem como cadastro, nem como consulta.

Isso não é ruído: são módulos de negócio inteiros, com volume de dado de produção real,
prontos para virar funcionalidade. Abaixo, os domínios agrupados por relevância (volume de
dado + aderência ao objetivo do produto), cada um com a leitura de "o que dá pra construir".

---

## 2. Domínios inteiramente ausentes do app hoje

### 2.1 Fiscal eletrônico (NFe / CTe / NFSe / MDFe / DVE) — o maior módulo ausente

| Tabela | Linhas | Papel |
|---|---|---|
| `item_invoices` | 166.849 | Item de nota de entrada |
| `invoices` | 45.363 | Nota de entrada (compra) |
| `dves` | 82.430 | Documento de Vinculação Eletrônica (eventos de nota) |
| `nves` | 19.818 | Nota de venda eletrônica (NF-e de saída) |
| `nfses` | 12.716 | Nota fiscal de serviço |
| `ncms`/`category_ncms` | 10.678 / 194 | Classificação fiscal de produto |
| `nature_operations` | 11.592 | Natureza de operação fiscal (CFOP) |
| `manifesta_ctes`, `info_descargas`, `n_fe_descargas`, `unidade_cargas`, `mdves`, `municipio_carregamentos` | 2.318–2.924 cada | Manifesto de CT-e / logística de carga fiscal |
| `ctes`, `componente_ctes`, `medida_ctes`, `c_te_descargas` | 5–93 | Conhecimento de Transporte Eletrônico |
| `mdfe_payments`, `devolucaos`, `item_devolucaos`, `inutilizacaos` | 1–2 | Manifesto de documentos fiscais / devolução / inutilização |
| `tax_rules`, `product_ibpts`, `ibpts`, `item_ibpts` | 0–14 | Regras tributárias e IBPT |

**Leitura**: o backend real já processa emissão e recepção fiscal em escala (quase 250 mil
registros somando `item_invoices` + `dves`). O app hoje trata "Vendas" e "Compra de animais"
como formulário simples — não existe tela de **nota fiscal**, **CT-e** ou **conferência
fiscal**. Se o objetivo é o app ser o operador real da fazenda (não só um protótipo de
captura), este é o maior buraco de cobertura, e o mais caro de simular de forma convincente
sem o dado real por trás.

**Recomendação de cadastro/tela**: um módulo "Fiscal" (ou aba dentro de Vendas/Compras) com:
lista de NF-e emitidas/recebidas, status de integração (`dves.integration_status`), CT-e
vinculado a uma venda/transferência, e alerta de pendência de manifesto.

### 2.2 Contabilidade e fechamento financeiro avançado

| Tabela | Linhas | Papel |
|---|---|---|
| `movements` | 208.178 | Livro-razão consolidado (toda movimentação financeira, com conciliação `is_reconciled`) |
| `plan_accounts` | 5.408 | Plano de contas contábil hierárquico |
| `accounting_groupers`, `financial_category_plan_account` | 18 / 451 | De-para categoria financeira ↔ conta contábil |
| `week_vintages` | 18.394 | Semanas de safra (fechamento semanal por período) |
| `closing_weeks`, `charge_closing_week`, `item_closing_weeks` | 0 | Fechamento semanal de cobrança (estrutura pronta, vazia) |
| `financial_freezes`, `financial_freeze_movements` | 39 / 69 | Congelamento de período financeiro (trava contra edição retroativa) |
| `ofx_imports` | 290 | Conciliação bancária via importação OFX |
| `opening_balances` | 8.238 | Saldo de abertura de estoque por produto/armazém |
| `discount_rules`, `discount_tables`, `discount_table_products` | 8–7.712 | Tabela de desconto por faixa de preço |
| `payment_terms`, `payment_plans` | 755 / 0 | Condição de pagamento |
| `charges`, `charge_bills`, `charge_expense_ancillaries` | 699 / 1 / 4.733 | Cobrança e boletos |
| `advances` | 241 | Adiantamentos |

**Leitura**: hoje o painel "Financeiro e operacional" do app é um dashboard agregado (bom para
visão gerencial). O banco tem um **motor contábil completo** por trás — plano de contas,
conciliação bancária, congelamento de período, fechamento semanal. Isso é o tipo de
profundidade que diferencia um dashboard de apresentação de um ERP financeiro de verdade.

**Recomendação**: enriquecer o painel financeiro admin com drill-down por plano de contas, e
considerar uma tela de "Conciliação bancária" (OFX) — é uma automação de alto valor percebido
(elimina lançamento manual) e o dado real já existe (290 importações).

### 2.3 RH / Folha de colaboradores

| Tabela | Linhas | Papel |
|---|---|---|
| `earning_event` | 76.603 | Evento de remuneração (por tipo: hora extra, comissão, etc.) |
| `earnings` | 17.093 | Folha mensal consolidada por colaborador |
| `employee_events` | 6.356 | Eventos ligados ao colaborador |
| `absences` | 51 | Faltas |
| `bonuses` | 94 | Bonificações |
| `teams`, `team_employees`, `team_providers` | 49 / 10 / 174 | Equipes de trabalho |
| `cbos` | 10.345 | Tabela de ocupações (Classificação Brasileira de Ocupações) |
| `functions` | 203 | Função/cargo |
| `boss_user` | 222 | Hierarquia de chefia |

**Leitura**: o app usa `employee_id` só como FK de "responsável" nas telas operacionais — não
existe qualquer tela de **gestão de pessoas**. O banco tem folha de pagamento completa (17 mil
registros de folha, 76 mil eventos de remuneração). Isso é um módulo de produto em si (RH),
não só um enriquecimento de tela.

**Recomendação**: se o roadmap incluir "gestão de equipe" no perfil Administração, este é o
domínio com maior volume de dado pronto (earnings + earning_event ≈ 94 mil registros).

### 2.4 Cadastro de terceiros (Clientes, Parceiros, Proprietários)

| Tabela | Linhas | Papel |
|---|---|---|
| `people` | 25.234 | Pessoa física/jurídica base (endereço, documento) |
| `clients` | 3.247 | Cliente comercial (compra produção) |
| `providers` | 21.868 | Fornecedor (já usado indiretamente em Compras) |
| `partners` | 2 | Parceiro comercial/revenda |
| `proprietaries` | 539 | Proprietário de fazenda |
| `farm_client`, `farm_provider`, `farm_proprietary`, `farm_employee` | 783–33.521 | Vínculo N:N fazenda↔pessoa |
| `state_registrations`, `proprietary_state_registration`, `issue_state_registration` | 251–464 | Inscrição estadual multi-UF |
| `cities`, `states`, `countries` | 245–5.984 | Base geográfica |
| `banks` | 168 | Banco para dados bancários de terceiro |

**Leitura**: o app não tem hoje uma tela de "Clientes" nem "Proprietários" — `providers`
aparece só embutido no fluxo de Compras/Suprimentos. Há 3.247 clientes e 25.234 pessoas reais
cadastradas. Um cadastro dedicado de Clientes seria natural ao lado de Vendas (que já existe e
tem bom volume — 1.262 vendas para 3.247 clientes potenciais).

**Recomendação**: novo cadastro "Clientes" no grupo Cadastros/Pecuária (ou seção própria),
reaproveitando o padrão de lista→formulário já existente para Áreas.

### 2.5 Planejamento agropecuário (orçamento de safra/pecuária)

| Tabela | Linhas | Papel |
|---|---|---|
| `planning_operations` | 5.864 | Operação planejada (safra) |
| `plannings` | 54 | Cabeçalho de planejamento |
| `planning_cultivations`, `planning_species`, `planning_species_categories` | 12–38 | Plano por cultura/espécie |
| `planning_livestocks`, `planning_livestock_operations` | 19 / 196 | Plano pecuário |
| `production_cycles`, `production_cycle_areas` | 45 / 151 | Ciclo de produção por área |
| `cultivations` | 565 | Cultivo cadastrado |
| `activities`, `operations` | 22.960 / 3.180 | Catálogo de atividades/operações agronômicas |
| `activity_cost_centers` | 29 | Custo por atividade |
| `area_rainfall`, `rainfalls` | 5.806 / 3.076 | Pluviometria por área |

**Leitura**: o app tem "Apontamento agrícola" (registro do que foi feito), mas não tem
**planejamento** (o que se pretende fazer, orçado, por safra/ciclo). O banco modela os dois
lados. Isso é uma funcionalidade nova de alto valor para Administração: comparar planejado ×
realizado por safra — inclusive com pluviometria real (8.882 registros de chuva) para cruzar
com produtividade.

**Recomendação**: nova funcionalidade administrativa "Planejamento de safra" com
planejado×realizado, aproveitando `operation_activities`/`service_orders` já mapeados como o
lado "realizado".

### 2.6 Catálogo de produtos e precificação

| Tabela | Linhas | Papel |
|---|---|---|
| `products` | **543.983** | Catálogo de produtos — a maior tabela do banco inteiro |
| `measurements` | 56 | Unidades de medida |
| `packages`, `product_packages` | 161 / 213 | Embalagens |
| `group_products`, `category_products` | 7 / 43 | Categorização de produto |
| `groupers`, `grouper_batches`, `grouper_stocks` | 14 / 15 / 874 | Agrupador de estoque |
| `discount_tables`, `discount_table_products`, `discount_rules` | 8 / 11 / 7.712 | Tabela de preço por faixa |

**Leitura**: `products` sozinha tem mais da metade de um milhão de linhas — é o coração do
catálogo de insumos/mercadorias que todas as telas de estoque, compra e venda referenciam por
`product_id`. O app hoje não tem uma tela de **consulta/cadastro de produto** própria — o
produto só aparece embutido como campo `select` dentro de outras telas (Formulações, Carga,
Vendas etc.).

**Recomendação**: uma "Consulta de produtos" (perfil Administração, grupo Consultas e
auditoria) seria barata de construir (é praticamente `saldo-estoque` sem o filtro de estoque)
e destrava a granularidade de preço/categoria que hoje fica escondida atrás de selects.

### 2.7 Apropriação de custos (rateio)

| Tabela | Linhas | Papel |
|---|---|---|
| `appropriations` | 20.221 | Cabeçalho de rateio de custo por operação/área/atividade |
| `appropriation_equipment`, `appropriation_employee`, `appropriation_production`, `appropriation_stock`, `appropriation_movements`, `appropriation_occurrences` | 5–6.267 | Detalhamento do rateio por recurso |

**Leitura**: já mapeamos `appropriation_supply` e `appropriation_maintenance` (Abastecimento e
Manutenção). Mas existe um **motor de rateio genérico** por trás (`appropriations`, 20.221
linhas) que cobre também mão de obra (`appropriation_employee`), produção
(`appropriation_production`) e movimentação de estoque (`appropriation_stock`) — hoje nenhuma
dessas está espelhada em tela. É o motor de custo que dá substância a "Financeiro e
operacional" (custo real por área/atividade, não só por categoria).

**Recomendação**: se o painel financeiro evoluir para "custo por atividade/área", a fonte já
existe e está bem populada.

### 2.8 Central de notificações

`notifications` tem **457.416 linhas** — a segunda maior tabela do banco, maior até que
`animals`. É notificação real de sistema (`notifiable_type`/`notifiable_id` polimórfico,
`read_at`). O app não tem central de notificações hoje (`favorites` também existe, 3.679
linhas, e tampouco tem tela).

**Recomendação**: uma central de notificações no shell do app (ícone de sino já é padrão de
UI) tem dado de produção pronto para consumir — e é normalmente uma feature de baixo custo de
implementação com alto retorno de percepção de "app vivo".

### 2.9 RBAC multiempresa granular

| Tabela | Linhas | Papel |
|---|---|---|
| `roles`, `permissions`, `role_has_permissions` | 562 / 984 / **158.642** | Papéis e permissões granulares |
| `model_has_roles` | 1.401 | Atribuição de papel a usuário |
| `tenants`, `plan_tenants`, `plan_roles`, `plan_role_role`, `segment_plan_role` | 119–436 | Multiempresa e plano contratado |
| `request_authorizers`, `request_authorizer_rules`, `authorizer_farms` | 24–498 | Alçada de aprovação de compra |

**Leitura**: `role_has_permissions` tem 158.642 linhas — o backend real tem um RBAC muito mais
granular que os dois perfis fixos (Administração/Operacional) do Flutter atual. Isso é
esperado para o protótipo (CLAUDE.md já deixa claro que RBAC de backend é fora de escopo), mas
vale registrar: quando o app deixar de ser só frontend, a granularidade de permissão real é
por **papel dentro de módulo**, não por perfil binário — e há alçada de aprovação por valor
(`request_authorizers.max_value`/`min_value`) que hoje não existe em "Suprimentos".

### 2.10 Evolução zootécnica

`evolutions` tem 159.859 linhas — histórico de mudança de categoria do animal ao longo do
tempo (`category_old_id` → `category_next_id` por data). Isso é diferente de "Registrar
animal" (estático) — é a **linha do tempo de vida do animal**. Excelente candidato a uma aba
"Histórico" dentro da ficha do animal, com dado de altíssimo volume já pronto.

### 2.11 Contratos com fornecedor

`contracts`(14) + `item_contracts`(14): pequeno em volume, mas é um tipo de documento
(contrato de fornecimento com preço/quantidade fixados, parcelamento) que não existe no app —
complementaria "Suprimentos" além de cotação avulsa.

---

## 3. Enriquecimento do que já existe (mesmo domínio, mais profundidade)

Estes não são módulos novos — são campos e sub-relações reais que já cabem nas telas
existentes e ficaram de fora do catálogo atual:

| Tela atual | Campo/tabela real disponível, ainda não usado | Ganho |
|---|---|---|
| Registrar animal | `animals.value_unitary`, `value_average`, `vl_acquisition`, `depreciation_type` | Valorização patrimonial do animal, não só peso/preço |
| Ativos e depreciação | `equipments.chassi`, `renavam`, `plate`, `rntrc`, `owner_document` (dados de frota fiscal) | Ficha de veículo completa (hoje só nome/valor) |
| Suprimentos | `request_authorizers.max_value`/`min_value` (alçada), `payment_terms`, `discount_tables` | Fluxo de aprovação por alçada de valor, não só cotação |
| Financeiro | `plan_accounts` (plano de contas), `movements.is_reconciled` (conciliação) | Granularidade contábil real |
| Vendas | `sale_contracts` já mapeado, mas `nves` (NF-e de venda) e `dves` (eventos) ainda não | Rastreio fiscal completo da venda |
| Compra de animais | `invoices`/`item_invoices` (nota de entrada real) além de `movement_purchases` | Nota fiscal de compra vinculada |
| Manutenção de frota | `appropriation_maintenance_preventive` já mapeado; falta `feedlot_components`, `family_equipments` | Plano preventivo por família de equipamento |
| Pastagens | `area_rainfall`/`rainfalls` (pluviometria real por área) | Cruzar chuva × produção de pasto |
| Perfis administração/operação | `roles`/`permissions` reais (hoje só 2 perfis fixos) | Granularidade de acesso por módulo, se o backend real entrar em cena |

---

## 4. Priorização sugerida (valor × prontidão do dado)

| Prioridade | Iniciativa | Por quê |
|---|---|---|
| **Alta** | Consulta de produtos (catálogo) | Tabela com mais dado do banco (543.983), zero tela hoje, baixo custo (reusa padrão de lista/consulta já existente) |
| **Alta** | Central de notificações | 457.416 registros prontos, alto valor de percepção, baixo custo de implementação |
| **Alta** | Histórico/evolução do animal | 159.859 registros, encaixa como aba nova na ficha de animal já existente |
| **Média** | Cadastro de Clientes | 3.247 clientes reais, complementa Vendas que já existe e tem bom volume |
| **Média** | Conciliação bancária (OFX) | 290 importações reais, automação de alto valor percebido |
| **Média** | Planejamento de safra (planejado × realizado) | Módulo novo, mas dado maduro (planning_operations 5.864 + rainfall) |
| **Baixa-Média** | Módulo Fiscal (NF-e/CT-e) | Maior volume agregado do banco, mas é o mais complexo de construir bem (regras fiscais, não só CRUD) |
| **Baixa** | RH/Folha completa | Alto volume de dado, mas é um módulo de produto à parte — depende de decisão estratégica se GB CERNE vira também ferramenta de RH |
| **Baixa** | RBAC granular real | Contraria explicitamente o escopo atual do protótipo (frontend-only) — só relevante quando houver backend real |

---

## 5. Como este documento se conecta ao anterior

O [mapa campo a campo](01-mapa-catalogo-banco.md) responde "o que já dá pra ligar hoje,
dentro do que o app já promete fazer". Este documento responde a pergunta maior: "o que o
banco real sabe fazer que o app ainda nem promete". Juntos, formam o inventário completo de
decisão antes de qualquer trabalho de integração.

---

## Próximo passo

Aguardando definição da **segunda frente** (Documento 2), a ser detalhada pelo usuário na
sequência desta análise.
