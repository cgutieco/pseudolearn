import type { CodecProfile } from "../catalog/catalog_types.ts";
import type { LoudnessMeasure } from "../audit/loop_audit.ts";
import type { VideoProbe } from "../audit/video_audit.ts";

export type Outcome<T> = { readonly ok: true; readonly value: T } | { readonly ok: false; readonly error: string };

export type FrameRenderRequest = {
  readonly projectDirectory: string;
  readonly framesDirectory: string;
  readonly fps: number;
};

export type RenderedFrames = {
  readonly framePattern: string;
  readonly startNumber: number;
  readonly frameCount: number;
};

export type FrameRenderer = {
  renderFrames(request: FrameRenderRequest): Promise<Outcome<RenderedFrames>>;
};

export type EncodeRequest = {
  readonly framePattern: string;
  readonly startNumber: number;
  readonly fps: number;
  readonly audioPath: string | null;
  readonly profile: CodecProfile;
  readonly outputPath: string;
};

export type PlateAssemblyRequest = {
  readonly directory: string;
  readonly files: readonly string[];
  readonly fps: number;
  readonly outputPath: string;
};

export type StillRequest = {
  readonly videoPath: string;
  readonly frameIndex: number;
  readonly longSide: number | null;
  readonly outputPath: string;
};

export type MediaToolkit = {
  encode(request: EncodeRequest): Promise<Outcome<string>>;
  probe(path: string): Promise<Outcome<VideoProbe>>;
  measureLoudness(path: string): Promise<Outcome<LoudnessMeasure>>;
  sampleFrame(path: string, frameIndex: number): Promise<Outcome<Uint8Array>>;
  flattenImage(inputPath: string, outputPath: string): Promise<Outcome<string>>;
  assemblePlate(request: PlateAssemblyRequest): Promise<Outcome<string>>;
  extractStill(request: StillRequest): Promise<Outcome<string>>;
};

export type FileStore = {
  ensureDirectory(path: string): Promise<void>;
  writeText(path: string, content: string): Promise<void>;
  writeBytes(path: string, content: Uint8Array): Promise<void>;
  readBytes(path: string): Promise<Uint8Array>;
  readBytesIfPresent(path: string): Promise<Uint8Array | null>;
  copyTimelineLibrary(directory: string): Promise<void>;
  sha256(path: string): Promise<string>;
  join(...parts: readonly string[]): string;
};

export type Toolbox = {
  readonly frames: FrameRenderer;
  readonly media: MediaToolkit;
  readonly files: FileStore;
};
