import { Recorder } from "./check";
import { openStack, optionsFor } from "./scenario_stack";

declare const __ACCEPTANCE__: string;

export async function runAcceptanceScenario(recorder: Recorder): Promise<void> {
  if (!__ACCEPTANCE__) return;
  recorder.within("acceptance program against the real API");
  const stack = openStack([]);
  await stack.run.start({ program: __ACCEPTANCE__, ...optionsFor("es") }, { });
  const text = stack.output.join("");
  console.log(`ACCEPTANCE OUTPUT ${JSON.stringify(text)}`);
  recorder.equal(text.startsWith("200\nRick Sanchez\nAlive\n"), true, "program prints status, name and state without configuration");
}
