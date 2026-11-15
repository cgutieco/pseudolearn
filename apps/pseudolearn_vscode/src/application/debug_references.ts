export interface FrameReference {
  kind: "frame";
  task: string;
  position: string;
  generation: string;
}

export interface VariablesReference {
  kind: "variables";
  task: string;
  target: string;
  query: "frame_variables" | "object_fields";
  generation: string;
}

type Reference = FrameReference | VariablesReference;

export const maximumReferences = 65536;

export class DebugReferences {
  private readonly table = new Map<number, Reference>();
  private next = 0;

  allocate(reference: Reference): number {
    if (this.table.size >= maximumReferences) throw new Error("debug reference table limit exceeded");
    if (this.next >= 2147483647) throw new Error("debug references exhausted");
    this.next += 1;
    this.table.set(this.next, reference);
    return this.next;
  }

  frame(identifier: unknown, generation: string): FrameReference {
    const found = this.lookup(identifier, "invalid frame reference");
    if (found?.kind !== "frame" || found.generation !== generation) throw new Error("stale or foreign frame reference");
    return found;
  }

  variables(identifier: unknown, generation: string): VariablesReference {
    const found = this.lookup(identifier, "invalid variable reference");
    if (found?.kind !== "variables" || found.generation !== generation) throw new Error("stale or foreign variable reference");
    return found;
  }

  clear(): void {
    this.table.clear();
  }

  private lookup(identifier: unknown, invalid: string): Reference | undefined {
    if (typeof identifier !== "number" || !Number.isSafeInteger(identifier) || identifier < -2147483648
      || identifier > 2147483647) throw new Error(invalid);
    return this.table.get(identifier);
  }
}
