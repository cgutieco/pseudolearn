import * as vscode from "vscode";
import { finishLabel, stateLabel } from "../application/run_messages";
import type { InterfaceLanguage } from "../contracts/extension_configuration";
import type { RunEvent, RunPresenterPort, RunState } from "../contracts/editor_run";

export class VscodeRunPresenter implements RunPresenterPort, vscode.Disposable {
  private readonly channel = vscode.window.createOutputChannel("PseudoLearn");
  private readonly technical = vscode.window.createOutputChannel("PseudoLearn (technical)");
  private readonly status = vscode.window.createStatusBarItem(vscode.StatusBarAlignment.Left);

  showOutput(text: string): void {
    this.channel.append(text);
  }

  showDiagnostics(event: Extract<RunEvent, { event: "diagnostics" }>): void {
    for (const diagnostic of event.diagnostics) {
      this.channel.appendLine(JSON.stringify(diagnostic));
    }
    for (const projectError of event.projectErrors) {
      this.channel.appendLine(JSON.stringify(projectError));
    }
  }

  showState(state: RunState, language: InterfaceLanguage): void {
    if (state === "starting") {
      this.channel.clear();
      this.channel.show(true);
    }
    this.status.text = stateLabel(state, language);
    this.status.show();
    if (state === "finished") {
      this.channel.appendLine(finishLabel("completed", language));
    }
  }

  async requestInput(language: InterfaceLanguage): Promise<string | undefined> {
    return vscode.window.showInputBox({
      prompt: language === "es" ? "Valor para Leer" : "Value for Read",
      ignoreFocusOut: true,
    });
  }

  showTechnicalLine(line: string): void {
    this.technical.appendLine(line);
  }

  dispose(): void {
    this.channel.dispose();
    this.technical.dispose();
    this.status.dispose();
  }
}
