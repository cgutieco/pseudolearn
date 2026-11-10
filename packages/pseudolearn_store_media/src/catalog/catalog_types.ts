export const STORES = ["app-store", "microsoft-store"] as const;
export type StoreId = (typeof STORES)[number];

export const ASSET_KINDS = [
  "screenshot",
  "app-preview",
  "header-video",
  "search-video",
  "universal-image",
  "trailer",
  "trailer-thumbnail",
  "hero-art",
  "poster-art",
  "box-art",
  "tile-icon",
] as const;
export type AssetKind = (typeof ASSET_KINDS)[number];

export const LAYOUT_RULES = [
  "critical-top-two-thirds",
  "no-added-text",
  "no-text",
  "no-interface",
  "key-info-centered",
] as const;
export type LayoutRule = (typeof LAYOUT_RULES)[number];

export const AUDIO_POLICIES = ["required", "none"] as const;
export type AudioPolicy = (typeof AUDIO_POLICIES)[number];

export const LANGUAGES = ["es", "en"] as const;
export type Language = (typeof LANGUAGES)[number];

export type NormalizedRect = {
  readonly x: number;
  readonly y: number;
  readonly width: number;
  readonly height: number;
};

export type SecondsRange = { readonly min: number; readonly max: number };

export type AudioProfile = {
  readonly codec: "aac";
  readonly bitrateKbps: number;
  readonly sampleRate: number;
  readonly channels: number;
};

export type CodecProfile = {
  readonly id: string;
  readonly profile: "high";
  readonly level: string | null;
  readonly bitrateMbps: number;
  readonly maxBitrateMbps: number;
  readonly closedGopSeconds: number | null;
  readonly bFrames: number | null;
  readonly audio: AudioProfile;
};

export type VideoTraits = {
  readonly fps: number;
  readonly acceptedFps: readonly number[];
  readonly duration: SecondsRange;
  readonly codecProfile: CodecProfile;
  readonly audio: AudioPolicy;
};

export type Slot = {
  readonly id: string;
  readonly store: StoreId;
  readonly surface: string;
  readonly kind: AssetKind;
  readonly width: number;
  readonly height: number;
  readonly maxCount: number;
  readonly maxBytes: number;
  readonly safeArea: NormalizedRect;
  readonly rules: readonly LayoutRule[];
  readonly video: VideoTraits | null;
};

export type LoudnessTarget = {
  readonly integratedLufs: number;
  readonly toleranceLu: number;
  readonly truePeakDb: number;
};

export type LexiconEntry = { readonly id: string; readonly pattern: RegExp };

export type Catalog = {
  readonly slots: readonly Slot[];
  readonly loudness: LoudnessTarget;
  readonly lexicon: Readonly<Record<StoreId, readonly LexiconEntry[]>>;
  readonly localesByLanguage: Readonly<Record<StoreId, Readonly<Record<Language, readonly string[]>>>>;
};

export type CatalogError = { readonly path: string; readonly message: string };

export type Parsed<T> =
  | { readonly ok: true; readonly value: T }
  | { readonly ok: false; readonly errors: readonly CatalogError[] };
