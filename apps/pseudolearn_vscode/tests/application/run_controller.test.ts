import { describe, expect, it } from "vitest";
import { RunController, stopGraceMilliseconds } from "../../src/application/run_controller";
import { finishLabel } from "../../src/application/run_messages";
import type {
  ProcessLauncherPort,
  RunCompletion,
  RunEvent,
  RunPresenterPort,
  RunProcessPort,
  RunSettings,
  RunState,
  SchedulerPort,
} from "../../src/contracts/editor_run";

const settings: RunSettings = { executable: "pseudo", language: "es", profile: "es", strictness: "strict" };
const target = { kind: "file", path: "p.pseudo" } as const;

class FakeProcess implements RunProcessPort {
  sent: string[] = [];
  terminated = false;
  lineListener: (line: string) => void = () => undefined;
  exitListener: (code: number | null) => void = () => undefined;
  onLine(listener: (line: string) => void): void { this.lineListener = listener; }
  onExit(listener: (code: number | null) => void): void { this.exitListener = listener; }
  send(line: string): void { this.sent.push(line); }
  terminate(): void { this.terminated = true; }
}

class Harness {
  processes: FakeProcess[] = [];
  states: RunState[] = [];
  completions: Array<RunCompletion | undefined> = [];
  diagnostics: Array<Extract<RunEvent, { event: "diagnostics" }>> = [];
  output: string[] = [];
  technical: string[] = [];
  inputs: Array<string | undefined> = [];
  timers: Array<() => void> = [];
  launches: string[][] = [];
  readonly controller: RunController;

  constructor() {
    const launcher: ProcessLauncherPort = {
      launch: (_executable, args) => {
        const process = new FakeProcess();
        this.processes.push(process);
        this.launches.push(args);
        return process;
      },
    };
    const presenter: RunPresenterPort = {
      showOutput: (text) => this.output.push(text),
      showDiagnostics: (event) => this.diagnostics.push(event),
      showState: (state, _language, completion) => {
        this.states.push(state);
        this.completions.push(completion);
      },
      requestInput: async () => this.inputs.shift(),
      showTechnicalLine: (line) => this.technical.push(line),
    };
    const scheduler: SchedulerPort = {
      after: (_milliseconds, task) => {
        this.timers.push(task);
        return { dispose: () => undefined };
      },
    };
    this.controller = new RunController({ launcher, presenter, scheduler });
  }

  start(): FakeProcess {
    this.controller.start({ target, workingDirectory: ".", settings });
    return this.processes[this.processes.length - 1]!;
  }
}

const hello = '{"event":"hello","schema":1}';
const wait = () => new Promise((resolve) => setTimeout(resolve, 0));

describe("RunController input", () => {
  it("answers awaiting_input with the typed line, including an empty line", async () => {
    const harness = new Harness();
    const process = harness.start();
    harness.inputs.push("");
    process.lineListener(hello);
    process.lineListener('{"event":"awaiting_input"}');
    await wait();
    expect(process.sent).toEqual(['{"command":"input","text":""}']);
  });

  it("cancels the run when the input box is dismissed instead of sending an empty line", async () => {
    const harness = new Harness();
    const process = harness.start();
    harness.inputs.push(undefined);
    process.lineListener('{"event":"awaiting_input"}');
    await wait();
    expect(process.sent).toEqual(['{"command":"cancel"}']);
  });

});

describe("RunController sessions", () => {
  it("rejects a second run while one is active and allows it after finishing", () => {
    const harness = new Harness();
    const first = harness.start();
    expect(harness.controller.start({ target, workingDirectory: ".", settings })).toEqual({
      ok: false,
      refusal: "runActive",
    });
    first.lineListener('{"event":"finished","status":"completed","termination":"completed","exit_code":0}');
    first.exitListener(0);
    expect(harness.controller.start({ target, workingDirectory: ".", settings })).toEqual({ ok: true });
  });

  it("shows program output as text and never as events", () => {
    const harness = new Harness();
    const process = harness.start();
    process.lineListener('{"event":"output","text":"{\\"event\\":\\"finished\\"}"}');
    expect(harness.output).toEqual(['{"event":"finished"}']);
    expect(harness.controller.isActive).toBe(true);
  });

  it("does not report successful completion when diagnostics contain errors", () => {
    const harness = new Harness();
    const process = harness.start();
    process.lineListener(
      '{"event":"diagnostics","diagnostics":[{"severity":"error"}],"project_errors":[],"sources":[]}',
    );
    process.lineListener(
      '{"event":"finished","status":"completed","termination":"completed","exit_code":0}',
    );
    const completion = harness.completions[harness.completions.length - 1];
    expect(completion?.diagnosticErrorCount).toBe(1);
    expect(finishLabel(completion!, "es")).toBe("No se ejecutó el programa: hay 1 error.");
    expect(harness.diagnostics).toHaveLength(1);
  });

});

describe("RunController stale sessions", () => {
  it("ignores late lines and exits from a previous session", () => {
    const harness = new Harness();
    const first = harness.start();
    first.lineListener('{"event":"finished","status":"completed","termination":"completed","exit_code":0}');
    first.exitListener(0);
    const second = harness.start();
    first.lineListener('{"event":"output","text":"stale"}');
    first.exitListener(1);
    expect(harness.output).toEqual([]);
    expect(harness.controller.isActive).toBe(true);
    expect(second.terminated).toBe(false);
  });

});

describe("RunController shutdown", () => {
  it("terminates a process that ignores cancel after the grace period", () => {
    const harness = new Harness();
    const process = harness.start();
    harness.controller.stop(settings);
    expect(process.sent).toEqual(['{"command":"cancel"}']);
    expect(process.terminated).toBe(false);
    harness.timers[0]!();
    expect(process.terminated).toBe(true);
    expect(harness.states[harness.states.length - 1]).toBe("aborted");
    expect(stopGraceMilliseconds).toBeGreaterThan(0);
  });

});

describe("RunController failures", () => {
  it("reports a dead server when the process exits without finishing", () => {
    const harness = new Harness();
    const process = harness.start();
    process.exitListener(137);
    expect(harness.states[harness.states.length - 1]).toBe("serverDown");
    expect(harness.controller.isActive).toBe(false);
  });

  it("aborts when the executable speaks another schema", () => {
    const harness = new Harness();
    const process = harness.start();
    process.lineListener('{"event":"hello","schema":2}');
    expect(process.terminated).toBe(true);
    expect(harness.controller.isActive).toBe(false);
  });

  it("closes and terminates the active run on dispose", () => {
    const harness = new Harness();
    const process = harness.start();
    harness.controller.dispose(settings);
    expect(process.sent).toEqual(['{"command":"close"}']);
    expect(process.terminated).toBe(true);
  });

  it("keeps unparseable lines out of the student output", () => {
    const harness = new Harness();
    const process = harness.start();
    process.lineListener("panic: something");
    expect(harness.technical).toEqual(["panic: something"]);
    expect(harness.output).toEqual([]);
  });
});
