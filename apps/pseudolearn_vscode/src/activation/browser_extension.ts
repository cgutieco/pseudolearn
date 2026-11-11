import * as vscode from "vscode";
import { BrowserWorkerClient } from "../adapters/browser_worker_client";
import { BrowserLanguageService } from "../adapters/browser_language_client";
import { BrowserWorkspace } from "../adapters/browser_workspace";
import { BrowserRun } from "../adapters/browser_run";
import { browserCommands } from "../adapters/browser_commands";
import type { BrowserCommands } from "../adapters/browser_commands";

let active: BrowserCommands | undefined;
let generation = 0;

function worker(context: vscode.ExtensionContext, channel: "language" | "execution"): BrowserWorkerClient {
  const url = vscode.Uri.joinPath(context.extensionUri, `dist/web/${channel}_worker.js`).toString();
  const wasm = vscode.Uri.joinPath(context.extensionUri, "dist/web/wasm/pseudolearn_wasm.js").toString();
  return new BrowserWorkerClient(new Worker(url, { name: `PseudoLearn ${channel}` }), {
    channel, session: crypto.randomUUID(), generation: ++generation, wasm,
  });
}

export async function activate(context: vscode.ExtensionContext): Promise<void> {
  if (!vscode.workspace.isTrusted) return;
  const options = configuredOptions();
  const languageApi = worker(context, "language");
  const runApi = worker(context, "execution");
  const language = new BrowserLanguageService(languageApi, options);
  const output = vscode.window.createOutputChannel("PseudoLearn");
  const root = vscode.workspace.workspaceFolders?.[0]?.uri;
  const workspace = root ? new BrowserWorkspace(languageApi, root) : undefined;
  const run = new BrowserRun(runApi, output);
  active = { extension: context, api: languageApi, language, workspace, run, output, host: { root: vscode.workspace.workspaceFolders?.[0]?.uri.toString() }, options };
  context.subscriptions.push(output, ...browserCommands(active), { dispose: () => { run.close(); void language.close(); } },
    vscode.commands.registerCommand("pseudolearn.restartServer", () => restart(context)),
    vscode.workspace.onDidChangeConfiguration((event) => void reconfigure(context, event)),
    vscode.workspace.onDidSaveTextDocument(() => void synchronize(active!)),
    vscode.workspace.onDidCreateFiles(() => void synchronize(active!)),
    vscode.workspace.onDidDeleteFiles(() => void synchronize(active!)),
    vscode.workspace.onDidRenameFiles(() => void synchronize(active!)));
  await language.client.start();
  await synchronize(active);
}

function configuredOptions(): BrowserCommands["options"] {
  const configuration = vscode.workspace.getConfiguration("pseudolearn");
  return { profile: configuration.get("profile", "es"), locale: configuration.get("interfaceLanguage", "es") };
}

async function reconfigure(context: vscode.ExtensionContext, event: vscode.ConfigurationChangeEvent): Promise<void> {
  if (!active || !event.affectsConfiguration("pseudolearn")) return;
  const next = configuredOptions();
  if (next.profile === active.options.profile && next.locale === active.options.locale) return;
  active.options = next;
  await restart(context);
}

async function synchronize(context: BrowserCommands): Promise<void> {
  try {
    if (!context.workspace) return;
    const snapshot = await context.workspace.read();
    if (!snapshot.project.manifests.length) return;
    await context.language.snapshot(context.workspace.lspParameters(snapshot, context.options));
  } catch (error) { context.output.appendLine(`PseudoLearn snapshot stale / desactualizado: ${String(error)}`); }
}

async function restart(context: vscode.ExtensionContext): Promise<void> {
  const previous = active;
  if (!previous) return;
  await previous.language.close();
  previous.api = worker(context, "language");
  previous.language = new BrowserLanguageService(previous.api, previous.options);
  const root = vscode.workspace.workspaceFolders?.[0]?.uri;
  previous.workspace = root ? new BrowserWorkspace(previous.api, root) : undefined;
  await previous.language.client.start();
  await synchronize(previous);
}

export function deactivate(): void {
  active?.run.close();
  void active?.language.close();
  active = undefined;
}
