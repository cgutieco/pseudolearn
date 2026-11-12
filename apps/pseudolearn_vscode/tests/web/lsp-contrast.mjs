import { deepStrictEqual } from "node:assert";
import { spawn } from "node:child_process";
import { cp, mkdtemp, readFile, rm } from "node:fs/promises";
import { tmpdir } from "node:os";
import { dirname, resolve } from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";

const root = resolve(dirname(fileURLToPath(import.meta.url)), "../..");
const wasmDirectory = resolve(root, ".artifacts/web-extension/dist/web/wasm");
const executable = resolve(root, "bin/darwin-arm64/pseudo");
const fixture = resolve(root, "tests/fixtures/web/project");
const options = { profile: "es", locale: "es" };
const files = [["app/main.pseudo", "app/main"], ["geo/escalas.pseudo", "geo/escalas"], ["geo/vectores.pseudo", "geo/vectores"]];
const manifests = ["app", "geo"];

function textOf(path) { return readFile(path, "utf8"); }

async function openWasm() {
  const module = await import(resolve(wasmDirectory, "pseudolearn_wasm.js"));
  await module.default({ module_or_path: await readFile(resolve(wasmDirectory, "pseudolearn_wasm_bg.wasm")) });
  return new module.WasmSession();
}

async function snapshotFor(session, directory) {
  const sources = [];
  const uris = {};
  const packages = [];
  for (const [index, [path]] of files.entries()) {
    const module = path.slice(0, -".pseudo".length);
    sources.push({ path: module, source_id: index + 1, text: await textOf(resolve(directory, path)) });
    uris[module] = pathToFileURL(resolve(directory, path)).href;
  }
  for (const location of manifests) {
    const manifest = await textOf(resolve(directory, location, "pseudolearn.toml"));
    const configuration = JSON.parse(session.call("resolve_manifest", JSON.stringify({ manifest, location }))).value.configuration;
    const declaration = configuration.package;
    packages.push({ name: declaration.name.value, root: declaration.root.value, kind: declaration.kind.value,
      entries: declaration.entries.value,
      dependencies: Object.fromEntries(configuration.dependencies.map((entry) => [entry.alias, entry.package])) });
  }
  return { project: { project_id: 1, revision_id: 1, files: sources, packages }, uris, options };
}

class WasmServer {
  constructor(session, resource) { this.session = session; this.resource = resource; }
  send(message) {
    const answer = JSON.parse(this.session.call("lsp_message", JSON.stringify({ resource: this.resource, message })));
    if (answer.failure) throw new Error(JSON.stringify(answer.failure));
    return answer.value.messages;
  }
  async close() { this.session.free(); }
}

class StdioServer {
  constructor() {
    this.buffer = Buffer.alloc(0);
    this.messages = [];
    this.waiters = [];
    this.child = spawn(executable, ["lsp"], { env: {}, shell: false, stdio: "pipe" });
    this.child.stdout.on("data", (chunk) => this.receive(chunk));
    this.child.stderr.resume();
    this.child.stdin.on("error", () => undefined);
  }
  receive(chunk) {
    this.buffer = Buffer.concat([this.buffer, chunk]);
    for (;;) {
      const separator = this.buffer.indexOf("\r\n\r\n");
      if (separator < 0) return;
      const length = Number(/Content-Length: (\d+)/i.exec(this.buffer.subarray(0, separator).toString())?.[1]);
      const end = separator + 4 + length;
      if (this.buffer.length < end) return;
      this.messages.push(JSON.parse(this.buffer.subarray(separator + 4, end).toString()));
      this.buffer = this.buffer.subarray(end);
      for (const waiter of this.waiters.splice(0)) waiter();
    }
  }
  write(message) {
    const payload = Buffer.from(JSON.stringify(message));
    this.child.stdin.write(`Content-Length: ${payload.length}\r\n\r\n`);
    this.child.stdin.write(payload);
  }
  async settle(idle = 400) {
    for (;;) {
      const before = this.messages.length;
      await new Promise((resolveWait) => { const timer = setTimeout(resolveWait, idle); this.waiters.push(() => clearTimeout(timer) || resolveWait()); });
      if (this.messages.length === before) return;
    }
  }
  async send(message) {
    const from = this.messages.length;
    this.write(message);
    await this.settle();
    return this.messages.splice(from);
  }
  async close() {
    await this.send({ jsonrpc: "2.0", id: 9999, method: "shutdown" });
    this.write({ jsonrpc: "2.0", method: "exit" });
    await new Promise((resolveClose) => this.child.once("close", resolveClose));
  }
}

const emojiText = 'Algoritmo Principal\nDefinir numero Como Entero <- 21;\nEscribir numero;\nEscribir "\u{1F30D}ñ"; Escribir numero;\nFinAlgoritmo\n';

