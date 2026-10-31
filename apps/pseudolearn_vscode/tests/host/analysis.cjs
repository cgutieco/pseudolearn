const vscode = require("vscode");
const path = require("node:path");
const { step, sleep, until, pseudoProcesses, diagnosticsOf } = require("./support.cjs");

const commandIds = [
  "pseudolearn.runFile",
  "pseudolearn.runProject",
  "pseudolearn.stopRun",
  "pseudolearn.selectEntry",
  "pseudolearn.explainAtCursor",
  "pseudolearn.translate",
  "pseudolearn.restartServer",
];

async function activationChecks(extension) {
  await step("extension is installed from the VSIX", async () => {
    if (!extension) throw new Error("not installed");
    if (!extension.extensionPath.includes("extensions")) throw new Error(extension.extensionPath);
    return extension.extensionPath;
  });
  await step("extension activates and registers every command", async () => {
    await extension.activate();
    const commands = await vscode.commands.getCommands(true);
    const missing = commandIds.filter((id) => !commands.includes(id));
    if (missing.length > 0) throw new Error(`missing ${missing}`);
  });
  await step("activation starts no program except the language server", async () => {
    const programs = pseudoProcesses().filter((line) => !line.includes(" lsp"));
    if (programs.length > 0) throw new Error(programs.join("\n"));
  });
}

async function diagnosticChecks(main) {
  await step("language id is pseudolearn", async () => {
    if (main.languageId !== "pseudolearn") throw new Error(main.languageId);
  });
  await step("valid project reports no diagnostics", async () => {
    await sleep(3000);
    const found = diagnosticsOf(main);
    if (found.length !== 0) throw new Error(JSON.stringify(found.map((item) => item.message)));
  });
  await step("unsaved typo produces a diagnostic from the overlay", async () => {
    const edit = new vscode.WorkspaceEdit();
    const start = main.positionAt(main.getText().indexOf("Doble(numero)") + "Doble(".length);
    edit.replace(main.uri, new vscode.Range(start, start.translate(0, "numero".length)), "totall");
    await vscode.workspace.applyEdit(edit);
    const found = await until("diagnostic", () => (diagnosticsOf(main).length > 0 ? diagnosticsOf(main) : undefined));
    return found.map((item) => item.message).join(" | ");
  });
  await step("undoing the typo clears the diagnostic", async () => {
    await vscode.commands.executeCommand("undo");
    await until("cleared", () => diagnosticsOf(main).length === 0);
  });
}

async function navigationChecks(main, callPosition) {
  await step("definition navigates to a closed file", async () => {
    const locations = await vscode.commands.executeCommand("vscode.executeDefinitionProvider", main.uri, callPosition());
    const target = locations && locations[0] && (locations[0].targetUri || locations[0].uri);
    if (!target || !target.fsPath.endsWith(path.join("geo", "vectores.pseudo"))) {
      throw new Error(JSON.stringify(locations));
    }
  });
  await step("hover returns help", async () => {
    const hovers = await vscode.commands.executeCommand("vscode.executeHoverProvider", main.uri, new vscode.Position(2, 3));
    if (!hovers || hovers.length === 0) throw new Error("no hover");
  });
  await step("completion offers items", async () => {
    const list = await vscode.commands.executeCommand("vscode.executeCompletionItemProvider", main.uri, new vscode.Position(4, 0));
    if (!list || list.items.length === 0) throw new Error("no items");
    return list.items.length;
  });
  await step("document symbols are reported", async () => {
    const symbols = await vscode.commands.executeCommand("vscode.executeDocumentSymbolProvider", main.uri);
    if (!symbols || symbols.length === 0) throw new Error("no symbols");
  });
  await step("semantic tokens are reported", async () => {
    const tokens = await vscode.commands.executeCommand("vscode.provideDocumentSemanticTokens", main.uri);
    if (!tokens || !tokens.data || tokens.data.length === 0) throw new Error("no tokens");
    return tokens.data.length / 5;
  });
}

module.exports = { activationChecks, diagnosticChecks, navigationChecks };
