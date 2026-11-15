import { describe, expect, it } from "vitest";
import { finishLabel, refusalMessage, stateConclusionLabel } from "../../src/application/run_messages";
import type { RunCompletion, RunState } from "../../src/contracts/editor_run";

const completion = (
  status: RunCompletion["status"],
  diagnosticErrorCount = 0,
  termination: string | null = null,
): RunCompletion => ({ status, diagnosticErrorCount, termination });

describe("finishLabel", () => {
  it("reports successful completion only when no errors were reported", () => {
    expect(finishLabel(completion("completed", 0, "completed"), "es")).toBe("Ejecución completada.");
    expect(finishLabel(completion("completed", 2, "completed"), "es")).toBe(
      "No se ejecutó el programa: hay 2 errores.",
    );
  });

  it("localizes the diagnostic summary and preserves singular grammar", () => {
    expect(finishLabel(completion("failed", 1), "en")).toBe("The program was not run: 1 error.");
    expect(finishLabel(completion("failed", 3), "en")).toBe("The program was not run: 3 errors.");
  });

  it("distinguishes cancellation and failed host execution", () => {
    expect(finishLabel(completion("cancelled"), "es")).toBe("Ejecución cancelada.");
    expect(finishLabel(completion("failed", 0), "en")).toBe("The program could not be started.");
    expect(finishLabel(completion("protocol_error", 0, "protocol_error"), "en")).toBe(
      "Editor protocol error.",
    );
  });
});

describe("stateConclusionLabel", () => {
  it("reports host abort and unexpected host exit separately", () => {
    const stateLabels: RunState[] = ["aborted", "serverDown"];
    expect(stateLabels.map((state) => stateConclusionLabel(state, "es"))).toEqual([
      "Ejecución abortada por el anfitrión.",
      "El anfitrión terminó la ejecución sin informar su resultado.",
    ]);
  });

  it("does not create a conclusion for transient states", () => {
    expect(stateConclusionLabel("running", "en")).toBeUndefined();
  });
});

describe("refusalMessage", () => {
  it("localizes execution refusals in neutral Spanish and English", () => {
    expect(refusalMessage("unsavedChanges", "es")).toBe(
      "Guarda los cambios antes de ejecutar: la ejecución usa los archivos guardados.",
    );
    expect(refusalMessage("unsavedChanges", "en")).toBe(
      "Save your changes before running: execution uses the saved files.",
    );
    expect(refusalMessage("noEntry", "es")).toBe(
      "Elige un punto de entrada del proyecto antes de ejecutar.",
    );
    expect(refusalMessage("noEntry", "en")).toBe(
      "Choose a project entry before running.",
    );
  });
});
