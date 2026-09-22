<p align="center">
  <img src="apps/mobile/assets/images/Logo.svg" alt="GB CERNE" width="240" />
</p>

# GB CERNE ADM

Superapp administrativo do **GB CERNE**: gestão das fazendas, banco, crédito e marketplace num só
lugar. Protótipo frontend navegável (Flutter Web), dados simulados, sem backend.

## Stack

Flutter 3.44.6 + Dart 3 · Riverpod · go_router · Widgetbook · Cloudflare Workers Static Assets.

## Funcionalidades e fluxos

Login único (sem seleção de perfil) leva à Home (hub), com acesso pelo dock a **Fazendas · Bank ·
Crédito · Marketplace · Armazém**.

### Fazendas — administração

Três abas: **Gestão**, **Consultas** e **Ordens de Serviço**.

- **Gestão** (painéis de decisão) — Resultado (receita/custo/margem consolidados), Rebanho e
  confinamento (ocupação, GMD, alertas de curral), Suprimentos (cotações), Ativos e depreciação,
  Adoção e governança (uso e auditoria).
- **Consultas e auditoria** — 100% leitura: consultas gerenciais, saldo de estoque, produtos, áreas
  cadastradas, lotes/reprodução, processamentos pecuários, compra de animais, vendas, e exportação
  de logs de estoque/pecuária (CSV/JSON).
- **Ordens de Serviço** — consulta das OS e dos apontamentos agrícolas lançados pelo Operacional,
  com ações de avaliar/cancelar enquanto a OS segue em aberto.

### Bank

Extrato, pagamentos (Pix incluso), cartões e limites.

### Crédito

Propostas em andamento, simulação de novas propostas e contratos.

### Marketplace

Categorias, pedidos e favoritos.

### Armazém

Estoque, movimentações, unidades e relatórios.

## Como rodar

```bash
npm install
npm run dev                # Flutter Web no Chrome
npm run lint               # flutter analyze --fatal-infos
npm test                   # suíte Flutter completa
npm run quality:functional # gates de arquitetura, acesso e catálogo funcional
npm run build              # app + Widgetbook em apps/mobile/build/site
npm run smoke:deploy       # rotas e fallbacks do Worker Cloudflare
```

## Limites do protótipo

Frontend puro: autenticação, RBAC, APIs e persistência são simulados. Os cadastros de campo (perfil
Operacional) vivem no app irmão `cerne-app-operacao` — consultas aqui que dependem deles (Ordens de
Serviço, Apontamentos, Áreas) abrem vazias ou com dado demonstrativo até o backend ligar as duas
pontas.
