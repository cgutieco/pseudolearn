import * as vscode from "vscode";
import type { DebugApiPort, DebugTarget } from "../contracts/debug_session";
import type { ApiPort } from "../contracts/worker_transport";
import { encodeArguments, numeric } from "../application/canonical_arguments";
import { acceptAnswer, object } from "../application/wire_projection";
import { record } from "../application/debug_protocol";
import type { BrowserWorkspace } from "./browser_workspace";
import { NETWORK_CAPABILITIES } from "./browser_effect_host";

export interface BrowserDebugOptions {
  profile: string;
  workspace?: BrowserWorkspace;
}

export function debugApi(api: ApiPort): DebugApiPort {
  return { call: async (operation, argumentsValue) => {
    const answer = await api.call(operation, encodeArguments(argumentsValue));
    acceptAnswer(answer);
    return record(object(answer.projection).value) ?? {};
  } };
}

export async function prepareTarget(api: DebugApiPort, launch: Record<string, unknown>, options: BrowserDebugOptions): Promise<DebugTarget> {
  await api.call("negotiate", { network_capabilities: NETWORK_CAPABILITIES });
  const execution = { profile: typeof launch.profile === "string" ? launch.profile : options.profile, seed: seed(launch.seed),
    observe: "events", host: { detached: true }, execution_mode: "live_record" };
  if (typeof launch.project === "string") return projectTarget(launch, options, execution);
  if (typeof launch.program !== "string") throw new Error("missing program");
  const uri = vscode.Uri.parse(launch.program);
  const text = new TextDecoder("utf-8", { fatal: true }).decode(await vscode.workspace.fs.readFile(uri));
  return { operation: "start", request: { ...execution, program: text }, sources: [{ sourceId: 0, path: launch.program, text }] };
}

async function projectTarget(launch: Record<string, unknown>, options: BrowserDebugOptions,
  execution: Record<string, unknown>): Promise<DebugTarget> {
  if (!options.workspace) throw new Error("Open a project folder");
  if (typeof launch.entry !== "string") throw new Error("missing entry");
  const snapshot = await options.workspace.read();
  const sources = snapshot.project.files.map((file) => ({ sourceId: file.source_id, path: snapshot.uris[file.path] ?? file.path,
    text: file.text }));
  return { operation: "start_project", request: { ...execution, project: snapshot.project, entry: launch.entry }, sources };
}

function seed(value: unknown) {
  if (typeof value === "string") return numeric(value);
  const entropy = crypto.getRandomValues(new Uint32Array(2));
  return numeric(BigInt.asIntN(64, (BigInt(entropy[0]!) << 32n) | BigInt(entropy[1]!)).toString());
}
