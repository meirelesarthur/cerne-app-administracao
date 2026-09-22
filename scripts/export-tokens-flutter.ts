/**
 * Exportador de tokens DTCG → Dart (F1 do PLANO-MIGRACAO-FLUTTER.md).
 * Lê tokens/tokens.json (fonte: design/tokens.ts, via `npm run tokens:export`) e gera os
 * arquivos Dart consumidos pelo app Flutter em apps/mobile/lib/design/generated/.
 *
 * Direção do fluxo (imutável, Lei 5): tokens.ts → tokens.json → Dart gerado.
 * Os arquivos gerados NUNCA são editados à mão — todos levam um comentário-guarda no header.
 *
 * Rodar: `npm run tokens:export:flutter` (roda após `npm run tokens:export`).
 */
import { writeFileSync, mkdirSync, readFileSync } from 'node:fs'
import { resolve, dirname } from 'node:path'
import { fileURLToPath } from 'node:url'

const __dirname = dirname(fileURLToPath(import.meta.url))
const TOKENS_PATH = resolve(__dirname, '../tokens/tokens.json')
const OUT_DIR = resolve(__dirname, '../apps/mobile/lib/design/generated')

type Leaf = { $value: unknown; $type: string }
type Node = Leaf | { [k: string]: Node }

const isLeaf = (n: unknown): n is Leaf =>
  typeof n === 'object' && n !== null && '$value' in (n as object) && '$type' in (n as object)

// --- sanitização de nomes de campo Dart ---------------------------------------------------

/** "2xl" -> "xl2", "btn-sm" -> "btnSm" (hífen tratado no toCamel), "100" -> "100" (numérico puro intocado) */
function sanitizeSegment(seg: string): string {
  const numLead = seg.match(/^(\d+)([a-zA-Z].*)$/)
  if (numLead) return `${numLead[2]}${numLead[1]}`
  return seg
}

function toCamel(parts: string[]): string {
  return parts
    .map(sanitizeSegment)
    .map((p) => p.replace(/[^a-zA-Z0-9]+(.)/g, (_, c: string) => c.toUpperCase()))
    .map((p, i) => (i === 0 ? p.charAt(0).toLowerCase() + p.slice(1) : p.charAt(0).toUpperCase() + p.slice(1)))
    .join('')
}

/** Nomes puramente numéricos (chaves de space) precisam de prefixo textual antes de virar identificador. */
function fieldName(pathAfterPrefix: string[], prefix = ''): string {
  const parts = pathAfterPrefix.map(sanitizeSegment)
  const joined = toCamel(parts)
  if (/^[0-9]/.test(joined)) return toCamel([prefix, ...pathAfterPrefix])
  return joined
}

// --- parsing de valores ---------------------------------------------------------------------

function hexToArgb(hex: string): string {
  let h = hex.replace('#', '')
  if (h.length === 6) h = `FF${h}`
  else if (h.length === 8) h = `${h.slice(6, 8)}${h.slice(0, 6)}`
  return `0x${h.toUpperCase()}`
}

function rgbaToArgb(css: string): string {
  const m = css.match(/rgba?\(\s*([\d.]+)\s*,\s*([\d.]+)\s*,\s*([\d.]+)\s*(?:,\s*([\d.]+)\s*)?\)/)
  if (!m) throw new Error(`Cor não reconhecida: ${css}`)
  const [, r, g, b, a] = m
  const alpha = a === undefined ? 255 : Math.round(parseFloat(a) * 255)
  const toHex = (n: string) => Math.round(parseFloat(n)).toString(16).padStart(2, '0')
  return `0x${toHex(alpha === 255 ? '255' : String(alpha))}${toHex(r)}${toHex(g)}${toHex(b)}`.toUpperCase().replace('0X', '0x')
}

/** Converte uma cor DTCG (hex ou rgba(...)) para o literal `Color(0xAARRGGBB)` do Dart. */
function parseColorValue(v: string): string {
  const argb = v.trim().startsWith('#') ? hexToArgb(v.trim()) : rgbaToArgb(v.trim())
  return `Color(${argb})`
}

