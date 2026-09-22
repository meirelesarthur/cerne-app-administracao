# GB CERNE — Site Map de Funcionalidades

Mapa completo do protótipo navegável (estado pós-esteira de navegabilidade, Fases A–E do
`PLANO-NAVEGABILIDADE.md`). Foco no módulo **Fazendas** (o Cerne do app), com os demais mapeados.

**Legenda:** `[rota]` tela real com URL · `[sheet]` BottomSheet (overlay, sem rota) · `[menu]`
RevealMenu · `[placeholder]` honesto/rotulado por recorte · `⚖` regra de negócio na UI.

---

## Shell do Superapp — `/:moduleId/*`

Camada persistente: header global (saudação + notificações), Barra de Módulos, Bottom Tab Bar
genérica e RevealMenu. Raiz `/` → redirect `/inicio`.

```
/login          [rota]  entrada mock · "Conhecer o app" → onboarding
/onboarding     [rota]  voltar → login · "Começar" → /fazendas
/notificacoes   [rota]  cada item deep-linka ao módulo de origem
/perfil         [rota]  configurações · tema GB Mode · sair → login
RevealMenu      [menu]  seções contextuais do módulo ativo (menuSections)
                        + Conta (notificações, config, GB Mode, sair)
DevToolbar              botão flutuante dev: alterna offline e tema
```

---

## 🌱 Fazendas — `/fazendas` (CERNE DO APP)

Gestão agro multi-tenant com **duas visões**: Gerencial (leitura) e Campo (lançamentos).

### Acesso por responsabilidade
```
/login                         [rota]  Login Administração → /fazendas/administracao
                                      Login Operacional → /fazendas/operacional
/fazendas/administracao       [rota]  12 funções de gestão, consulta e auditoria
/fazendas/administracao/:id   [rota]  detalhe mapeado administrativo
/fazendas/operacional         [rota]  41 funções de entrada e campo
/fazendas/operacional/:id     [rota]  formulário/estado mapeado operacional
⚖ rotas dashboards            somente Administração
⚖ rotas campo/sync            somente Operacional
```

### Contexto do módulo (header)
```
Farm Switcher                [sheet]  troca a fazenda ativa (tenant)
"Lançando em: {fazenda}"     ⚖        badge fixo em toda tela operacional (mitigação IDOR)
Perfil Administração/Operação [shell] definido no login e protegido nas rotas do módulo
Banner crédito pré-aprovado           deep-link → /credito
```

### Home — `/fazendas` [rota]
```
Visão Gerencial   atalhos p/ dashboards · 2 cards de indicadores c/ sparkline
                  atividades recentes → Detalhe de Atividade [sheet]
Visão Campo       grid bento com os 6 lançamentos + card da fila de sync
```

### Abas
```
/fazendas/fazendas     [rota]  lista das fazendas do usuário
/fazendas/atividades   [rota]  histórico completo · Detalhe de Atividade [sheet]
/fazendas/financeiro   [rota]  atalho ao dashboard Financeiro
/fazendas/mais         [rota]  hub de links
/fazendas/mais/sync    [rota]  fila de sincronização: pendências c/ status,
                               banner offline, "Sincronizar agora"
```

### Visão Gerencial — 7 dashboards `/fazendas/dashboards/:dashId`
```
financeiro    [rota]  KPIs + despesas por centro de custo
                      (nota de fragilidade do legado: grouper_id=7, comentada no mock)
pecuaria      [rota]  ⚖ bloco produtivo/reprodutivo DESATIVADO c/ cadeado
                      (LACUNA no legado — não simular dado) · atividades [sheet]
confinamento  [rota]  grid de currais por ocupação · detalhe do curral [sheet]
ativos        [rota]  equipamentos · detalhe c/ depreciação acumulada [sheet]
suprimentos   [rota]  cotações filtráveis · ⚖ selo "Dados de exemplo"
                      · detalhe da cotação c/ mini-histórico [sheet]
uso           [rota]  multi-tenant · "Acesso restrito" · ⚖ indisponível offline
consultas     [rota]  ⚖ 100% read-only: lotes, estoque, pesagens
                      · localização: esquema ilustrativo dos lotes (mock, sem GPS)
```

