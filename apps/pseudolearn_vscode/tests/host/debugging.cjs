const vscode = require("vscode");
const fs = require("node:fs/promises");
const path = require("node:path");
const { step, until, pseudoProcesses, folder } = require("./support.cjs");

function hostClient() {
  const events = [];
  const transcript = [];
  let session;
  const registration = vscode.debug.registerDebugAdapterTrackerFactory("pseudolearn", {
    createDebugAdapterTracker: (candidate) => {
      if (candidate.name !== "PseudoLearn DAP interoperability") return undefined;
      session = candidate;
      return {
        onWillReceiveMessage: (message) => transcript.push({ direction: "request", message }),
        onDidSendMessage: (message) => {
          transcript.push({ direction: "response", message });
          if (message.type === "event") events.push(message);
          if (message.event === "pseudolearn/awaitingInput") {
            void session.customRequest("pseudolearn/input", { token: message.body.token, action: "line", text: "20" });
          }
        },
      };
    },
  });
  return { transcript, registration, get session() { return session; },
    request: (command, argumentsList) => session.customRequest(command, argumentsList),
    waitEvent: (name) => until(`DAP event ${name}`, () => {
      const index = events.findIndex((event) => event.event === name);
      return index >= 0 ? events.splice(index, 1)[0] : undefined;
    }),
  };
}

async function debugChecks() {
  await step("DAP uses the real VS Code debugger and logical task snapshots", async () => {
    const { exercise, prepare, scenario } = await import("../dap/scenario.mjs");
    const directory = path.join(folder(), "dap-project");
    await prepare(directory);
    const breakpoint = new vscode.SourceBreakpoint(new vscode.Location(
      vscode.Uri.file(path.join(directory, scenario.breakpoint.path)),
      new vscode.Position(scenario.breakpoint.line - 1, 0)));
    vscode.debug.addBreakpoints([breakpoint]);
    const client = hostClient();
    try {
      const started = await vscode.debug.startDebugging(vscode.workspace.workspaceFolders[0], {
        type: "pseudolearn", request: "launch", name: "PseudoLearn DAP interoperability",
        project: directory, entry: scenario.entry, stopOnEntry: false,
      });
      if (!started) throw new Error("VS Code refused the DAP launch");
      const projection = await exercise(client, directory);
      const report = process.env.PSEUDOLEARN_HOST_DAP_REPORT ?? path.join(path.dirname(process.env.PSEUDOLEARN_HOST_RESULT), "dap");
      await fs.mkdir(report, { recursive: true });
      await fs.writeFile(path.join(report, "projection.json"), JSON.stringify(projection, null, 2));
      await fs.writeFile(path.join(report, "transcript.json"), JSON.stringify(client.transcript, null, 2));
      return report;
    } finally {
      if (client.session) await vscode.debug.stopDebugging(client.session);
      client.registration.dispose();
      vscode.debug.removeBreakpoints([breakpoint]);
    }
  });
  await step("DAP process is released after the real client stops", async () => {
    await until("DAP release", () => !pseudoProcesses().some((process) => process.includes(" dap")));
  });
}

module.exports = { debugChecks };
