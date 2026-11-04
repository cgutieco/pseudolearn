import {
  type ConfigurationFailure,
  type ConfigurationResult,
  type ExtensionConfigurationPort,
  type InterfaceLanguage,
  type Profile,
} from "../contracts/extension_configuration";

export function resolveConfiguration(
  input: ExtensionConfigurationPort,
): ConfigurationResult {
  const language = resolveInterfaceLanguage(input);
  if (input.interfaceLanguage.workspaceValue !== undefined) {
    return failure("workspaceInterfaceLanguage", language ?? "es");
  }
  if (!language) {
    return failure("invalidInterfaceLanguage", "es");
  }
  const profile = resolveProfile(input);
  if (!profile) {
    return failure("invalidProfile", language);
  }
  const serverPath = resolveServerPath(input);
  if (!serverPath.ok) {
    return { ...serverPath, language };
  }
  return {
    ok: true,
    value: { profile, interfaceLanguage: language, serverPath: serverPath.value },
  };
}

function resolveProfile(input: ExtensionConfigurationPort): Profile | undefined {
  const value = input.profile.workspaceValue ?? input.profile.globalValue ?? "es";
  return value === "es" || value === "en" ? value : undefined;
}

function resolveInterfaceLanguage(input: ExtensionConfigurationPort): InterfaceLanguage | undefined {
  const value = input.interfaceLanguage.globalValue;
  if (value === undefined) {
    return "es";
  }
  return value === "es" || value === "en" ? value : undefined;
}

function resolveServerPath(
  input: ExtensionConfigurationPort,
): { ok: true; value: string } | { ok: false; failure: ConfigurationFailure } {
  if (input.serverPath.workspaceValue !== undefined && input.serverPath.workspaceValue !== "") {
    return { ok: false, failure: "workspaceServerPath" };
  }
  const configuredPath = input.serverPath.globalValue;
  if (configuredPath === undefined || configuredPath === "") {
    return { ok: true, value: input.bundledServerPath };
  }
  if (typeof configuredPath !== "string") {
    return { ok: false, failure: "serverPathMustBeAbsolute" };
  }
  if (!input.development) {
    return { ok: false, failure: "serverPathDevelopmentOnly" };
  }
  if (!input.workspaceTrusted) {
    return { ok: false, failure: "serverPathRestrictedMode" };
  }
  if (!input.isAbsolutePath(configuredPath)) {
    return { ok: false, failure: "serverPathMustBeAbsolute" };
  }
  return { ok: true, value: configuredPath };
}

function failure(
  reason: ConfigurationFailure,
  language: InterfaceLanguage,
): ConfigurationResult {
  return { ok: false, failure: reason, language };
}
