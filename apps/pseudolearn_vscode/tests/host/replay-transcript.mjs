import { spawn } from "node:child_process";
import { readFileSync } from "node:fs";
import { join } from "node:path";

const [transcriptDirectory, server] = process.argv.slice(2);

function frames(buffer) {
  const messages = [];
  let offset = 0;
  while (offset < buffer.length) {
    const headerEnd = buffer.indexOf("\r\n\r\n", offset);
    if (headerEnd < 0) break;
    const length = Number(/Content-Length: (\d+)/i.exec(buffer.subarray(offset, headerEnd).toString())[1]);
    const start = headerEnd + 4;
    if (start + length > buffer.length) break;
    messages.push(JSON.parse(buffer.subarray(start, start + length).toString("utf8")));
    offset = start + length;
  }
  return messages;
}

function sessions(messages, isStart) {
  const groups = [];
  for (const message of messages) {
    if (isStart(message)) groups.push([]);
    if (groups.length > 0) groups[groups.length - 1].push(message);
  }
  return groups;
}

function encode(message) {
  const body = Buffer.from(JSON.stringify(message), "utf8");
  return Buffer.concat([Buffer.from(`Content-Length: ${body.length}\r\n\r\n`), body]);
}

function replay(messages) {
  return new Promise((resolve) => {
    const child = spawn(server, ["lsp"], { stdio: ["pipe", "pipe", "ignore"], env: {} });
    const chunks = [];
    const answered = new Set();
    child.stdout.on("data", (chunk) => {
      chunks.push(chunk);
      for (const message of frames(Buffer.concat(chunks))) if (message.id !== undefined && message.method === undefined) answered.add(String(message.id));
    });
    child.on("close", () => resolve(frames(Buffer.concat(chunks))));
    sendAll(child, messages, answered).then(() => setTimeout(() => child.stdin.end(), 1500));
  });
}

async function sendAll(child, messages, answered) {
  for (const message of messages) {
    child.stdin.write(encode(message));
    if (message.id === undefined || message.method === undefined) continue;
    const deadline = Date.now() + 20000;
    while (!answered.has(String(message.id)) && Date.now() < deadline) await new Promise((resolve) => setTimeout(resolve, 20));
  }
}

function summary(messages) {
  const responses = new Map();
  const diagnostics = new Map();
  for (const message of messages) {
    if (message.id !== undefined && message.method === undefined) responses.set(String(message.id), JSON.stringify(message.result ?? message.error));
    if (message.method === "textDocument/publishDiagnostics") diagnostics.set(message.params.uri, JSON.stringify(message.params.diagnostics));
  }
  return { responses, diagnostics };
}

function differences(recorded, replayed) {
  const found = [];
  for (const [key, value] of recorded.responses) {
    if (replayed.responses.get(key) !== value) found.push(`response ${key} differs`);
  }
  for (const [key, value] of recorded.diagnostics) {
    if (replayed.diagnostics.get(key) !== value) found.push(`diagnostics ${key} differ`);
  }
  return found;
}

const sent = frames(readFileSync(join(transcriptDirectory, "client-to-server.log")));
const received = frames(readFileSync(join(transcriptDirectory, "server-to-client.log")));
const clientSessions = sessions(sent, (message) => message.method === "initialize");
const serverSessions = sessions(received, (message) => message.result?.capabilities !== undefined);
let failures = 0;
for (const [index, messages] of clientSessions.entries()) {
  const replayed = summary(await replay(messages));
  const recorded = summary(serverSessions[index] ?? []);
  const found = differences(recorded, replayed);
  failures += found.length;
  process.stdout.write(`session ${index + 1}: ${messages.length} client messages, ${recorded.responses.size} responses, ${recorded.diagnostics.size} diagnostic sets, ${found.length} differences\n`);
  for (const line of found) process.stdout.write(`  ${line}\n`);
}
process.stdout.write(`sessions=${clientSessions.length} serverSessions=${serverSessions.length} failures=${failures}\n`);
process.exitCode = failures === 0 && clientSessions.length > 0 ? 0 : 1;
