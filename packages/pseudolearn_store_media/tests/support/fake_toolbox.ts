import type { LoudnessMeasure } from "../../src/audit/loop_audit.ts";
import type { VideoProbe } from "../../src/audit/video_audit.ts";
import type { EncodeRequest, FileStore, MediaToolkit, Outcome, RenderedFrames, Toolbox } from "../../src/pipeline/ports.ts";

export type FakeScript = {
  readonly frames?: Outcome<RenderedFrames>;
  readonly encode?: Outcome<string>;
  readonly probe?: Partial<VideoProbe>;
  readonly loudness?: readonly LoudnessMeasure[];
  readonly lastFrame?: Uint8Array;
  readonly flatten?: Outcome<string>;
  readonly flattened?: Uint8Array;
  readonly assemble?: Outcome<string>;
  readonly still?: Uint8Array;
};

export type FakeToolbox = Toolbox & {
  readonly written: Map<string, string | Uint8Array>;
  readonly encodes: EncodeRequest[];
  readonly renders: string[];
};

const FRAME = new Uint8Array(600 * 400 * 3).fill(40);
const DEFAULT_LOUDNESS = [{ integratedLufs: -21, truePeakDb: -9 }, { integratedLufs: -16, truePeakDb: -4 }];
const DEFAULT_FRAMES: Outcome<RenderedFrames> = { ok: true, value: { framePattern: "frames/frame_%06d.png", startNumber: 1, frameCount: 450 } };

export function fakeToolbox(script: FakeScript, probe: VideoProbe): FakeToolbox {
  const written = new Map<string, string | Uint8Array>();
  const encodes: EncodeRequest[] = [];
  const renders: string[] = [];
  return {
    written,
    encodes,
    renders,
    frames: {
      renderFrames: async (request) => {
        renders.push(request.projectDirectory);
        return script.frames ?? DEFAULT_FRAMES;
      },
    },
    media: fakeMedia(script, probe, { encodes, written }),
    files: fakeFiles(written),
  };
}

type MediaRecord = { readonly encodes: EncodeRequest[]; readonly written: Map<string, string | Uint8Array> };

function fakeMedia(script: FakeScript, probe: VideoProbe, record: MediaRecord): MediaToolkit {
  const { encodes, written } = record;
  const loudness = [...(script.loudness ?? DEFAULT_LOUDNESS)];
  return {
    encode: async (request) => {
      encodes.push(request);
      return script.encode ?? { ok: true, value: request.outputPath };
    },
    probe: async () => ({ ok: true, value: { ...probe, ...script.probe } }),
    measureLoudness: async () => ({ ok: true, value: loudness.shift() ?? { integratedLufs: -16, truePeakDb: -4 } }),
    sampleFrame: async (_path, index) => ({ ok: true, value: index === lastIndex(script) ? (script.lastFrame ?? FRAME) : FRAME }),
    assemblePlate: async (request) => {
      written.set(request.outputPath, new Uint8Array([request.files.length]));
      return script.assemble ?? { ok: true, value: request.outputPath };
    },
    extractStill: async (request) => {
      written.set(request.outputPath, script.still ?? new Uint8Array([request.longSide ?? 0]));
      return { ok: true, value: request.outputPath };
    },
    flattenImage: async (_input, output) => {
      written.set(output, script.flattened ?? new Uint8Array(0));
      return script.flatten ?? { ok: true, value: output };
    },
  };
}

function lastIndex(script: FakeScript): number {
  const frames = script.frames ?? DEFAULT_FRAMES;
  return frames.ok ? frames.value.frameCount - 1 : -1;
}

function fakeFiles(written: Map<string, string | Uint8Array>): FileStore {
  return {
    ensureDirectory: async () => undefined,
    writeText: async (path, content) => {
      written.set(path, content);
    },
    writeBytes: async (path, content) => {
      written.set(path, content);
    },
    readBytes: async (path) => {
      const content = written.get(path);
      return content instanceof Uint8Array ? content : new Uint8Array(0);
    },
    readBytesIfPresent: async (path) => {
      const content = written.get(path);
      return content instanceof Uint8Array ? content : null;
    },
    copyTimelineLibrary: async (directory) => {
      written.set(`${directory}/gsap.min.js`, "library");
    },
    sha256: async () => "f".repeat(64),
    join: (...parts) => parts.join("/"),
  };
}
