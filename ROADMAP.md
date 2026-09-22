# Roadmap — Protótipo Superapp GB CERNE (módulo Fazendas)

> **Documento histórico:** as fases React abaixo registram a origem do protótipo. A migração M0–M13
> foi concluída em 17/08/2026; Flutter 3.44.6 é o único runtime oficial. Consulte
> `docs/MEMORIA-MIGRACAO-FLUTTER.md` para os commits e gates atuais.

Esteira de desenvolvimento em fases, conforme `spec-cerne-app.md` §8 e o `CLAUDE.md`.
Marcação `[x]` a cada etapa concluída, com o commit correspondente.

> **Escopo:** protótipo frontend mobile de alta fidelidade, dados mockados, sem backend.
> **Stack histórica:** React 18 + Vite 5 + TS · Tailwind · react-router · zustand · lucide-react.
> **Fora de escopo (não exigido pelo spec):** Chakra UI, Storybook, testes automatizados — opcionais na Fase 7.

---

## Fase 0 — Fundação  ✅
- [x] Scaffold Vite (React + TS strict), alias `@/`, `git init` — `c25058c`
- [x] `src/design/tokens.ts` (fonte única, Lei 3) — `c25058c`
- [x] `tailwind.config.ts` derivado dos tokens + `darkMode` por `data-theme` — `c25058c`
- [x] `src/styles/tokens.css` (CSS vars light/gbMode) + fonte Outfit — `c25058c`
- [x] `scripts/export-tokens-dtcg.ts` + `tokens/tokens.json` (Lei 5) — `c25058c`
- [x] `ThemeContext` + `useTheme` (light/gbMode) — `c25058c`
- [x] Componentes base `ui/`: Button, Card, Chip, Badge, Tag, IconButton, Skeleton, Banner, BottomSheet, Modal, Spinner — `c25058c`
- [x] `shell/moduleConfig.ts` (registro dos 5 módulos) + `shell/state/shellStore.ts` (zustand) — `c25058c`
- [x] Build de produção + typecheck passando · `npm run tokens:export` ok

## Fase 1 — Shell  ✅
- [x] `ShellLayout`: header global (saudação, sino c/ badge) + banner offline
- [x] `ModuleSwitcher` (barra de módulos, scroll horizontal, item ativo sublinhado)
- [x] `BottomTabBar` genérico consumindo `moduleConfig`
- [x] `DevToolbar` (toggle offline + toggle tema)
- [x] Roteamento react-router `/:moduleId/*` (troca módulo mantém header do Shell)
- [x] Telas do Shell: Login, Onboarding, Notificações, Perfil/Configurações
- [x] `PhoneFrame` (moldura mobile) + verificação visual (troca de módulo + gbMode)
- ↪ ícone "olho"/modo consulta: fica para a Fase 2 (contextual ao módulo Fazendas)

## Fase 2 — Módulo Fazendas · Home + navegação  ✅
- [x] `FazendasModule`: header do módulo com `FarmSwitcher` (pill + bottom sheet) + rotas internas
- [x] `ViewSwitch` segmentado [Gerencial | Campo] + `ContextBadge` + ícone "olho"/modo consulta
- [x] `fazendasStore` (visão ativa, fazenda ativa, fila de sync) + mocks (fazendas, atividades)
- [x] Home: `ShortcutGrid`, `DashboardCard` (claro + escuro), `SparklineArea`, `ActivityListItem`
- [x] Telas de aba: Home (Gerencial/Campo), Atividades, Fazendas, Mais
- [x] `Heading`/`SectionTitle` (Lei 1) + refactor das páginas da Fase 1 · verificação visual OK

## Fase 3 — Visão Administrativa (7 dashboards)  ✅
- [x] Charts SVG: `SparklineArea`, `BarChart`, `DonutChart`, `ProgressBar`, `KpiStatCard`, `ChartCard`
- [x] Scaffold `DashboardScreen` (skeleton de load + banner offline com timestamp) + `useSimulatedLoad`
- [x] Financeiro (comentário `grouper_id=7` no mock)
- [x] Pecuária de Corte (bloco produtivo/reprodutivo desativado com cadeado)
- [x] Confinamento / Lotação de Currais (grid + progress por ocupação + bottom sheet)
- [x] Ativos / Depreciação
- [x] Suprimentos (filtro por tipo + selo "Dados de exemplo")
- [x] Análise de Uso (badge "Acesso restrito")
- [x] Consultas Gerenciais (hub read-only + placeholder de mapa)
- [x] Fonte Outfit self-hospedada (@fontsource) — sem dependência de rede

