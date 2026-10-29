import assert from 'node:assert/strict';
import { spawn } from 'node:child_process';
import { once } from 'node:events';
import { createInterface } from 'node:readline';
import { after, before, describe, it } from 'node:test';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { chromium, firefox, webkit } from 'playwright-core';
import { createBrowserServer } from './server.mjs';

const browserDirectory = dirname(fileURLToPath(import.meta.url));
const engineDirectory = resolve(browserDirectory, '../../..');
const cliDirectory = resolve(browserDirectory, '../../../../../apps/pseudolearn_cli');
let httpServer;
let browserServer;
let browserUrl;

describe('Fetch HTTP contract across browsers', () => {
  before(async () => {
    httpServer = await startHttpServer();
    browserServer = createBrowserServer(engineDirectory);
    await new Promise((resolveListen, rejectListen) => {
      browserServer.once('error', rejectListen);
      browserServer.listen(0, '127.0.0.1', resolveListen);
    });
    const address = browserServer.address();
    assert.ok(address && typeof address !== 'string');
    browserUrl = `http://127.0.0.1:${address.port}`;
  });

  after(async () => {
    await stopHttpServer(httpServer);
    if (browserServer?.listening) {
      await new Promise((resolveClose, rejectClose) => {
        browserServer.close((error) => error ? rejectClose(error) : resolveClose());
      });
    }
  });

  for (const [name, browserType] of [
    ['Chromium', chromium],
    ['WebKit', webkit],
    ['Firefox', firefox],
  ]) {
    it(`matches the local HTTP contract in ${name}`, async () => {
      const browser = await browserType.launch({ headless: true });
      const page = await browser.newPage();
      try {
        await page.goto(browserUrl);
        const actual = await page.evaluate(async ({ origin, routes }) => {
          const { performFetch } = await import('/fetch_host.mjs');
          const requests = routes.map(({
            path,
            headers = [],
            responseLimit = 1024,
            timeoutNanos = 5_000_000_000,
          }) => ({
            operation: 'network_send',
            arguments: [{
              kind: 'http_request',
              value: {
                method: 'GET',
                url: `${origin}${path}`,
                headers,
                body: null,
                effective_response_limit: responseLimit,
                effective_timeout_nanos: timeoutNanos,
              },
            }],
          }));
          const results = [];
          for (const request of requests) {
            const response = await performFetch(request, { allowedOrigins: [origin] });
            results.push(response.outcome === 'committed'
              ? {
                outcome: response.outcome,
                status: response.value.value.status,
                body: response.value.value.body,
              }
              : { outcome: response.outcome, code: response.value.code });
          }
          return results;
        }, {
          origin: httpServer.httpAddress,
          routes: [
            { path: '/texto' },
            { path: '/binario' },
            { path: '/vacio' },
            { path: '/estado/404' },
            { path: '/estado/500' },
            { path: '/redireccion/mismo' },
            { path: '/redireccion/http' },
            {
              path: '/redireccion/otro-origen',
              headers: [['Authorization', 'Bearer local-test-secret']],
            },
            { path: '/grande', responseLimit: 64 },
            { path: '/infinito', responseLimit: 64 },
            { path: '/bomba-gzip', responseLimit: 64 },
            { path: '/lento', responseLimit: 64, timeoutNanos: 100_000_000 },
          ],
        });
        assert.deepEqual(actual, expectedResponses());
      } finally {
        await page.close();
        await browser.close();
      }
    });
  }
});

function expectedResponses() {
  const encoder = new TextEncoder();
  return [
    committed(200, encoder.encode('Hello from PseudoLearn test server\n')),
    committed(200, [0, 255, 13, 10]),
    committed(204, []),
    committed(404, encoder.encode('Not found\n')),
    committed(500, encoder.encode('Server error\n')),
    rejected('redireccion_denegada'),
    rejected('redireccion_denegada'),
    rejected('redireccion_denegada'),
    rejected('limite_excedido'),
    rejected('limite_excedido'),
    rejected('limite_excedido'),
    rejected('tiempo_agotado'),
  ];
}

function committed(status, body) {
  return { outcome: 'committed', status, body: Array.from(body) };
}

function rejected(code) {
  return { outcome: 'failed', code };
}

async function startHttpServer() {
  const process = spawn('cargo', [
    'xtask',
    'http-test-server',
    '--bind',
    '127.0.0.1',
  ], {
    cwd: cliDirectory,
    stdio: ['ignore', 'pipe', 'inherit'],
  });
  const lines = createInterface({ input: process.stdout });
  const announcement = await Promise.race([
    once(lines, 'line').then(([line]) => JSON.parse(line)),
    once(process, 'exit').then(([code]) => {
      throw new Error(`HTTP test server exited before startup with ${code}`);
    }),
  ]);
  if (typeof announcement.http_address !== 'string') {
    process.kill();
    throw new Error('HTTP test server did not publish its address');
  }
  return { process, lines, httpAddress: announcement.http_address };
}

async function stopHttpServer(server) {
  if (server === undefined) return;
  const closed = once(server.process, 'close');
  server.process.kill();
  await closed;
  server.lines.close();
}
