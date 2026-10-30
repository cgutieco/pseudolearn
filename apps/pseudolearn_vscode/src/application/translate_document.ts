import type { CommandRunnerPort, TranslationEditPort } from "../contracts/editor_documents";
import type { RunSettings } from "../contracts/editor_run";

export type TranslationOutcome =
  | "applied"
  | "unsaved"
  | "collision"
  | "documentChanged"
  | "notOpen";

export interface TranslationRequest {
  path: string;
  targetProfile: "es" | "en";
  unsaved: boolean;
  settings: RunSettings;
}

export async function translateDocument(
  ports: { runner: CommandRunnerPort; edits: TranslationEditPort },
  request: TranslationRequest,
): Promise<TranslationOutcome> {
  if (request.unsaved) {
    return "unsaved";
  }
  const version = ports.edits.currentVersion(request.path);
  if (version === undefined) {
    return "notOpen";
  }
  const args = [
    "translate",
    "--to",
    request.targetProfile,
    "--language",
    request.settings.language,
    "--strictness",
    request.settings.strictness,
    request.path,
  ];
  const result = await ports.runner.run(request.settings.executable, args, ".");
  if (result.code !== 0) {
    return "collision";
  }
  const applied = await ports.edits.replaceWhole(request.path, version, result.stdout);
  return applied ? "applied" : "documentChanged";
}
