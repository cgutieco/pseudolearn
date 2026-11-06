import { Recorder } from "./check";
import { openStack, optionsFor } from "./scenario_stack";

declare const __SCENARIOS__: Record<string, string>;

const INTEGRATOR = "es/clasico/integrador.es.pseudo";

export async function runClassicScenario(recorder: Recorder): Promise<void> {
  recorder.within("classic pseudocode");
  const stack = openStack(["Lucia", "7.5", "9", "6", "2", "s"]);
  await stack.run.start({ program: __SCENARIOS__[INTEGRATOR]!, ...optionsFor("es") }, { });
  recorder.equal(
    stack.output.join("").startsWith("Hola, LUCIA\nLetras: 5 Inicio: Luc\nPromedio: 7.5 Mejor: 9.0\nRevisar\nFin\n"),
    true,
    "a classic program pasted without changes reads its inputs and prints the output derived from the rules",
  );
  recorder.equal(stack.prompts(), 6, "each Leer asks for one value");
  stack.close();
}
