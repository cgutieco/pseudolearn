import * as vscode from "vscode";
import type { ApiPort, Projection } from "../contracts/worker_transport";
import type { BrowserHostContext } from "../contracts/host_capabilities";
import { encodeArguments, numeric } from "../application/canonical_arguments";
import { acceptAnswer, answerValue, object, text } from "../application/wire_projection";
import { BrowserEffectHost, NETWORK_CAPABILITIES } from "./browser_effect_host";
import { publishRunActivity } from "./vscode_run_context";

interface CompletedEffect { effect: Record<string, Projection>; result: unknown }

export class BrowserRun {
  private readonly pendingEffects = new Map<string, Promise<CompletedEffect>>();
  private resource: string | undefined;
  private stopping = false;
  private effects: BrowserEffectHost | undefined;
  private starting = false;
  private analysis: string | undefined;

  constructor(private readonly api: ApiPort, private readonly output: vscode.OutputChannel) {}

  async start(argumentsValue: Record<string, unknown>, host: BrowserHostContext): Promise<void> {
    if (this.resource || this.starting) throw new Error("A program is already running");
    if (!vscode.workspace.isTrusted) throw new Error("Workspace trust is required");
    this.starting = true;
    this.stopping = false;
    publishRunActivity(true);
    this.pendingEffects.clear();
    this.effects = new BrowserEffectHost(host);
    try {
      await this.prepare(argumentsValue, host);
      if (this.stopping) await this.stop();
      await this.drive();
    } finally {
      await this.release();
      this.starting = false;
      this.effects.close();
      publishRunActivity(false);
    }
  }

  private async prepare(argumentsValue: Record<string, unknown>, _host: BrowserHostContext): Promise<void> {
    await this.api.call("negotiate", encodeArguments({ network_capabilities: NETWORK_CAPABILITIES }));
    const entropy = crypto.getRandomValues(new Uint32Array(2));
    const seed = BigInt.asIntN(64, (BigInt(entropy[0]!) << 32n) | BigInt(entropy[1]!));
    const request = { ...argumentsValue, seed: argumentsValue.seed ?? numeric(seed.toString()),
      observe: "events", host: { detached: true }, execution_mode: "live_record" };
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
    if (termination.kind === "awaiting_input") { await this.input(value); return true; }
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

  private async input(value: Record<string, Projection>): Promise<void> {
    const line = await vscode.window.showInputBox({ prompt: "PseudoLearn input / Entrada", ignoreFocusOut: true });
    const cancelled = line === undefined || this.stopping;
    if (cancelled) { await this.stop(); return; }
    const pending = object(value.pending_input);
    acceptAnswer(await this.api.call("input", encodeArguments({ resource: numeric(this.resource!), text: line,
      resource_id: numeric(text(pending.resource_id)), task_id: numeric(text(pending.task_id)),
      request_id: numeric(text(pending.request_id)) })));

  }

  private async effect(value: Record<string, Projection>): Promise<void> {
    const requests = Array.isArray(value.pending_effects) ? value.pending_effects : [value.pending_effect];
    for (const raw of requests) {
      const effect = object(raw);
      const sequence = text(effect.effect_seq);
      if (!this.pendingEffects.has(sequence)) {
        this.pendingEffects.set(sequence, this.effects!.perform(effect).then((result) => ({ effect, result })));
      }
    }
    const completed = await Promise.race(this.pendingEffects.values());
    const sequence = text(completed.effect.effect_seq);
    this.pendingEffects.delete(sequence);
    if (this.stopping) return;
    acceptAnswer(await this.api.call("effect_result", encodeArguments({ resource: numeric(this.resource!),
      effect_seq: numeric(sequence), result: completed.result })));

  }
}
