/**
 * Exportador de tokens → W3C DTCG (Lei 5).
 * Lê design/tokens.ts e emite tokens/tokens.json no formato Design Tokens Community Group,
 * consumível por Tokens Studio → Figma Variables → Supernova.
 *
 * Direção do fluxo (imutável): o CÓDIGO define, o design CONSOME.
 * Rodar: `npm run tokens:export`.
 *
 * $type permitidos (DTCG): color, dimension, number, fontFamily, fontWeight, duration,
 * cubicBezier, strokeStyle, border, transition, shadow, gradient, typography.
 */
import { writeFileSync, mkdirSync } from 'node:fs'
import { resolve, dirname } from 'node:path'
import { fileURLToPath } from 'node:url'
import {
  color as colorTokens,
  primitive,
  font,
  space,
  size,
  radius,
  shadow,
  chart,
  animation,
  component,
  themePalette,
  layout,
} from '../design/tokens'

const __dirname = dirname(fileURLToPath(import.meta.url))

type DTCGToken = { $value: unknown; $type: string }
type DTCGGroup = { [k: string]: DTCGToken | DTCGGroup }

const color = (v: string): DTCGToken => ({ $value: v, $type: 'color' })
const dimension = (v: string): DTCGToken => ({ $value: v, $type: 'dimension' })
const number = (v: number): DTCGToken => ({ $value: v, $type: 'number' })

// '150ms' → { value: 150, unit: 'ms' } (forma estrutural DTCG para duration)
const duration = (v: string): DTCGToken => {
  const m = v.match(/^(-?[\d.]+)(ms|s)$/)
  return { $type: 'duration', $value: m ? { value: Number(m[1]), unit: m[2] } : v }
}

// 'cubic-bezier(a, b, c, d)' → [a, b, c, d] (forma estrutural DTCG para cubicBezier)
const cubicBezier = (v: string): DTCGToken => {
  const m = v.match(/^cubic-bezier\(([^)]+)\)$/)
  return { $type: 'cubicBezier', $value: m ? m[1].split(',').map((n) => Number(n.trim())) : v }
}

// Aceita cor simples ou lista ordenada de cores (paleta categórica de gráfico):
// DTCG permite `$value` array sob `$type: 'color'`, e o exportador Dart já
// materializa esse caso como `List<Color>`.
function mapColors(scale: Record<string | number, string | readonly string[]>): DTCGGroup {
  const out: DTCGGroup = {}
  for (const [k, v] of Object.entries(scale)) {
    out[k] = Array.isArray(v) ? { $value: v, $type: 'color' } : color(v as string)
  }
  return out
}

function mapDimensions(scale: Record<string | number, string>): DTCGGroup {
  const out: DTCGGroup = {}
  for (const [k, v] of Object.entries(scale)) out[k] = dimension(v)
  return out
}

// Achata a escala `size` (que tem valores string OU objeto aninhado) em pares chave→dimensão.
function flattenSize(scale: Record<string, unknown>): Record<string, string> {
  const out: Record<string, string> = {}
  for (const [k, v] of Object.entries(scale)) {
    if (typeof v === 'string') {
      out[k] = v
    } else if (v && typeof v === 'object') {
      for (const [kk, vv] of Object.entries(v as Record<string, string>)) out[`${k}-${kk}`] = vv
    }
  }
  return out
}

// shadow "0 1px 3px rgba(..)" → objeto DTCG (aproximação de camada única)
function parseShadow(css: string): DTCGToken {
  const first = css.split('),')[0] + (css.includes('),') ? ')' : '')
  const m = first.match(/(-?\d+px)\s+(-?\d+px)\s+(-?\d+px)(?:\s+(-?\d+px))?\s+(rgba?\([^)]+\))/)
  if (!m) return { $value: css, $type: 'shadow' }
  const [, x, y, blur, spread, c] = m
  return {
    $type: 'shadow',
    $value: { color: c, offsetX: x, offsetY: y, blur, spread: spread ?? '0px' },
  }
}

