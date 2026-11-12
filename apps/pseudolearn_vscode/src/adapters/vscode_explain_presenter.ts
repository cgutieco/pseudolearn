import * as vscode from "vscode";
import { explainNotice } from "../application/explain_messages";
import type { InterfaceLanguage } from "../contracts/extension_configuration";
import type { ExplainNotice, ExplainPresenterPort } from "../contracts/language_client";

export class VscodeExplainPresenter implements ExplainPresenterPort, vscode.Disposable {
  private readonly channel = vscode.window.createOutputChannel("PseudoLearn Help");

  constructor(private readonly language: InterfaceLanguage) {}

  showHelp(text: string): void {
    this.channel.clear();
    this.channel.appendLine(text);
    this.channel.show(true);
  }

  showNotice(notice: ExplainNotice): void {
    void vscode.window.showInformationMessage(explainNotice(notice, this.language));
  }

  dispose(): void {
    this.channel.dispose();
  }
}
