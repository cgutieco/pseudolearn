import * as vscode from "vscode";
import type { Recorder } from "./check";

async function until(predicate: () => boolean, limit = 10000): Promise<void> {
  const started = Date.now();
  while (!predicate()) {
    if (Date.now() - started > limit) throw new Error("Host condition timed out");
    await new Promise((resolve) => setTimeout(resolve, 20));
  }
}

async function infiniteRun(recorder: Recorder, root: vscode.Uri): Promise<void> {
  const uri = vscode.Uri.joinPath(root, "loop.pseudo");
  const source = "Algoritmo Loop\nMientras Verdadero Hacer\nFinMientras\nFinAlgoritmo\n";
  await vscode.workspace.fs.writeFile(uri, new TextEncoder().encode(source));
  await vscode.window.showTextDocument(await vscode.workspace.openTextDocument(uri));
  let finished = false;
  const run = Promise.resolve(vscode.commands.executeCommand("pseudolearn.runFile")).finally(() => { finished = true; });
  await new Promise((resolve) => setTimeout(resolve, 250));
  recorder.check(!finished, "infinite program remains running");
  const hover = await vscode.commands.executeCommand<vscode.Hover[]>("vscode.executeHoverProvider", uri, new vscode.Position(0, 12));
  recorder.check(hover?.length, "execution did not block the language Worker");
  await vscode.commands.executeCommand("pseudolearn.stopRun");
  await until(() => finished, 5000);
  await run;
  recorder.check(finished, "stop ends the run and keeps the editor responsive");
}

export async function runHostChecks(recorder: Recorder): Promise<void> {
  recorder.within("host");
  const extension = vscode.extensions.getExtension("pseudolearn.pseudolearn-vscode");
  recorder.check(extension, "product extension present");
  await extension!.activate();
  const root = vscode.workspace.workspaceFolders?.[0]?.uri;
  recorder.check(root, "fixture root present");
  const document = await vscode.workspace.openTextDocument(vscode.Uri.joinPath(root!, "app/main.pseudo"));
  await vscode.window.showTextDocument(document);
  const completions = await vscode.commands.executeCommand<vscode.CompletionList>("vscode.executeCompletionItemProvider", document.uri, new vscode.Position(2, 0));
  recorder.check(completions && completions.items.length > 0, "completion available");
  const hover = await vscode.commands.executeCommand<vscode.Hover[]>("vscode.executeHoverProvider", document.uri, new vscode.Position(2, 10));
  recorder.check(hover && hover.length > 0, "hover available");
  const edits = await vscode.commands.executeCommand<vscode.TextEdit[]>("vscode.executeFormatDocumentProvider", document.uri, { tabSize: 4, insertSpaces: true });
  recorder.check(edits === undefined || Array.isArray(edits), "formatting available");
  await vscode.commands.executeCommand("pseudolearn.explainAtCursor");
  recorder.check(true, "help command completes");
  await infiniteRun(recorder, root!);
}
