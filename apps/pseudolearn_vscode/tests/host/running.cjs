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
    await vscode.window.showTextDocument(main, { preserveFocus: false });
    await vscode.commands.executeCommand("workbench.action.files.revert");
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

async function acceptanceChecks() {
  if (!process.env.PSEUDOLEARN_HOST_RUN_OUTPUT) return;
  await step("language constructs program prints the values derived from the rules", async () => {
    await open("../constructs.pseudo");
    await vscode.commands.executeCommand("pseudolearn.runFile");
    const captured = () => {
      const path = process.env.PSEUDOLEARN_HOST_RUN_OUTPUT;
      return require("node:fs").existsSync(path) ? require("node:fs").readFileSync(path, "utf8") : "";
    };
    await until("constructs output", () => captured().includes("5050"), 30000);
    await until("program finished", () => programs().length === 0, 30000);
    const output = captured();
    const written = output.split("\n").filter((line) => line.includes('"event":"output"')).join(" ");
    for (const line of ["3:15", "4:6", "12:0", "5050"]) {
      if (!written.includes(line)) throw new Error(`missing ${line}: ${output.slice(-600)}`);
    }
    return written;
  });
  await step("acceptance program reaches the real API without configuration", async () => {
    await open("../character.pseudo");
    await vscode.commands.executeCommand("pseudolearn.runFile");
    await until("program started", () => programs().length > 0);
    await until("program finished", () => programs().length === 0, 30000);
    const output = require("node:fs").readFileSync(process.env.PSEUDOLEARN_HOST_RUN_OUTPUT, "utf8");
    const written = output.split("\n").filter((line) => line.includes('"event":"output"'));
    if (!/200/.test(written.join()) || !/Rick Sanchez/.test(written.join()) || !/Alive/.test(written.join())) throw new Error(`unexpected output: ${output.slice(-600)}`);
    return written.join(" ");
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

module.exports = { refusalChecks, runChecks, acceptanceChecks, lifecycleChecks };
