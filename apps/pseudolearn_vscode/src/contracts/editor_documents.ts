export interface DocumentsPort {
  unsavedPaths(): string[];
}

export interface CommandRunnerPort {
  run(
    executable: string,
    argumentsList: string[],
    workingDirectory: string,
  ): Promise<{ code: number | null; stdout: string }>;
}

export interface TranslationEditPort {
  currentVersion(path: string): number | undefined;
  replaceWhole(path: string, version: number, text: string): Promise<boolean>;
}
