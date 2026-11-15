import type { InterfaceLanguage } from "../contracts/extension_configuration";
import type { ExplainNotice } from "../contracts/language_client";

const notices: Record<ExplainNotice, Record<InterfaceLanguage, string>> = {
  none: { es: "No hay ayuda en esta posición.", en: "No help at this position." },
  stale: {
    es: "El documento cambió; repite la consulta.",
    en: "The document changed; repeat the query.",
  },
  unavailable: {
    es: "El servidor de lenguaje no está disponible.",
    en: "The language server is not available.",
  },
};

export function explainNotice(notice: ExplainNotice, language: InterfaceLanguage): string {
  return notices[notice][language];
}
