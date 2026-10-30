import * as path from "node:path";
import * as vscode from "vscode";
import type { ExtensionConfigurationPort } from "../contracts/extension_configuration";

export function readVscodeConfiguration(
  context: vscode.ExtensionContext,
): ExtensionConfigurationPort {
  const configuration = vscode.workspace.getConfiguration("pseudolearn");
  const target = `${process.platform}-${process.arch}`;
  const executable = process.platform === "win32" ? "pseudo.exe" : "pseudo";
  return {
    profile: configuration.inspect("profile") ?? {},
    strictness: configuration.inspect("strictness") ?? {},
    interfaceLanguage: configuration.inspect("interfaceLanguage") ?? {},
    serverPath: configuration.inspect("server.path") ?? {},
    workspaceTrusted: vscode.workspace.isTrusted,
    development: process.env.NODE_ENV === "development",
    bundledServerPath: path.join(context.extensionPath, "bin", target, executable),
    isAbsolutePath: path.isAbsolute,
  };
}
