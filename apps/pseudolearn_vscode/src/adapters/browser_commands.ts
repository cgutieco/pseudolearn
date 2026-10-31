import * as vscode from "vscode";
import { encodeArguments } from "../application/canonical_arguments";
import { answerValue, object } from "../application/wire_projection";
import type { ApiPort } from "../contracts/worker_transport";
import type { BrowserGrants } from "../contracts/host_capabilities";
import type { BrowserLanguageService } from "./browser_language_client";
import type { BrowserWorkspace } from "./browser_workspace";
import type { BrowserRun } from "./browser_run";
import { scratchRoot } from "./browser_scratch_files";

export interface BrowserCommands {
  extension: vscode.ExtensionContext;
  api: ApiPort;
  language: BrowserLanguageService;
  workspace?: BrowserWorkspace;
  run: BrowserRun;
  output: vscode.OutputChannel;
  grants: BrowserGrants;
  options: { profile: string; strictness: string; locale: string };
}

function register(name: string, action: () => Promise<unknown>): vscode.Disposable {
  return vscode.commands.registerCommand(name, () => action().catch((error) => vscode.window.showErrorMessage(String(error))));
}

export function browserCommands(context: BrowserCommands): vscode.Disposable[] {
  return [
    register("pseudolearn.runFile", () => runFile(context)),
    register("pseudolearn.runProject", () => runProject(context)),
    register("pseudolearn.selectEntry", () => selectEntry(context)),
    register("pseudolearn.stopRun", () => context.run.stop()),
    register("pseudolearn.translate", () => translate(context)),
    register("pseudolearn.explainAtCursor", () => explain(context)),
    register("pseudolearn.grantNetwork", () => grantNetwork(context)),
    register("pseudolearn.grantFiles", () => grantFiles(context)),
    register("pseudolearn.showCapabilities", async () => vscode.window.showInformationMessage(
      "PseudoLearn browser: local Wasm execution, input, language tools; HTTP requires an explicit origin. Program files require a confined provider. AOT, FFI, processes and browser debugging are unavailable.")),
  ];
}

function savedDocument(): vscode.TextDocument {
  const document = vscode.window.activeTextEditor?.document;
  if (!document || document.languageId !== "pseudolearn") throw new Error("Open a PseudoLearn file");
  if (vscode.workspace.textDocuments.some((entry) => entry.isDirty)) throw new Error("Save workspace changes before running");
  return document;
}

async function runFile(context: BrowserCommands): Promise<void> {
  const document = savedDocument();
  context.output.show(true);
  await context.run.start({ program: document.getText(), ...context.options }, context.grants);
}

async function runProject(context: BrowserCommands): Promise<void> {
  savedDocument();
  if (!context.workspace) throw new Error("Open a project folder");
  const snapshot = await context.workspace.read();
  const entry = context.extension.workspaceState.get<string>("pseudolearn.entry");
  if (!entry) throw new Error("Select a project entry first");
  context.output.show(true);
  await context.run.start({ project: snapshot.project, entry, ...context.options }, context.grants);
}

async function selectEntry(context: BrowserCommands): Promise<void> {
  if (!context.workspace) throw new Error("Open a project folder");
  const snapshot = await context.workspace.read();
  const entry = await vscode.window.showQuickPick(snapshot.entries, { title: "PseudoLearn: select entry / elegir entrada" });
  if (entry !== undefined) await context.extension.workspaceState.update("pseudolearn.entry", entry);
}

async function translate(context: BrowserCommands): Promise<void> {
  const document = savedDocument();
  const version = document.version;
  const target = await vscode.window.showQuickPick(["es", "en"], { title: "PseudoLearn vocabulary / vocabulario" });
  if (!target) return;
  const result = answerValue(await context.api.call("translate", encodeArguments({ program: document.getText(), target_profile: target,
    strictness: context.options.strictness })));
  if (document.version !== version) throw new Error("Document changed; repeat translation");
  const edit = new vscode.WorkspaceEdit();
  edit.replace(document.uri, new vscode.Range(document.positionAt(0), document.positionAt(document.getText().length)), String(result.text));
  if (!await vscode.workspace.applyEdit(edit)) throw new Error("Translation edit rejected");
}

async function explain(context: BrowserCommands): Promise<void> {
  const editor = vscode.window.activeTextEditor;
  if (!editor) return;
  const result = await context.language.client.sendRequest<{ contents?: { value?: string } } | null>("workspace/executeCommand", {
    command: "pseudolearn.explain", arguments: [{ uri: editor.document.uri.toString(), version: editor.document.version,
      position: { line: editor.selection.active.line, character: editor.selection.active.character }, format: "plaintext" }],
  });
  context.output.appendLine(result?.contents?.value ?? "No help at this position / No hay ayuda en esta posición");
  context.output.show(true);
}

async function grantNetwork(context: BrowserCommands): Promise<void> {
  if (!vscode.workspace.isTrusted) throw new Error("Workspace trust is required");
  const origin = await vscode.window.showInputBox({ prompt: "Exact HTTP origin / Origen HTTP exacto (https://example.com)" });
  if (origin === undefined) return;
  if (origin === "") { context.grants.origins.length = 0; await context.run.stop(); return; }
  const url = new URL(origin);
  if (!["http:", "https:"].includes(url.protocol) || url.origin !== origin) throw new Error("Enter an exact HTTP origin");
  if (!context.grants.origins.includes(origin)) context.grants.origins.push(origin);
}

async function grantFiles(context: BrowserCommands): Promise<void> {
  if (!vscode.workspace.isTrusted) throw new Error("Workspace trust is required");
  const choice = await vscode.window.showQuickPick(["Read and write / Leer y escribir", "Read only / Solo lectura", "Revoke / Revocar"],
    { title: "Temporary program files / Archivos temporales del programa" });
  if (!choice) return;
  await context.run.stop();
  context.grants.files = choice.startsWith("Revoke") ? undefined : { root: scratchRoot, confined: true, writable: choice.startsWith("Read and write") };
  context.output.appendLine("Program files use temporary memory; they are separate from saved editor files. / Los archivos del programa usan memoria temporal, separada del editor.");
}
