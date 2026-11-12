import * as path from "node:path";
import * as vscode from "vscode";
import { type Refusal, refusalMessage } from "../application/run_messages";
import { hasUnsavedChanges } from "../application/saved_snapshot_guard";
import type { RunTarget } from "../contracts/editor_run";
import { type CommandContext, entryKey, firstWorkspaceDirectory } from "./command_context";

export function registerRunCommands(command: CommandContext): vscode.Disposable[] {
  const refuse = (refusal: Refusal): void => {
    void vscode.window.showWarningMessage(refusalMessage(refusal, command.settings.language));
  };
  const launch = (target: RunTarget, workingDirectory: string): void => {
    if (hasUnsavedChanges(command.documents, target)) {
      refuse("unsavedChanges");
      return;
    }
    const outcome = command.controller.start({
      target,
      workingDirectory,
      settings: command.settings,
    });
    if (!outcome.ok) {
      refuse(outcome.refusal);
    }
  };
  return [
    vscode.commands.registerCommand("pseudolearn.runFile", () => runFile(launch)),
    vscode.commands.registerCommand("pseudolearn.runProject", () => runProject(command, launch, refuse)),
    vscode.commands.registerCommand("pseudolearn.stopRun", () =>
      command.controller.stop(command.settings),
    ),
  ];
}

function runFile(launch: (target: RunTarget, workingDirectory: string) => void): void {
  const file = vscode.window.activeTextEditor?.document;
  if (file?.languageId === "pseudolearn" && !file.isUntitled) {
    launch({ kind: "file", path: file.uri.fsPath }, path.dirname(file.uri.fsPath));
  }
}

function runProject(
  command: CommandContext,
  launch: (target: RunTarget, workingDirectory: string) => void,
  refuse: (refusal: Refusal) => void,
): void {
  const directory = firstWorkspaceDirectory(vscode.workspace);
  if (!directory) {
    return;
  }
  const entry = command.extension.workspaceState.get<string>(entryKey);
  if (!entry) {
    refuse("noEntry");
    return;
  }
  launch({ kind: "project", directory, entry }, directory);
}