/** "16px" -> 16, "-58%" -> -58 (percentual mantido como número puro, comentado no field name) */
function parseDimensionValue(v: string): number {
  const m = v.trim().match(/^(-?[\d.]+)(px|%)?$/)
  if (!m) throw new Error(`Dimension não reconhecida: ${v}`)
  return parseFloat(m[1])
}

function isPercent(v: string): boolean {
  return v.trim().endsWith('%')
}

/** Separa por vírgulas de topo (fora de parênteses) — usado para camadas de shadow. */
function splitTopLevel(str: string, sep: string): string[] {
  const out: string[] = []
  let depth = 0
  let cur = ''
  for (const ch of str) {
    if (ch === '(') depth++
    if (ch === ')') depth--
    if (ch === sep && depth === 0) {
      out.push(cur.trim())
      cur = ''
    } else {
      cur += ch
    }
  }
  if (cur.trim()) out.push(cur.trim())
  return out
}

type ShadowLayer = { offsetX: number; offsetY: number; blur: number; spread: number; color: string }

/** "0 1px 2px rgba(0,0,0,0.05), 0 8px 24px rgba(0,0,0,0.05)" -> ShadowLayer[] */
function parseShadowValue(css: string): ShadowLayer[] {
  return splitTopLevel(css, ',').map((layer) => {
    const tokens = layer.trim().split(/\s+/)
    const color = tokens[tokens.length - 1]
    const nums = tokens.slice(0, -1).map((t) => parseFloat(t.replace('px', '')))
    const [offsetX, offsetY, blur, spread] = [nums[0] ?? 0, nums[1] ?? 0, nums[2] ?? 0, nums[3] ?? 0]
    return { offsetX, offsetY, blur, spread, color: parseColorValue(color) }
  })
}

function boxShadowListLiteral(layers: ShadowLayer[]): string {
  const items = layers.map((l) => {
    const spread = l.spread === 0 ? '' : `, spreadRadius: ${l.spread}`
    return `BoxShadow(color: ${l.color}, offset: Offset(${l.offsetX}, ${l.offsetY}), blurRadius: ${l.blur}${spread})`
  })
  return `[${items.join(', ')}]`
}

// --- carregamento dos tokens -----------------------------------------------------------------

const tokens = JSON.parse(readFileSync(TOKENS_PATH, 'utf8'))

const GUARD = `// GERADO AUTOMATICAMENTE — não editar à mão.
// Fonte: tokens/tokens.json (DTCG) <- design/tokens.ts
// Pipeline: \`npm run tokens:export\` seguido de \`npm run tokens:export:flutter\`.
// Qualquer ajuste de valor deve entrar em design/tokens.ts (Lei 3/5 do CLAUDE.md).
`

function header(needsMaterial = true): string {
  return `${GUARD}\n${needsMaterial ? "import 'package:flutter/material.dart';\n" : ''}`
}

// --- app_colors.dart ---------------------------------------------------------------------

function collectColors(node: Node, path: string[], out: Array<{ name: string; value: string }>, prefix: string) {
  if (isLeaf(node)) {
    if (node.$type === 'color') {
      if (Array.isArray(node.$value)) {
        const items = (node.$value as string[]).map((v) => parseColorValue(v))
        out.push({ name: `List<Color> ${fieldName(path, prefix)}`, value: `[${items.join(', ')}]` })
      } else {
        out.push({ name: `Color ${fieldName(path, prefix)}`, value: parseColorValue(node.$value as string) })
      }
    }
    return
  }
  for (const [k, v] of Object.entries(node as Record<string, Node>)) {
    collectColors(v, [...path, k], out, prefix)
  }
}

