import * as vscode from "vscode";
import { ExtensionLifecycle } from "../application/extension_lifecycle";
import { VscodeExtensionHost } from "../adapters/vscode_extension_host";

let activeLifecycle: ExtensionLifecycle | undefined;

export function activate(context: vscode.ExtensionContext): void {
  activeLifecycle = new ExtensionLifecycle(new VscodeExtensionHost(context));
  const result = activeLifecycle.activate();
  if (!result.ok) {
    activeLifecycle = undefined;
    void vscode.window.showErrorMessage("PseudoLearn could not activate.");
  }
}

export function deactivate(): void {
  const result = activeLifecycle?.deactivate();
  activeLifecycle = undefined;
  if (result && !result.ok) {
    void vscode.window.showErrorMessage("PseudoLearn could not release all resources.");
  }
}
