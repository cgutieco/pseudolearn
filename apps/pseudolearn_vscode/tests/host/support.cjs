const vscode = require("vscode");
const path = require("node:path");
const { execFileSync } = require("node:child_process");

const checks = [];

function record(name, ok, detail) {
  checks.push({ name, ok, detail: detail === undefined ? "" : String(detail) });
}

async function step(name, body) {
  try {
    record(name, true, await body());
  } catch (error) {
    record(name, false, error && error.stack ? error.stack : error);
  }
}

function sleep(milliseconds) {
  return new Promise((resolve) => setTimeout(resolve, milliseconds));
}

async function until(label, probe, timeout = 20000) {
  const deadline = Date.now() + timeout;
  for (;;) {
    const value = await probe();
    if (value) return value;
    if (Date.now() > deadline) throw new Error(`timeout: ${label}`);
    await sleep(100);
  }
}

function pseudoProcesses() {
  try {
    const output = execFileSync("/bin/ps", ["-axo", "pid=,command="], { encoding: "utf8" });
    const own = process.env.PSEUDOLEARN_HOST_EXTENSIONS;
    return output.split("\n").filter((line) => line.includes("/bin/darwin-arm64/pseudo") && line.includes(own));
  } catch {
    return [];
  }
}

function folder() {
  return vscode.workspace.workspaceFolders[0].uri.fsPath;
}

async function open(relative) {
  const document = await vscode.workspace.openTextDocument(vscode.Uri.file(path.join(folder(), relative)));
  await vscode.window.showTextDocument(document);
  return document;
}

function diagnosticsOf(document) {
  return vscode.languages.getDiagnostics(document.uri);
}

module.exports = { checks, record, step, sleep, until, pseudoProcesses, folder, open, diagnosticsOf };
