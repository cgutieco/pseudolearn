const vscode = require("vscode");
const path = require("node:path");
const { step, until, folder } = require("./support.cjs");

const formatting = { tabSize: 2, insertSpaces: true };

async function formatChecks(main) {
  await step("formatting is idempotent", async () => {
    const edits = await vscode.commands.executeCommand("vscode.executeFormatDocumentProvider", main.uri, formatting);
    const edit = new vscode.WorkspaceEdit();
    for (const item of edits || []) edit.replace(main.uri, item.range, item.newText);
    await vscode.workspace.applyEdit(edit);
    const again = await vscode.commands.executeCommand("vscode.executeFormatDocumentProvider", main.uri, formatting);
    if ((again || []).some((item) => main.getText(item.range) !== item.newText)) throw new Error("not idempotent");
    await vscode.commands.executeCommand("workbench.action.files.revert");
  });
}

async function renameChecks(main, callPosition) {
  await step("rename across files is one edit and is reverted", async () => {
    const edit = await vscode.commands.executeCommand("vscode.executeDocumentRenameProvider", main.uri, callPosition(), "Triple");
    if (!edit) throw new Error("no edit");
    const names = edit.entries().map(([uri]) => path.basename(uri.fsPath));
    if (!names.includes("main.pseudo") || !names.includes("vectores.pseudo")) throw new Error(names.join());
    await vscode.workspace.applyEdit(edit);
    const geo = await vscode.workspace.openTextDocument(vscode.Uri.file(path.join(folder(), "geo/vectores.pseudo")));
    if (!geo.getText().includes("Triple") || !main.getText().includes("Triple")) throw new Error("not applied");
    for (const document of [geo, main]) {
      await vscode.window.showTextDocument(document);
      await vscode.commands.executeCommand("workbench.action.files.revert");
    }
    await until("reverted", () => !geo.getText().includes("Triple") && !main.getText().includes("Triple"));
  });
  await step("rename to a reserved word is rejected without edits", async () => {
    let rejected = false;
    try {
      const edit = await vscode.commands.executeCommand("vscode.executeDocumentRenameProvider", main.uri, callPosition(), "Algoritmo");
      rejected = !edit || edit.size === 0;
    } catch {
      rejected = true;
    }
    if (!rejected) throw new Error("reserved word accepted");
  });
}

module.exports = { formatChecks, renameChecks };
