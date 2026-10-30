import type { RunSettings, RunTarget } from "../contracts/editor_run";

export function buildRunArguments(target: RunTarget, settings: RunSettings): string[] {
  const common = ["run", "--editor", "--language", settings.language, "--strictness", settings.strictness];
  if (target.kind === "project") {
    return [...common, "--project", target.directory, "--entry", target.entry];
  }
  return [...common, "--profile", settings.profile, target.path];
}
