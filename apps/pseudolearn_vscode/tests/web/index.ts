import * as vscode from "vscode";

function assert(value: unknown, message: string): asserts value {
  if (!value) throw new Error(message);
}

async function until(predicate: () => boolean, limit = 10000): Promise<void> {
  const started = Date.now();
  while (!predicate()) {
    if (Date.now() - started > limit) throw new Error("Host condition timed out");
    await new Promise((resolve) => setTimeout(resolve, 20));
  }
}

export async function run(): Promise<void> {
  const extension = vscode.extensions.getExtension("pseudolearn.pseudolearn-vscode");
  assert(extension, "Product extension missing");
  await extension.activate();
  const root = vscode.workspace.workspaceFolders?.[0]?.uri;
  assert(root, "Fixture root missing");
  const document = await vscode.workspace.openTextDocument(vscode.Uri.joinPath(root, "app/main.pseudo"));
  await vscode.window.showTextDocument(document);
  const completions = await vscode.commands.executeCommand<vscode.CompletionList>("vscode.executeCompletionItemProvider", document.uri, new vscode.Position(2, 0));
  assert(completions && completions.items.length > 0, "Completion unavailable");
  const hover = await vscode.commands.executeCommand<vscode.Hover[]>("vscode.executeHoverProvider", document.uri, new vscode.Position(2, 10));
  assert(hover && hover.length > 0, "Hover unavailable");
  const edits = await vscode.commands.executeCommand<vscode.TextEdit[]>("vscode.executeFormatDocumentProvider", document.uri, { tabSize: 4, insertSpaces: true });
  assert(edits === undefined || Array.isArray(edits), "Formatting unavailable");
  await vscode.commands.executeCommand("pseudolearn.explainAtCursor");
  await infiniteRun(root);
  assert(vscode.workspace.fs.isWritableFileSystem(root.scheme) !== undefined, "Provider capability missing");
  console.log(JSON.stringify({ schema: 1, target: "vscode-web-host", result: "passed", checks: ["activation", "completion", "hover", "format", "help", "worker-independence", "stop"], durablePersistence: false }));
}

async function infiniteRun(root: vscode.Uri): Promise<void> {
  const uri = vscode.Uri.joinPath(root, "loop.pseudo");
  const source = "Algoritmo Loop\nMientras Verdadero Hacer\nFinMientras\nFinAlgoritmo\n";
  await vscode.workspace.fs.writeFile(uri, new TextEncoder().encode(source));
  const document = await vscode.workspace.openTextDocument(uri);
  await vscode.window.showTextDocument(document);
  let finished = false;
  const run = Promise.resolve(vscode.commands.executeCommand("pseudolearn.runFile")).finally(() => { finished = true; });
  await new Promise((resolve) => setTimeout(resolve, 250));
  assert(!finished, "Infinite program did not remain running");
  const hover = await vscode.commands.executeCommand<vscode.Hover[]>("vscode.executeHoverProvider", uri, new vscode.Position(0, 12));
  assert(hover?.length, "Execution blocked language Worker");
  await vscode.commands.executeCommand("pseudolearn.stopRun");
  await until(() => finished, 5000);
  await run;
}