## Fase 4 — Visão Operacional (7 fluxos)  ✅
- [x] Componentes de form: `FormField`, `TextInput`, `Textarea`, `FormSelect`, `SearchSelect`, `Stepper`, `Checkbox`, `FileUpload`, `Tooltip`
- [x] Scaffold `FlowShell` (contexto + rodapé + chip offline) + `SuccessScreen` (efeitos no web)
- [x] Pesagem (input manual grande + nota da balança; registra pesagem do dia)
- [x] Eventos de Ciclo do Rebanho (form dinâmico por tipo)
- [x] Arraçoamento / Nutrição (sem rateio — LACUNA)
- [x] Venda de Animais (mês congelado bloqueia edição + contagem/total validados)
- [x] Recebimento / Entrada por XML (upload + conferência de itens)
- [x] Aplicação de Insumos / Ocorrências Agrícolas (validação mínima)
- [x] Regra: transferência exige pesagem do dia → bloqueio funcional real (verificado)

## Fase 5 — Módulos-casca  ✅
- [x] Bank · Crédito · Marketplace · Armazém (header + bottom tab próprio + tela de entrada + abas em desenvolvimento)
- [x] Tela de entrada do módulo-casca com identidade + prévia das áreas planejadas
- [x] Card de deep-link "crédito pré-aprovado" em Fazendas → módulo Crédito (verificado)

## Fase 6 — Estados transversais  ✅
- [x] Offline/sync: `DevToolbar` alterna `isOnline`; `SyncBanner` com contagem de pendências + "Sincronizar"
- [x] Fluxo completo verificado: lançamento offline → fila → banner → sincronizar → fila limpa
- [x] `ErrorState` (com retry) no catálogo; Análise de Uso indisponível offline (dados não cacheáveis)
- [x] Estados por tela: loading (skeleton), vazio (EmptyState), offline (banner+timestamp), erro (retry)

## Fase 7 — Polimento para handoff  ✅
- [x] Revisão do tema `gbMode` (verificado em shell, home e dashboards — CSS vars propagam)
- [x] Microinterações via tokens de transição; acessibilidade (tab bar 64px, botões 40–48px, list rows)
- [x] Documentação inline (JSDoc) nos componentes e módulos
- [x] `README.md` com stack, arquitetura, Leis, notas de handoff e **checklist de aceite §9**
- ↪ Nota: Storybook/testes/Chakra fora do escopo (não exigidos pelo spec); IconButtons secundários do header a ~30px

## Fase 8 — Navegabilidade total (PLANO-NAVEGABILIDADE.md)  ✅
- [x] **A** Quick wins: fila de sync real (`9d56023`), deep-link de notificação (`2a825ea`),
  back no Onboarding (`d572084`), telas "Mais" dos módulos-casca (`2f58d16`),
  destinos enganosos (`772d226`), remoção do PlaceholderModule órfão (`b54878c`)
- [x] **B** Detalhes reaproveitáveis: `ActivityDetailSheet` (`5db1c10`, 3 pontos de uso) e
  `TransactionDetailSheet` (`291e99c`, 4 pontos de uso)
- [x] **C** Bank: hub de Pagamentos com fluxo Pix completo + Cartões/Limites, novos
  `SuccessPanel` e `ToggleSwitch` no catálogo (`b9ffc9d`)
- [x] **D** Marketplace PDP/Categorias/Pedidos/Favoritos (`a3cde95`) · Armazém
  Estoque/Movimentações/Unidades/Relatórios (`4eaa5aa`) · Crédito Proposta/Contratos/Ajuda
  (`fe15cfd`) · detalhes de Ativo e Cotação (`69453c2`)
- [x] **E** Varredura final: menuSections nos 4 módulos-casca destravando rotas órfãs e
  removendo as `*MaisScreen` redundantes (`7fe3099`); verificação visual light/gbMode;
  console limpo; `tsc -b --noEmit` sem erros
- ↪ Placeholders honestos remanescentes (rotulados, por decisão): `/bank/ajuda`,
  `/marketplace/ajuda`, mapa de localização em Consultas, segunda via/ajustar limite em Cartões

## Fase 9 — Perfis e cobertura AGRO365  ✅
- [x] Login demonstrativo separado: Administração e Operacional
- [x] Rotas, navegação e identidade do ambiente protegidas por perfil
- [x] Catálogo funcional normalizado a partir de `mapeamento_funcional_agro365_v2.md`
- [x] Central administrativa com dashboards, consultas e auditoria
- [x] Central operacional com todas as entradas do sitemap mapeado
- [x] Estados `Pronto`, `Mapeado` e `Hardware` para comunicar maturidade sem inventar requisitos
- [x] Dashboards financeiro/operacional e pecuário aperfeiçoados com os indicadores observados
- [x] Esteira de evolução e definição de pronto em `docs/ESTEIRA-PERFIS-AGRO365.md`

