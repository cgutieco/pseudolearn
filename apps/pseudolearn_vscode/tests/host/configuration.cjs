const vscode = require("vscode");
const fs = require("node:fs");
const path = require("node:path");
const { step, sleep, until, pseudoProcesses, diagnosticsOf, folder } = require("./support.cjs");

const spanishProgram = "Algoritmo Intervalo\n    Definir minutos Como Entero;\n    minutos <- 2;\n    Escribir minutos * 60;\nFinAlgoritmo\n";
const englishProgram = "Algorithm Interval\n    Define minutes As Integer;\n    minutes <- 2;\n    Write total;\nEndAlgorithm\n";

async function setProfile(profile) {
  await vscode.workspace.getConfiguration("pseudolearn").update("profile", profile, vscode.ConfigurationTarget.Global);
}

async function configurationChecks(main) {
  await step("a Spanish project starts without diagnostics", async () => {
    await vscode.window.showTextDocument(main);
    await sleep(3000);
    const found = diagnosticsOf(main);
    if (found.length !== 0) throw new Error(JSON.stringify(found.map((item) => [item.source, item.message])));
  });
  await step("switching the profile to English reanalyzes it without a reload", async () => {
    await setProfile("en");
    const found = await until("reported", () => (diagnosticsOf(main).length > 0 ? diagnosticsOf(main) : undefined));
    return found.length;
  });
  await step("switching back to Spanish clears them without a reload", async () => {
    await setProfile("es");
    await until("cleared", () => diagnosticsOf(main).length === 0);
  });
  await step("reconfiguring keeps one language server child", async () => {
    await sleep(2500);
    const servers = pseudoProcesses().filter((line) => line.includes(" lsp"));
    if (servers.length !== 1) throw new Error(`servers: ${servers.length}`);
  });
}

async function vocabularyChecks() {
  const file = path.join(folder(), "..", "intervalo.pseudo");
  fs.writeFileSync(file, spanishProgram);
  const loose = await vscode.workspace.openTextDocument(vscode.Uri.file(file));
  await vscode.window.showTextDocument(loose);
  await step("a loose Spanish program starts without diagnostics", async () => {
    await sleep(2000);
    if (diagnosticsOf(loose).length !== 0) throw new Error(JSON.stringify(diagnosticsOf(loose).map((item) => item.message)));
  });
  await step("rewriting it in English is analyzed with the English vocabulary", async () => {
    const edit = new vscode.WorkspaceEdit();
    edit.replace(loose.uri, new vscode.Range(loose.positionAt(0), loose.positionAt(loose.getText().length)), englishProgram);
    await vscode.workspace.applyEdit(edit);
    const found = await until("reported", () => (diagnosticsOf(loose).length > 0 ? diagnosticsOf(loose) : undefined));
    const messages = found.map((item) => item.message);
    if (messages.length !== 1 || !messages[0].includes("total")) throw new Error(JSON.stringify(messages));
    return messages[0];
  });
  await vscode.commands.executeCommand("workbench.action.revertAndCloseActiveEditor");
  fs.rmSync(file, { force: true });
}

module.exports = { configurationChecks, vocabularyChecks };
