# CERNE ADM — Instruções para desenvolvimento

O Flutter em `apps/mobile` é a única aplicação oficial deste repositório.

Este repo é o **CERNE ADM**: o superapp com **apenas o perfil Administração**. Os cadastros de
campo (perfil Operacional) vivem no app irmão, `cerne-app-operacao`, e **não devem voltar para
cá** — nem rotas, nem telas, nem entradas de catálogo funcional. O login abre direto no ambiente
administrativo, sem seleção de perfil.

## Stack oficial

- Flutter `3.44.6` e Dart 3.
- Riverpod para estado e `go_router` para navegação e política de acesso.
- Widgetbook em `apps/mobile/lib/widgetbook_app.dart`.
- Outfit self-hosted, Hugeicons 1.2 e design tokens gerados.
- Cloudflare Workers Static Assets com app em `/` e Widgetbook em `/storybook/`.

## Comandos principais

```bash
npm run dev                # Flutter Web no Chrome
npm run lint               # flutter analyze --fatal-infos
npm test                   # suíte Flutter completa
npm run quality:functional # gates de arquitetura, acesso e catálogo administrativo 17/17
npm run tokens:verify      # design/tokens.ts → DTCG → Dart
npm run build              # app + Widgetbook em apps/mobile/build/site
npm run smoke:deploy       # rotas e fallbacks do Worker
```

## Estrutura

- `apps/mobile/lib/ui/`: catálogo component-first e casos do Widgetbook.
- `apps/mobile/lib/design/`: temas e arquivos Dart gerados.
- `apps/mobile/lib/router/`: roteamento e política de acesso.
- `apps/mobile/lib/shell/`: shell, sessão demonstrativa e navegação global.
- `apps/mobile/lib/modules/`: Início, Fazendas (só administrativo), Bank, Crédito, Marketplace e
  Armazém.
- `design/tokens.ts`: fonte única neutra dos tokens.
- `tokens/tokens.json`: exportação W3C DTCG.
- `workers/index.js`: fallbacks separados do app e Widgetbook.

## Leis do projeto

### 1 — Component-first

Todo controle visível reutilizável deve nascer em `apps/mobile/lib/ui/` antes de ser consumido por
telas. Componentes públicos entram no barrel `ui.dart` e possuem caso correspondente no Widgetbook.
Não reimplementar localmente controles já existentes no catálogo.

### 2 — Fonte única de componentes

Extensões visuais ou comportamentais são feitas no widget compartilhado por props/parâmetros, não
por cópias ou patches em uma única tela. Estado de domínio ou sessão compartilhado usa Riverpod.

### 3 — Tokens e tipografia

Outfit é a única família tipográfica de apresentação. Cores, espaços, dimensões, raios, sombras e
movimento vêm dos arquivos em `apps/mobile/lib/design/generated`; valores novos entram primeiro em
`design/tokens.ts`.

### 4 — Commits e push

Cada unidade lógica concluída recebe imediatamente um commit Conventional Commit. Push só ocorre
quando solicitado explicitamente pelo usuário.

### 5 — Pipeline W3C DTCG

O fluxo é imutável:

`design/tokens.ts` → `npm run tokens:export` → `tokens/tokens.json` →
`npm run tokens:export:flutter` → `apps/mobile/lib/design/generated`

Toda mudança na fonte exige regenerar e commitar DTCG e Dart na mesma unidade lógica. O exportador
só emite tipos válidos do padrão DTCG, e valores compostos devem usar sua forma estrutural.

## Limites do protótipo

O produto continua exclusivamente frontend: autenticação, RBAC de backend, APIs, persistência e
hardware real são simulados.

As consultas administrativas que citam registros de campo (ex.: "Áreas cadastradas",
"Ordens de Serviço", "Apontamentos") leem a fonte que o app Operação alimentaria — neste protótipo
elas abrem vazias ou com dado demonstrativo. Não há integração de hardware neste app: Bluetooth,
RFID, câmera, localização e balança eram do perfil Operacional e saíram junto com ele.
