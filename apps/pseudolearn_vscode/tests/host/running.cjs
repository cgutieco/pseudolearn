const vscode = require("vscode");
const { step, sleep, until, pseudoProcesses, open } = require("./support.cjs");

function programs() {
  return pseudoProcesses().filter((line) => !line.includes(" lsp"));
}

async function refusalChecks(main) {
  await step("run is refused while the document has unsaved changes", async () => {
    const edit = new vscode.WorkspaceEdit();
    edit.insert(main.uri, new vscode.Position(0, 0), "\n");
    await vscode.workspace.applyEdit(edit);
    await vscode.commands.executeCommand("pseudolearn.runProject");
    await sleep(1500);
    if (programs().length > 0) throw new Error("a program was started");
    await vscode.commands.executeCommand("undo");
    await until("clean", () => !main.isDirty);
  });
}

async function runChecks(main) {
  await step("select entry, run project and stop it without leftovers", async () => {
    await vscode.window.showTextDocument(main);
    const selecting = vscode.commands.executeCommand("pseudolearn.selectEntry");
    await sleep(2500);
    await vscode.commands.executeCommand("workbench.action.acceptSelectedQuickOpenItem");
    await selecting;
    await vscode.commands.executeCommand("pseudolearn.runProject");
    await until("program", () => programs().length > 0);
    await sleep(1500);
    await vscode.commands.executeCommand("pseudolearn.stopRun");
    await until("no program left", () => programs().length === 0, 10000);
  });
  await step("run file waits for input and stop leaves no process", async () => {
    await open("../saludo.pseudo");
    await vscode.commands.executeCommand("pseudolearn.runFile");
    await sleep(3000);
    await vscode.commands.executeCommand("pseudolearn.stopRun");
    await until("no program left", () => programs().length === 0, 10000);
  });
}

async function lifecycleChecks() {
  await step("explain answers without error", async () => {
    await vscode.commands.executeCommand("pseudolearn.explainAtCursor");
  });
  await step("restart server keeps one language server child", async () => {
    await vscode.commands.executeCommand("pseudolearn.restartServer");
    await sleep(2500);
    const servers = pseudoProcesses().filter((line) => line.includes(" lsp"));
    if (servers.length !== 1) throw new Error(`servers: ${servers.length}`);
  });
}

module.exports = { refusalChecks, runChecks, lifecycleChecks };
