# Memória de continuidade — extinção do React e corte definitivo para Flutter

> Documento operacional para retomada entre sessões. Leia este arquivo antes de alterar o projeto e atualize-o no mesmo commit de cada onda concluída.

## Objetivo imutável

Transformar o Flutter em `apps/mobile` na única implementação oficial do GB CERNE, portar para Dart toda a cobertura funcional hoje mais recente no React, publicar app + Widgetbook pela mesma pipeline e remover o runtime React somente depois do gate de paridade.

O escopo continua sendo um protótipo exclusivamente frontend, com mocks e simulações. Autenticação real, RBAC de backend, APIs e integrações nativas de hardware não devem ser apresentados como concluídos.

## Checkpoint atual — 17/08/2026

- Branch de execução da M13: `feature/flutter-migration`; destino definitivo: `main`, com remoção local e remota da branch após o merge solicitado pelo usuário.
- Baseline antes da criação desta memória: `960fe545b73e7092587a30b746db3ed495c47acd`.
- A branch local estava sincronizada com `origin/feature/flutter-migration` nesse baseline.
- O usuário autorizou o corte M13 após o preview Flutter aprovado tecnicamente; Flutter passa a ser o único runtime, build de apresentação e pipeline do repositório.
- M0 a M12 e a correção do deploy foram enviadas ao remoto em `feature/flutter-migration` até `2a7ce8a`.
- O Cloudflare Workers Builds executou o build `a9cf4b64-c290-4643-a6f7-9aaabc066465` para `1b990ef`: app, Widgetbook, smoke e upload de 76 assets passaram, mas `wrangler versions upload` foi rejeitado porque `apps/mobile/web/_redirects` gerou duas regras SPA em loop. O check GitHub `95336869663` permaneceu incorretamente `in_progress`; o log autenticado fornecido pelo usuário registra a falha às 09:06:31Z.
- A correção remove o `_redirects` legado de Pages e o smoke agora bloqueia sua reintrodução na raiz e em `/storybook`. O build limpo, o smoke de seis rotas e `wrangler versions upload --dry-run` passaram localmente.
- A correção `2a7ce8a` gerou com sucesso o Workers Build `3c3da585-ed9d-4720-833a-ce5433fc6a39`: versão `8dff1703-6d97-41f2-8f35-94e107f9d8c7`, preview `https://8dff1703-cerne-app-operacao.meireles-arthur.workers.dev` e alias da branch `https://feature-flutter-migration-cerne-app-operacao.meireles-arthur.workers.dev`. O smoke HTTP real confirmou `200` e base correta nas seis rotas, com fallbacks `app` e `widgetbook` separados. O check GitHub `95371514147` permaneceu incorretamente `in_progress`, embora o log termine em `Success: Build completed`.
- A tag anotada `react-rollback-final-2026-08-17` preserva o último estado completo com React no commit `5879bbf`, imediatamente anterior às remoções da M13.
- A M13 removeu `src`, entrypoints, assets duplicados, Vite, Tailwind, Zustand, React Router e todas as dependências React. O tooling TypeScript restante existe apenas para tokens DTCG/Dart, build e Cloudflare.
- O Flutter agora exige sessão demonstrativa, oferece Login Administração/Login Operacional e protege rotas cruzadas por perfil.
- A correção temporária do deploy React foi enviada no commit `0489a2e`: `wrangler.jsonc` publica `dist` como SPA no Cloudflare Worker.
- `AGENTS.md` aparece como arquivo não rastreado e pertence ao usuário: não adicionar, editar ou remover sem autorização explícita.
- `RTK.md`, embora referenciado nas instruções do projeto, não foi encontrado no repositório neste checkpoint.

## Verdade técnica atual

### Flutter existente

- Aplicativo em `apps/mobile/lib`, iniciado por `apps/mobile/lib/main.dart`.
- Seis módulos: Início, Fazendas, Bank, Crédito, Marketplace e Armazém.
- Estado com Riverpod, rotas com `go_router`, tema/tokenização e fonte Outfit local.
- Catálogo Flutter e Widgetbook em `apps/mobile/lib/widgetbook_app.dart`.
- Build combinado oficial disponível por `npm run build` (com wrapper de compatibilidade em `apps/mobile/tool/cf_pages_build.sh`), gerando:
  - aplicativo em `build/site`;
  - Widgetbook em `build/site/storybook`.
