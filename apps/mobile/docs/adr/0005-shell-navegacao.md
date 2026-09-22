# ADR 0005 — Shell e navegação (F3)

**Status:** aceito · 2026-07-19

## Contexto

F3 do [`PLANO-MIGRACAO-FLUTTER.md`](../../../PLANO-MIGRACAO-FLUTTER.md): `ShellRoute` (go_router) +
header global + module-bar + reveal menu + stores do shell, espelhando `ShellLayout.tsx` e os
componentes de `src/shell/`.

## Decisões

| Item | Decisão |
|---|---|
| Navegação nos componentes | Todos os componentes de `lib/shell/components/` (header, tabs, dock, reveal menu) recebem **callbacks** (`ValueChanged<String> onTabSelected`, `onModuleSelected`, `onNavigate`, `VoidCallback? onOpenProfile`...) em vez de chamar `context.go(...)` diretamente. Only o `ShellLayout` conhece o `go_router`. Motivo: os componentes foram portados por um subagente antes de o router existir; o desacoplamento também os deixa testáveis isoladamente (ver `test/shell/*_test.dart`) sem precisar de um `GoRouter` real |
| Estrutura de rotas | `ShellRoute` envolvendo `/:moduleId` e `/:moduleId/:tab`, uma `GoRoute` por módulo (gerada a partir de `modules` em `module_config.dart` — nenhum módulo hardcoded no router). `/` redireciona para `/inicio`. `/perfil`, `/notificacoes`, `/login` são rotas standalone fora do shell (`PlaceholderPage`) — conteúdo real é F4/F6, fora do escopo aqui |
| Conteúdo dos módulos | `ModulePlaceholderScreen` (mostra módulo + aba) no lugar das telas reais (F4 ainda não existe) — prova que o roteamento por módulo/aba funciona ponta a ponta sem precisar esperar os módulos |
| Encolhimento do app (reveal menu) | `AnimatedContainer` com `transform` (`Matrix4` scale+translate) no `ShellLayout`, não nos componentes — `AppRevealMenu` é só o painel que desliza |
| "Modo GB" no reveal menu | Reaproveita `themeVariantProvider` (F1) — não é um `ThemeContext` novo |

## Bug encontrado e corrigido: overlay de "tocar fora fecha o menu"

A primeira integração tinha um `Positioned.fill` com `GestureDetector` **depois** do `AppRevealMenu`
na `Stack`, para fechar o menu ao tocar na área do app encolhido — replicando o botão invisível
`absolute inset-0` do React. Como esse overlay cobria a tela inteira e ficava por cima de tudo
(inclusive do próprio menu), **nenhum item do `AppRevealMenu` era tocável enquanto o menu estava
aberto** — todo toque (inclusive em "Modo GB", "Conexão", "Sair") era capturado pelo overlay e só
fechava o menu.

**Descoberto via verificação visual manual** (Browser pane) — os testes de widget do próprio
`AppRevealMenu` (`reveal_menu_test.dart`) não pegaram isso porque testam o componente isolado, sem
o `ShellLayout`/`Stack` real ao redor.

**Correção:** o gesto de "tocar fora fecha" foi movido para dentro do próprio conteúdo do app
encolhido (`_ShrunkAppTapToClose`, em `shell_layout.dart`) em vez de um overlay `Positioned.fill`
separado. O `Transform` do Flutter já restringe o hit-test à área visual real do app encolhido, então
toques no `AppRevealMenu` (fora dessa área) passam direto para ele — sem overlay concorrendo.

**Teste de regressão:** `test/router/app_router_test.dart` — "tocar em um item do RevealMenu (Modo
GB) alterna o tema — não fecha o menu por engano" — só reproduz o bug com o `ShellLayout` completo
integrado ao `go_router` real, exatamente o cenário que faltava cobertura.

## Consequências

- **Lição de processo:** testes de widget isolados por componente não substituem testes de
  integração do layout completo — bugs de composição (z-order de `Stack`, hit-testing) só aparecem
  quando as peças são montadas juntas. `test/router/app_router_test.dart` cobre isso para o shell.
- Clique em área vazia **fora** do app encolhido (mas dentro da tela) não fecha mais o menu — só
  clique dentro do conteúdo visível do app encolhido ou nos próprios itens do menu. Pequeno desvio
  do React (que usa um botão full-bleed atrás do app); aceitável, documentado em código.
