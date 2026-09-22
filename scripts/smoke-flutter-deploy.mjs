import { existsSync, readFileSync, statSync } from 'node:fs'
import { dirname, extname, join, normalize, resolve } from 'node:path'
import { fileURLToPath } from 'node:url'

import worker from '../workers/index.js'

const scriptDir = dirname(fileURLToPath(import.meta.url))
const siteRoot = resolve(scriptDir, '../apps/mobile/build/site')

function assert(condition, message) {
  if (!condition) throw new Error(message)
}

function localAsset(pathname) {
  const decoded = decodeURIComponent(pathname)
  const relative = decoded === '/' ? 'index.html' : decoded.replace(/^\/+/, '')
  const candidate = resolve(siteRoot, normalize(relative))
  if (!candidate.startsWith(`${siteRoot}\\`) && !candidate.startsWith(`${siteRoot}/`) && candidate !== siteRoot) {
    return null
  }
  if (existsSync(candidate) && statSync(candidate).isFile()) return candidate
  if (existsSync(candidate) && statSync(candidate).isDirectory()) {
    const index = join(candidate, 'index.html')
    if (existsSync(index)) return index
  }
  return null
}

function contentType(path) {
  return extname(path) === '.html' ? 'text/html; charset=utf-8' : 'application/octet-stream'
}

const assets = {
  async fetch(request) {
    const path = localAsset(new URL(request.url).pathname)
    if (path == null) return new Response('Not found', { status: 404 })
    return new Response(request.method === 'HEAD' ? null : readFileSync(path), {
      status: 200,
      headers: { 'content-type': contentType(path) },
    })
  },
}

async function serveLikeCloudflare(request) {
  const direct = await assets.fetch(request)
  if (direct.status !== 404) return direct
  return worker.fetch(request, { ASSETS: assets })
}

assert(existsSync(join(siteRoot, 'index.html')), 'App Flutter ausente em build/site/index.html')
assert(existsSync(join(siteRoot, 'main.dart.js')), 'Bundle do app Flutter ausente')
assert(existsSync(join(siteRoot, 'storybook/index.html')), 'Widgetbook ausente em build/site/storybook/index.html')
assert(existsSync(join(siteRoot, 'storybook/main.dart.js')), 'Bundle do Widgetbook ausente')
assert(!existsSync(join(siteRoot, '_redirects')), 'Worker não deve publicar _redirects legado do Cloudflare Pages')
assert(
  !existsSync(join(siteRoot, 'storybook/_redirects')),
  'Widgetbook não deve publicar _redirects legado do Cloudflare Pages',
)

const cases = [
  { path: '/', base: '<base href="/">' },
  { path: '/login', base: '<base href="/">', shell: 'app' },
  { path: '/fazendas/administracao', base: '<base href="/">', shell: 'app' },
  { path: '/fazendas/ordem-servico', base: '<base href="/">', shell: 'app' },
  { path: '/storybook/', base: '<base href="/storybook/">' },
  { path: '/storybook/components/button', base: '<base href="/storybook/">', shell: 'widgetbook' },
]

for (const testCase of cases) {
  const response = await serveLikeCloudflare(new Request(`https://cerne.test${testCase.path}`))
  const body = await response.text()
  assert(response.status === 200, `${testCase.path} respondeu ${response.status}`)
  assert(body.includes(testCase.base), `${testCase.path} recebeu o shell incorreto`)
  if (testCase.shell != null) {
    assert(response.headers.get('x-gb-cerne-shell') === testCase.shell, `${testCase.path} não usou fallback ${testCase.shell}`)
  }
}

const missingAsset = await serveLikeCloudflare(new Request('https://cerne.test/assets/inexistente.js'))
assert(missingAsset.status === 404, 'Asset inexistente não pode receber shell SPA')

const invalidMethod = await worker.fetch(
  new Request('https://cerne.test/login', { method: 'POST' }),
  { ASSETS: assets },
)
assert(invalidMethod.status === 405, 'Worker deve rejeitar métodos fora de GET/HEAD')

console.log(`Smoke Cloudflare aprovado: ${cases.length} rotas, dois shells e fallbacks separados.`)
