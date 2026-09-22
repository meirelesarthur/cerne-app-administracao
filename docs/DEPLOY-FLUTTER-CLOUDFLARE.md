# Deploy Flutter no Cloudflare Worker

O repositório publica um único artefato estático:

- app Flutter em `/`;
- Widgetbook em `/storybook/`;
- saída física em `apps/mobile/build/site`.

## Configuração do Workers Builds

No Worker `cerne-app-operacao`, use:

- **Root directory:** `/` (raiz do repositório);
- **Build command:** `npm run build`;
- **Deploy command:** `npx wrangler deploy`;
- **Non-production deploy command:** `npx wrangler versions upload`;
- **Production branch:** a branch de produção escolhida no dashboard;
- **Non-production branch builds:** habilitado para gerar a URL de preview antes do corte.

O `wrangler.jsonc` aponta para `apps/mobile/build/site` e para o Worker em
`workers/index.js`. Assets existentes são servidos diretamente pela Cloudflare. Somente rotas sem
arquivo chegam ao Worker, que usa fallbacks separados:

- `/storybook` e `/storybook/*` → `/storybook/index.html`;
- todas as demais rotas navegáveis → `/index.html`.

O artefato não contém `_redirects`: esse arquivo pertence ao fluxo Cloudflare Pages e conflita com
o roteamento do Worker Static Assets. O smoke test bloqueia sua reintrodução tanto na raiz quanto
em `/storybook`.

## SDK e comandos

`scripts/build-flutter-site.mjs` exige Flutter `3.44.6`. Se essa versão não estiver disponível no
ambiente, o script baixa a tag oficial para o cache local ignorado pelo Git. O antigo caminho
`apps/mobile/tool/cf_pages_build.sh` permanece como wrapper compatível.

No Windows, também é possível indicar explicitamente o SDK já instalado:

```powershell
$env:FLUTTER_BIN='C:\flutter\bin\flutter.bat'
npm run build
```

```bash
npm run build
npm run smoke:deploy
```

O build falha se qualquer uma destas rotas deixar de entregar o shell correto:

- `/`;
- `/login`;
- `/fazendas/administracao`;
- `/fazendas/operacional`;
- `/storybook/`;
- `/storybook/components/button`.

## Gate de corte

Antes de promover a versão Flutter para produção:

1. abrir a URL de preview criada por `wrangler versions upload`;
2. conferir as seis rotas do smoke test no navegador;
3. validar login Administração e Operacional;
4. conferir temas Light e GB Mode nas jornadas críticas;
5. somente então promover a versão no dashboard ou executar `wrangler deploy` na branch de produção.

O runtime React foi removido na M13. O último estado recuperável está preservado exclusivamente na
tag Git `react-rollback-final-2026-08-17`.
