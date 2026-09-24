/**
 * GB CERNE — Design Tokens (fonte única de verdade)
 * =================================================
 * Arquitetura em 3 camadas, alinhada ao padrão W3C DTCG (Design Tokens Community Group):
 *   1. primitive  — valores crus (paletas, escalas numéricas)
 *   2. semantic   — papéis (feedback, accent, state) + theme-aware (light | gbMode)
 *   3. foundation/component — font, space, size, radius, shadow, dashboardTile, ...
 *
 * REGRAS (CLAUDE.md — Leis 3 e 5):
 *  - Nenhum valor novo de design nasce fora deste arquivo. O Flutter consome o Dart gerado via DTCG.
 *  - Ao alterar este arquivo, rodar `npm run tokens:export` e commitar `tokens/tokens.json`
 *    (DTCG) na mesma unidade lógica. O código define; Figma/Supernova consomem.
 *  - Única família tipográfica permitida: Outfit.
 */

/* ------------------------------------------------------------------ *
 * 1. PRIMITIVOS
 * ------------------------------------------------------------------ */

export const primitive = {
  transparent: 'rgba(0,0,0,0)',
  black: '#000000',
  brand: {
    50: '#f0fdf4',
    100: '#dcfce7',
    200: '#bbf7d0',
    300: '#86efac',
    400: '#4ade80',
    500: '#22c55e',
    600: '#059669', // cor de marca principal (accent/CTA)
    700: '#047857', // hover
    800: '#065f46',
    900: '#064e3b',
  },
  neutral: {
    0: '#ffffff',
    50: '#fafafa',
    100: '#f5f5f5',
    150: '#f3f4f6',
    200: '#e5e7eb',
    250: '#e5e5e5',
    300: '#d1d5db',
    400: '#9ca3af',
    500: '#6b7280',
    600: '#616161',
    700: '#404040',
    800: '#1a1a1a',
    900: '#111827',
    950: '#171717',
  },
  red: {
    50: '#fef2f2',
    100: '#fee2e2',
    200: '#fecaca',
    300: '#fca5a5',
    400: '#f87171',
    500: '#ef4444',
    600: '#dc2626',
    700: '#b91c1c',
    800: '#991b1b',
    900: '#7f1d1d',
  },
  amber: {
    50: '#fffbeb',
    100: '#fef3c7',
    200: '#fde68a',
    300: '#fcd34d',
    400: '#fbbf24',
    500: '#f59e0b',
    600: '#d97706',
    700: '#b45309',
    800: '#92400e',
    900: '#78350f',
  },
  blue: {
    50: '#eff6ff',
    100: '#dbeafe',
    200: '#bfdbfe',
    300: '#93c5fd',
    400: '#60a5fa',
    500: '#3b82f6',
    600: '#2563eb',
    700: '#1d4ed8',
    800: '#1e40af',
    900: '#1e3a8a',
  },
} as const

/* ------------------------------------------------------------------ *
 * 2. SEMÂNTICO
 * ------------------------------------------------------------------ */

// 2a. theme-agnostic — papéis que não mudam entre light/gbMode
const feedback = {
  success: { bg: primitive.brand[50], border: primitive.brand[200], text: primitive.brand[700], solid: primitive.brand[600] },
  // Figma 54300-2458: o vermelho de "Cancelar" (borda + rótulo do botão outline) e o
  // âmbar do badge "Em análise" são hexes próprios da referência, não tons da escala.
  // Auditoria de UX (09/2026): o texto de erro e de aviso passa aos tons 700 da
  // escala para ficar em AA (4,5:1) sobre branco — o #ed3437 dava 4,08:1 e o
  // âmbar #be9304 dava 2,85:1. `solid` continua o hex da referência.
  error: { bg: primitive.red[50], border: primitive.red[200], text: primitive.red[700], solid: '#ed3437' },
  warning: { bg: primitive.amber[50], border: primitive.amber[200], text: primitive.amber[700], solid: '#be9304' },
  info: { bg: primitive.blue[50], border: primitive.blue[200], text: primitive.blue[600], solid: primitive.blue[500] },
  notice: primitive.amber[500],
} as const

