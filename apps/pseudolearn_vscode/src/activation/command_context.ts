import type * as vscode from "vscode";
import type { VscodeDocuments } from "../adapters/vscode_documents";
import type { RunController } from "../application/run_controller";
import type { CommandRunnerPort } from "../contracts/editor_documents";
import type { RunSettings } from "../contracts/editor_run";

export interface CommandContext {
  extension: vscode.ExtensionContext;
  settings: RunSettings;
  documents: VscodeDocuments;
  runner: CommandRunnerPort;
  controller: RunController;
}

export const entryKey = "pseudolearn.projectEntry";

export function firstWorkspaceDirectory(workspace: typeof vscode.workspace): string | undefined {
  return workspace.workspaceFolders?.[0]?.uri.fsPath;
}
