import * as vscode from "vscode";
import {
  agentInstructionFiles,
  instructionsReport,
} from "../application/agent_instructions";
import { mcpProviderId, mcpServerLaunch } from "../application/mcp_server_definition";
import type { RunSettings } from "../contracts/editor_run";

export function registerAgentIntegration(settings: RunSettings): vscode.Disposable[] {
  const launch = mcpServerLaunch(settings.executable, settings.language);
  return [
    vscode.lm.registerMcpServerDefinitionProvider(mcpProviderId, {
      provideMcpServerDefinitions: () => [
        new vscode.McpStdioServerDefinition(launch.label, launch.command, [...launch.args], {
          ...launch.env,
        }),
      ],
    }),
    vscode.commands.registerCommand("pseudolearn.createAgentInstructions", () =>
      createInstructions(settings),
    ),
  ];
}

async function createInstructions(settings: RunSettings): Promise<void> {
  const folder = vscode.workspace.workspaceFolders?.[0];
  if (folder === undefined) return;
  let created = 0;
  let skipped = 0;
  for (const file of agentInstructionFiles(settings.language)) {
    const target = vscode.Uri.joinPath(folder.uri, ...file.path);
    if (await exists(target)) {
      skipped += 1;
      continue;
    }
    await vscode.workspace.fs.writeFile(target, new TextEncoder().encode(file.text));
    created += 1;
  }
  void vscode.window.showInformationMessage(instructionsReport(created, skipped, settings.language));
}

async function exists(target: vscode.Uri): Promise<boolean> {
  try {
    await vscode.workspace.fs.stat(target);
    return true;
  } catch {
    return false;
  }
}