const accent = {
  purple: { bg: '#f5f3ff', solid: '#7c3aed', border: '#ddd6fe' },
  cyan: { bg: '#ecfeff', solid: '#0891b2', border: '#a5f3fc' },
} as const

const state = {
  disabled: { bg: primitive.neutral[100], text: primitive.neutral[400], border: primitive.neutral[200] },
  readonly: { bg: primitive.neutral[50], text: primitive.neutral[600] },
  row: { hover: primitive.neutral[50], selected: primitive.brand[50], striped: primitive.neutral[50] },
} as const

const overlay = {
  modal: 'rgba(17, 24, 39, 0.45)',
  drawer: 'rgba(17, 24, 39, 0.35)',
} as const

const gb = {
  accent: '#4ade80',
  surface: 'rgba(14, 42, 29, 0.55)',
} as const

export const color = {
  ...primitive,
  feedback,
  accent,
  state,
  overlay,
  gb,
} as const

// 2b. theme-aware — consumido via ThemeContext / useTheme()
// Nova UI: canvas suave, cartões-cápsula, superfície "ink" (carvão-verde que permanece
// escura nos dois temas — cartões-herói da referência) e CTA vibrante com texto escuro.
export interface ThemePalette {
  /**
   * Escala de texto do padrão global (Figma 54300-2458). Cada papel existe porque a
   * referência usa um tom distinto para ele — não são sinônimos:
   * `default` título de card/ladrilho · `heading` título de top bar e de grupo de
   * formulário · `section` cabeçalho de seção com seta · `muted` rótulo de campo e aba
   * inativa · `secondary` subtítulo de card · `subtle` metadado · `quiet` nome de
   * parceiro na linha de oferta · `placeholder` texto fantasma de input (o rgba já
   * embute a opacidade 60% aplicada no Figma sobre rgba(2,53,53,.9)).
   */
  fg: {
    default: string
    heading: string
    section: string
    muted: string
    secondary: string
    subtle: string
    quiet: string
    placeholder: string
    inverse: string
  }
  /**
   * `sheet` é a folha de conteúdo do Figma (`action-card`): superfície levemente
   * distinta do branco puro, com raio 24 no topo, que cobre o canvas em toda tela.
   * `track` é o trilho do segmented control.
   * `inset` é o bloco cinza que agrupa conteúdo *sobre* a folha branca
   * (seções do detalhe, card inset, menu sutil). No claro é o cinza da folha;
   * no Modo GB precisa ser o verde elevado — ali `sheet` é igual à folha e o
   * bloco sumia.
   */
  bg: { canvas: string; sheet: string; surface: string; subtle: string; raised: string; track: string; kpi: string; inset: string }
  /**
   * Preenchimento dos campos de formulário (`AppFieldCapsule`), que precisa
   * contrastar com a superfície em que o campo está — não com um branco fixo.
   * `onSurface` é o preenchimento quando o campo está sobre `bg.surface`
   * (branco em claro); `onCanvas`, sobre `bg.canvas`/`bg.sheet` (cinza em
   * claro). Em gbMode nenhuma superfície é branca, então os dois papéis
   * convergem para `bg.raised` — o campo continua dentro da paleta escura,
   * nunca vira um retângulo branco sobre o tema escuro.
   */
  field: { onSurface: string; onCanvas: string }
  border: { default: string; strong: string; subtle: string; tint: string }
  accent: { default: string; hover: string; subtle: string; contrast: string }
  /** superfície escura de destaque (hero cards / canvas invertido da referência) */
  ink: { bg: string; fg: string; muted: string; subtle: string; bubble: string; line: string }
  /**
   * Cartão-herói do Figma (Dashboard Hero, nó 54300:16089): gradiente diagonal com
   * texto e caixas de ícone translúcidas por cima. O ângulo não é cor e vive em
   * `component.hero.angle`.
   */
  hero: { from: string; to: string; fg: string; fgMuted: string; fgSubtle: string; overlay: string; line: string }
  /** CTA de alto impacto: verde vibrante + texto quase-preto (referência) */
  cta: { bg: string; hover: string; fg: string }
  /** tab bar flutuante em cápsula translúcida */
  nav: { bg: string; fg: string; active: string; border: string }
  shadow: { card: string; cardHover: string; modal: string }
  /**
   * Superfície de gráfico, theme-aware. A paleta categórica de `chart.series`
   * (seção 3) é fixa e nasceu no tema claro; em gbMode ela colide com o fundo
   * escuro. Aqui cada tema declara a sua série e o seu cromo (grade, eixo,
   * trilho) — nenhum gráfico deve mais ler `AppColors.chartSeries` direto.
   */
  chart: {
    /** paleta categórica ordenada; o índice da série escolhe a cor */
    series: string[]
    /** linhas de grade horizontais — o mais apagado que ainda se enxerga */
    grid: string
    /** eixo e seus rótulos */
    axis: string
    /** trilho de fundo de barra/gauge (100% da escala) */
    track: string
    /** leitura financeira: entrou dinheiro / saiu dinheiro */
    positive: string
    negative: string
  }
  /**
   * Superfícies de tom (chips de status, blocos de aviso do detalhe),
   * theme-aware. As escalas cruas `*.50/200/600` só funcionam sobre branco: em
   * gbMode viravam retângulos pastel claros com texto quase invisível. Cada
   * tom declara fundo, borda e texto/ícone próprios por tema.
   */
  tone: Record<'brand' | 'blue' | 'amber' | 'red' | 'neutral', { bg: string; border: string; fg: string }>
}