function buildColorsFile(): string {
  const core: Array<{ name: string; value: string }> = []
  collectColors(tokens.core.color, [], core, 'color')
  const chart: Array<{ name: string; value: string }> = []
  collectColors(tokens.core.chart, ['chart'], chart, 'chart')

  const light: Array<{ name: string; value: string }> = []
  collectColors(tokens.light, [], light, 'light')
  const gbMode: Array<{ name: string; value: string }> = []
  collectColors(tokens.gbMode, [], gbMode, 'gbMode')

  const component: Array<{ name: string; value: string }> = []
  collectColors(tokens.component, [], component, 'component')

  const cls = (name: string, entries: Array<{ name: string; value: string }>) => `
class ${name} {
  ${name}._();

${entries.map((e) => `  static const ${e.name} = ${e.value};`).join('\n')}
}
`

  return `${header()}
${cls('AppColors', [...core, ...chart])}
${cls('AppColorsLight', light)}
${cls('AppColorsGbMode', gbMode)}
${cls('AppComponentColors', component)}
`
}

// --- app_spacing.dart / app_radius.dart -------------------------------------------------------

function collectDimensions(
  node: Node,
  path: string[],
  out: Array<{ name: string; value: number; percent?: boolean }>,
  prefix: string,
) {
  if (isLeaf(node)) {
    if (node.$type === 'dimension') {
      const raw = node.$value as string
      out.push({ name: fieldName(path, prefix), value: parseDimensionValue(raw), percent: isPercent(raw) })
    } else if (node.$type === 'number') {
      out.push({ name: fieldName(path, prefix), value: node.$value as number })
    }
    return
  }
  for (const [k, v] of Object.entries(node as Record<string, Node>)) {
    collectDimensions(v, [...path, k], out, prefix)
  }
}

function buildSpacingFile(): string {
  const space: Array<{ name: string; value: number }> = []
  collectDimensions(tokens.core.space, [], space, 'space')
  return `${header(false)}
class AppSpacing {
  AppSpacing._();

${space.map((e) => `  static const double ${e.name} = ${e.value};`).join('\n')}
}
`
}

function buildRadiusFile(): string {
  const radius: Array<{ name: string; value: number }> = []
  collectDimensions(tokens.core.radius, [], radius, 'radius')
  return `${header(false)}
class AppRadius {
  AppRadius._();

${radius.map((e) => `  static const double ${e.name} = ${e.value};`).join('\n')}
}
`
}

function buildLayoutFile(): string {
  const layout: Array<{ name: string; value: number }> = []
  collectDimensions(tokens.core.layout, [], layout, 'layout')
  const size: Array<{ name: string; value: number }> = []
  collectDimensions(tokens.core.size, [], size, 'size')

  const componentMetrics: Array<{ name: string; value: number; percent?: boolean }> = []
  for (const key of Object.keys(tokens.component)) {
    const sub = tokens.component[key]
    const acc: Array<{ name: string; value: number; percent?: boolean }> = []
    collectDimensions(sub, [key], acc, 'component')
    componentMetrics.push(...acc)
  }

  return `${header(false)}
class AppLayout {
  AppLayout._();

${layout.map((e) => `  static const double ${e.name} = ${e.value};`).join('\n')}
}

class AppSize {
  AppSize._();

${size.map((e) => `  static const double ${e.name} = ${e.value};`).join('\n')}
}

/// Métricas não coloridas de componentes específicos (revealMenu, hub, tabbar…).
/// Campos que terminavam em "%" no token de origem mantêm o número puro (ex.: -58 para "-58%")
/// — o consumidor aplica a divisão por 100 explicitamente.
class AppComponentMetrics {
  AppComponentMetrics._();

${componentMetrics.map((e) => `  static const double ${e.name} = ${e.value};${e.percent ? ' // valor percentual original' : ''}`).join('\n')}
}
`
}

// --- app_typography.dart ----------------------------------------------------------------------

