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

export type EntryProblem = "noFolder" | "noModules" | "noEntry";

const entryMessages: Record<EntryProblem, Record<"es" | "en", string>> = {
  noFolder: { es: "Abre la carpeta del proyecto (la que contiene las carpetas de paquetes con pseudolearn.toml).",
    en: "Open the project folder (the one that contains the package folders with pseudolearn.toml)." },
  noModules: { es: "No se encontraron módulos: abre como carpeta del workspace la raíz del proyecto, por ejemplo examples/project, no una carpeta superior.",
    en: "No modules were found: open the project root as the workspace folder, for example examples/project, not a parent folder." },
  noEntry: { es: "Elige primero el punto de entrada con «PseudoLearn: Select Project Entry».",
    en: "Choose the entry first with \"PseudoLearn: Select Project Entry\"." },
};

export function entryProblemMessage(problem: EntryProblem, language: string): string {
  return entryMessages[problem][language.startsWith("es") ? "es" : "en"];
}