export const themePalette: Record<'light' | 'gbMode', ThemePalette> = {
  light: {
    // Nova UI (referência Força Agro): canvas neutro (era um sage-cream mais
    // quente) e brand alinhado ao primary/pure exato da referência (#047857
    // = brand[700], não brand[600]) — usado em bordas de foco, links e ícones
    // de destaque em todo o app.
    // Padrão global do Figma (54300-2458): a escala de texto deixa de ser o
    // trio verde-acinzentado da referência anterior e passa aos neutros exatos
    // medidos nos seis frames. Cada papel tem um tom próprio na referência.
    fg: {
      default: '#141414',
      heading: '#262626',
      section: '#1f1a19',
      // Auditoria de UX (09/2026): muted/subtle/quiet escurecidos para AA (4,5:1)
      // também sobre o canvas cinza — o público lê no sol. Antes: #6b7280 e
      // #80807f (3,47:1 no canvas).
      muted: '#636b78',
      secondary: '#615b58',
      subtle: '#686867',
      quiet: '#686867',
      // Figma: alpha .54; subido para .64 para o exemplo do campo ser legível.
      placeholder: 'rgba(2,53,53,0.64)',
      inverse: primitive.neutral[0],
    },
    // O canvas e a folha estrutural permanecem cinza. Todo elemento que recebe
    // conteúdo ou interação — campos, cards, ladrilhos e a barra de navegação
    // — usa uma superfície branca. Essa separação é global para que os perfis
    // operacional e administrativo não voltem a parecer uma única massa cinza.
    bg: {
      canvas: '#f0f0f2',
      sheet: '#f0f0f0',
      surface: primitive.neutral[0],
      subtle: primitive.neutral[0],
      raised: primitive.neutral[0],
      track: '#e6e6e6',
      kpi: primitive.neutral[0],
      inset: '#f0f0f0',
    },
    // Sobre o branco de `bg.surface`, o campo precisa de um cinza próprio
    // para se destacar (neutral[100]) — `bg.subtle`/`bg.raised` são brancos
    // aqui e não serviriam. Sobre o cinza do canvas/folha, o branco puro já
    // contrasta, e é a leitura histórica do campo de busca do app.
    field: { onSurface: primitive.neutral[100], onCanvas: primitive.neutral[0] },
    // `strong` escurecido na auditoria de UX: é a borda de repouso dos campos,
    // que antes sumiam na folha branca (1,09:1).
    border: { default: '#e8e9e1', strong: '#c4c7bb', subtle: '#f0f1ea', tint: primitive.brand[100] },
    accent: { default: primitive.brand[700], hover: primitive.brand[800], subtle: primitive.brand[50], contrast: primitive.neutral[0] },
    ink: {
      bg: '#131712',
      fg: '#f2f5ee',
      muted: 'rgba(242,245,238,0.62)',
      subtle: 'rgba(242,245,238,0.40)',
      bubble: 'rgba(255,255,255,0.08)',
      line: 'rgba(255,255,255,0.09)',
    },
    hero: {
      from: '#011e15',
      to: '#04845f',
      fg: primitive.neutral[0],
      fgMuted: 'rgba(255,255,255,0.8)',
      fgSubtle: 'rgba(255,255,255,0.6)',
      overlay: 'rgba(255,255,255,0.2)',
      line: 'rgba(255,255,255,0.16)',
    },
    // Nova UI (referência Força Agro): CTA vira verde sólido + texto branco
    // (era verde-menta + texto quase-preto); nav deixa de depender de blur/
    // translucidez e vira cápsula opaca, como a referência.
    cta: { bg: primitive.brand[700], hover: primitive.brand[800], fg: primitive.neutral[0] },
    nav: { bg: primitive.neutral[0], fg: '#67716a', active: primitive.brand[700], border: '#e8e9e1' },
    shadow: {
      card: '0 1px 2px rgba(16,21,16,0.03), 0 8px 24px rgba(16,21,16,0.05)',
      cardHover: '0 10px 30px rgba(16,21,16,0.10)',
      modal: '0 20px 48px rgba(0,0,0,0.24)',
    },
    // série do tema claro = a paleta categórica histórica de `chart.series`,
    // mantida para não mudar a leitura dos painéis já publicados.
    chart: {
      series: ['#059669', '#2563eb', '#f59e0b', '#7c3aed', '#0891b2', '#dc2626', '#14532d', '#9ca3af'],
      // grid mais claro que track de proposito: a linha de grade e referencia
      // de fundo, o trilho e a escala cheia de uma barra/gauge e precisa ser
      // visivel sobre a superficie branca do card (o neutral[100] anterior era
      // o mesmo tom do canvas e sumia).
      grid: primitive.neutral[150],
      axis: primitive.neutral[400],
      track: primitive.neutral[200],
      positive: primitive.brand[600],
      negative: primitive.red[600],
    },
    // Tema claro = as escalas que o AppChip já usava (sem mudança visual).
    tone: {
      brand: { bg: primitive.brand[50], border: primitive.brand[200], fg: primitive.brand[700] },
      blue: { bg: primitive.blue[50], border: primitive.blue[200], fg: primitive.blue[600] },
      // Âmbar e vermelho no tom 700: o 600 dava 3,07:1 sobre o fundo 50.
      amber: { bg: primitive.amber[50], border: primitive.amber[200], fg: primitive.amber[700] },
      red: { bg: primitive.red[50], border: primitive.red[200], fg: primitive.red[700] },
      neutral: { bg: primitive.neutral[100], border: primitive.neutral[200], fg: primitive.neutral[600] },
    },
  },
  gbMode: {
    // Congelado por decisão: o Figma só define o tema claro. Os papéis novos
    // apontam para o equivalente escuro mais próximo já existente, sem
    // refinamento próprio — gbMode continua funcional, não ganha identidade nova.
    fg: {
      default: '#e2f0e8',
      heading: '#e2f0e8',
      section: '#e2f0e8',
      muted: '#8fb3a2',
      secondary: '#8fb3a2',
      // #5f7d6e dava 2,80:1 sobre bg.raised; #86a696 dá 4,76:1.
      subtle: '#86a696',
      quiet: '#8fb3a2',
      placeholder: 'rgba(226,240,232,0.54)',
      inverse: '#051008',
    },
    bg: { canvas: '#051008', sheet: '#0e2a1d', surface: '#0e2a1d', subtle: '#0a2016', raised: '#123a28', track: 'rgba(255,255,255,0.10)', kpi: '#0e2a1d', inset: '#123a28' },
    // Nenhuma superfície de gbMode é branca — os dois papéis convergem para
    // `bg.raised` (o mesmo verde elevado dos cards), corrigindo o campo que
    // antes virava branco puro sobre o tema escuro (quebra de contraste
    // reportada: busca com fill branco total no GB mode).
    field: { onSurface: '#123a28', onCanvas: '#123a28' },
    border: { default: 'rgba(255,255,255,0.10)', strong: 'rgba(255,255,255,0.18)', subtle: 'rgba(255,255,255,0.06)', tint: 'rgba(255,255,255,0.10)' },
    accent: { default: '#10b981', hover: '#34d399', subtle: 'rgba(16,185,129,0.14)', contrast: '#051008' },
    ink: {
      bg: '#102b1e',
      fg: '#e9f4ed',
      muted: 'rgba(233,244,237,0.62)',
      subtle: 'rgba(233,244,237,0.40)',
      bubble: 'rgba(255,255,255,0.06)',
      line: 'rgba(255,255,255,0.08)',
    },
    hero: {
      from: '#051008',
      to: '#102b1e',
      fg: '#e9f4ed',
      fgMuted: 'rgba(233,244,237,0.62)',
      fgSubtle: 'rgba(233,244,237,0.40)',
      overlay: 'rgba(255,255,255,0.06)',
      line: 'rgba(255,255,255,0.08)',
    },
    // gbMode mantém a identidade escura, mas segue a mesma direção: CTA/ativo
    // do dock em verde sólido de marca + texto branco, nav em superfície opaca.
    // Texto do CTA escuro: branco sobre #10b981 dava 2,54:1; #051008 dá 7,64:1.
    cta: { bg: '#10b981', hover: '#34d399', fg: '#051008' },
    nav: { bg: '#0e2a1d', fg: '#8fb3a2', active: '#10b981', border: 'rgba(255,255,255,0.10)' },
    shadow: {
      card: '0 1px 3px rgba(0,0,0,0.4)',
      cardHover: '0 6px 16px rgba(0,0,0,0.5)',
      modal: '0 20px 48px rgba(0,0,0,0.6)',
    },
    // gbMode sobe a luminosidade de cada matiz da série (tom 400/300 em vez de
    // 600/700): sobre `bg.surface` #0e2a1d o verde #059669 e o verde-floresta
    // #14532d praticamente desaparecem. Grade e trilho viram branco translúcido,
    // como o resto do cromo escuro do app.
    chart: {
      series: ['#34d399', '#60a5fa', '#fbbf24', '#a78bfa', '#22d3ee', '#f87171', '#86efac', '#94a3b8'],
      grid: 'rgba(255,255,255,0.08)',
      axis: 'rgba(255,255,255,0.32)',
      track: 'rgba(255,255,255,0.07)',
      positive: '#34d399',
      negative: '#f87171',
    },
    // Fundo translúcido do matiz sobre o verde escuro + texto no tom 300: o
    // tom continua reconhecível sem acender um bloco claro na tela.
    tone: {
      brand: { bg: 'rgba(52,211,153,0.12)', border: 'rgba(52,211,153,0.32)', fg: '#6ee7b7' },
      blue: { bg: 'rgba(96,165,250,0.12)', border: 'rgba(96,165,250,0.32)', fg: '#93c5fd' },
      amber: { bg: 'rgba(251,191,36,0.10)', border: 'rgba(251,191,36,0.32)', fg: '#fcd34d' },
      red: { bg: 'rgba(248,113,113,0.10)', border: 'rgba(248,113,113,0.34)', fg: '#fca5a5' },
      neutral: { bg: 'rgba(255,255,255,0.06)', border: 'rgba(255,255,255,0.14)', fg: '#c3d6cb' },
    },
  },
}

