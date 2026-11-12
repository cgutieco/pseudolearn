import type { DebugMessage, DebugPorts } from "../contracts/debug_session";
import { setBreakpoints } from "./debug_breakpoints";
import { control } from "./debug_control";
import { inspect } from "./debug_inspection";
import { close, configurationDone, initialize, launch, terminate } from "./debug_lifecycle";
import { event, response } from "./debug_protocol";
import { pumpBatch } from "./debug_pump";
import { createState, type DebugState } from "./debug_state";

const lifecycleCommands = new Set(["initialize", "launch", "configurationDone", "terminate", "disconnect"]);
const controlCommands = new Set(["continue", "next", "stepIn", "stepOut", "pause", "stepBack", "pseudolearn/input"]);
const inspectionCommands = new Set(["threads", "stackTrace", "scopes", "variables", "evaluate", "source", "loadedSources"]);

export class DebugSession {
  private readonly state: DebugState;

  constructor(ports: DebugPorts) {
    this.state = createState(ports);
  }

  async handle(request: DebugMessage): Promise<DebugMessage[]> {
    this.state.pending = [];
    let reply: DebugMessage;
    try {
      reply = response(request, { ok: true, body: await this.dispatch(request) });
    } catch (error) {
      reply = response(request, { ok: false, message: error instanceof Error ? error.message : String(error) });
    }
    return [reply, ...this.state.pending.splice(0)];
  }

  async pump(): Promise<DebugMessage[]> {
    this.state.pending = [];
    try {
      await pumpBatch(this.state);
    } catch (error) {
      this.state.pending.push(event("output", { category: "stderr", output: `${error instanceof Error ? error.message : String(error)}\n` }));
      await terminate(this.state);
    }
    return this.state.pending.splice(0);
  }

  canAdvance(): boolean {
    return this.state.running && this.state.inputToken === undefined && !this.state.effects?.isPending();
  }

  waitingForEffect(): Promise<void> | undefined {
    return this.state.running && this.state.effects?.isPending() ? this.state.effects.settle() : undefined;
  }

  isFinished(): boolean {
    return this.state.finished;
  }

  async close(): Promise<void> {
    await close(this.state);
  }

  private async dispatch(request: DebugMessage): Promise<unknown> {
    if (request.type !== "request" || typeof request.seq !== "number") throw new Error("invalid debug request");
    const command = String(request.command ?? "");
    if (lifecycleCommands.has(command)) return this.lifecycle(command, request);
    if (command === "setBreakpoints") return setBreakpoints(this.state, request);
    if (controlCommands.has(command)) return control(this.state, request);
    if (inspectionCommands.has(command)) return inspect(this.state, request);
    throw new Error("unsupported debug request");
  }

  private async lifecycle(command: string, request: DebugMessage): Promise<unknown> {
    if (command === "initialize") return initialize(this.state, request);
    if (command === "launch") return launch(this.state, request);
    if (command === "configurationDone") return configurationDone(this.state);
    await terminate(this.state);
    return {};
  }
}
