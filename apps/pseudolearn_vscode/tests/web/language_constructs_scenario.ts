import { Recorder } from "./check";
import { openStack, optionsFor, projectRequest } from "./scenario_stack";

declare const __SCENARIOS__: Record<string, string>;

const CONSTRUCTS = "es/construcciones/constructs.es.pseudo";
const PROJECT = "pseudolearn-fixture:/es/construcciones/proyecto";

export async function runLanguageConstructScenarios(recorder: Recorder): Promise<void> {
  recorder.within("language constructs");
  const single = openStack([]);
  await single.run.start({ program: __SCENARIOS__[CONSTRUCTS]!, ...optionsFor("es") }, { });
  recorder.equal(single.output.join("").startsWith("3:15\n7\n4:6\n12:0\n5050\n"), true,
    "records, generic classes, declared variants and block objects print the values derived from the rules");
  single.close();
  const project = openStack([]);
  await project.run.start(await projectRequest(project, PROJECT, "es"), { });
  recorder.equal(project.output.join("").startsWith("8:Verde:8:14\n4:hola\n"), true,
    "imported constants, enumerations, records, interfaces and templates run as a project");
  project.close();
}