/* ------------------------------------------------------------------ *
 * 3. FUNDAÇÃO (não-cor)
 * ------------------------------------------------------------------ */

export const font = {
  family: { sans: "'Outfit', sans-serif" },
  size: {
    // 20 é o título de tela do cabeçalho de saudação (entre xlPlus 18 e 2xl 22).
    // Auditoria de UX (09/2026): 12px é o piso — os antigos 2xs (10) e xs (11)
    // saíram da escala; o corpo de leitura fica em 14 (md).
    sm: '12px',
    base: '13px',
    md: '14px',
    lg: '15px',
    xl: '16px',
    xlPlus: '18px',
    xlPlus2: '20px',
    '2xl': '22px',
    '3xl': '26px',
    display: '30px',
    '4xl': '32px',
  },
  weight: { normal: 400, medium: 500, semibold: 600, bold: 700, extrabold: 800 },
  // `heading` e `section` são as alturas medidas no Figma (1.4 em títulos de tela
  // e de grupo; 1.42 no cabeçalho de seção).
  lineHeight: { tight: 1.2, snug: 1.35, heading: 1.4, section: 1.42, normal: 1.5, relaxed: 1.625 },
} as const

// escala de espaço base 4px (keys alinhadas ao Tailwind)
export const space = {
  0: '0px',
  quarter: '1px',
  half: '2px',
  // 3px é fora da grade base-4 de propósito: é a altura de respiro do badge de
  // status do Figma (54300:16147, `py 3`), que não cabe em 2 nem em 4.
  threeQuarter: '3px',
  1: '4px',
  oneHalf: '6px',
  2: '8px',
  twoHalf: '10px',
  3: '12px',
  4: '16px',
  5: '20px',
  6: '24px',
  7: '28px',
  8: '32px',
  9: '36px',
  10: '40px',
  12: '48px',
  14: '56px',
  15: '60px',
  16: '64px',
  20: '80px',
} as const

