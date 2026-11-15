import * as vscode from "vscode";
import { configurationMessage } from "../application/configuration_message";
import { configurationDiffers } from "../application/configuration_change";
import { resolveConfiguration } from "../application/configuration_resolver";
import { readVscodeConfiguration } from "../adapters/vscode_configuration";
import type { ResolvedExtensionConfiguration } from "../contracts/extension_configuration";
import { registerCommands } from "./commands";
import { registerDebugCommands } from "./debug_commands";

function startSession(
  extension: vscode.ExtensionContext,
  configuration: ResolvedExtensionConfiguration,
): vscode.Disposable {
  return vscode.Disposable.from(
    ...registerCommands(extension, configuration),
    ...registerDebugCommands(extension, configuration),
  );
}

export function startConfiguredSession(
  extension: vscode.ExtensionContext,
  initial: ResolvedExtensionConfiguration,
): vscode.Disposable {
  let current = initial;
  let session = startSession(extension, current);
  const watcher = vscode.workspace.onDidChangeConfiguration((event) => {
    if (!event.affectsConfiguration("pseudolearn")) return;
    const next = resolveConfiguration(readVscodeConfiguration(extension));
    if (!next.ok) {
      void vscode.window.showErrorMessage(configurationMessage(next.failure, next.language));
      return;
    }
    if (!configurationDiffers(current, next.value)) return;
    session.dispose();
    current = next.value;
    session = startSession(extension, current);
  });
  return { dispose: () => { watcher.dispose(); session.dispose(); } };
}