- A migração Flutter contém as mudanças de perfil, as ondas funcionais A–H e os respectivos gates arquiteturais.

### Rollback React preservado por tag

- O runtime React não existe mais na árvore oficial após a M13.
- O último estado completo pode ser consultado ou restaurado exclusivamente pela tag `react-rollback-final-2026-08-17` (`5879bbf`).
- A separação Administração/Operacional, os dois logins e as ondas A–H estão integralmente portados para Flutter.
- O catálogo funcional canônico atual é `apps/mobile/lib/modules/fazendas/functional_catalog.dart`.
- Cobertura atual verificada no Flutter:
  - 53 funcionalidades;
  - 12 administrativas;
  - 41 operacionais;
  - 46 com jornada frontend pronta;
  - 7 com simulação funcional de hardware;
  - zero item apenas `Mapeado`.

### Commits React que formam a referência de portabilidade

| Entrega | Commit |
|---|---|
| Separação Administração/Operacional | `8cbadb1` |
| Onda A | `874705e` |
| Onda B | `da62f91` |
| Onda C | `22c87d6` |
| Onda D | `047d72a` |
| Onda E | `888fd21` |
| Onda F | `fa73647` |
| Onda G | `5017912` |
| Onda H | `960fe54` |

Esses commits são especificação de comportamento, não código a ser reutilizado diretamente. A implementação Flutter deve ser Dart nativo, component-first e aderente aos tokens.

## Regras de execução

1. Flutter é o único runtime oficial; React existe apenas na tag de rollback.
2. Não reintroduzir runtime, dependências ou configuração de build React na árvore principal.
3. Criar o widget reutilizável em `apps/mobile/lib/ui` antes da tela que o consome.
4. Estado compartilhado ou de sessão deve usar Riverpod; não criar globais ou `setState` para estado de domínio.
5. Usar `LayoutBuilder`/constraints quando o layout precisar se adaptar.
6. Interações devem ter `Semantics`, foco e alvo de toque mínimo de 44dp.
7. Fonte Outfit e valores gerados dos tokens continuam obrigatórios; não aceitar cores, fontes, espaços ou raios literais nas telas.
8. Cada onda concluída recebe seu próprio commit Conventional Commit imediatamente.
9. Atualizar este arquivo no mesmo commit da onda, marcando o checkbox e registrando hash, testes e pendências.
10. Push somente mediante solicitação explícita do usuário.

## Esteira de migração

### M0 — Congelamento e contrato de paridade

- [x] Marcar o React como referência congelada na documentação.
- [x] Criar matriz verificável das 53 funcionalidades React → Flutter.
- [x] Registrar rota, perfil, maturidade e destino de cada item; campos, validações e dependências permanecem vinculados por ID ao catálogo React congelado até a porta Dart de M1.
- [x] Registrar as jornadas críticas que serão usadas no aceite visual.

Gate: não existe item do Markdown sem uma linha de rastreabilidade.

Commit planejado: `docs(mobile): formaliza matriz de paridade para extincao do React`.

### M1 — Catálogo funcional em Dart

- [x] Criar o contrato Dart equivalente ao `functionalCatalog.ts`.
- [x] Portar as 12 funcionalidades administrativas e 41 operacionais.
- [x] Representar campos, grupos, opções, obrigatoriedade, tipo de entrada, status e dependências.
- [x] Criar gate/teste que valide 53 itens, divisão 12/41, IDs únicos, zero `Mapped` e sete itens de hardware simulável.

Gate: o catálogo Dart passa a ser a fonte funcional do app Flutter.

Commit planejado: `feat(mobile): porta catalogo funcional AGRO365 para Dart`.

### M2 — Motor de jornadas e componentes

- [x] Criar motor reutilizável para lista → formulário → validação → sucesso, com rascunho de detalhe consumido pelo armazenamento; a composição visual da tela entra em M3.
- [x] Criar armazenamento de registros de protótipo com Riverpod.
- [x] Criar equivalentes Flutter de grupos adicionáveis, superfície pressionável, preparação de exportação de auditoria e simulador de hardware.
- [x] Publicar componentes e variantes no Widgetbook antes de usá-los em telas.

