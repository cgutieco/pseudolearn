import * as path from "node:path";
import * as vscode from "vscode";
import { NodeDebugAdapter } from "../adapters/node_debug_adapter";
import { VscodeDocuments } from "../adapters/vscode_documents";
import { debugLaunch } from "../application/debug_configuration";
import { hasUnsavedChanges } from "../application/saved_snapshot_guard";
import type { ResolvedExtensionConfiguration } from "../contracts/extension_configuration";
import { entryKey } from "./command_context";

export function registerDebugCommands(
  extension: vscode.ExtensionContext,
  configuration: ResolvedExtensionConfiguration,
): void {
  extension.subscriptions.push(
    vscode.debug.registerDebugConfigurationProvider("pseudolearn", {
      resolveDebugConfiguration: (folder, requested) => resolve(folder, requested, configuration),
    }),
    vscode.debug.registerDebugAdapterDescriptorFactory("pseudolearn", {
      createDebugAdapterDescriptor: (session) => descriptor(extension, session, configuration),
    }),
    vscode.debug.registerDebugAdapterTrackerFactory("pseudolearn", { createDebugAdapterTracker: inputTracker }),
    vscode.commands.registerCommand("pseudolearn.debugFile", () => startFile()),
    vscode.commands.registerCommand("pseudolearn.debugProject", () => startProject(extension)),
  );
}

function resolve(
  folder: vscode.WorkspaceFolder | undefined,
  requested: vscode.DebugConfiguration,
  configuration: ResolvedExtensionConfiguration,
): vscode.DebugConfiguration | undefined {
  const launch = debugLaunch(requested);
  if (!vscode.workspace.isTrusted || !launch.ok) return refuse(configuration.interfaceLanguage);
  const target = launch.value.project
    ? { kind: "project" as const, directory: launch.value.project, entry: launch.value.entry ?? "" }
    : { kind: "file" as const, path: launch.value.program ?? "" };
  if (hasUnsavedChanges(new VscodeDocuments(), target)) return refuse(configuration.interfaceLanguage);
  return { type: "pseudolearn", request: "launch", name: requested.name || "PseudoLearn", ...launch.value,
    workspaceRoot: folder?.uri.fsPath ?? path.dirname(launch.value.program ?? launch.value.project ?? ""),
    profile: launch.value.profile ?? configuration.profile, strictness: launch.value.strictness ?? configuration.strictness };
}

function descriptor(extension: vscode.ExtensionContext, session: vscode.DebugSession, configuration: ResolvedExtensionConfiguration): vscode.DebugAdapterDescriptor {
  const adapter = new NodeDebugAdapter(configuration.serverPath,
    ["dap", "--language", configuration.interfaceLanguage, "--profile", configuration.profile,
      "--strictness", configuration.strictness], session.configuration.workspaceRoot as string | undefined);
  extension.subscriptions.push(adapter);
  return new vscode.DebugAdapterInlineImplementation(adapter);
}

function inputTracker(session: vscode.DebugSession): vscode.DebugAdapterTracker {
  let active: string | undefined;
  return { onDidSendMessage: (message: Record<string, unknown>) => {
    if (message.event === "terminated") active = undefined;
    if (message.event !== "pseudolearn/awaitingInput") return;
    const body = message.body as { token?: string } | undefined;
    const token = body?.token;
    if (!token) return;
    active = token;
    void vscode.window.showInputBox({ prompt: vscode.env.language.startsWith("es") ? "Entrada del programa" : "Program input", ignoreFocusOut: true })
      .then((text) => {
        if (active !== token) return;
        active = undefined;
        void session.customRequest("pseudolearn/input", { token, action: text === undefined ? "cancel" : "line", text });
      });
  } };
}

function startFile(): Thenable<boolean> | undefined {
  const document = vscode.window.activeTextEditor?.document;
  if (!document || document.isUntitled || document.languageId !== "pseudolearn") return undefined;
  return vscode.debug.startDebugging(vscode.workspace.getWorkspaceFolder(document.uri),
    { type: "pseudolearn", request: "launch", name: "PseudoLearn", program: document.uri.fsPath });
}

function startProject(extension: vscode.ExtensionContext): Thenable<boolean> | undefined {
  const folder = vscode.workspace.workspaceFolders?.[0];
  const entry = extension.workspaceState.get<string>(entryKey);
  if (!folder || !entry) return undefined;
  return vscode.debug.startDebugging(folder, { type: "pseudolearn", request: "launch", name: "PseudoLearn", project: folder.uri.fsPath, entry });
}

function refuse(language: "es" | "en"): undefined {
  void vscode.window.showWarningMessage(language === "es"
    ? "La depuración requiere un workspace confiable, fuentes guardadas y configuración VM válida."
    : "Debugging requires a trusted workspace, saved sources and valid VM configuration.");
  return undefined;
}
