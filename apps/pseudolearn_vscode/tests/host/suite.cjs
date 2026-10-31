const vscode = require("vscode");
const fs = require("node:fs");
const { checks, record, step, sleep, until, pseudoProcesses, open } = require("./support.cjs");
const { activationChecks, diagnosticChecks, navigationChecks } = require("./analysis.cjs");
const { formatChecks, renameChecks } = require("./editing.cjs");
const { refusalChecks, runChecks, lifecycleChecks } = require("./running.cjs");
const { debugChecks } = require("./debugging.cjs");

const extensionId = "pseudolearn.pseudolearn-vscode";

async function trustedSuite() {
  await activationChecks(vscode.extensions.getExtension(extensionId));
  const main = await open("app/main.pseudo");
  const callPosition = () => main.positionAt(main.getText().indexOf("Doble(numero)") + 2);
  await diagnosticChecks(main);
  await refusalChecks(main);
  await navigationChecks(main, callPosition);
  await formatChecks(main);
  await renameChecks(main, callPosition);
  await runChecks(main);
  await debugChecks();
  await lifecycleChecks();
}

async function restrictedSuite() {
  await step("workspace is untrusted", async () => {
    if (vscode.workspace.isTrusted) throw new Error("trusted");
  });
  await step("extension activates in Restricted Mode", async () => {
    await vscode.extensions.getExtension(extensionId).activate();
  });
  const main = await open("app/main.pseudo");
  await step("analysis still works with the bundled binary", async () => {
    const symbols = await until("symbols", async () => {
      const found = await vscode.commands.executeCommand("vscode.executeDocumentSymbolProvider", main.uri);
      return found && found.length > 0 ? found : undefined;
    });
    return symbols.length;
  });
  await step("running is refused in Restricted Mode", async () => {
    await vscode.commands.executeCommand("pseudolearn.runFile");
    await sleep(1500);
    if (pseudoProcesses().some((line) => line.includes("ejecutar"))) throw new Error("a program was started");
  });
}

async function run() {
  try {
    if (process.env.PSEUDOLEARN_HOST_MODE === "restricted") await restrictedSuite();
    else await trustedSuite();
  } catch (error) {
    record("suite", false, error && error.stack ? error.stack : error);
  }
  const report = { mode: process.env.PSEUDOLEARN_HOST_MODE, trusted: vscode.workspace.isTrusted, checks };
  fs.writeFileSync(process.env.PSEUDOLEARN_HOST_RESULT, JSON.stringify(report, null, 2));
  if (checks.some((item) => !item.ok)) throw new Error("host checks failed");
}

module.exports = { run };