Gate: uma funcionalidade dirigida pelo catálogo completa a jornada inteira e possui testes.

Commit planejado: `feat(mobile): cria motor funcional reutilizavel AGRO365`.

### M3 — Separação de responsabilidades

- [x] Criar botões Login Administração e Login Operacional no Flutter.
- [x] Persistir o perfil da sessão demonstrativa em Riverpod.
- [x] Proteger o shell e deep links sem sessão.
- [x] Criar central de gestão e central de rotinas.
- [x] Restringir rotas, abas, menus e ações por perfil.
- [x] Remover do Flutter a alternância local Gerencial/Campo; o perfil define a responsabilidade durante a sessão.

Gate: operador não acessa dashboards; administrador não cria entradas; logout invalida a sessão.

Commit planejado: `feat(mobile): separa ambientes administrativo e operacional`.

### M4 — Onda A Flutter

- [x] Áreas.
- [x] Formulações.
- [x] Batidas.
- [x] Apontamento agrícola.
- [x] Abastecimento e Manutenção de Frota.

Gate: lista, criação, validação, sucesso e consulta compartilham os mesmos registros em memória.

Commit planejado: `feat(mobile): conclui onda A funcional AGRO365`.

### M5 — Onda B Flutter

- [x] Rebanho Inicial, Lotes e Animais.
- [x] Transferência Lote/Área, Sanitário, Desmama e Pastagens.
- [x] Estação de Monta, Lotes/Reprodução, Material Reprodutivo, Protocolos, Monta Natural e Diagnóstico de Gestação.

Gate: todas as jornadas possuem validação explícita e premissas de domínio sinalizadas.

Commit planejado: `feat(mobile): conclui onda B de pecuaria e reproducao`.

### M6 — Onda C Flutter

- [x] Descoberta e conexão Bluetooth simuladas.
- [x] Balança e captura de peso simuladas.
- [x] RFID e alternativa manual.
- [x] Scanner SISBOV.
- [x] Transferência de animal, Localização e Perdas.

Gate: os sete itens têm simulação navegável e permanecem identificados como dependentes de hardware real.

Commit planejado: `feat(mobile): conclui onda C de simulacoes de hardware`.

### M7 — Onda D Flutter

- [x] Saldo de Estoque e Processamentos Pecuários.
- [x] Logs e exportação local de auditoria.
- [x] Carga, Descarga, Nota de Cocho e Configurações do Misturador.
- [x] Marcação agrícola.
- [x] Compra de Animais, Apartação e Minhas OS.

Gate: 46 itens `Ready`, sete `Hardware` simulados e nenhum item apenas mapeado.

Commit planejado: `feat(mobile): conclui onda D de cobertura funcional`.

### M8 — Onda E Flutter

- [x] Sessão demonstrativa obrigatória.
- [x] Logout efetivo.
- [x] Proteção de deep links e rotas cruzadas.
- [x] Gate funcional incorporado ao CI Flutter.

Gate: tentativa de acesso direto sem sessão retorna ao login correto.

Commit planejado: `fix(mobile): conclui onda E de endurecimento frontend`.

### M9 — Onda F Flutter

- [x] Alvos de toque mínimos de 44dp.
- [x] `Semantics` e rótulos contextuais.
- [x] Foco/teclado na web.
- [x] Auditoria em 390×844 e layouts adaptativos sem overflow.

Gate: testes de semântica e inspeção das jornadas críticas aprovados.

Commit planejado: `fix(mobile): conclui onda F de acessibilidade`.

### M10 — Onda G Flutter

- [x] Auditar component-first em todas as telas novas.
- [x] Bloquear controles visíveis reimplementados fora de `lib/ui` quando houver equivalente no catálogo.
- [x] Garantir que todos os novos componentes apareçam no Widgetbook.

Gate: zero duplicação local de widgets do design system.

Commit planejado: `refactor(mobile): conclui onda G component first`.

### M11 — Onda H Flutter

- [x] Auditar cores, tipografia, espaçamento, raio, sombra e movimento.
- [x] Sincronizar `tokens.ts` → DTCG → Dart gerado quando necessário.
- [x] Criar/verificar guardrails contra hardcode visual.

