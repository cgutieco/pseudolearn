import { Recorder } from "./check";
import { runFileScenarios } from "./file_scenarios";
import { runHttpScenarios, probeTls, type Fixture } from "./http_scenarios";
import { registerMemoryProvider } from "./memory_provider";
import { runProgramScenarios } from "./program_scenarios";
import { runHostChecks } from "./host_checks";
import { runAcceptanceScenario } from "./acceptance_scenario";
import { runGeneralPurposeScenarios } from "./general_purpose_scenario";
import { runLanguageConstructScenarios } from "./language_constructs_scenario";
import { runClassicScenario } from "./classic_scenario";
import { runDebugScenario } from "./debug_scenario";

declare const __FIXTURE__: Fixture;

export async function run(): Promise<void> {
  const recorder = new Recorder();
  await runHostChecks(recorder);
  const { provider, registration } = registerMemoryProvider("pseudolearn-fixture");
  try {
    const tls = await probeTls(__FIXTURE__);
    await runHttpScenarios(recorder, __FIXTURE__, tls);
    await runFileScenarios(recorder, provider);
    await runProgramScenarios(recorder, provider, tls === "accepted" ? __FIXTURE__.https : __FIXTURE__.http);
    await runGeneralPurposeScenarios(recorder);
    await runLanguageConstructScenarios(recorder);
    await runClassicScenario(recorder);
    await runAcceptanceScenario(recorder);
    await runDebugScenario(recorder);
    console.log(JSON.stringify({ schema: 2, target: "vscode-web-host", result: "passed", tls, durablePersistence: false,
      steps: recorder.steps }));
  } catch (error) {
    console.log(JSON.stringify({ schema: 2, target: "vscode-web-host", result: "failed", reason: String(error), stack: String((error as Error).stack).slice(0, 600), lastStep: recorder.steps[recorder.steps.length - 1] }));
    throw error;
  } finally { registration.dispose(); }
}
