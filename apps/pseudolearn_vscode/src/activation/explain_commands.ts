import * as vscode from "vscode";
import { VscodeExplainPresenter } from "../adapters/vscode_explain_presenter";
import type { ClientLifecycle } from "../application/client_lifecycle";
import { explainAtCursor } from "../application/explain_command";
import type { InterfaceLanguage } from "../contracts/extension_configuration";

export function registerExplainCommand(
  client: ClientLifecycle,
  language: InterfaceLanguage,
): vscode.Disposable[] {
  const presenter = new VscodeExplainPresenter(language);
  const command = vscode.commands.registerCommand("pseudolearn.explainAtCursor", () => {
    const editor = vscode.window.activeTextEditor;
    if (editor?.document.languageId !== "pseudolearn") {
      return undefined;
    }
    const { line, character } = editor.selection.active;
    const { uri, version } = editor.document;
    return explainAtCursor({ client, presenter }, { uri: uri.toString(), version, line, character });
  });
  return [presenter, command];
}
