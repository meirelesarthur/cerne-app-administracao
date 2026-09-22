// Servidor estático simples para build/web — usado apenas para inspeção visual manual do build de
// release (sem o cliente de debug do DWDS, que trava a aba em `flutter run -d web-server`).
// Rodar: node tool/serve_web_build.mjs
import { createServer } from 'node:http'
import { readFile } from 'node:fs/promises'
import { extname, join } from 'node:path'

const ROOT = join(import.meta.dirname, '..', process.env.BUILD_DIR ?? 'build/web')
const PORT = process.env.PORT ?? 5176

const MIME = {
  '.html': 'text/html',
  '.js': 'text/javascript',
  '.json': 'application/json',
  '.wasm': 'application/wasm',
  '.png': 'image/png',
  '.ico': 'image/x-icon',
  '.woff2': 'font/woff2',
}

createServer(async (req, res) => {
  const path = req.url === '/' ? '/index.html' : req.url
  try {
    const data = await readFile(join(ROOT, path))
    res.writeHead(200, { 'Content-Type': MIME[extname(path)] ?? 'application/octet-stream' })
    res.end(data)
  } catch {
    res.writeHead(404)
    res.end('not found')
  }
}).listen(PORT, () => console.log(`build/web servido em http://localhost:${PORT}`))