const dtcg = {
  $metadata: { tokenSetOrder: ['core', 'semantic', 'light', 'gbMode', 'component'] },
  core: {
    color: {
      transparent: color(primitive.transparent),
      black: color(primitive.black),
      brand: mapColors(primitive.brand),
      neutral: mapColors(primitive.neutral),
      red: mapColors(primitive.red),
      amber: mapColors(primitive.amber),
      blue: mapColors(primitive.blue),
      // Camada semântica de feedback: existia em design/tokens.ts desde sempre,
      // mas nunca chegava ao Dart — os componentes acabavam lendo `red500`/
      // `amber500` crus. O padrão global precisa dos tons próprios do Figma
      // (o vermelho do "Cancelar" e o âmbar do badge "Em análise"), e é aqui
      // que eles ganham nome.
      feedback: {
        success: mapColors(colorTokens.feedback.success),
        error: mapColors(colorTokens.feedback.error),
        warning: mapColors(colorTokens.feedback.warning),
        info: mapColors(colorTokens.feedback.info),
        notice: color(colorTokens.feedback.notice),
      },
    },
    font: {
      family: { sans: { $value: font.family.sans, $type: 'fontFamily' } },
      size: mapDimensions(font.size),
      weight: Object.fromEntries(
        Object.entries(font.weight).map(([k, v]) => [k, { $value: v, $type: 'fontWeight' }]),
      ),
      lineHeight: Object.fromEntries(Object.entries(font.lineHeight).map(([k, v]) => [k, number(v)])),
    },
    space: mapDimensions(space),
    size: mapDimensions(flattenSize(size)),
    layout: mapDimensions(layout),
    radius: mapDimensions(radius),
    shadow: Object.fromEntries(Object.entries(shadow).map(([k, v]) => [k, parseShadow(v)])),
    chart: {
      revenue: color(chart.revenue),
      expense: color(chart.expense),
      finance: color(chart.finance),
      onDark: color(chart.onDark),
      grid: color(chart.grid),
      axis: color(chart.axis),
      series: { $value: chart.series, $type: 'color' },
    },
    animation: {
      duration: Object.fromEntries(Object.entries(animation.duration).map(([k, v]) => [k, duration(v)])),
      easing: Object.fromEntries(Object.entries(animation.easing).map(([k, v]) => [k, cubicBezier(v)])),
      stagger: duration(animation.stagger),
    },
  },
  light: mapThemePalette('light'),
  gbMode: mapThemePalette('gbMode'),
  component: {
    dashboardTile: mapColors(component.dashboardTile),
    login: {
      heroScrim: mapColors(component.login.heroScrim),
      card: {
        fill: color(component.login.card.fill),
        blur: dimension(component.login.card.blur),
      },
    },
    hub: {
      bankCard: mapColors(component.hub.bankCard),
      glass: mapColors(component.hub.glass),
      glassBlur: dimension(component.hub.glassBlur),
    },
    revealMenu: {
      appScale: number(component.revealMenu.appScale),
      appShiftX: dimension(component.revealMenu.appShiftX),
      menuWidth: dimension(component.revealMenu.menuWidth),
      bg: color(component.revealMenu.bg),
      itemStagger: duration(component.revealMenu.itemStagger),
    },
    header: mapColors(component.header),
    hero: { angle: number(component.hero.angle) },
    kpi: mapColors(component.kpi),
    tabbar: mapDimensions(component.tabbar),
    navigationCard: mapDimensions(component.navigationCard),
    emptyState: mapDimensions(component.emptyState),
  },
} as const

function mapThemePalette(mode: 'light' | 'gbMode'): DTCGGroup {
  const p = themePalette[mode]
  const out: DTCGGroup = {}
  for (const [group, roles] of Object.entries(p)) {
    if (group === 'shadow') {
      out[group] = Object.fromEntries(
        Object.entries(roles as Record<string, string>).map(([k, v]) => [k, parseShadow(v)]),
      )
    } else {
      out[group] = mapColors(roles as Record<string, string | readonly string[]>)
    }
  }
  return out
}

const outPath = resolve(__dirname, '../tokens/tokens.json')
mkdirSync(dirname(outPath), { recursive: true })
writeFileSync(outPath, JSON.stringify(dtcg, null, 2) + '\n', 'utf8')
// eslint-disable-next-line no-console
console.log(`✓ DTCG tokens escritos em ${outPath}`)