export const size = {
  // Alvos de toque em 48dp (Material) — o público usa luva e está em pé no
  // campo. O CTA grande fica em 52.
  control: '48px',
  controlSm: '36px',
  controlLg: '52px',
  btn: { sm: '48px', md: '48px', lg: '52px' },
  iconBtn: { sm: '48px', md: '48px', lg: '52px' },
  toggle: { track: '40px', thumb: '18px' },
  tableRow: '42px',
  drawer: '320px',
  tabBar: '64px', // altura do bottom tab bar (mobile)
  phone: '420px', // largura máxima do frame de telefone
  // Iconografia (Hugeicons stroke-rounded). A escala cobre as medidas do Figma
  // (node 54300-2458): 14 nos indicadores de resumo, 20 no seletor de fazenda,
  // 24 no ladrilho de módulo, 28 na bolha de notificação.
  // `smPlus` (18) é o ícone de meta inline do hero; `xxl` (32) é o par voltar/overflow
  // da top bar e o ícone de topo da folha de conteúdo.
  icon: { xs: '14px', sm: '16px', smPlus: '18px', md: '20px', lg: '24px', xl: '28px', xxl: '32px' },
  // Espessura do traço do ícone. Único valor do sistema — `AppIcon` o aplica a
  // todo ícone renderizado; nenhuma tela passa espessura própria.
  // 1.5 (antes 1.2): traço fino some ao ar livre.
  iconStroke: '1.5px',
} as const