### Visão Campo — 6 fluxos `/fazendas/campo/:flowId`
Todos com FlowShell (contexto + rodapé fixo) e tela de sucesso com efeitos no sistema web.
```
pesagem       [rota]  input manual grande (balança fica p/ nativo)
                      · ⚖ registra a "pesagem do dia"
ciclo         [rota]  form dinâmico: nascimento · desmame · transferência · morte
                      · ⚖ TRANSFERÊNCIA EXIGE PESAGEM DO DIA (bloqueio funcional real)
arracoamento  [rota]  lote → dieta → quantidade → depósito
                      · ⚖ sem tela de rateio (LACUNA documentada)
venda         [rota]  ⚖ mês congelado bloqueia edição (cadeado + tooltip)
                      · ⚖ contagem e total > 0 validados
recebimento   [rota]  upload XML NF-e + conferência item a item
insumos       [rota]  talhão, data, tipo (validação mínima, fiel ao legado)
```

### Estados transversais (offline-first simulado)
```
⚖ lançamento offline → fila → SyncBanner c/ contagem → "Sincronizar" → fila limpa
⚖ por tela: loading (skeleton) · vazio (EmptyState) · offline (banner+timestamp) · erro (retry)
```

---

## 🏠 Início (Hub) — `/inicio`

Porta de entrada; agrega mini-apps com o GB Bank no centro. Leitura — transações no Bank.
```
/inicio           [rota]  saldo (toggle privacidade) · ações rápidas → Bank
                          · banner crédito → /credito · "Seus apps"
                          · movimentações → comprovante [sheet]
/inicio/apps      [rota]  catálogo completo (disponíveis + "Em breve" desabilitados)
/inicio/carteira  [rota]  resumo Banking (leitura) + CTA "Abrir GB Bank"
```

## 🏦 Bank — `/bank`
```
/bank             [rota]  saldo · ações rápidas · card "Meu cartão" → /bank/cartoes
                          · movimentações [sheet]
/bank/extrato     [rota]  filtros · comprovante [sheet]
/bank/pagamentos  [rota]  hub: Pix · Pagar boleto · Transferir · Cobrar
/bank/pix         [rota]  fluxo completo: chave/contato → valor → revisão → sucesso
/bank/cartoes     [rota]  cartão visual · limite · bloqueio (toggle)
                          · 2ª via / ajustar limite [placeholder]
/bank/limites     [rota]  faixas de limite com uso/teto
/bank/ajuda       [placeholder]
```

## 💰 Crédito — `/credito`
```
/credito               [rota]  simulador funcional (valor × prazo)
                               · linhas → detalhe [sheet] + CTA "Simular esta linha"
/credito/simular       [rota]  Home com scroll automático ao simulador
/credito/propostas     [rota]  lista → detalhe
/credito/proposta/:id  [rota]  timeline de status (enviada → análise → aprovada/recusada)
                               · documentos · CTA contextual por status
/credito/contratos     [rota]  parcelas pagas/total · resumo [sheet]
/credito/ajuda         [rota]  FAQ + "Fale com seu gerente"
```

## 🛒 Marketplace — `/marketplace`
```
/marketplace              [rota]  busca + filtro por categoria + grid
/marketplace/produto/:id  [rota]  PDP: preço, vendedor, specs, "Adicionar ao pedido"
/marketplace/categorias   [rota]  grade → Home já filtrada
/marketplace/pedidos      [rota]  status por pedido · itens [sheet]
/marketplace/favoritos    [rota]
/marketplace/ajuda        [placeholder]
```

## 🏗 Armazém — `/armazem`
```
/armazem                [rota]  KPIs, alertas · unidades [sheet] · movimentações [sheet]
                                · deep-link → /marketplace
/armazem/estoque        [rota]  itens c/ ocupação · filtro por unidade (?unidade=)
/armazem/movimentacoes  [rota]  entradas/saídas · detalhe (nota, responsável, veículo) [sheet]
/armazem/unidades       [rota]  capacidade/ocupação · CTA "Ver estoque da unidade"
/armazem/relatorios     [rota]  relatórios disponíveis (mock)
```

---

## Deep-links entre módulos
```
Hub / Fazendas / Bank  →  Crédito      (banner "crédito pré-aprovado")
Hub                    →  Bank         (ações rápidas, extrato, carteira)
Armazém                →  Marketplace  (reposição de insumos)
Notificações (Shell)   →  módulo de origem de cada aviso
```

---

> **Escopo:** protótipo frontend de alta fidelidade — dados mockados, sem backend.
> Fiscal, RBAC, hardware de balança e sincronização real são decisões do MVP (backlog técnico).
> Placeholders remanescentes são honestos e rotulados: `/bank/ajuda`, `/marketplace/ajuda`,
> mapa de localização (Consultas) e 2ª via/ajustar limite (Cartões).
