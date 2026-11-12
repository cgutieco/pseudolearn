import type {
  ExplainPresenterPort,
  ExplainRequest,
} from "../contracts/language_client";
import type { ClientLifecycle } from "./client_lifecycle";

export async function explainAtCursor(
  ports: { client: ClientLifecycle; presenter: ExplainPresenterPort },
  request: ExplainRequest,
): Promise<void> {
  const answer = await ports.client.explain(request);
  if (!answer) {
    ports.presenter.showNotice("unavailable");
    return;
  }
  if (answer.kind === "help") {
    ports.presenter.showHelp(answer.text);
    return;
  }
  ports.presenter.showNotice(answer.kind);
}
