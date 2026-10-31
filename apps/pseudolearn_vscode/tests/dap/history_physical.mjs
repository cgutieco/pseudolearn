import assert from "node:assert/strict";
import { createHash } from "node:crypto";
import { createServer } from "node:http";
import { mkdtemp, mkdir, readFile, rm, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join, resolve } from "node:path";
import { StdioClient } from "./stdio_client.mjs";

const executable = resolve(process.argv[2] ?? "../pseudolearn_cli/target/debug/pseudo");
const report = resolve(process.argv[3] ?? ".artifacts/dap-history");
const directory = await mkdtemp(join(tmpdir(), "pseudolearn-dap-history-"));
const requests = [];
const sockets = new Set();
const server = createServer((request, response) => {
  let body = "";
  request.on("data", (chunk) => { body += chunk.toString("utf8"); });
  request.on("end", () => {
    requests.push({ method: request.method, path: request.url, body });
    if (request.url === "/hold") return;
    response.writeHead(200, { "content-type": "text/plain" });
    response.end("ok");
  });
});
server.on("connection", (socket) => { sockets.add(socket); socket.on("close", () => sockets.delete(socket)); });
await new Promise((resolve) => server.listen(0, "127.0.0.1", resolve));
const origin = `http://127.0.0.1:${server.address().port}`;
const argumentsList = ["--grant", "red,archivos_lectura,archivos_escritura", "--files", directory, "--local-origin", origin];

function program(path = "/count") {
  return `SubProceso Probe() Como Resultado<Entero, ErrorES>
Definir directory Como DirectorioCap <- Propagar SolicitarDirectorio("root");
Definir file Como ArchivoCap <- Propagar directory.Abrir("out.txt", "escritura");
Definir written Como Entero <- Propagar file.EscribirTexto("guardado");
Definir net Como RedCap <- Propagar SolicitarRed();
Definir request Como PeticionHttp <- PeticionHttp(MetodoHttp.POST, "${origin}${path}").ConCuerpoTexto("one");
Definir response Como RespuestaHttp <- Propagar net.Enviar(request);
Retornar Exito(written);
FinSubProceso
Algoritmo Main
Segun Probe() Hacer
Exito(value): Escribir value;
Error(problem): Escribir problem.Codigo;
FinSegun
Definir Mutable anchor Como Entero <- 7;
Escribir anchor;
anchor <- anchor + 1;
Descartar Probe();
Escribir anchor;
FinAlgoritmo
`;
}

async function launch(client, source, breakpoints) {
  const path = join(directory, "main.pseudo");
  await writeFile(path, source);
  await client.request("initialize", { adapterID: "pseudolearn-history-physical" });
  await client.request("launch", { program: path, workspaceRoot: directory, stopOnEntry: false });
  await client.waitEvent("initialized");
  const resolved = await client.request("setBreakpoints", { source: { path }, breakpoints });
  assert.ok(resolved.breakpoints.every((point) => point.verified));
  await client.request("configurationDone");
}

async function state() {
  const bytes = await readFile(join(directory, "out.txt"));
  return { requests: requests.length, bytes: bytes.toString("hex"), sha256: createHash("sha256").update(bytes).digest("hex") };
}

async function history() {
  const client = new StdioClient(executable, argumentsList);
  const output = [];
  client.onEvent = (event) => { if (event.event === "output" && event.body.category === "stdout") output.push(event.body.output); };
  try {
    const source = program();
    const breakpoints = source.split("\n").flatMap((line, index) => line === "Escribir anchor;" ? [{ line: index + 1 }] : []);
    await launch(client, source, breakpoints);
    const stopped = await client.waitEvent("stopped");
    const before = await state();
    const printed = output.join("");
    assert.equal(before.requests, 1);
    assert.equal(Buffer.from(before.bytes, "hex").toString("utf8"), "guardado");
    await client.request("stepBack", { threadId: stopped.body.threadId });
    const previous = await client.waitEvent("stopped");
    const stack = await client.request("stackTrace", { threadId: previous.body.threadId, levels: 4 });
    const frame = stack.stackFrames[0];
    const scope = await client.request("scopes", { frameId: frame.id });
    await client.request("variables", { variablesReference: scope.scopes[0].variablesReference, count: 1 });
    await client.request("evaluate", { frameId: frame.id, context: "watch", expression: "1 + 2" });
    assert.deepEqual(await state(), before);
    assert.equal(output.join(""), printed);
    await client.request("continue", { threadId: previous.body.threadId });
    const live = await client.waitEvent("stopped");
    assert.deepEqual(await state(), before);
    assert.equal(output.join(""), printed);
    await client.request("continue", { threadId: live.body.threadId });
    await client.waitEvent("stopped");
    assert.equal(requests.length, 2);
    assert.deepEqual(requests.map((request) => request.body), ["one", "one"]);
    await writeFile(join(report, "history.json"), JSON.stringify({ before, after: await state(), output: output.join(""), requests }, null, 2));
  } finally {
    await client.stop();
    await writeFile(join(report, "history-transcript.json"), JSON.stringify(client.transcript, null, 2));
  }
}

async function cancelMutatingRequest() {
  const client = new StdioClient(executable, argumentsList);
  try {
    const count = requests.length;
    await launch(client, program("/hold"), []);
    const deadline = Date.now() + 20000;
    while (requests.length === count && Date.now() < deadline) await new Promise((resolve) => setTimeout(resolve, 10));
    assert.equal(requests.length, count + 1);
    const started = Date.now();
    await client.request("terminate");
    await client.closed;
    assert.ok(Date.now() - started <= 5000);
    assert.equal(requests.length, count + 1);
    await writeFile(join(report, "cancel.json"), JSON.stringify({ requests: requests.length, elapsedMs: Date.now() - started }, null, 2));
  } finally { await client.stop(); }
}

try {
  await mkdir(report, { recursive: true });
  await writeFile(join(directory, "out.txt"), "before");
  await history();
  await cancelMutatingRequest();
  process.stdout.write(`${JSON.stringify({ ok: true, report })}\n`);
} finally {
  for (const socket of sockets) socket.destroy();
  await new Promise((resolve) => server.close(resolve));
  await rm(directory, { recursive: true, force: true });
}
