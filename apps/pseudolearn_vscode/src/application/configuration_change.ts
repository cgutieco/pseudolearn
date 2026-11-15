import type { ResolvedExtensionConfiguration } from "../contracts/extension_configuration";

export function configurationDiffers(
  previous: ResolvedExtensionConfiguration,
  next: ResolvedExtensionConfiguration,
): boolean {
  return previous.profile !== next.profile
    || previous.interfaceLanguage !== next.interfaceLanguage
    || previous.serverPath !== next.serverPath;
}
