import { Recorder } from "./check";
import type { MemoryProvider } from "./memory_provider";
import { openStack, optionsFor, projectRequest, type Answer, type Stack } from "./scenario_stack";
import type { BrowserGrants } from "../../src/contracts/host_capabilities";

declare const __SCENARIOS__: Record<string, string>;

type Profile = "es" | "en";

interface Names { saludo: string; bucle: string; entero: string; red: string; archivo: string; proyecto: string; error: string; folder: string }

const names: Record<Profile, Names> = {
  es: { saludo: "es/archivo/saludo.pseudo", bucle: "es/archivo/bucle.pseudo", entero: "es/archivo/entero.pseudo", red: "es/archivo/red.pseudo",
    archivo: "es/archivo/archivo.pseudo", proyecto: "es/proyecto", error: "es/proyecto-error", folder: "es" },
  en: { saludo: "en/file/greeting.pseudo", bucle: "en/file/loop.pseudo", entero: "en/file/extremes.pseudo", red: "en/file/network.pseudo",
    archivo: "en/file/files.pseudo", proyecto: "en/project", error: "en/project-error", folder: "en" },
};

const wait = (milliseconds: number) => new Promise<void>((resolve) => setTimeout(resolve, milliseconds));
const sourceOf = (path: string, origin = "") => __SCENARIOS__[path]!.replace("__ORIGIN__", origin);
const joined = (stack: Stack) => stack.output.join("");

export function seedProject(provider: MemoryProvider): void {
  for (const [path, text] of Object.entries(__SCENARIOS__)) provider.seed(`/${path}`, text);
}

interface FileRun { path: string; profile: Profile; answers: Answer[]; grants: BrowserGrants; origin?: string }

async function runFile(request: FileRun): Promise<Stack> {
  const stack = openStack(request.answers);
  await stack.run.start({ program: sourceOf(request.path, request.origin), ...optionsFor(request.profile) }, request.grants);
  return stack;
}

async function unicodeAndInput(recorder: Recorder, profile: Profile): Promise<void> {
  const file = names[profile];
  recorder.within(`${profile} file input`);
  const filled = await runFile({ path: file.saludo, profile, answers: ["Ana ñ"], grants: { origins: [] } });
  recorder.equal(joined(filled).includes("ñandú 🌍\n"), true, "Unicode output survives the Worker boundary");
  recorder.equal(joined(filled).includes(profile === "es" ? "Hola Ana ñ\n" : "Hello Ana ñ\n"), true, "typed input reaches the program");
  recorder.equal([filled.prompts(), joined(filled).endsWith("PseudoLearn: completed\n")], [1, true], "one prompt and a completed run");
  const empty = await runFile({ path: file.saludo, profile, answers: [""], grants: { origins: [] } });
  recorder.equal(joined(empty).includes(profile === "es" ? "Hola \n" : "Hello \n"), true, "empty input is a valid empty line");
  const extremes = await runFile({ path: file.entero, profile, answers: [], grants: { origins: [] } });
  recorder.equal(joined(extremes).startsWith("9223372036854775807\n-9223372036854775808\n"), true, "64-bit extremes keep every digit");
}

async function cancellation(recorder: Recorder, profile: Profile): Promise<void> {
  recorder.within(`${profile} cancellation`);
  const stack = openStack([]);
  const finished = stack.run.start({ program: sourceOf(names[profile].bucle), ...optionsFor(profile) }, { origins: [] });
  await wait(300);
  recorder.equal(joined(stack), "start\n".replace("start", profile === "es" ? "inicio" : "start"), "program started and is still running");
  await stack.run.stop();
  await finished;
  recorder.equal(joined(stack).endsWith("PseudoLearn: cancelled\n"), true, "stop ends the run as cancelled");
  const declined = openStack([undefined]);
  await declined.run.start({ program: sourceOf(names[profile].saludo), ...optionsFor(profile) }, { origins: [] });
  recorder.equal([declined.prompts(), joined(declined).endsWith("PseudoLearn: cancelled\n")], [1, true], "dismissing the input box cancels the run");
}

async function project(recorder: Recorder, profile: Profile): Promise<void> {
  const place = names[profile];
  recorder.within(`${profile} project`);
  const good = openStack([]);
  await good.run.start(await projectRequest(good, `pseudolearn-fixture:/${place.proyecto}`, profile), { origins: [] });
  recorder.equal(joined(good), "ñandú 🌍\n42\nPseudoLearn: completed\n", "three modules run and the imported result is exact");
  const broken = openStack([]);
  const request = await projectRequest(broken, `pseudolearn-fixture:/${place.error}`, profile);
  let rejection = "";
  await broken.run.start(request, { origins: [] }).catch((error: Error) => { rejection = error.message; });
  recorder.equal(rejection, "Program rejected before execution", "an error in the imported module rejects the program");
  recorder.equal(joined(broken), "", "nothing runs after the rejection");
}

async function effects(recorder: Recorder, profile: Profile, origin: string, provider: MemoryProvider): Promise<void> {
  const place = names[profile];
  recorder.within(`${profile} effects`);
  const granted = await runFile({ path: place.red, profile, answers: [], grants: { origins: [origin] }, origin });
  recorder.equal(joined(granted), "200\n2\nPseudoLearn: completed\n", "granted origin returns status and body length");
  const denied = await runFile({ path: place.red, profile, answers: [], grants: { origins: [] }, origin });
  recorder.equal(joined(denied), "permiso_denegado\nPseudoLearn: completed\n", "no network permission sends nothing");
  const files = await runFile({ path: place.archivo, profile, answers: [], grants: { origins: [], files: { root: "pseudolearn-fixture://files/root", writable: true, confined: true } } });
  recorder.equal([joined(files).startsWith(profile === "es" ? "escrito\n" : "written\n"), provider.text("/root/salida.txt")], [true, "guardado ñ"], "granted files are written through the provider");
  const refused = await runFile({ path: place.archivo, profile, answers: [], grants: { origins: [] } });
  recorder.equal(joined(refused), "permiso_denegado\nPseudoLearn: completed\n", "ungranted files are denied");
}

export async function runProgramScenarios(recorder: Recorder, provider: MemoryProvider, origin: string): Promise<void> {
  seedProject(provider);
  for (const profile of ["es", "en"] as const) {
    await unicodeAndInput(recorder, profile);
    await cancellation(recorder, profile);
    await project(recorder, profile);
    await effects(recorder, profile, origin, provider);
  }
}

