import { Recorder } from "./check";
import { openStack, optionsFor } from "./scenario_stack";

declare const __SCENARIOS__: Record<string, string>;

const PURE_LIBRARY = "es/proposito-general/pure-library.es.pseudo";
const CONSOLE_ENVIRONMENT = "es/proposito-general/console-environment.es.pseudo";

async function outputOf(path: string): Promise<string> {
  const stack = openStack([]);
  await stack.run.start({ program: __SCENARIOS__[path]!, ...optionsFor("es") }, { });
  return stack.output.join("");
}

export async function runGeneralPurposeScenarios(recorder: Recorder): Promise<void> {
  recorder.within("general purpose library");
  const pure = await outputOf(PURE_LIBRARY);
  const expected = "STRASSE:école\n3:2.5:-1:0\n0.0:0.0:0.0:0.0:3.0:-1.0\n0.13:7.00:-3\n007:ab..\n-1:2:3\n3:-1\nVerdadero\n0\nbb:aa\n1970-01-01T00:00:00Z\n";
  recorder.equal(pure.startsWith(expected), true, "pure library operations print the values derived from the rules");
  const platform = await outputOf(CONSOLE_ENVIRONMENT);
  recorder.equal(platform.includes("permiso_denegado"), true, "the browser answers the environment with a typed platform error");
}
