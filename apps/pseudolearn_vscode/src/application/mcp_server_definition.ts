import type { InterfaceLanguage } from "../contracts/extension_configuration";

export const mcpProviderId = "pseudolearn.mcp";

export interface McpServerLaunch {
  readonly label: string;
  readonly command: string;
  readonly args: readonly string[];
  readonly env: Readonly<Record<string, string>>;
}

export function mcpServerLaunch(serverPath: string, language: InterfaceLanguage): McpServerLaunch {
  return {
    label: "PseudoLearn",
    command: serverPath,
    args: ["mcp"],
    env: { PSEUDO_IDIOMA: language },
  };
}