// Nova UI: geometria cápsula — raios generosos em toda a hierarquia (referência)
export const radius = {
  sm: '6px',
  md: '8px',
  base: '10px',
  mdPlus: '12px',
  lg: '14px',
  lgPlus: '16px',
  xl: '18px',
  '2xl': '22px',
  '3xl': '28px',
  '4xl': '32px',
  modal: '28px',
  // Geometria do padrão global do Figma (node 54300-2458): ladrilho de módulo,
  // campo de busca e superfície de conteúdo sobre o canvas em 20 — a mesma
  // aresta cria o "detalhe" da folha cinza encaixada sobre a faixa branca de
  // seleção da fazenda (correção de medição: valor antigo, 24, não batia com
  // a referência).
  tile: '20px',
  surface: '20px',
  full: '9999px',
} as const

export const shadow = {
  sm: '0 1px 2px rgba(0,0,0,0.05)',
  base: '0 1px 3px rgba(0,0,0,0.1)',
  md: '0 4px 6px rgba(0,0,0,0.07)',
  lg: '0 10px 20px rgba(0,0,0,0.12)',
  brand: '0 6px 16px rgba(5,150,105,0.30)',
  overlay: '0 12px 32px rgba(0,0,0,0.18)',
  modal: '0 20px 48px rgba(0,0,0,0.24)',
  card: '0 1px 3px rgba(0,0,0,0.06), 0 1px 2px rgba(0,0,0,0.04)',
  cardHover: '0 4px 12px rgba(0,0,0,0.08)',
  // Padrão global do Figma (54300-2458) — sombras quase imperceptíveis, que
  // separam superfícies sem desenhar borda. São theme-agnostic de propósito:
  // o preto a 2–12% funciona sobre a folha clara e sobre o canvas escuro.
  tile: '0 4px 12px rgba(0,0,0,0.02)',
  row: '0 4px 6px rgba(0,0,0,0.02)',
  hero: '0 4px 8px rgba(0,0,0,0.12)',
  bubble: '0 2px 4px rgba(0,0,0,0.04)',
} as const

