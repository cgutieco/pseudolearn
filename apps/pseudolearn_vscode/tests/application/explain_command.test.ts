import { describe, expect, it } from "vitest";
import { ClientLifecycle } from "../../src/application/client_lifecycle";
import { explainAtCursor } from "../../src/application/explain_command";
import { explainNotice } from "../../src/application/explain_messages";
import type {
  ExplainAnswer,
  ExplainNotice,
  ExplainPresenterPort,
  ExplainRequest,
  LanguageClientPort,
} from "../../src/contracts/language_client";

const request: ExplainRequest = { uri: "file:///a.pseudo", version: 3, line: 1, character: 4 };

function setup(answer: ExplainAnswer | Error) {
  const sent: ExplainRequest[] = [];
  const client: LanguageClientPort = {
    start: async () => undefined,
    stop: async () => undefined,
    explain: async (received) => {
      sent.push(received);
      if (answer instanceof Error) throw answer;
      return answer;
    },
  };
  const shown: string[] = [];
  const notices: ExplainNotice[] = [];
  const presenter: ExplainPresenterPort = {
    showHelp: (text) => shown.push(text),
    showNotice: (notice) => notices.push(notice),
  };
  const lifecycle = new ClientLifecycle({ create: () => client }, "pseudo");
  return { lifecycle, presenter, sent, shown, notices };
}

describe("explainAtCursor", () => {
  it("shows the server text verbatim and forwards the document version", async () => {
    const { lifecycle, presenter, sent, shown } = setup({ kind: "help", text: "<b>x</b> [a](command:evil)" });
    await lifecycle.start();
    await explainAtCursor({ client: lifecycle, presenter }, request);
    expect(sent).toEqual([request]);
    expect(shown).toEqual(["<b>x</b> [a](command:evil)"]);
  });

  it("reports no help and stale queries without showing help", async () => {
    for (const kind of ["none", "stale"] as const) {
      const { lifecycle, presenter, shown, notices } = setup({ kind });
      await lifecycle.start();
      await explainAtCursor({ client: lifecycle, presenter }, request);
      expect(notices).toEqual([kind]);
      expect(shown).toEqual([]);
    }
  });

  it("reports unavailable when the client is stopped or the request fails", async () => {
    const stopped = setup({ kind: "none" });
    await explainAtCursor({ client: stopped.lifecycle, presenter: stopped.presenter }, request);
    expect(stopped.notices).toEqual(["unavailable"]);
    const failing = setup(new Error("down"));
    await failing.lifecycle.start();
    await explainAtCursor({ client: failing.lifecycle, presenter: failing.presenter }, request);
    expect(failing.notices).toEqual(["unavailable"]);
  });
});

describe("explainNotice", () => {
  it("localizes every notice in both languages", () => {
    for (const notice of ["none", "stale", "unavailable"] as const) {
      expect(explainNotice(notice, "es")).not.toBe(explainNotice(notice, "en"));
    }
  });
});
