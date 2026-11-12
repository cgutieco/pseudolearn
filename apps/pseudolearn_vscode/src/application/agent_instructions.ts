import type { InterfaceLanguage } from "../contracts/extension_configuration";

export interface InstructionFile {
  readonly path: readonly string[];
  readonly text: string;
}

const spanishRules = [
  "# Instrucciones para agentes: PseudoLearn",
  "",
  "Este proyecto está escrito en PseudoLearn, no en PSeInt.",
  "",
  "- Los arreglos empiezan en 0.",
  "- Toda sentencia simple termina en punto y coma.",
  "- Toda variable y todo parámetro se declaran con su tipo.",
  "- Comprueba cada programa con la herramienta `check` del servidor MCP `PseudoLearn` (o con `pseudo comprobar`) antes de proponerlo.",
  "- Prueba los programas con `run` y sus entradas; no concede acceso a archivos ni red.",
  "- Ante la duda, consulta el recurso `pseudolearn://language-sheet/es` o la herramienta `search_reference`.",
  "",
];

const englishRules = [
  "# Agent instructions: PseudoLearn",
  "",
  "This project is written in PseudoLearn, not PSeInt.",
  "",
  "- Arrays start at 0.",
  "- Every simple statement ends with a semicolon.",
  "- Every variable and parameter is declared with a type.",
  "- Check every program with the `check` tool of the `PseudoLearn` MCP server (or with `pseudo check`) before proposing it.",
  "- Test programs with `run` and their inputs; it grants no access to files or network.",
  "- When unsure, read the `pseudolearn://language-sheet/en` resource or use the `search_reference` tool.",
  "",
];

export function agentInstructionFiles(language: InterfaceLanguage): InstructionFile[] {
  const text = (language === "en" ? englishRules : spanishRules).join("\n");
  return [
    { path: ["AGENTS.md"], text },
    { path: [".github", "copilot-instructions.md"], text },
  ];
}

export function instructionsReport(created: number, skipped: number, language: InterfaceLanguage): string {
  return language === "en"
    ? `PseudoLearn agent instructions: ${created} created, ${skipped} already present.`
    : `Instrucciones para agentes de PseudoLearn: ${created} creadas, ${skipped} ya existían.`;
}
