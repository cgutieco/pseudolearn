import * as vscode from "vscode";
import { configurationMessage } from "../application/configuration_message";
import { resolveConfiguration } from "../application/configuration_resolver";
import { registerCommands } from "./commands";
import { ExtensionLifecycle } from "../application/extension_lifecycle";
import { readVscodeConfiguration } from "../adapters/vscode_configuration";
import { VscodeExtensionHost } from "../adapters/vscode_extension_host";
import { registerDebugCommands } from "./debug_commands";

let activeLifecycle: ExtensionLifecycle | undefined;

export function activate(context: vscode.ExtensionContext): void {
  const configuration = resolveConfiguration(readVscodeConfiguration(context));
  if (!configuration.ok) {
    void vscode.window.showErrorMessage(
      configurationMessage(configuration.failure, configuration.language),
    );
    return;
  }
  activeLifecycle = new ExtensionLifecycle(new VscodeExtensionHost(context));
  const result = activeLifecycle.activate();
  if (!result.ok) {
    activeLifecycle = undefined;
    void vscode.window.showErrorMessage("PseudoLearn could not activate.");
    return;
  }
  registerCommands(context, configuration.value);
  registerDebugCommands(context, configuration.value);
}

export function deactivate(): void {
  const result = activeLifecycle?.deactivate();
  activeLifecycle = undefined;
  if (result && !result.ok) {
    void vscode.window.showErrorMessage("PseudoLearn could not release all resources.");
  }
}
