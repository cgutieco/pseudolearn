import * as vscode from "vscode";
import type { DocumentsPort, TranslationEditPort } from "../contracts/editor_documents";

export class VscodeDocuments implements DocumentsPort, TranslationEditPort {
  unsavedPaths(): string[] {
    return vscode.workspace.textDocuments
      .filter((document) => document.isDirty && document.languageId === "pseudolearn")
      .map((document) => document.uri.fsPath);
  }

  currentVersion(path: string): number | undefined {
    return this.find(path)?.version;
  }

  async replaceWhole(path: string, version: number, text: string): Promise<boolean> {
    const document = this.find(path);
    if (!document || document.version !== version) {
      return false;
    }
    const edit = new vscode.WorkspaceEdit();
    const whole = new vscode.Range(0, 0, document.lineCount, 0);
    edit.replace(document.uri, document.validateRange(whole), text);
    return vscode.workspace.applyEdit(edit);
  }

  private find(path: string): vscode.TextDocument | undefined {
    return vscode.workspace.textDocuments.find((document) => document.uri.fsPath === path);
  }
}
