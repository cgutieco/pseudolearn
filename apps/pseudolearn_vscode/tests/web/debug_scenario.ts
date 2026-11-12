import * as vscode from "vscode";
import type { Recorder } from "./check";

const source = "Algoritmo Depurar\nDefinir total Como Entero <- 20;\ntotal <- total + 1;\nEscribir total;\nFinAlgoritmo\n";

interface Observed {
  events: Array<{ event?: string; body?: Record<string, unknown> }>;
}

async function until(predicate: () => boolean, limit = 15000): Promise<void> {
  const started = Date.now();
  while (!predicate()) {
    if (Date.now() - started > limit) throw new Error("Debug condition timed out");
    await new Promise((resolve) => setTimeout(resolve, 20));
  }
}

function track(observed: Observed): vscode.Disposable {
  return vscode.debug.registerDebugAdapterTrackerFactory("pseudolearn", {
    createDebugAdapterTracker: () => ({
      onDidSendMessage: (message: { type?: string; event?: string; body?: Record<string, unknown> }) => {
        if (message.type === "event") observed.events.push(message);
      },
    }),
  });
}

async function inspectStop(recorder: Recorder, session: vscode.DebugSession, observed: Observed): Promise<void> {
  const stopped = observed.events.find((event) => event.event === "stopped");
  const threadId = stopped?.body?.threadId as number;
  const stack = await session.customRequest("stackTrace", { threadId, startFrame: 0, levels: 8 }) as { stackFrames: Array<{ id: number; line: number }> };
  recorder.check(stack.stackFrames[0]?.line === 3, "web debugger stops at the breakpoint line");
  const value = await session.customRequest("evaluate", { frameId: stack.stackFrames[0]?.id, expression: "total + 1", context: "watch" }) as { result: string };
  recorder.check(value.result === "21", "web debugger evaluates a pure expression in the paused frame");
  const threads = await session.customRequest("threads") as { threads: unknown[] };
  recorder.check(threads.threads.length >= 1, "web debugger lists tasks as threads");
}

export async function runDebugScenario(recorder: Recorder): Promise<void> {
  recorder.within("debug");
  const folder = vscode.workspace.workspaceFolders?.[0];
  recorder.check(folder, "debug fixture folder present");
  const uri = vscode.Uri.joinPath(folder!.uri, "debug.pseudo");
  await vscode.workspace.fs.writeFile(uri, new TextEncoder().encode(source));
  const breakpoint = new vscode.SourceBreakpoint(new vscode.Location(uri, new vscode.Position(2, 0)));
  vscode.debug.addBreakpoints([breakpoint]);
  const observed: Observed = { events: [] };
  const tracker = track(observed);
  try {
    const started = await vscode.debug.startDebugging(folder, { type: "pseudolearn", request: "launch", name: "PseudoLearn web", program: uri.toString(), stopOnEntry: false });
    recorder.check(started, "web debug session starts");
    await until(() => observed.events.some((event) => event.event === "stopped"));
    await inspectStop(recorder, vscode.debug.activeDebugSession!, observed);
    await vscode.debug.activeDebugSession!.customRequest("continue", {});
    await until(() => observed.events.some((event) => event.event === "terminated"));
    const output = observed.events.filter((event) => event.event === "output").map((event) => String(event.body?.output ?? "")).join("");
    recorder.check(output.includes("21"), "web debugger forwards program output");
  } finally {
    tracker.dispose();
    vscode.debug.removeBreakpoints([breakpoint]);
  }
}
