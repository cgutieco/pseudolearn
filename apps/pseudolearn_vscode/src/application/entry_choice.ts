import type { CommandRunnerPort } from "../contracts/editor_documents";
import type { RunSettings } from "../contracts/editor_run";

export async function listProjectEntries(
  runner: CommandRunnerPort,
  request: { directory: string; settings: RunSettings },
): Promise<string[]> {
  const args = ["check", "--json", "--language", request.settings.language, "--project", request.directory];
  const result = await runner.run(request.settings.executable, args, request.directory);
  try {
    const document = JSON.parse(result.stdout) as { modules?: Array<{ path?: unknown }> };
    return (document.modules ?? []).flatMap((module) =>
      typeof module.path === "string" ? [module.path] : [],
    );
  } catch {
    return [];
  }
}