## Fase 10 — Onda A da esteira funcional  ✅
- [x] Motor frontend reutilizável de lista, formulário, validação, sucesso e detalhe
- [x] Estado em memória compartilhado entre entrada operacional e consulta administrativa
- [x] Áreas: cadastro operacional e consulta administrativa conectados
- [x] Formulações, Batidas e Apontamento agrícola com listas e lançamentos funcionais
- [x] Abastecimentos e Manutenção de frota com listas e lançamentos funcionais
- [x] Validação mobile dos fluxos, proteção de perfil e roteamento administrativo

## Fase 11 — Onda B da esteira funcional  ✅
- [x] Rebanho Inicial, Lotes e Animais com histórico e criação frontend
- [x] Transferência Lote/Área, Sanitário, Desmama e Pastagens com jornadas completas
- [x] Seis rotinas de Reprodução transformadas de acesso mapeado em protótipos funcionais
- [x] Premissas de campos não observados sinalizadas para validação posterior de domínio
- [x] Validação explícita de obrigatoriedade, números positivos e período da estação de monta
- [x] Verificação mobile de erro, criação, confirmação e atualização de lista

## Fase 12 — Onda C · Simulações de hardware  ✅
- [x] Componente reutilizável para descoberta Bluetooth, balança, RFID e scanner
- [x] Conexão simulada em duas etapas com dispositivos encontrados e estado conectado
- [x] Leitura RFID integrada aos campos de identificação e alternativa manual preservada
- [x] Scanner SISBOV com enquadramento, captura, reinício e confirmação
- [x] Transferência de animal e Perdas com listas, formulários e histórico frontend
- [x] Localização de animal e leitura de balança demonstráveis sem hardware real
- [x] Selo `Hardware` mantido para não confundir simulação com integração nativa

## Fase 13 — Onda D · Cobertura funcional total  ✅
- [x] Saldo de Estoque e Processamentos Pecuários com consultas e detalhes
- [x] Exportação local dos logs de Estoque e Pecuária em CSV e JSON
- [x] Carga, Descarga, Nota de Cocho e Configurações do Misturador funcionais
- [x] Marcação agrícola com lista, cadastro e referência de localização
- [x] Compra de Animais e Apartação com jornadas completas
- [x] Minhas OS com consulta por funcionário e fazenda
- [x] Catálogo com 46 itens `Pronto`, 7 `Hardware` simulados e nenhum `Mapeado`

## Fase 14 — Onda E · Endurecimento frontend  ✅
- [x] Sessão demonstrativa obrigatória antes do acesso às rotas internas
- [x] Logout encerra a sessão em memória e redireciona para a escolha de perfil
- [x] Proteção de rota no Shell combinada aos desvios Admin/Operacional do módulo Fazendas
- [x] Gate `quality:functional` valida 12 funções administrativas e 41 operacionais
- [x] Gate rejeita IDs duplicados, itens `Mapeado`, jornadas sem mecanismo demonstrável e hardware sem simulação
- [x] Fronteiras de produção documentadas sem apresentar RBAC, telemetria ou integração nativa como prontas

## Fase 15 — Onda F · Prontidão para apresentação  ✅
- [x] Alvos de toque mínimos de 44 px nos controles reutilizáveis e na navegação contextual
- [x] Foco global preservado em Button e IconButton
- [x] Checkbox de conferência XML com nome acessível contextual
- [x] Login, ambientes Administração/Operacional, formulário e onboarding verificados em 390 × 844 px
- [x] Zero overflow horizontal e zero alvos abaixo de 44 px nas telas auditadas

## Fase 16 — Onda G · Conformidade Component-First  ✅
- [x] Primitivo `Pressable` criado e exportado pelo catálogo UI
- [x] Navegação, atalhos, filtros, cards e seletores migrados para o primitivo
- [x] Zero `<button>` direto fora de `src/components/ui/`
- [x] Gate funcional ampliado para bloquear elementos HTML proibidos fora do catálogo

## Fase 17 — Onda H · Integridade de tokens  ✅
- [x] Cores residuais dos sparklines movidas para `t.chart`
- [x] Token `chart.onDark` mapeado como `color` no exportador W3C DTCG
- [x] `tokens/tokens.json` regenerado junto com a fonte TypeScript
- [x] Gate ampliado para rejeitar cores literais e fontes não autorizadas em TSX
- [x] Outfit verificada como família tipográfica global obrigatória