export const border = {
  base: `1px solid ${primitive.neutral[200]}`,
  medium: `1px solid ${primitive.neutral[300]}`,
  brand: `1px solid ${primitive.brand[200]}`,
  error: `1.5px solid ${primitive.red[600]}`,
} as const

export const transition = {
  fast: '120ms cubic-bezier(0.4, 0, 0.2, 1)',
  base: '200ms cubic-bezier(0.4, 0, 0.2, 1)',
  smooth: '300ms cubic-bezier(0.4, 0, 0.2, 1)',
  spring: '400ms cubic-bezier(0.34, 1.56, 0.64, 1)',
} as const

export const animation = {
  duration: { fast: '150ms', base: '200ms', medium: '250ms', slow: '300ms', slower: '400ms' },
  easing: {
    in: 'cubic-bezier(0.4, 0, 1, 1)',
    out: 'cubic-bezier(0, 0, 0.2, 1)',
    inOut: 'cubic-bezier(0.4, 0, 0.2, 1)',
    spring: 'cubic-bezier(0.34, 1.56, 0.64, 1)',
  },
  /** passo de escalonamento entre itens em entradas de lista/grid (stagger) */
  stagger: '40ms',
} as const

export const zIndex = {
  base: 0,
  raised: 10,
  sticky: 100,
  header: 200,
  tabBar: 200,
  drawer: 900,
  overlay: 1000,
  modal: 1100,
  toast: 1200,
} as const

export const breakpoint = { xs: '360px', sm: '768px', md: '1024px', lg: '1280px', xl: '1920px' } as const

export const layout = {
  headerH: '64px',
  moduleBarH: '48px',
  tabBarH: '68px',
  gutter: '16px',
  /** folga inferior dos scrollers para o conteúdo não morrer sob a tab bar flutuante.
   * Reduzido de 104 (ver plano de melhorias de UX): a folga anterior era maior que o
   * necessário — dock (68px) + respiro (14px) já cobrem a cápsula flutuante. */
  tabBarClearance: '88px',
} as const

// paleta categórica para gráficos SVG próprios
export const chart = {
  revenue: '#059669',
  expense: '#dc2626',
  finance: '#2563eb',
  onDark: 'rgba(255,255,255,0.90)',
  grid: primitive.neutral[200],
  axis: primitive.neutral[400],
  series: ['#059669', '#2563eb', '#f59e0b', '#7c3aed', '#0891b2', '#dc2626', '#14532d', '#9ca3af'],
} as const

/* ------------------------------------------------------------------ *
 * 4. COMPONENTE
 * ------------------------------------------------------------------ */

