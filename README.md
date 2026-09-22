# GB CERNE — Superapp (protótipo frontend)

Protótipo navegável de alta fidelidade do **superapp corporativo GB CERNE**, com foco no módulo
**Fazendas** (ex-"Cerne"/agro365). Somente frontend, dados mockados, sem backend — feito para validar
fluxo e servir de handoff ao time mobile. Baseado em `spec-cerne-app.md`.

## Stack

- **Flutter 3.44.6 + Dart 3** em `apps/mobile`
- **Riverpod** (estado) · **go_router** (roteamento protegido em dois níveis)
- **Outfit** self-hosted · **Hugeicons 1.2** · gráficos próprios tokenizados
- **Widgetbook** publicado junto com o app em `/storybook/`
- **Cloudflare Workers Static Assets** com fallbacks separados para app e Widgetbook

Flutter é o único runtime do repositório. O último estado React está preservado somente na tag Git
`react-rollback-final-2026-08-17`.

## Como rodar

```bash
npm install
npm run dev            # Flutter Web no Chrome
npm run lint           # flutter analyze --fatal-infos
npm test               # suíte Flutter
npm run quality:functional # gate de arquitetura, acesso e 57 funções
npm run build          # app + Widgetbook em apps/mobile/build/site
npm run smoke:deploy   # valida rotas e fallbacks Cloudflare
npm run tokens:export  # regenera tokens/tokens.json (DTCG) a partir de design/tokens.ts
```

A configuração completa do Worker está em `docs/DEPLOY-FLUTTER-CLOUDFLARE.md`. O último runtime
React existe somente na tag Git `react-rollback-final-2026-08-17`.

## Arquitetura

Roteamento em dois níveis: `/:moduleId/*` → o **Shell** Flutter escolhe o módulo e injeta seu bottom
tab bar; cada módulo tem suas rotas internas e as famílias administrativas/operacionais respeitam a
sessão demonstrativa.

```
apps/mobile/lib/
  design/generated/       # Dart gerado do DTCG; nunca editado manualmente
  design/theme/           # temas Light e GB Mode
  ui/                     # catálogo component-first e casos do Widgetbook
  router/                 # go_router + política de acesso
  shell/                  # shell global e sessão demonstrativa
  modules/
    fazendas/             # 14 funções administrativas + 43 operacionais
    hub|bank|credito|marketplace|armazem/
```

### Design system (Leis do projeto)

- **Lei 1** — controles visíveis passam pelo catálogo `apps/mobile/lib/ui`.
- **Lei 2** — widgets compartilhados são fonte única; telas não reimplementam componentes.
- **Lei 3** — todo valor visual vem do tema ou dos arquivos Dart gerados; fonte Outfit apenas.
- **Lei 5** — `tokens.ts` → `tokens.json` W3C DTCG → Dart gerado, verificado por `tokens:verify`.

## Módulo Fazendas

- **Dois ambientes protegidos por perfil**: Administração (leitura/decisão) e Operacional (entrada/campo).
- **Farm switcher** (multi-tenant) no header do módulo; badge "Lançando em: {fazenda}" nos formulários.
- **14 funções administrativas** e **43 operacionais** cobertas pelo catálogo normalizado, com
  50 jornadas frontend prontas e 7 integrações de hardware funcionalmente simuladas.

### Regras de negócio refletidas na UI (§7.2)

- Bloco produtivo/reprodutivo do Dashboard Pecuária **sempre desativado** (cadeado).
- Transferência de lote **exige pesagem do dia** — bloqueio funcional real (versão correta, sem o bug do legado).
- Venda de animais: **mês congelado bloqueia edição** (cadeado + tooltip); total > 0 e contagem devem bater.
- Consultas Gerenciais **100% read-only**; localização de animais como placeholder de mapa.
- Dados PARCIAL/LACUNA marcados com selo "Dados de exemplo" ou bloco "Indisponível".

## Checklist de aceite (spec §9)

- [x] Shell funcional: Barra de Módulos troca header, conteúdo e bottom tab bar dos 5 módulos.
- [x] Cores/spacing/radius/shadow vêm de tokens; sem valores hardcoded nas telas Flutter.
- [x] Módulo Fazendas: duas visões (Gerencial/Campo) via switch, com farm switcher (mock).
- [x] 7 telas administrativas + fluxos operacionais implementados com mock, dentro do módulo Fazendas.
- [x] Bank/Crédito/Marketplace/Armazém navegáveis como cascas, cada um com seu bottom tab bar.
- [x] Itens PARCIAL/LACUNA com selo/placeholder, sem dado fictício "real".
- [x] Trava de pesagem do dia bloqueando transferência funciona no protótipo.
- [x] Banner de offline/sync demonstrável via toggle de dev, restrito ao módulo Fazendas.
- [x] Tema light 100% funcional; GB Mode com cores base aplicadas.
- [x] Estado demonstrativo em memória por Riverpod, sem backend ou autenticação real.
- [x] Estrutura Flutter `shell/` + `modules/<nome>/` como pipeline mobile oficial.
- [x] Sessão demonstrativa obrigatória, logout efetivo e redirecionamento de rotas internas para o login.
- [x] Gate automatizado garantindo 14 funções administrativas, 43 operacionais, IDs únicos,
  zero itens apenas `Mapeado` e simulação presente em toda dependência de hardware.
- [x] Controles primários e secundários do design system com alvo mínimo de toque de 44 px,
  foco visível, rótulos acessíveis e ausência de rolagem horizontal em 390 px.
- [x] Nenhuma tela ou componente de módulo usa controles interativos proibidos diretamente;
  superfícies customizadas passam pelo `AppPressable` do catálogo UI.
- [x] Cores dos widgets Dart vêm dos tokens, Outfit permanece como fonte única e o gate
  rejeita novas cores literais ou famílias tipográficas não autorizadas.

## Limites do protótipo

- Autenticação, RBAC, APIs e persistência continuam simulados no frontend.
- Bluetooth, RFID, câmera, localização e balança possuem jornadas demonstrativas; integração nativa
  real continua fora do escopo do protótipo web.
- O Widgetbook é o catálogo oficial de componentes Flutter e faz parte do mesmo build Cloudflare.
