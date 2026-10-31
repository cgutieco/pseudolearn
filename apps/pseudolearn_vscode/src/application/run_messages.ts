import type { InterfaceLanguage } from "../contracts/extension_configuration";
import type { RunCompletion, RunState } from "../contracts/editor_run";

const stateLabels: Record<RunState, Record<InterfaceLanguage, string>> = {
  idle: { es: "PseudoLearn: listo", en: "PseudoLearn: ready" },
  starting: { es: "PseudoLearn: iniciando", en: "PseudoLearn: starting" },
  running: { es: "PseudoLearn: ejecutando", en: "PseudoLearn: running" },
  awaitingInput: { es: "PseudoLearn: esperando entrada", en: "PseudoLearn: waiting for input" },
  stopping: { es: "PseudoLearn: deteniendo", en: "PseudoLearn: stopping" },
  finished: { es: "PseudoLearn: terminado", en: "PseudoLearn: finished" },
  aborted: {
    es: "PseudoLearn: abortado por el anfitrión",
    en: "PseudoLearn: aborted by the host",
  },
  serverDown: { es: "PseudoLearn: el proceso terminó", en: "PseudoLearn: the process ended" },
};

const finishLabels = {
  completed: { es: "Ejecución completada.", en: "Run completed." },
  failed: { es: "La ejecución falló.", en: "The run failed." },
  cancelled: { es: "Ejecución cancelada.", en: "Run cancelled." },
  input_closed: {
    es: "La entrada se cerró mientras el programa esperaba un valor.",
    en: "Input closed while the program was waiting for a value.",
  },
  output_limit: { es: "Se superó el límite de salida.", en: "The output limit was exceeded." },
  protocol_error: { es: "Error de protocolo del editor.", en: "Editor protocol error." },
};

export function stateLabel(state: RunState, language: InterfaceLanguage): string {
  return stateLabels[state][language];
}

export function finishLabel(completion: RunCompletion, language: InterfaceLanguage): string {
  if (completion.status === "failed" && completion.termination === null && completion.diagnosticErrorCount === 0) {
    return language === "es" ? "No se pudo iniciar el programa." : "The program could not be started.";
  }
  if (
    completion.diagnosticErrorCount > 0
    && (completion.status === "failed" || completion.status === "completed")
  ) {
    return diagnosticFailureLabel(completion.diagnosticErrorCount, language);
  }
  return finishLabels[completion.status][language];
}

export function stateConclusionLabel(
  state: RunState,
  language: InterfaceLanguage,
): string | undefined {
  if (state === "aborted") {
    return language === "es" ? "Ejecución abortada por el anfitrión." : "Run aborted by the host.";
  }
  if (state === "serverDown") {
    return language === "es"
      ? "El anfitrión terminó la ejecución sin informar su resultado."
      : "The host ended the run without reporting a result.";
  }
  return undefined;
}

function diagnosticFailureLabel(count: number, language: InterfaceLanguage): string {
  if (language === "es") {
    return count === 1
      ? "No se ejecutó el programa: hay 1 error."
      : `No se ejecutó el programa: hay ${count} errores.`;
  }
  return count === 1
    ? "The program was not run: 1 error."
    : `The program was not run: ${count} errors.`;
}

const refusals = {
  runActive: {
    es: "Ya hay una ejecución activa; deténla antes de iniciar otra.",
    en: "A run is already active; stop it before starting another.",
  },
  unsavedChanges: {
    es: "Guarda los cambios antes de ejecutar: la ejecución usa los archivos guardados.",
    en: "Save your changes before running: execution uses the saved files.",
  },
  noEntry: {
    es: "Elige un punto de entrada del proyecto antes de ejecutar.",
    en: "Choose a project entry before running.",
  },
  versionMismatch: {
    es: "El ejecutable habla otra versión del protocolo de editor.",
    en: "The executable speaks a different editor protocol version.",
  },
} as const;

export type Refusal = keyof typeof refusals;

export function refusalMessage(refusal: Refusal, language: InterfaceLanguage): string {
  return refusals[refusal][language];
}