function conversation(directory) {
  const uri = (path) => pathToFileURL(resolve(directory, path)).href;
  const main = uri("app/main.pseudo");
  const position = (line, character) => ({ line, character });
  let id = 0;
  const request = (method, params) => ({ jsonrpc: "2.0", id: ++id, method, params });
  const notify = (method, params) => ({ jsonrpc: "2.0", method, params });
  return [
    request("initialize", { processId: null, rootUri: pathToFileURL(directory).href, capabilities: {}, initializationOptions: options }),
    notify("initialized", {}),
    ...files.map(([path]) => notify("textDocument/didOpen", { textDocument: { uri: uri(path), languageId: "pseudolearn", version: 1,
      text: undefined, path } })),
    request("textDocument/hover", { textDocument: { uri: main }, position: position(3, 12) }),
    request("textDocument/completion", { textDocument: { uri: main }, position: position(3, 0) }),
    request("textDocument/definition", { textDocument: { uri: main }, position: position(4, 10) }),
    request("textDocument/documentSymbol", { textDocument: { uri: main } }),
    request("textDocument/formatting", { textDocument: { uri: main }, options: { tabSize: 4, insertSpaces: true } }),
    notify("textDocument/didChange", { textDocument: { uri: main, version: 2 }, contentChanges: [{ text: process.env.CHANGE_TEXT ?? "Algoritmo\nFinAlgoritmo\nBroken(" }] }),
    request("textDocument/hover", { textDocument: { uri: main }, position: position(0, 3) }),
    notify("textDocument/didChange", { textDocument: { uri: main, version: 3 }, contentChanges: [{ text: emojiText }] }),
    request("textDocument/hover", { textDocument: { uri: main }, position: position(3, 27) }),
    request("textDocument/definition", { textDocument: { uri: main }, position: position(3, 27) }),
    notify("textDocument/didChange", { textDocument: { uri: main, version: 2 }, contentChanges: [{ text: "Algoritmo\nFinAlgoritmo\nStale(" }] }),
    request("textDocument/hover", { textDocument: { uri: main }, position: position(3, 27) }),
  ];
}

async function withTexts(messages, directory) {
  const resolved = [];
  for (const message of messages) {
    if (message.method === "textDocument/didOpen") {
      const { path, ...rest } = message.params.textDocument;
      resolved.push({ ...message, params: { textDocument: { ...rest, text: await textOf(resolve(directory, path)) } } });
    } else resolved.push(message);
  }
  return resolved;
}

function normalize(messages) {
  const responses = new Map();
  const diagnostics = new Map();
  for (const message of messages) {
    if (message.id !== undefined && (message.result !== undefined || message.error)) responses.set(message.id, message.result ?? message.error);
    else if (message.method === "textDocument/publishDiagnostics") diagnostics.set(message.params.uri, message.params.diagnostics);
  }
  return { responses: [...responses.entries()].sort(([left], [right]) => left - right), diagnostics: [...diagnostics.entries()].sort() };
}

const directory = await mkdtemp(resolve(tmpdir(), "pseudolearn lsp contraste ñ "));
try {
  await cp(fixture, directory, { recursive: true });
  const session = await openWasm();
  const created = JSON.parse(session.call("create_lsp", "{}")).value.resource;
  const wasm = new WasmServer(session, created);
  const stdio = new StdioServer();
  const script = await withTexts(conversation(directory), directory);
  const wasmMessages = [];
  const stdioMessages = [];
  for (const [index, message] of script.entries()) {
    const produced = wasm.send(message);
    if (process.env.LSP_DEBUG && message.method === "textDocument/didChange") console.error(JSON.stringify(produced).slice(0, 1500));
    wasmMessages.push(...produced);
    if (index === 1 && !process.env.NO_SNAPSHOT) {
      const snapshot = await snapshotFor(session, directory);
      wasmMessages.push(...wasm.send({ jsonrpc: "2.0", method: "pseudolearn/workspaceSnapshot", params: snapshot }));
    }
    stdioMessages.push(...await stdio.send(message));
  }
  if (process.env.LSP_DEBUG) {
    const shape = (list) => list.filter((m) => m.method === "textDocument/publishDiagnostics").map((m) => [m.params.uri.slice(-20), m.params.diagnostics.length]);
    console.error(JSON.stringify(shape(wasmMessages)), JSON.stringify(shape(stdioMessages)));
  }
  const wasmView = normalize(wasmMessages);
  const stdioView = normalize(stdioMessages);
  deepStrictEqual(wasmView.responses, stdioView.responses, "LSP responses differ between the Wasm resource and the Rust server");
  deepStrictEqual(wasmView.diagnostics, stdioView.diagnostics, "LSP diagnostics differ between the Wasm resource and the Rust server");
  if (wasmView.responses.length < 10 || wasmView.diagnostics.length < 3) throw new Error("LSP contrast covered too little");
  await stdio.close();
  await wasm.close();
  process.stdout.write(`LSP contrast matches: ${wasmView.responses.length} responses, ${wasmView.diagnostics.length} diagnostic sets\n`);
} finally {
  await rm(directory, { recursive: true, force: true });
}
