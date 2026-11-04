import type { RunSettings, RunTarget } from "../contracts/editor_run";

export function buildRunArguments(target: RunTarget, settings: RunSettings): string[] {
  const programArguments = settings.args?.length ? ["--", ...settings.args] : [];
  const common = ["run", "--editor", "--language", settings.language];
  if (target.kind === "project") {
    return [...common, "--project", target.directory, "--entry", target.entry, ...programArguments];
  }
  return [...common, "--profile", settings.profile, target.path, ...programArguments];
}
