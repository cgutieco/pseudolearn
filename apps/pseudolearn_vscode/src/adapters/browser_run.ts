import * as vscode from "vscode";
import type { ApiPort, Projection } from "../contracts/worker_transport";
import type { BrowserGrants } from "../contracts/host_capabilities";
import { encodeArguments, numeric } from "../application/canonical_arguments";
import { answerValue, object, text } from "../application/wire_projection";
import { BrowserEffectHost, NETWORK_CAPABILITIES } from "./browser_effect_host";

export class BrowserRun {
  private resource: string | undefined;
  private stopping = false;
  private effects: BrowserEffectHost | undefined;
  private starting = false;
  private analysis: string | undefined;

  constructor(private readonly api: ApiPort, private readonly output: vscode.OutputChannel) {}

  async start(argumentsValue: Record<string, unknown>, grants: BrowserGrants): Promise<void> {
    if (this.resource || this.starting) throw new Error("A program is already running");
    if (!vscode.workspace.isTrusted) throw new Error("Workspace trust is required");
    this.starting = true;
    this.stopping = false;
    this.effects = new BrowserEffectHost(grants);
    try {
      await this.prepare(argumentsValue, grants);
      if (this.stopping) await this.stop();
      await this.drive();
    } finally {
      await this.release();
      this.starting = false;
      this.effects.close();
    }
  }

  private async prepare(argumentsValue: Record<string, unknown>, grants: BrowserGrants): Promise<void> {
    await this.api.call("negotiate", encodeArguments({ network_capabilities: NETWORK_CAPABILITIES }));
    const permissions = grants.origins.length ? ["red"] : [];
    if (grants.files) permissions.push("archivos_lectura", ...(grants.files.writable ? ["archivos_escritura"] : []));
    const request = { ...argumentsValue, observe: "events", host: { detached: true, permissions,
      network_origins: grants.origins }, execution_mode: "live_record" };
    const result = argumentsValue.project ? await this.api.call("start_project", encodeArguments(request))
      : await this.startFile(request);
    const value = answerValue(result);
    if (typeof value.resource !== "string") throw new Error("Program rejected before execution");
    this.resource = value.resource;
  }

  async stop(): Promise<void> {
    this.stopping = true;
    this.effects?.close();
    if (this.resource) await this.api.call("cancel", encodeArguments({ resource: numeric(this.resource) }));
  }

  close(): void {
    this.stopping = true;
    this.effects?.close();
    this.api.close();
  }

  private async startFile(request: Record<string, unknown>) {
    const analysis = answerValue(await this.api.call("create_analysis", encodeArguments(request)));
    this.analysis = text(analysis.resource);
    return this.api.call("start", encodeArguments({ ...request, analysis: numeric(this.analysis) }));
  }

  private async drive(): Promise<void> {
    let printed = "";
    for (;;) {
      const value = answerValue(await this.api.call("advance", encodeArguments({ resource: numeric(this.resource!), batch_size: 64 })));
      const output = text(value.output);
      this.output.append(output.slice(printed.length));
      printed = output;
      if (!await this.handleResponse(value)) return;
      await new Promise<void>((resolve) => setTimeout(resolve, 0));
    }
  }

  private async handleResponse(value: Record<string, Projection>): Promise<boolean> {
    const termination = object(value.termination);
    if (termination.kind === "awaiting_input") { await this.input(); return true; }
    if (termination.kind === "awaiting_effect") { await this.effect(value); return true; }
    if (termination.kind === "running") return true;
    this.output.appendLine(`PseudoLearn: ${termination.kind}`);
    return false;
  }

  private async release(): Promise<void> {
    for (const resource of [this.resource, this.analysis]) {
      if (resource) await this.api.call("release", encodeArguments({ resource: numeric(resource) })).catch(() => undefined);
    }
    this.resource = undefined;
    this.analysis = undefined;
  }

  private async input(): Promise<void> {
    const line = await vscode.window.showInputBox({ prompt: "PseudoLearn input / Entrada", ignoreFocusOut: true });
    if (line === undefined || this.stopping) await this.stop();
    else await this.api.call("input", encodeArguments({ resource: numeric(this.resource!), text: line }));
  }

  private async effect(value: Record<string, Projection>): Promise<void> {
    const effect = object(value.pending_effect);
    const result = await this.effects!.perform(effect);
    if (this.stopping) return;
    await this.api.call("effect_result", encodeArguments({ resource: numeric(this.resource!), effect_seq: numeric(text(effect.effect_seq)), result }));
  }
}
