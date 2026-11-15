import * as vscode from "vscode";
import { BrowserDebugAdapter } from "../adapters/browser_debug_adapter";
import { debugApi, prepareTarget } from "../adapters/browser_debug_target";
import { BrowserEffectHost } from "../adapters/browser_effect_host";
import type { BrowserWorkerClient } from "../adapters/browser_worker_client";
import type { BrowserWorkspace } from "../adapters/browser_workspace";
import { debugLaunch } from "../application/debug_configuration";
import { DebugSession } from "../application/debug_session";
import { inputTracker } from "./debug_input_tracker";

export interface BrowserDebugContext {
  extension: vscode.ExtensionContext;
  worker: () => BrowserWorkerClient;
  workspace: () => BrowserWorkspace | undefined;
  options: () => { profile: string };
}

export function registerBrowserDebugCommands(context: BrowserDebugContext): vscode.Disposable[] {
  return [
    vscode.debug.registerDebugConfigurationProvider("pseudolearn", { resolveDebugConfiguration: (_folder, requested) => resolve(requested) }),
    vscode.debug.registerDebugAdapterDescriptorFactory("pseudolearn", { createDebugAdapterDescriptor: (session) => descriptor(context, session) }),
    vscode.debug.registerDebugAdapterTrackerFactory("pseudolearn", { createDebugAdapterTracker: inputTracker }),
    vscode.commands.registerCommand("pseudolearn.debugFile", () => startFile()),
    vscode.commands.registerCommand("pseudolearn.debugProject", () => startProject(context)),
  ];
}

function resolve(requested: vscode.DebugConfiguration): vscode.DebugConfiguration | undefined {
  const launch = debugLaunch(requested);
  if (!vscode.workspace.isTrusted || !launch.ok || vscode.workspace.textDocuments.some((document) => document.isDirty)) {
    void vscode.window.showWarningMessage("PseudoLearn: debugging requires a trusted workspace, saved sources and a valid VM configuration.");
    return undefined;
  }
  return { ...requested, type: "pseudolearn", request: "launch", name: requested.name || "PseudoLearn", ...launch.value };
}

function descriptor(context: BrowserDebugContext, session: vscode.DebugSession): vscode.DebugAdapterDescriptor {
  const worker = context.worker();
  const api = debugApi(worker);
  const root = vscode.workspace.workspaceFolders?.[0]?.uri.toString();
  const args = Array.isArray(session.configuration.args) ? session.configuration.args as string[] : [];
  const debugSession = new DebugSession({
    api,
    effects: () => new BrowserEffectHost({ root, args }),
    prepare: (launch) => prepareTarget(api, launch, { profile: context.options().profile, workspace: context.workspace() }),
  });
  const adapter = new BrowserDebugAdapter(debugSession, () => worker.close());
  context.extension.subscriptions.push(adapter);
  return new vscode.DebugAdapterInlineImplementation(adapter);
}

function startFile(): Thenable<boolean> | undefined {
  const document = vscode.window.activeTextEditor?.document;
  if (!document || document.isUntitled || document.languageId !== "pseudolearn") return undefined;
  return vscode.debug.startDebugging(vscode.workspace.getWorkspaceFolder(document.uri),
    { type: "pseudolearn", request: "launch", name: "PseudoLearn", program: document.uri.toString() });
}

function startProject(context: BrowserDebugContext): Thenable<boolean> | undefined {
  const folder = vscode.workspace.workspaceFolders?.[0];
  const entry = context.extension.workspaceState.get<string>("pseudolearn.entry");
  if (!folder || !entry) {
    void vscode.window.showWarningMessage("PseudoLearn: open a project folder and select an entry first.");
    return undefined;
  }
  return vscode.debug.startDebugging(folder, { type: "pseudolearn", request: "launch", name: "PseudoLearn", project: folder.uri.toString(), entry });
}
