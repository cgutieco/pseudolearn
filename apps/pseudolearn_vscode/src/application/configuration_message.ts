import type {
  ConfigurationFailure,
  InterfaceLanguage,
} from "../contracts/extension_configuration";

const messages: Record<ConfigurationFailure, Record<InterfaceLanguage, string>> = {
  invalidProfile: {
    es: "El perfil de PseudoLearn debe ser es o en.",
    en: "PseudoLearn profile must be es or en.",
  },
  invalidStrictness: {
    es: "El rigor de PseudoLearn debe ser strict o flexible.",
    en: "PseudoLearn strictness must be strict or flexible.",
  },
  invalidInterfaceLanguage: {
    es: "El idioma de interfaz de PseudoLearn debe ser es o en.",
    en: "PseudoLearn interface language must be es or en.",
  },
  workspaceInterfaceLanguage: {
    es: "El idioma de interfaz es una preferencia personal y no puede venir del workspace.",
    en: "Interface language is a personal preference and cannot come from the workspace.",
  },
  workspaceServerPath: {
    es: "La ruta del servidor no puede configurarse desde el workspace.",
    en: "The server path cannot be configured by the workspace.",
  },
  serverPathDevelopmentOnly: {
    es: "La ruta alternativa del servidor solo está disponible en desarrollo.",
    en: "The server path override is available only in development.",
  },
  serverPathRestrictedMode: {
    es: "La ruta alternativa del servidor requiere un workspace de confianza.",
    en: "The server path override requires a trusted workspace.",
  },
  serverPathMustBeAbsolute: {
    es: "La ruta alternativa del servidor debe ser absoluta.",
    en: "The server path override must be absolute.",
  },
};

export function configurationMessage(
  failure: ConfigurationFailure,
  language: InterfaceLanguage,
): string {
  return messages[failure][language];
}
