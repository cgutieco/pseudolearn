export interface ConfigurationInspection {
  globalValue?: unknown;
  workspaceValue?: unknown;
}

export interface ExtensionConfigurationPort {
  profile: ConfigurationInspection;
  interfaceLanguage: ConfigurationInspection;
  serverPath: ConfigurationInspection;
  workspaceTrusted: boolean;
  development: boolean;
  bundledServerPath: string;
  isAbsolutePath(path: string): boolean;
}

export type Profile = "es" | "en";
export type InterfaceLanguage = "es" | "en";

export interface ResolvedExtensionConfiguration {
  profile: Profile;
  interfaceLanguage: InterfaceLanguage;
  serverPath: string;
}

export type ConfigurationFailure =
  | "invalidProfile"
  | "invalidInterfaceLanguage"
  | "workspaceInterfaceLanguage"
  | "workspaceServerPath"
  | "serverPathDevelopmentOnly"
  | "serverPathRestrictedMode"
  | "serverPathMustBeAbsolute";

export type ConfigurationResult =
  | { ok: true; value: ResolvedExtensionConfiguration }
  | { ok: false; failure: ConfigurationFailure; language: InterfaceLanguage };