Gate: tokens DTCG e arquivos Dart gerados não divergem.

Commit planejado: `refactor(mobile): conclui onda H de integridade de tokens`.

### M12 — Pipeline oficial e corte Cloudflare

- [x] Fixar Flutter `3.44.6` no CI e no build Cloudflare.
- [x] Fazer o CI compilar o app e o entrypoint real do Widgetbook.
- [x] Gerar exclusivamente `apps/mobile/build/site`.
- [x] Configurar Cloudflare Worker Static Assets de acordo com o produto real do dashboard.
- [x] Adicionar Wrangler fixado e fallback separado para `/storybook/*` e para o app.
- [x] Executar smoke tests em `/`, `/login`, deep links dos dois perfis e `/storybook/`.
- [x] Aprovar preview Flutter antes de trocar o ambiente público.

Gate aprovado: o preview público entregou Flutter e Widgetbook em seis rotas reais, e o usuário autorizou explicitamente o corte M13 e a promoção para `main`.

Commit planejado: `ci: torna Flutter a unica pipeline oficial`.

### M13 — Extinção do React

- [x] Criar tag de rollback do último estado React.
- [x] Remover componentes, módulos, shell, imagens duplicadas e entrypoints React.
- [x] Remover Vite, Tailwind, Zustand, react-router e dependências React.
- [x] Remover `dist` e configurações exclusivas do aplicativo React.
- [x] Manter somente o tooling TypeScript neutro necessário a tokens, build e Cloudflare.
- [x] Atualizar README, arquitetura, comandos e instruções para refletirem Flutter.
- [x] Confirmar por busca e pela árvore Git que não existe runtime React restante.

Gate final: Flutter é o único aplicativo, o único build de apresentação e a única pipeline de deploy.

Commit planejado: `refactor: remove aplicacao React apos corte Flutter`.

## Gates obrigatórios antes de M13

- [x] 53/53 funcionalidades presentes no catálogo Dart.
- [x] 12 administrativas e 41 operacionais verificadas por teste.
- [x] Login e rotas protegidas nos dois perfis.
- [x] Ondas A–H portadas e commitadas separadamente.
- [x] `dart format` limpo.
- [x] `flutter analyze --fatal-infos` verde.
- [x] `flutter test` verde.
- [x] App Flutter Web compilado.
- [x] Widgetbook compilado pelo entrypoint `lib/widgetbook_app.dart`.
- [x] Paridade light/GB Mode coberta por goldens, regressão e aceite explícito do corte M13 pelo usuário.
- [x] Preview Cloudflare Flutter aprovado tecnicamente em seis rotas públicas; o usuário autorizou a promoção.
- [x] Rollback React etiquetado e identificável no Git como `react-rollback-final-2026-08-17` (`5879bbf`).

## Protocolo de retomada para uma nova sessão

1. Ler `AGENTS.md`, este arquivo, `PLANO-MIGRACAO-FLUTTER.md` e `docs/ESTEIRA-PERFIS-AGRO365.md`.
2. Executar `git status --short --branch` e preservar qualquer alteração do usuário.
3. Executar `git log --oneline -20` e localizar o último commit registrado nesta memória.
4. Identificar a primeira etapa M0–M13 ainda não marcada.
5. Inspecionar o commit React de referência da onda antes de escrever o equivalente Dart.
6. Implementar somente uma unidade lógica por vez.
7. Rodar os testes proporcionais à onda e depois os gates Flutter completos antes de fechá-la.
8. Atualizar os checkboxes, registrar o hash e os testes executados neste documento.
9. Criar o commit imediatamente; não fazer push sem pedido explícito.

## Registro de execução

