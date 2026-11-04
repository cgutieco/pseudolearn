import * as vscode from "vscode";
import { BrowserRun } from "../../src/adapters/browser_run";
import { BrowserWorkerClient } from "../../src/adapters/browser_worker_client";
import { BrowserWorkspace } from "../../src/adapters/browser_workspace";
import type { BrowserHostContext } from "../../src/contracts/host_capabilities";

export type Answer = string | undefined;

export interface Stack {
  run: BrowserRun;
  api: BrowserWorkerClient;
  output: string[];
  prompts: () => number;
  close: () => void;
}

let generation = 0;

export function openStack(answers: Answer[]): Stack {
  const extension = vscode.extensions.getExtension("pseudolearn.pseudolearn-vscode");
  if (!extension) throw new Error("Product extension missing");
  const url = (path: string) => vscode.Uri.joinPath(extension.extensionUri, path).toString();
  const api = new BrowserWorkerClient(new Worker(url("dist/web/execution_worker.js")), {
    channel: "execution", session: `scenario-${crypto.randomUUID()}`, generation: ++generation, wasm: url("dist/web/wasm/pseudolearn_wasm.js") });
  const output: string[] = [];
  const channel = { append: (text: string) => output.push(text), appendLine: (text: string) => output.push(`${text}\n`) };
  let prompts = 0;
  (vscode.window as unknown as { showInputBox: () => Promise<Answer> }).showInputBox = async () => { prompts += 1; return answers.shift(); };
  const run = new BrowserRun(api, channel as unknown as vscode.OutputChannel);
  return { run, api, output, prompts: () => prompts, close: () => run.close() };
}

export const optionsFor = (profile: "es" | "en") => ({ profile, locale: profile });

export async function projectRequest(stack: Stack, root: string, profile: "es" | "en") {
  const snapshot = await new BrowserWorkspace(stack.api, vscode.Uri.parse(root)).read();
  return { project: snapshot.project, entry: "app/main", ...optionsFor(profile) };
}

export type { BrowserHostContext };
