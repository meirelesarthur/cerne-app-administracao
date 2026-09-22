# New-UI — Hub Agregador do Super App Agro (Banking central)

Branch `New-UI`. Especificação da porta de entrada do superapp: módulo **Início** (`/inicio`),
um hub que agrega os mini-apps existentes e coloca o **GB Bank no centro da experiência**.

---

## 1. Arquitetura de Informação (navegação)

```
Shell (header global + barra de módulos)          ← persiste sempre
└── Início (/inicio)                              ← HUB — landing padrão do app
    ├── Início      → saldo + ações rápidas + crédito + apps + movimentações
    ├── Apps        → catálogo completo (disponíveis + "Em breve")
    └── Carteira    → resumo condensado do Banking (leitura) + CTA "Abrir GB Bank"
├── Fazendas (/fazendas)      — módulo completo (gerencial + campo)
├── Bank (/bank)              — casca navegável (Início/Extrato/Pagamentos/Cartões/Mais)
├── Crédito (/credito)        — casca navegável
├── Marketplace (/marketplace) e Armazém (/armazem) — cascas navegáveis
```

Princípios:

- **Hub agrega, não duplica.** A Carteira e os widgets de Banking do hub são *leitura*;
  toda transação acontece no módulo Bank via deep link (`/bank/extrato`, `/bank/pagamentos`).
- **Injeção contínua de mini-apps.** O hub itera o catálogo `modules/hub/mocks/apps.ts`
  (contrato `{ icon, name, description, route, badge }`) e `shell/moduleConfig.ts`.
  Um app novo entra no superapp sem tocar em nenhuma tela do hub.
- **Deep links em todos os destinos** (rotas URL-endereçáveis), inclusive entre módulos
  (crédito pré-aprovado no hub → `/credito`).
- **Bottom nav ≤ 5 itens** por módulo; hub usa 3 (Início · Apps · Carteira).

## 2. Banking: confiança institucional

- `BalanceCard`: gradiente verde institucional profundo (`component.hub.bankCard`),
  glow sutil da marca (profundidade sem ruído), tipografia Outfit bold `4xl`,
  **números tabulares** (`tabular-nums`) em saldos, extratos e KPIs — zero jitter de layout.
- **Privacidade por padrão de mercado**: toggle olho (44×44px) oculta saldo e valores
  em todas as telas do hub (estado global `shellStore.balanceHidden`).
- Direção de transação nunca é só cor: ícone (↙ entrada / ↗ saída) + sinal + cor.
- Whitespace generoso: seções com `gap-6`, hierarquia rigorosa label → valor → caption.

## 3. Motion design (nativo, 60fps)

| Animação | Spec | Token |
| --- | --- | --- |
| Entrada de seções | `animate-rise` — opacity + translateY(12px), ease-out | `animation.duration.slow` + `animation.easing.out` |
| Stagger entre seções | 40ms por índice | `animation.stagger` |
| Press feedback (tiles, ações) | `active:scale-[0.95–0.99]`, transform-only | `transition.fast` (via Tailwind `transition-all`) |
| Skeleton do saldo | pulse dentro do card, espaço reservado (CLS = 0) | `component.hub.bankCard.skeleton` |

- Apenas `transform`/`opacity` — nada de animar width/height/top/left.
- `prefers-reduced-motion: reduce` desliga `animate-rise` (index.css).
- Sucesso de transação: já coberto pelo padrão `SuccessScreen` dos fluxos (reutilizar no Bank).

## 4. Tokens novos (Lei 3 + Lei 5)

- `component.hub.bankCard` — `from/to/glow/divider/fgMuted/skeleton` (cartão de saldo).
- `component.hub.glass` + `glassBlur` — superfícies glass para destaques futuros.
- `animation.stagger` — passo de escalonamento de entrada.
- Exportados no DTCG (`tokens/tokens.json`): cores como `color`, blur como `dimension`,
  novo grupo `core.animation` com `duration` estrutural (`{value, unit}`) e easing como
  `cubicBezier` (`[x1,y1,x2,y2]`).

## 5. Componentes novos no catálogo (Lei 1)

| Componente | Papel |
| --- | --- |
| `BalanceCard` (+ `BalanceSummaryItem`) | Saldo premium com toggle de visibilidade, skeleton interno e slot de footer |
| `QuickAction` | Ação rápida circular 56px com press feedback |
| `MiniAppTile` | Tile de mini-app com selo `novo`/`breve` e estado desabilitado |
| `TransactionListItem` | Linha de extrato com direção acessível e valores tabulares |

`Card` foi estendido (não clonado): quando `interactive + onClick`, ganha
`role="button"`, `tabIndex` e ativação por Enter/Espaço.

## 6. Acessibilidade (WCAG 2.1 AA+)

- Contraste: branco sobre `#064e3b` ≈ 9,7:1; textos secundários do card ≥ 4,5:1.
- Touch targets ≥ 44px (toggle do saldo 44px, ações rápidas 56px, tiles ≥ 96px de altura).
- Legibilidade solar: valores em bold, superfícies de alto contraste, sem cinza-sobre-cinza.
- `aria-label`/`aria-pressed` no toggle de saldo; ícones decorativos com `aria-hidden`.
- Estado ativo da navegação por cor **e** peso de traço (BottomTabBar existente).