| Etapa | Estado | Commit Flutter | Verificações | Observações |
|---|---|---|---|---|
| Memória inicial | Concluída | preencher pelo histórico Git | Arquivo criado; nenhuma implementação iniciada | React permanece oficial por ora |
| M0 | Concluída | `8e03fad` | Matriz 53/53; contagem 12/41 conferida | React congelado como referência; nenhuma tela alterada |
| M1 | Concluída | `da3c8dd` | Analyze limpo; 7 testes de contrato; 58 testes de Fazendas verdes | 168 campos, 156 obrigatórios, 46 Ready e 7 Hardware; suíte global excedeu 10 min sem falha reportada |
| M2 | Concluída | `3021f9c` | Analyze limpo; 10 testes novos; Widgetbook Web compilado | Catálogo ampliado de 42 para 46 componentes; download físico do arquivo de auditoria conectado em M7 |
| M3 | Concluída | `f786870` | Analyze limpo; 45 testes focados verdes; Flutter Web compilado | Duas centrais derivadas do catálogo 12/41; rotas cruzadas redirecionam; logout invalida sessão; jornadas sem tela própria permanecem para M4–M7 |
| M4 / A | Concluída | `93f5d58` | Analyze limpo; 25 testes focados verdes; teste ponta a ponta lista → validação → sucesso → consulta | Tela dirigida pelo catálogo reutiliza o motor M2; seis contratos da onda usam os mesmos registros Riverpod e Administração lê Áreas criadas no Operacional |
| M5 / B | Concluída | `a78bdf5` | Analyze limpo; 19 testes focados verdes | Treze contratos executáveis; período reprodutivo inválido é bloqueado; grupos de Pastagens aceitam itens vinculados |
| M6 / C | Concluída | `0275bc7` | Analyze limpo; 13 testes focados e 77 testes ampliados verdes; Flutter Web compilado | Sete contratos bloqueiam sem captura; Bluetooth usa descoberta em duas etapas; RFID aceita captura ou entrada manual; scanner mantém enquadramento semântico |
| M7 / D | Concluída | `5cab23f` | Analyze limpo; 12 testes focados e 83 testes ampliados verdes; Flutter Web compilado | As 46 funcionalidades Ready têm destino executável; consultas e OS recebem amostras; auditorias geram CSV/JSON e baixam o arquivo no Flutter Web |
| M8 / E | Concluída | `1cda773` | Analyze limpo; 53 testes do gate funcional verdes | Política cobre sessão ausente, famílias de rotas cruzadas, logout e redirecionamento para a central correta; CI executa o gate antes da suíte global |
| M9 / F | Concluída | `fb7eba8` | Analyze limpo; 6 testes novos e regressão ampliada de 200 testes verdes; Flutter Web compilado | Controles compartilhados preservam alvo mínimo de 44dp; formulário e ações expõem semântica; teclado e viewports 390×844/1024×844 cobertos; login e botões largos não causam overflow |
| M10 / G | Concluída | `c90ae7f` | Analyze limpo; 3 testes arquiteturais, gate CI com 56 testes e regressão focada com 71 testes verdes; app e Widgetbook Web compilados | AppPressable centraliza superfícies interativas em 16 arquivos de shell/módulos; imports públicos passam por ui.dart; gate bloqueia controles crus e componentes sem caso no Widgetbook |
| M11 / H | Concluída | `d0d5ef2` | `tokens:verify` verde; analyze limpo; 4 testes novos e suíte global com 373 testes verdes; app e Widgetbook Web compilados; React congelado compilado | Cores, tipografia, pesos, insets, gaps, raios e movimento visual consomem tokens; CI regenera DTCG/Dart e rejeita divergência; golden CI do AppButton sincronizado. A regressão de sessão/checkbox XML descoberta pela suíte foi corrigida antes em `f366e74` |
| M12 | Concluída | `1b990ef`, fix `2a7ce8a` | Build Cloudflare concluído; versão `8dff1703-6d97-41f2-8f35-94e107f9d8c7`; smoke HTTP real com 6 rotas, status 200, bases e fallbacks corretos | Preview Flutter e Widgetbook publicados sem tráfego de produção; o usuário autorizou o corte e a promoção para `main`. |
| M13 | Concluída | `refactor: remove aplicacao React apos corte Flutter` | Analyze limpo; 373 testes verdes; app + Widgetbook Web compilados; smoke de 6 rotas verde; `npm audit` com 0 vulnerabilidades; busca de runtime React vazia | Tag `react-rollback-final-2026-08-17` aponta para `5879bbf`; Flutter é o único runtime e pipeline; merge, push e remoção da branch executados na sequência solicitada. |
