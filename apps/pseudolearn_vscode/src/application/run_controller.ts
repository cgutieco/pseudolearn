import type {
  ProcessLauncherPort,
  RunCommand,
  RunCompletion,
  RunEvent,
  RunPresenterPort,
  RunProcessPort,
  RunSettings,
  RunState,
  RunTarget,
  SchedulerPort,
} from "../contracts/editor_run";
import type { DisposablePort } from "../contracts/extension_host";
import { buildRunArguments } from "./run_arguments";
import { encodeRunCommand, parseRunEvent, supportedSchema } from "./run_events";
import { countDiagnosticErrors } from "./diagnostic_report";

export const stopGraceMilliseconds = 5000;

export type StartOutcome = { ok: true } | { ok: false; refusal: "runActive" };

interface Session {
  process: RunProcessPort;
  finished: boolean;
  workingDirectory: string;
  diagnostics?: Extract<RunEvent, { event: "diagnostics" }>;
  graceTimer?: DisposablePort;
}

export interface RunControllerPorts {
  launcher: ProcessLauncherPort;
  presenter: RunPresenterPort;
  scheduler: SchedulerPort;
}

export class RunController {
  private active: Session | undefined;

  constructor(private readonly ports: RunControllerPorts) {}

  get isActive(): boolean {
    return this.active !== undefined;
  }

  start(request: { target: RunTarget; workingDirectory: string; settings: RunSettings }): StartOutcome {
    if (this.active) {
      return { ok: false, refusal: "runActive" };
    }
    const { target, workingDirectory, settings } = request;
    const args = buildRunArguments(target, settings);
    const process = this.ports.launcher.launch(settings.executable, args, workingDirectory);
    const session: Session = { process, finished: false, workingDirectory, diagnostics: undefined };
    this.active = session;
    this.state("starting", settings);
    process.onLine((line) => this.receive(session, settings, line));
    process.onExit((code) => this.exited(session, settings, code));
    return { ok: true };
  }

  stop(settings: RunSettings): void {
    const session = this.active;
    if (!session || session.graceTimer) {
      return;
    }
    this.state("stopping", settings);
    this.transmit(session, { command: "cancel" });
    session.graceTimer = this.ports.scheduler.after(stopGraceMilliseconds, () => {
      this.abort(session, settings);
    });
  }

  dispose(settings: RunSettings): void {
    const session = this.active;
    if (session) {
      this.transmit(session, { command: "close" });
      this.abort(session, settings);
    }
  }

  private receive(session: Session, settings: RunSettings, line: string): void {
    if (this.active !== session) {
      return;
    }
    const event = parseRunEvent(line);
    if (!event) {
      this.ports.presenter.showTechnicalLine(line);
      return;
    }
    this.apply(session, settings, event);
  }

  private apply(session: Session, settings: RunSettings, event: RunEvent): void {
    switch (event.event) {
      case "hello":
        this.hello(session, settings, event.schema);
        break;
      case "output":
        this.ports.presenter.showOutput(event.text);
        this.state("running", settings);
        break;
      case "awaiting_input":
        void this.collectInput(session, settings);
        break;
      case "diagnostics":
        session.diagnostics = mergeDiagnostics(session.diagnostics, event);
        break;
      case "protocol_error":
        this.ports.presenter.showTechnicalLine(event.reason);
        break;
      case "finished":
        this.conclude(session, settings, event);
        break;
    }
  }

  private hello(session: Session, settings: RunSettings, schema: number): void {
    if (schema !== supportedSchema) {
      this.transmit(session, { command: "close" });
      this.abort(session, settings);
      return;
    }
    this.state("running", settings);
  }

  private async collectInput(session: Session, settings: RunSettings): Promise<void> {
    this.state("awaitingInput", settings);
    const text = await this.ports.presenter.requestInput(settings.language);
    if (this.active !== session || session.finished) {
      return;
    }
    if (text === undefined) {
      this.transmit(session, { command: "cancel" });
      return;
    }
    this.state("running", settings);
    this.transmit(session, { command: "input", text });
  }

  private conclude(
    session: Session,
    settings: RunSettings,
    event: Extract<RunEvent, { event: "finished" }>,
  ): void {
    session.finished = true;
    const completion: RunCompletion = {
      status: event.status,
      termination: event.termination,
      diagnosticErrorCount: session.diagnostics ? countDiagnosticErrors(session.diagnostics) : 0,
    };
    this.presentDiagnostics(session, settings, completion);
    this.state("finished", settings, completion);
  }

  private exited(session: Session, settings: RunSettings, code: number | null): void {
    if (this.active !== session) {
      return;
    }
    session.graceTimer?.dispose();
    this.active = undefined;
    if (!session.finished) {
      this.presentDiagnostics(session, settings);
      this.state("serverDown", settings);
      this.ports.presenter.showTechnicalLine(`exit ${code ?? "signal"}`);
    }
  }

  private abort(session: Session, settings: RunSettings): void {
    if (this.active !== session) {
      return;
    }
    session.graceTimer?.dispose();
    this.active = undefined;
    session.process.terminate();
    this.presentDiagnostics(session, settings);
    this.state("aborted", settings);
  }

  private transmit(session: Session, command: RunCommand): void {
    session.process.send(encodeRunCommand(command));
  }

  private presentDiagnostics(
    session: Session,
    settings: RunSettings,
    completion?: RunCompletion,
  ): void {
    if (session.diagnostics) {
      this.ports.presenter.showDiagnostics(
        session.diagnostics,
        session.workingDirectory,
        settings.language,
        completion,
      );
      session.diagnostics = undefined;
    }
  }

  private state(state: RunState, settings: RunSettings, completion?: RunCompletion): void {
    this.ports.presenter.showState(state, settings.language, completion);
  }
}

function mergeDiagnostics(
  current: Extract<RunEvent, { event: "diagnostics" }> | undefined,
  incoming: Extract<RunEvent, { event: "diagnostics" }>,
): Extract<RunEvent, { event: "diagnostics" }> {
  if (!current) {
    return incoming;
  }
  const sources = new Map(current.sources.map((source) => [source.sourceId, source]));
  for (const source of incoming.sources) {
    sources.set(source.sourceId, source);
  }
  return {
    event: "diagnostics",
    diagnostics: [...current.diagnostics, ...incoming.diagnostics],
    projectErrors: [...current.projectErrors, ...incoming.projectErrors],
    sources: [...sources.values()],
  };
}