export const component = {
  // spec §2.6 — cards de dashboard escuros colorizados por categoria
  dashboardTile: {
    revenue: '#1b4332', // receitas/financeiro positivo
    expense: primitive.red[900], // despesas (#7f1d1d)
    finance: '#1e3a5f', // financeiro geral
    production: '#14532d', // produtivo/reprodutivo
    dark: '#1c1917', // neutro/genérico
  },
  login: {
    /** véu em gradiente sobre a arte de fundo integral — escurece só o topo (céu claro)
     *  para o bloco branco da marca; a base da arte já é escura e dispensa véu */
    heroScrim: {
      from: 'rgba(9,41,26,0.72)',
      mid: 'rgba(6,78,59,0.22)',
      to: 'rgba(6,95,70,0)',
    },
    /** cartão de "Bem-vindo de volta!" em vidro fosco sobre a arte de fundo
     *  (Figma T003, node 6:100): branco 80% + blur — em vez do `AppCard`
     *  opaco, deixa a fotografia respirar por trás do formulário. */
    card: {
      fill: 'rgba(255,255,255,0.80)',
      blur: '8px',
    },
  },
  // New-UI — hub agregador do superapp (módulo Início) com Banking central
  hub: {
    /** cartão de saldo premium: gradiente institucional profundo + glow da marca */
    bankCard: {
      from: '#064e3b',
      to: '#022c22',
      glow: 'rgba(74,222,128,0.20)',
      divider: 'rgba(255,255,255,0.14)',
      fgMuted: 'rgba(255,255,255,0.72)',
      skeleton: 'rgba(255,255,255,0.16)',
    },
    /** superfícies glass sutis para destaques sobre o canvas */
    glass: {
      light: 'rgba(255,255,255,0.70)',
      dark: 'rgba(14,42,29,0.55)',
      border: 'rgba(255,255,255,0.16)',
    },
    glassBlur: '14px',
  },
  /** menu "reveal" global (aba Mais/Menu): app encolhe à esquerda, menu escuro desliza da direita */
  revealMenu: {
    appScale: 0.78,
    appShiftX: '-58%',
    menuWidth: '78%',
    bg: '#0b2e1e', // verde floresta profundo — lê como verde, não preto (gbMode segue padrão)
    itemStagger: '30ms',
  },
  /** header global do Shell (premium clean): gradiente verde profundo + decoração de onda */
  header: {
    from: '#09291a',
    mid: '#064e3b',
    to: '#0b5c47',
    tabsBg: '#065f46',
    wave: 'rgba(134,239,172,0.08)',
    /** pílulas de contexto dentro do header (fazenda ativa, crédito) */
    pillBg: 'rgba(255,255,255,0.09)',
    pillBorder: 'rgba(255,255,255,0.16)',
    creditBg: 'rgba(74,222,128,0.10)',
    creditBorder: 'rgba(74,222,128,0.25)',
  },
  /** cartão-herói do padrão global: só o ângulo do gradiente (as cores vivem em themePalette.hero) */
  hero: {
    angle: 233.92,
  },
  /** fundo levemente tintado para KPIs em cards claros */
  kpi: {
    bg: '#f8fffe',
  },
  /** Nova UI — tab bar flutuante em cápsula translúcida sobre o conteúdo */
  tabbar: {
    blur: '20px',
    height: '68px',
    /** respiro lateral/inferior da cápsula dentro do frame */
    inset: '14px',
    /** diâmetro dos botões circulares internos */
    itemSize: '48px',
  },
  /** card de primeiro nível para menus extensos (mosaico 2×N com lista interna) */
  navigationCard: {
    height: '140px',
  },
  /** Arte do estado vazio (`AppEmptyState`): halo com o ícone Hugeicons grande
   *  no tom do cenário e um selo sólido no canto (check, x, lupa…) que diz o
   *  "porquê" do vazio. `compact` é a versão para folhas, seletores e cards. */
  emptyState: {
    art: '112px',
    artIcon: '56px',
    badge: '36px',
    badgeIcon: '18px',
    artCompact: '64px',
    artIconCompact: '32px',
    badgeCompact: '24px',
    badgeIconCompact: '14px',
  },
} as const

/* ------------------------------------------------------------------ *
 * EXPORT
 * ------------------------------------------------------------------ */

export const t = {
  color,
  font,
  space,
  size,
  radius,
  shadow,
  border,
  transition,
  animation,
  zIndex,
  breakpoint,
  layout,
  chart,
  component,
  themePalette,
} as const

export type Tokens = typeof t
export default t
