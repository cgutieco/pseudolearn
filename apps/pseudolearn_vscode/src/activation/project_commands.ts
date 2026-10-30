import * as vscode from "vscode";
import { listProjectEntries } from "../application/entry_choice";
import { translateDocument } from "../application/translate_document";
import { type CommandContext, entryKey, firstWorkspaceDirectory } from "./command_context";

export function registerProjectCommands(command: CommandContext): vscode.Disposable[] {
  return [
    vscode.commands.registerCommand("pseudolearn.selectEntry", () => selectEntry(command)),
    vscode.commands.registerCommand("pseudolearn.translate", () => translate(command)),
  ];
}

async function selectEntry(command: CommandContext): Promise<void> {
  const directory = firstWorkspaceDirectory(vscode.workspace);
  if (!directory) {
    return;
  }
  const entries = await listProjectEntries(command.runner, {
    directory,
    settings: command.settings,
  });
  const choice = await vscode.window.showQuickPick(entries);
  if (choice) {
    await command.extension.workspaceState.update(entryKey, choice);
  }
}

async function translate(command: CommandContext): Promise<void> {
  const file = vscode.window.activeTextEditor?.document;
  const target = await vscode.window.showQuickPick(["es", "en"]);
  if (!file || (target !== "es" && target !== "en")) {
    return;
  }
  const outcome = await translateDocument(
    { runner: command.runner, edits: command.documents },
    {
      path: file.uri.fsPath,
      targetProfile: target,
      unsaved: file.isDirty,
      settings: command.settings,
    },
  );
  if (outcome !== "applied") {
    void vscode.window.showWarningMessage(`PseudoLearn: ${outcome}`);
  }
}
