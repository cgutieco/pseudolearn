import { readFileSync, realpathSync, statSync } from "node:fs";
import * as path from "node:path";
import * as vscode from "vscode";
import { buildDiagnosticReport, type DiagnosticReportProblem, type DiagnosticReportSource } from "../application/diagnostic_report";
import { finishLabel, stateConclusionLabel, stateLabel } from "../application/run_messages";
import type { InterfaceLanguage } from "../contracts/extension_configuration";
import type { RunCompletion, RunEvent, RunPresenterPort, RunState } from "../contracts/editor_run";

const maximumSourceBytes = 1_048_576;

export class VscodeRunPresenter implements RunPresenterPort, vscode.Disposable {
  private readonly channel = vscode.window.createOutputChannel("PseudoLearn");
  private readonly technical = vscode.window.createOutputChannel("PseudoLearn (technical)");
  private readonly status = vscode.window.createStatusBarItem(vscode.StatusBarAlignment.Left);
  private readonly problems = vscode.languages.createDiagnosticCollection("PseudoLearn");

  showOutput(text: string): void {
    this.channel.append(text);
  }

  showDiagnostics(
    event: Extract<RunEvent, { event: "diagnostics" }>,
    workingDirectory: string,
    language: InterfaceLanguage,
    completion?: RunCompletion,
  ): void {
    const sources = diagnosticSources(event, workingDirectory);
    const report = buildDiagnosticReport(event, sources, language, completion);
    this.problems.clear();
    for (const line of report.technicalLines) {
      this.technical.appendLine(line);
    }
    this.publishProblems(report.problems);
    if (report.text) {
      this.channel.appendLine(report.text);
    }
  }

  showState(state: RunState, language: InterfaceLanguage, completion?: RunCompletion): void {
    if (state === "starting") {
      this.channel.clear();
      this.channel.show(true);
      this.problems.clear();
    }
    this.status.text = stateLabel(state, language);
    this.status.show();
    if (state === "finished" && completion && completion.diagnosticErrorCount === 0) {
      this.channel.appendLine(finishLabel(completion, language));
    }
    if (state === "aborted" || state === "serverDown") {
      const conclusion = stateConclusionLabel(state, language);
      if (conclusion) {
        this.channel.appendLine(conclusion);
      }
    }
  }

  async requestInput(language: InterfaceLanguage): Promise<string | undefined> {
    this.channel.show(true);
    return vscode.window.showInputBox({
      prompt: language === "es" ? "Valor para Leer" : "Value for Read",
      ignoreFocusOut: true,
    });
  }

  showTechnicalLine(line: string): void {
    this.technical.appendLine(line);
  }

  private publishProblems(problems: DiagnosticReportProblem[]): void {
    const grouped = new Map<string, vscode.Diagnostic[]>();
    for (const problem of problems) {
      if (!problem.path) {
        continue;
      }
      const diagnostics = grouped.get(problem.path) ?? [];
      diagnostics.push(toVscodeDiagnostic(problem));
      grouped.set(problem.path, diagnostics);
    }
    for (const [filePath, diagnostics] of grouped) {
      this.problems.set(vscode.Uri.file(filePath), diagnostics);
    }
  }

  dispose(): void {
    this.channel.dispose();
    this.technical.dispose();
    this.status.dispose();
    this.problems.dispose();
  }
}

function diagnosticSources(
  event: Extract<RunEvent, { event: "diagnostics" }>,
  workingDirectory: string,
): DiagnosticReportSource[] {
  return event.sources.flatMap((source) => {
    if (!source.path) {
      return [];
    }
    const filePath = path.resolve(workingDirectory, source.path);
    const relativePath = path.relative(workingDirectory, filePath);
    return [{
      sourceId: source.sourceId,
      path: filePath,
      label: (relativePath || path.basename(filePath)).split(path.sep).join("/"),
      text: readSourceText(filePath, workingDirectory),
      tabSize: configuredTabSize(filePath),
    }];
  });
}

function readSourceText(filePath: string, workingDirectory: string): string | undefined {
  try {
    const rootPath = realpathSync(workingDirectory);
    const sourcePath = realpathSync(filePath);
    if (!isWithinDirectory(rootPath, sourcePath)) {
      return undefined;
    }
    const details = statSync(sourcePath);
    if (!details.isFile() || details.size > maximumSourceBytes) {
      return undefined;
    }
    const bytes = readFileSync(sourcePath);
    if (bytes.includes(0)) {
      return undefined;
    }
    return new TextDecoder("utf-8", { fatal: true }).decode(bytes);
  } catch {
    return undefined;
  }
}

function isWithinDirectory(directory: string, filePath: string): boolean {
  const relative = path.relative(directory, filePath);
  return relative === "" || (relative !== ".." && !relative.startsWith(`..${path.sep}`));
}

function configuredTabSize(filePath: string): number {
  const value = vscode.workspace
    .getConfiguration("editor", vscode.Uri.file(filePath))
    .get<number>("tabSize", 4);
  return Number.isInteger(value) && value > 0 ? value : 4;
}

function toVscodeDiagnostic(problem: DiagnosticReportProblem): vscode.Diagnostic {
  const start = new vscode.Position(problem.line - 1, problem.character);
  const end = new vscode.Position(problem.endLine - 1, problem.endCharacter);
  const diagnostic = new vscode.Diagnostic(
    new vscode.Range(start, end),
    problem.message,
    vscodeSeverity(problem.severity),
  );
  diagnostic.source = "PseudoLearn";
  diagnostic.code = problem.code;
  return diagnostic;
}

function vscodeSeverity(
  severity: DiagnosticReportProblem["severity"],
): vscode.DiagnosticSeverity {
  if (severity === "error") {
    return vscode.DiagnosticSeverity.Error;
  }
  return severity === "warning"
    ? vscode.DiagnosticSeverity.Warning
    : vscode.DiagnosticSeverity.Information;
}
