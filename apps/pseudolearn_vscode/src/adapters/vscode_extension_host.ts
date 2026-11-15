import * as vscode from "vscode";
import type { DisposablePort, ExtensionHostPort } from "../contracts/extension_host";

export class VscodeExtensionHost implements ExtensionHostPort {
  constructor(private readonly context: vscode.ExtensionContext) {}

  registerLifecycle(): DisposablePort {
    const disposable = new vscode.Disposable(() => undefined);
    this.context.subscriptions.push(disposable);
    return disposable;
  }
}
