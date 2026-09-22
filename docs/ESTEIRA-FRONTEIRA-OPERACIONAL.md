# Esteira — Fronteira Operação / Gestão

Referência funcional: catálogo em `apps/mobile/lib/modules/fazendas/functional_catalog.dart`
(59 funcionalidades: 13 administrativas, 46 operacionais), submódulo Confinamento
(`apps/mobile/lib/modules/fazendas/confinamento/`) e a especificação de Apontamentos do AGRO365 web.

## Objetivo

O app mobile é **executor**; o AGRO365 web é o **demandante**. Toda funcionalidade operacional
precisa passar por um único teste: *é uma ação física, repetida, que alguém faz de pé no campo?*
Quando a resposta é não — porque é configuração, cadastro estruturante ou decisão de dinheiro — o
lugar certo é o desktop, onde há tela grande, tempo e conferência.

Esta esteira aplica esse teste ao catálogo inteiro e organiza a correção em quatro ondas.

## Resultado da auditoria

As 46 funcionalidades operacionais, classificadas:

| Destino | Qtde | Significado |
|---|---|---|
| Fica no operacional | 36 | Ação de campo legítima — nada muda |
| Vira visualização | 7 | Consulta no app; cadastro só no desktop |
| Sobe para o ADM | 2 | Decisão comercial/financeira |
| Sai do escopo | 1 | Não é prioridade nesta fase |

Os três itens que entraram como "revisar caso a caso" foram todos decididos: `apontamento` foi
alinhado ao desktop na Onda 2; `nutricoes` e `configuracoes-misturador` ficam como estão (ver
Onda 3). Não há pendência de classificação em aberto.

### Duplicações confirmadas

Três pares gravam **na mesma tabela real**, conforme
`docs/ajustes-banco-real/01-mapa-catalogo-banco.md`:

| Tela antiga | Tela nova (Confinamento) | Tabela compartilhada |
|---|---|---|
| `carga` (Misturador) | `producao-batelada` | `item_diet_beats` |
| `descarga` (Misturador) | `trato-diario` | `item_nutritions` |
| `nota-cocho` (Misturador) | `leitura-cocho-confinamento` | `feedlot_corral_diet_histories` |

Um quarto par (`nutricoes` × `trato-diario`) era sobreposição de conceito, não de tabela — e foi
**descartado como duplicação** (ver Onda 3).

---

## Onda 1 — Reclassificação de perfil

Escopo: `functional_catalog.dart` e os testes congelados. Nenhuma tela nova.

**Viram consulta (7).** Padrão a aplicar: manter `listMode: true` e **remover** `createAction` e
`primaryAction` — é assim que `functional_journey_engine.dart` já distingue consulta de formulário.
Referências prontas no catálogo: `saldo-estoque` e `minhas-os`, que já são consulta pura.

| id | Título | Por quê |
|---|---|---|
| `cadastrar-area` | Áreas | Estrutura física da fazenda, não ação diária |
| `formulacoes` | Formulações | Formular dieta é decisão técnica e de custo |
| `batidas` | Batida | Cadastro de produção; a execução real é `producao-batelada` |
| `lote-animais` | Lote de animais | Montar lote é organização de rebanho, não evento de campo |
| `estacao-monta` | Estação de monta | Planejamento sazonal (nome, datas, método) |
| `material-reprodutivo` | Touros / sêmen / embrião | Estoque de material genético — cadastro de insumo |
| `protocolos-estacao` | Protocolos / estação | Configuração de regra reprodutiva |

**Sobem para decisão ADM (2).** Mesmo tratamento de `OrdemPendente` já implementado em
`confinamento/models.dart`: o ADM cria a ordem no web, o Operacional apenas confirma a execução.

| id | Título | Por quê |
|---|---|---|
| `vendas` | Vendas | Cliente, valor e condição de pagamento — decisão comercial. Em Confinamento, "Vender Animais" **já é** exclusiva do ADM; o catálogo geral ainda contradiz isso |
| `compras-animais` | Compra de animais | Fornecedor, valor total e documento fiscal — decisão financeira |

**Sai do escopo (1).** `colheita-frutas` — não é prioridade nesta fase.

**Testes a atualizar** (os números são congelados de propósito, para que mudança de escopo seja
sempre deliberada):
- `test/modules/fazendas/functional_catalog_test.dart` — totais por perfil e por maturidade
- `test/modules/fazendas/screens/mapped_feature_wave_d_test.dart` — contagem de features `ready`

---

## Onda 2 — Apontamento alinhado ao desktop

O Apontamento é hoje o maior desalinhamento entre app e sistema: o desktop tem identificação +
classificação agronômica + 5 abas de itens + 13 parâmetros de classificação de qualidade + ciclo de
status com trilha de auditoria. O app tem 11 campos planos, **três deles inexistentes no desktop**
(vieram da tabela `service_orders`, não de Apontamento), e nenhum ciclo de status.

