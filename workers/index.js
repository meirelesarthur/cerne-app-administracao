const appShellPath = '/index.html';
const widgetbookShellPath = '/storybook/index.html';

function isWidgetbookPath(pathname) {
  return pathname === '/storybook' || pathname.startsWith('/storybook/');
}

function looksLikeMissingAsset(pathname) {
  const lastSegment = pathname.split('/').at(-1) ?? '';
  return lastSegment.includes('.');
}

function textResponse(body, status, extraHeaders = {}) {
  return new Response(body, {
    status,
    headers: {
      'content-type': 'text/plain; charset=utf-8',
      'x-content-type-options': 'nosniff',
      ...extraHeaders,
    },
  });
}

export const worker = {
  async fetch(request, env) {
    if (request.method !== 'GET' && request.method !== 'HEAD') {
      return textResponse('Method not allowed', 405, { allow: 'GET, HEAD' });
    }

    const url = new URL(request.url);
    if (looksLikeMissingAsset(url.pathname)) {
      return textResponse('Not found', 404);
    }

    const shell = isWidgetbookPath(url.pathname) ? 'widgetbook' : 'app';
    const shellPath = shell === 'widgetbook' ? widgetbookShellPath : appShellPath;
    const shellUrl = new URL(shellPath, url.origin);
    const shellRequest = new Request(shellUrl, {
      method: request.method,
      headers: request.headers,
    });
    const shellResponse = await env.ASSETS.fetch(shellRequest);

    if (!shellResponse.ok) {
      return textResponse(`Shell ${shell} indisponível`, 503);
    }

    const headers = new Headers(shellResponse.headers);
    headers.set('cache-control', 'no-cache');
    headers.set('x-content-type-options', 'nosniff');
    headers.set('x-gb-cerne-shell', shell);
    return new Response(shellResponse.body, {
      status: 200,
      headers,
    });
  },
};

export default worker;
