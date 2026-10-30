import * as vscode from "vscode";
import { NodeCommandRunner } from "../adapters/node_command_runner";
import { NodeProcessLauncher } from "../adapters/node_process_launcher";
import { VscodeDocuments } from "../adapters/vscode_documents";
import { VscodeLanguageClientFactory } from "../adapters/vscode_language_client";
import { VscodeRunPresenter } from "../adapters/vscode_run_presenter";
import { ClientLifecycle } from "../application/client_lifecycle";
import { RunController } from "../application/run_controller";
import type { ResolvedExtensionConfiguration } from "../contracts/extension_configuration";
import type { RunPresenterPort, RunSettings } from "../contracts/editor_run";
import type { CommandContext } from "./command_context";
import { registerExplainCommand } from "./explain_commands";
import { registerProjectCommands } from "./project_commands";
import { registerRunCommands } from "./run_commands";

function toSettings(configuration: ResolvedExtensionConfiguration): RunSettings {
  return {
    executable: configuration.serverPath,
    language: configuration.interfaceLanguage,
    profile: configuration.profile,
    strictness: configuration.strictness,
  };
}

function createController(presenter: RunPresenterPort): RunController {
  return new RunController({
    launcher: new NodeProcessLauncher(),
    presenter,
    scheduler: {
      after: (milliseconds, task) => {
        const timer = setTimeout(task, milliseconds);
        return { dispose: () => clearTimeout(timer) };
      },
    },
  });
}

export function registerCommands(
  extension: vscode.ExtensionContext,
  configuration: ResolvedExtensionConfiguration,
): void {
  const settings = toSettings(configuration);
  const presenter = new VscodeRunPresenter();
  const controller = createController(presenter);
  const command: CommandContext = {
    extension,
    settings,
    documents: new VscodeDocuments(),
    runner: new NodeCommandRunner(),
    controller,
  };
  const client = new ClientLifecycle(new VscodeLanguageClientFactory(), settings.executable);
  extension.subscriptions.push(
    presenter,
    { dispose: () => controller.dispose(settings) },
    { dispose: () => void client.stop() },
    ...registerRunCommands(command),
    ...registerProjectCommands(command),
    ...registerExplainCommand(client, settings.language),
    vscode.commands.registerCommand("pseudolearn.restartServer", () => client.restart()),
  );
  void client.start();
}
