import { mkdtemp, mkdir, rm, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join, resolve } from "node:path";
import { StdioClient } from "./stdio_client.mjs";
import { exercise, prepare, scenario } from "./scenario.mjs";

const executable = resolve(process.argv[2] ?? "../pseudolearn_cli/target/debug/pseudo");
const reportDirectory = resolve(process.argv[3] ?? ".artifacts/dap-stdio");
const directory = await mkdtemp(join(tmpdir(), "pseudolearn-dap-ñ "));
await prepare(directory);
await mkdir(reportDirectory, { recursive: true });
const client = new StdioClient(executable);
client.onEvent = (event) => {
  if (event.event === "pseudolearn/awaitingInput") {
    void client.request("pseudolearn/input", { token: event.body.token, action: "line", text: scenario.input });
  }
};
try {
  await client.request("initialize", { adapterID: "pseudolearn-independent", linesStartAt1: true, columnsStartAt1: true });
  await client.request("launch", { project: directory, entry: scenario.entry, stopOnEntry: false });
  await client.waitEvent("initialized");
  await client.request("setBreakpoints", { source: { path: join(directory, scenario.breakpoint.path) }, breakpoints: [{ line: scenario.breakpoint.line }] });
  await client.request("configurationDone");
  const projection = await exercise(client, directory);
  await writeFile(join(reportDirectory, "projection.json"), JSON.stringify(projection, null, 2));
  process.stdout.write(`${JSON.stringify({ ok: true, reportDirectory, directory })}\n`);
} finally {
  await client.stop();
  await writeFile(join(reportDirectory, "transcript.json"), JSON.stringify(client.transcript, null, 2));
  await rm(directory, { recursive: true, force: true });
}