function buildTypographyFile(): string {
  const size: Array<{ name: string; value: number }> = []
  collectDimensions(tokens.core.font.size, [], size, 'size')

  const weights = Object.entries(tokens.core.font.weight as Record<string, Leaf>).map(([k, v]) => ({
    name: toCamel(['weight', k]),
    value: v.$value as number,
  }))

  const lineHeights = Object.entries(tokens.core.font.lineHeight as Record<string, Leaf>).map(([k, v]) => ({
    name: toCamel(['lineHeight', k]),
    value: v.$value as number,
  }))

  const familyRaw = (tokens.core.font.family.sans as Leaf).$value as string
  const family = familyRaw.split(',')[0].replace(/['"]/g, '').trim()

  return `${header()}
class AppTypography {
  AppTypography._();

  static const String fontFamily = '${family}';

${size.map((e) => `  static const double ${e.name} = ${e.value};`).join('\n')}

${weights.map((e) => `  static const FontWeight ${e.name} = FontWeight.w${e.value};`).join('\n')}

${lineHeights.map((e) => `  static const double ${e.name} = ${e.value};`).join('\n')}
}
`
}

// --- app_shadows.dart --------------------------------------------------------------------------

function buildShadowsFile(): string {
  const build = (obj: Record<string, Leaf>) =>
    Object.entries(obj).map(([k, v]) => ({
      name: fieldName([k], 'shadow'),
      value: boxShadowListLiteral(parseShadowValue(v.$value as string)),
    }))

  const core = build(tokens.core.shadow)
  const light = build(tokens.light.shadow)
  const gbMode = build(tokens.gbMode.shadow)

  const cls = (name: string, entries: Array<{ name: string; value: string }>) => `
class ${name} {
  ${name}._();

${entries.map((e) => `  static const List<BoxShadow> ${e.name} = ${e.value};`).join('\n')}
}
`

  return `${header()}
${cls('AppShadows', core)}
${cls('AppShadowsLight', light)}
${cls('AppShadowsGbMode', gbMode)}
`
}

// --- app_motion.dart ---------------------------------------------------------------------------

function buildMotionFile(): string {
  const durations = Object.entries(tokens.core.animation.duration as Record<string, Leaf>).map(([k, v]) => {
    const val = v.$value as { value: number; unit: string }
    return { name: fieldName([k], 'duration'), ms: val.unit === 's' ? val.value * 1000 : val.value }
  })

  const stagger = tokens.core.animation.stagger as Leaf
  const staggerVal = stagger.$value as { value: number; unit: string }
  durations.push({ name: 'stagger', ms: staggerVal.unit === 's' ? staggerVal.value * 1000 : staggerVal.value })

  const easings = Object.entries(tokens.core.animation.easing as Record<string, Leaf>).map(([k, v]) => ({
    name: toCamel(['easing', k]),
    curve: v.$value as number[],
  }))

  const revealItemStagger = tokens.component.revealMenu.itemStagger as Leaf
  const revealVal = revealItemStagger.$value as { value: number; unit: string }

  return `${header()}
class AppMotion {
  AppMotion._();

${durations.map((e) => `  static const Duration ${e.name} = Duration(milliseconds: ${e.ms});`).join('\n')}

  static const Duration revealMenuItemStagger = Duration(milliseconds: ${
    revealVal.unit === 's' ? revealVal.value * 1000 : revealVal.value
  });

${easings.map((e) => `  static const Cubic ${e.name} = Cubic(${e.curve.join(', ')});`).join('\n')}
}
`
}

// --- escrita -------------------------------------------------------------------------------

mkdirSync(OUT_DIR, { recursive: true })
const files: Record<string, string> = {
  'app_colors.dart': buildColorsFile(),
  'app_spacing.dart': buildSpacingFile(),
  'app_radius.dart': buildRadiusFile(),
  'app_layout.dart': buildLayoutFile(),
  'app_typography.dart': buildTypographyFile(),
  'app_shadows.dart': buildShadowsFile(),
  'app_motion.dart': buildMotionFile(),
}

for (const [name, content] of Object.entries(files)) {
  writeFileSync(resolve(OUT_DIR, name), content, 'utf8')
}

console.log(`Gerados ${Object.keys(files).length} arquivos Dart em ${OUT_DIR}`)
