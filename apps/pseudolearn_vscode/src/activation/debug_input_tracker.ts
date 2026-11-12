import * as vscode from "vscode";

export function inputTracker(session: vscode.DebugSession): vscode.DebugAdapterTracker {
  let active: string | undefined;
  return { onDidSendMessage: (message: Record<string, unknown>) => {
    if (message.event === "terminated") active = undefined;
    if (message.event !== "pseudolearn/awaitingInput") return;
    const body = message.body as { token?: string } | undefined;
    const token = body?.token;
    if (!token) return;
    active = token;
    void vscode.window.showInputBox({ prompt: vscode.env.language.startsWith("es") ? "Entrada del programa" : "Program input", ignoreFocusOut: true })
      .then((text) => {
        if (active !== token) return;
        active = undefined;
        void session.customRequest("pseudolearn/input", { token, action: text === undefined ? "cancel" : "line", text });
      });
  } };
}