**Recorte acordado:** o app fica com **4 abas** — MO/Serviços, Máq/Implementos, Insumos e
Ocorrências. Produção e os 13 parâmetros de qualidade (PH, avariados, umidade, quebra técnica…)
exigem balança e classificador: permanecem exclusivos do desktop.

### Campos

| Ação | Campo | Observação |
|---|---|---|
| ➖ Remover | `prazo`, `resultado-esperado`, `criterio-sucesso` | Vieram de `service_orders`; não existem no Apontamento real |
| ➕ Adicionar | `data-apontamento` | Data, obrigatória, padrão hoje |
| ➕ Adicionar | `descricao` | Texto longo, opcional — "Descrição/Histórico" no desktop |
| ➕ Adicionar | `cultura-variedade` | Seleção, opcional |
| ➕ Adicionar | `safra` | Seleção, opcional |
| ✏️ Ajustar | `responsavel` | Auto do usuário logado e somente leitura (hoje é select manual) |
| ✏️ Ajustar | `area-total` | Herdado da área selecionada e somente leitura (hoje é numérico editável) |
| ✏️ Ajustar | `sections` | Remover `Abastecimentos` (não existe no desktop) e `Produção` (fica no desktop) |

### Ciclo de status — é a mesma fronteira

O ciclo do desktop mapeia exatamente na divisão de perfil que o Confinamento já implementa:

| Status | Quem age | No app |
|---|---|---|
| **Aberto** | Operacional | Cria e edita livremente em campo |
| **Finalizado** | Operacional | Encerra o lançamento; edição direta bloqueada |
| **Apropriado** | ADM | Joga o custo no custeio — **decisão de custo**, só leitura no painel ADM |

Não é uma regra inventada para o app: é como o sistema web já funciona.

---

## Onda 3 — Resolver as duplicações

Para os três pares confirmados, **não excluir a tela antiga de imediato** — quem já usa o caminho
antigo perderia o acesso. Manter `carga`, `descarga` e `nota-cocho` como redirecionamento para a
tela nova equivalente, e retirar do catálogo só depois que o uso migrar.

**`nutricoes` (Arraçoamento) fica como está — decidido, não é duplicação.** Nem toda fazenda tem o
confinamento como atividade principal: com gado a pasto, Nutrições é o registro de alimentação que
faz sentido, e `trato-diario` é que seria inaplicável. Os dois convivem, cada um no seu regime de
criação. Não mexer.

**`configuracoes-misturador` fica como está — decidido, segue operacional com criação.** É
parâmetro da própria máquina (tolerância de pesagem, unidade padrão, alerta sonoro), não decisão
técnica ou de custo como uma dieta: quem opera o misturador é quem percebe que a tolerância está
apertada demais e ajusta na hora. Não mexer.

---

## Onda 4 — Usabilidade de navegação

1. **Confinamento como primeiro card do grid.** Hoje ele é o último por acidente: a ordem dos
   grupos vem de `groups.putIfAbsent` em `screens/responsibility_workspace.dart`, que preserva a
   ordem de inserção do array do catálogo. Corrigir exige ordenação explícita, não apenas mover o
   bloco no arquivo. A própria especificação de Confinamento aponta o Mapa/Trato como "a tela de uso
   diário mais frequente da equipe de campo".
2. **Consolidar um grupo "Consultas" no operacional.** Depois da Onda 1, Estoque, Cadastros e parte
   de Reprodução ficam com um item cada. Juntar tudo que virou visualização num único grupo — o
   perfil administrativo já tem "Consultas e auditoria" como precedente.
3. **Levar contexto nas ações rápidas.** Em `operacional/meus_currais_screen.dart`, os botões
   Pesagem / Sanitário / Óbito navegam para os fluxos genéricos de Pecuária sem passar o curral
   selecionado — o operador escolhe tudo de novo. Passar o contexto pré-selecionado.

---

## Critério de aceite por onda

Cada onda só fecha com:

- `npm run lint` — `flutter analyze --fatal-infos` sem apontamentos;
- `npm run quality:functional` — gates de arquitetura, tokens, catálogo e política de acesso;
- `npm test` — suíte completa;
- um commit Conventional Commit próprio (Lei 4 do `CLAUDE.md`), sem push automático.

## Limites honestos

- A divisão de perfil vive no frontend (catálogo + `router/app_router.dart`). **Ocultar menu não é
  RBAC** — a autorização real precisa existir no backend, por ação e por fazenda.
- O plano de Fases/Regras de Troca do Confinamento não tem tabela correspondente no dump mapeado;
  segue como premissa de protótipo até alinhamento com o time web.
- A classificação de qualidade do grão (13 parâmetros) foi deliberadamente deixada fora do app —
  se o negócio exigir captura em campo no futuro, é uma decisão nova, não um esquecimento.
