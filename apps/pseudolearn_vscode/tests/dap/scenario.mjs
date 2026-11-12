import assert from "node:assert/strict";
import { mkdir, readFile, writeFile } from "node:fs/promises";
import { dirname, join } from "node:path";

export const scenario = JSON.parse(await readFile(new URL("../fixtures/dap-project.json", import.meta.url), "utf8"));

export async function prepare(directory) {
  for (const [relative, text] of Object.entries(scenario.files)) {
    const path = join(directory, relative);
    await mkdir(dirname(path), { recursive: true });
    await writeFile(path, text);
  }
}

export async function inspectStop(client, stopped, directory) {
  const tasks = await client.request("threads");
  assert.ok(tasks.threads.length >= 2, "logical tasks are visible");
  const thread = tasks.threads.find((thread) => thread.id === stopped.body.threadId);
  assert.ok(thread, "stop identifies its logical task");
  const frames = await client.request("stackTrace", { threadId: thread.id, startFrame: 0, levels: 8 });
  assert.ok(frames.stackFrames.length >= 1);
  const frame = frames.stackFrames[0];
  const scopes = await client.request("scopes", { frameId: frame.id });
  const reference = scopes.scopes[0].variablesReference;
  const variables = await client.request("variables", { variablesReference: reference, start: 0, count: 1 });
  const expression = await client.request("evaluate", { frameId: frame.id, context: "watch", expression: scenario.expression });
  assert.equal(expression.result, "21");
  const largest = await client.request("evaluate", { frameId: frame.id, context: "hover", expression: "9223372036854775807" });
  assert.equal(largest.result, "9223372036854775807");
  await assert.rejects(client.request("evaluate", { frameId: frame.id, context: "repl", expression: "Double(1)" }));
  const source = await client.request("source", { sourceReference: frame.source.sourceReference });
  assert.equal(source.content, scenario.files[scenario.breakpoint.path]);
  return { thread, frames, reference, variables, expression, largest, source };
}

export async function exercise(client, directory) {
  const stopped = await client.waitEvent("stopped");
  const inspected = await inspectStop(client, stopped, directory);
  await writeFile(join(directory, scenario.breakpoint.path), `${inspected.source.content}\n`);
  const source = await client.request("source", { sourceReference: inspected.frames.stackFrames[0].source.sourceReference });
  assert.equal(source.content, inspected.source.content);
  await client.request("stepBack", { threadId: inspected.thread.id });
  const historical = await client.waitEvent("stopped");
  await assert.rejects(client.request("variables", { variablesReference: inspected.reference, count: 1 }));
  const historicalStack = await client.request("stackTrace", { threadId: historical.body.threadId, levels: 8 });
  return projection(directory, inspected, historical, historicalStack);
}

function projection(directory, inspected, historical, historicalStack) {
  const frames = (stack) => stack.stackFrames.map((frame) => ({
    name: frame.name, line: frame.line, column: frame.column,
    source: frame.source.path.replace(directory, "$ROOT"), revision: frame.source.adapterData?.revision,
  }));
  return { thread: inspected.thread.name, frames: frames(inspected.frames),
    variables: inspected.variables.variables.map((value) => ({ name: value.name, value: value.value, type: value.type })),
    expression: inspected.expression.result, largest: inspected.largest.result,
    source: inspected.source.content, historicalReason: historical.body.reason, historicalFrames: frames(historicalStack) };
}
