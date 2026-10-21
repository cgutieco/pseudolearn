import assert from 'node:assert/strict';
import { spawn } from 'node:child_process';
import { once } from 'node:events';
import { after, before, describe, it } from 'node:test';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { chromium } from 'playwright-core';
import { createBrowserServer } from './server.mjs';

const browserDirectory = dirname(fileURLToPath(import.meta.url));
const engineDirectory = resolve(browserDirectory, '../../..');

let browser;
let browserServer;
let browserUrl;

describe('pseudolearn_wasm browser package', () => {
  before(async () => {
    browserServer = createBrowserServer(engineDirectory);
    await new Promise((resolveListen, rejectListen) => {
      browserServer.once('error', rejectListen);
      browserServer.listen(0, '127.0.0.1', resolveListen);
    });
    const address = browserServer.address();
    assert.ok(address && typeof address !== 'string');
    browserUrl = `http://127.0.0.1:${address.port}`;
    browser = await chromium.launch({ channel: 'chrome', headless: true });
  });

  after(async () => {
    await browser?.close();
    if (browserServer?.listening) {
      await new Promise((resolveClose, rejectClose) => {
        browserServer.close((error) => error ? rejectClose(error) : resolveClose());
      });
    }
  });

  it('matches native API responses across lifecycle and boundary cases', async () => {
    const page = await openBrowserPage();
    try {
      const completionProgram = 'Algoritmo P\nDefinir total Como \nFinAlgoritmo\n';
      const completionCursor = completionProgram.indexOf('\n', 12);
      const requests = [
        {
          operation: 'complete',
          argumentsJson: JSON.stringify({
            program: completionProgram,
            profile: 'es',
            strictness: 'strict',
            revision: '17',
            cursor_utf8: String(completionCursor),
          }),
        },
        {
          operation: 'create_analysis',
          argumentsJson: JSON.stringify({
            program: 'Algoritmo Browser\nDefinir value Como Entero;\nEscribir "ñ🌍";\nLeer value;\nEscribir value;\nFinAlgoritmo\n',
          }),
        },
        { operation: 'start', argumentsJson: '{"analysis":2,"seed":-9223372036854775808}' },
        { operation: 'advance', argumentsJson: '{"resource":3,"batch_size":4096}' },
        { operation: 'input', argumentsJson: '{"resource":3,"text":"9223372036854775807"}' },
        { operation: 'advance', argumentsJson: '{"resource":3,"batch_size":4096}' },
        { operation: 'release', argumentsJson: '{"resource":3}' },
        { operation: 'query_state', argumentsJson: '{"resource":3,"event":0}' },
        {
          operation: 'encode_events',
          argumentsJson: '{"encoding":"json","events":[{"class":"decision","line":1,"depth":0,"data":{"rama":"case","indice":18446744073709551615}}]}',
        },
        {
          operation: 'create_analysis',
          argumentsJson: JSON.stringify({
            program: 'Algoritmo Cancellation\nDefinir i Como Entero;\ni <- 0;\nMientras i < 2 Hacer\ni <- i + 1;\nFinMientras\nFinAlgoritmo\n',
          }),
        },
        { operation: 'start', argumentsJson: '{"analysis":5,"seed":42}' },
        { operation: 'advance', argumentsJson: '{"resource":6,"batch_size":1}' },
        { operation: 'cancel', argumentsJson: '{"resource":6}' },
        { operation: 'advance', argumentsJson: '{"resource":6,"batch_size":1}' },
        { operation: 'advance', argumentsJson: '{"resource":6,"batch_size":1}' },
        { operation: 'release', argumentsJson: '{"resource":6}' },
      ];
      const wasmResponses = await page.evaluate((trace) => {
        const session = new window.WasmSession();
        return trace.map(({ operation, argumentsJson }) => session.call(operation, argumentsJson));
      }, requests);
      const nativeResponses = await runNativeTrace(requests);

      assert.deepEqual(wasmResponses, nativeResponses);
      const parsedResponses = wasmResponses.map((response) => JSON.parse(response));
      assert.equal(parsedResponses[0].value.revision, '17');
      assert.ok(parsedResponses[0].value.candidates.some((candidate) => candidate.label === 'Entero'));
      assert.ok(parsedResponses[10].value?.resource, wasmResponses[10]);
      assert.equal(parsedResponses[3].value?.termination?.kind, 'awaiting_input', wasmResponses[3]);
      assert.equal(parsedResponses[3].value?.output, 'ñ🌍\n', wasmResponses[3]);
      assert.equal(parsedResponses[5].value?.termination?.kind, 'completed', wasmResponses[5]);
      assert.equal(parsedResponses[5].value?.output, 'ñ🌍\n9223372036854775807\n', wasmResponses[5]);
      assert.equal(parsedResponses[7].failure.family, 'usage');
      assert.match(parsedResponses[8].value, /18446744073709551615/);
      assert.equal(parsedResponses[13].value?.termination?.kind, 'running', wasmResponses[13]);
      assert.equal(parsedResponses[14].value?.termination?.kind, 'cancelled', wasmResponses[14]);

      const invalidJsonWasRejected = await page.evaluate(() => {
        const session = new window.WasmSession();
        try {
          session.call('create_analysis', '{');
          return false;
        } catch {
          return true;
        }
      });
      assert.equal(invalidJsonWasRejected, true);
    } finally {
      await page.close();
    }
  });

  it('refreshes memory views after growth without corrupting the session', async () => {
    const page = await openBrowserPage();
    try {
      const memoryReport = await page.evaluate(() => {
        const memory = window.wasmExports.memory;
        const previousBuffer = memory.buffer;
        const staleView = new Uint8Array(previousBuffer);
        const session = new window.WasmSession();
        const comment = 'x'.repeat(8 * 1024 * 1024);
        const program = `// ${comment}\nAlgoritmo Memory\nFinAlgoritmo\n`;
        const created = session.call('create_analysis', JSON.stringify({ program }));
        const currentBuffer = memory.buffer;
        const response = session.call('version', '{}');
        return {
          before: previousBuffer.byteLength,
          after: currentBuffer.byteLength,
          staleLength: staleView.byteLength,
          staleBufferMatches: staleView.buffer === currentBuffer,
          response: JSON.parse(response),
          created: JSON.parse(created),
        };
      });

      assert.ok(memoryReport.after > memoryReport.before);
      assert.equal(memoryReport.staleLength, 0);
      assert.equal(memoryReport.staleBufferMatches, false);
      assert.ok(memoryReport.response.value.version);
      assert.ok(memoryReport.created.value.resource);
    } finally {
      await page.close();
    }
  });

  it('keeps an owned binary event batch intact across memory growth', async () => {
    const page = await openBrowserPage();
    try {
      const report = await page.evaluate(() => {
        const memory = window.wasmExports.memory;
        const session = new window.WasmSession();
        const events = [
          {
            class: 'output',
            line: 4294967295,
            depth: 2,
            data: { texto: 'é🧩' },
            source: {
              revision_id: 'rev1',
              node_id: 'rev1.n1',
              span: {
                start: { line: 1, column: 1 },
                end: { line: 1, column: 2 },
                start_byte: '0',
                end_byte: '1',
              },
            },
          },
          { class: 'statement_entered', line: 2, depth: 1, source: null },
        ];
        const encoded = JSON.parse(session.call('encode_events', JSON.stringify({ events, encoding: 'binary' })));
        const retained = Uint8Array.from(encoded.value);
        const bufferBeforeGrowth = memory.buffer;
        const comment = 'x'.repeat(8 * 1024 * 1024);
        session.call('create_analysis', JSON.stringify({ program: `// ${comment}\nAlgoritmo Memory\nFinAlgoritmo\n` }));
        const decoded = JSON.parse(session.call(
          'decode_events',
          JSON.stringify({ encoding: 'binary', encoded: Array.from(retained) }),
        ));
        return {
          signature: new TextDecoder().decode(retained.subarray(0, 4)),
          grew: memory.buffer.byteLength > bufferBeforeGrowth.byteLength,
          retainedBuffer: retained.buffer === memory.buffer,
          retainedLength: retained.byteLength,
          expected: JSON.parse(JSON.stringify(events)),
          decoded: decoded.value,
        };
      });

      assert.equal(report.signature, 'PLEV');
      assert.equal(report.grew, true);
      assert.equal(report.retainedBuffer, false);
      assert.ok(report.retainedLength > 16);
      assert.equal(report.decoded.length, report.expected.length);
      assert.deepEqual(report.decoded[0].source, report.expected[0].source);
      assert.equal(report.decoded[1].source, null);
      assert.deepEqual(report.decoded, report.expected);
    } finally {
      await page.close();
    }
  });

  it('rejects memory growth beyond the package limit and remains callable', async () => {
    const page = await openBrowserPage();
    try {
      const memoryReport = await page.evaluate(() => {
        const memory = window.wasmExports.memory;
        const before = memory.buffer.byteLength;
        let rejected = false;
        try {
          memory.grow(4096);
        } catch {
          rejected = true;
        }
        const after = memory.buffer.byteLength;
        const response = new window.WasmSession().call('version', '{}');
        return { before, after, rejected, response: JSON.parse(response) };
      });

      assert.equal(memoryReport.rejected, true);
      assert.equal(memoryReport.after, memoryReport.before);
      assert.ok(memoryReport.response.value.version);
    } finally {
      await page.close();
    }
  });
});

async function openBrowserPage() {
  const page = await browser.newPage();
  await page.goto(browserUrl);
  await page.waitForFunction(() => document.querySelector('#status')?.textContent === 'Motor listo');
  return page;
}

async function runNativeTrace(requests) {
  const child = spawn('cargo', [
    'run',
    '--quiet',
    '--locked',
    '--manifest-path',
    resolve(engineDirectory, 'Cargo.toml'),
    '-p',
    'pseudolearn_wasm',
    '--bin',
    'wasm_native_probe',
  ], { cwd: engineDirectory, stdio: ['pipe', 'pipe', 'pipe'] });
  const outputChunks = [];
  const errorChunks = [];
  child.stdout.on('data', (chunk) => outputChunks.push(chunk));
  child.stderr.on('data', (chunk) => errorChunks.push(chunk));
  child.stdin.end(`${requests.map(({ operation, argumentsJson }) => `${operation}\t${argumentsJson}`).join('\n')}\n`);
  const [exitCode] = await once(child, 'close');
  const errorOutput = Buffer.concat(errorChunks).toString('utf8');
  assert.equal(exitCode, 0, errorOutput);
  return Buffer.concat(outputChunks).toString('utf8').trimEnd().split('\n');
}
