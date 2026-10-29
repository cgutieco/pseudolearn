import { createServer } from 'node:http';
import { readFile } from 'node:fs/promises';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const browserDirectory = dirname(fileURLToPath(import.meta.url));

export function createBrowserServer(engineDirectory) {
  const packageDirectory = resolve(engineDirectory, 'target/wasm-browser/pkg');
  const files = new Map([
    ['/', [resolve(browserDirectory, 'index.html'), 'text/html; charset=utf-8']],
    ['/fetch_host.mjs', [resolve(browserDirectory, 'fetch_host.mjs'), 'text/javascript; charset=utf-8']],
    ['/pkg/pseudolearn_wasm.js', [resolve(packageDirectory, 'pseudolearn_wasm.js'), 'text/javascript; charset=utf-8']],
    ['/pkg/pseudolearn_wasm_bg.wasm', [resolve(packageDirectory, 'pseudolearn_wasm_bg.wasm'), 'application/wasm']],
  ]);

  return createServer((request, response) => {
    const requestPath = new URL(request.url ?? '/', 'http://127.0.0.1').pathname;
    const file = files.get(requestPath);
    if (file === undefined) {
      response.writeHead(404);
      response.end();
      return;
    }
    const [filePath, contentType] = file;
    readFile(filePath).then((contents) => {
      response.writeHead(200, { 'content-type': contentType });
      response.end(contents);
    }).catch(() => {
      response.writeHead(404);
      response.end();
    });
  });
}
