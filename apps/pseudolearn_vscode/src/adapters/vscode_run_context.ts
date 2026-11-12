import * as vscode from "vscode";

export const runningContextKey = "pseudolearn.running";

export function publishRunActivity(active: boolean): void {
  void vscode.commands.executeCommand("setContext", runningContextKey, active);
}
