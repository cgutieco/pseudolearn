export const STORES = ["app-store", "microsoft-store"] as const;
export type StoreId = (typeof STORES)[number];

export const ASSET_KINDS = [
  "screenshot",
  "header-video",
  "search-video",
  "universal-image",
  "trailer",
  "trailer-thumbnail",
  "hero-art",
  "poster-art",
  "box-art",
] as const;
export type AssetKind = (typeof ASSET_KINDS)[number];

export const LAYOUT_RULES = [
  "critical-top-two-thirds",
  "no-added-text",
  "no-text",
  "no-interface",
  "key-info-centered",
  "text-inside-margin",
  "seamless-loop",
] as const;
export type LayoutRule = (typeof LAYOUT_RULES)[number];

export const LABEL_KINDS = ["caption", "title"] as const;
export type LabelKind = (typeof LABEL_KINDS)[number];
export type LabelLimits = Readonly<Partial<Record<LabelKind, number>>>;

export const EDIT_LIST_POLICIES = ["allowed", "forbidden"] as const;
export type EditListPolicy = (typeof EDIT_LIST_POLICIES)[number];

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

export const DEVICE_FRAMES = ["phone", "foldable", "tablet", "window", "none"] as const;
export type DeviceFrame = (typeof DEVICE_FRAMES)[number];

export const FOLD_AXES = ["none", "vertical", "horizontal"] as const;
export type FoldAxis = (typeof FOLD_AXES)[number];

export type Device = {
  readonly id: string;
  readonly logicalWidth: number;
  readonly logicalHeight: number;
  readonly plateScale: number;
  readonly cornerRadius: number;
  readonly frame: DeviceFrame;
  readonly fold: FoldAxis;
};

export type ViewportRect = { readonly x: number; readonly y: number; readonly width: number; readonly height: number };

export type ViewportProfile = {
  readonly name: string;
  readonly viewport: { readonly width: number; readonly height: number };
  readonly occlusions: readonly ViewportRect[];
};

export type SecondsRange = { readonly min: number; readonly max: number };

export const AUDIO_ENCODERS = ["native", "audiotoolbox"] as const;
export type AudioEncoder = (typeof AUDIO_ENCODERS)[number];

export type AudioProfile = {
  readonly codec: "aac";
  readonly encoder: AudioEncoder;
  readonly bitrateKbps: number;
  readonly sampleRate: number;
  readonly channels: number;
};

export const RATE_CONTROLS = ["cbr", "vbr"] as const;
export type RateControl = (typeof RATE_CONTROLS)[number];

export type CodecProfile = {
  readonly id: string;
  readonly profile: "high";
  readonly rateControl: RateControl;
  readonly minBitrateMbps: number | null;
  readonly bitrateMbps: number;
  readonly maxBitrateMbps: number;
  readonly containers: readonly string[];
  readonly closedGopSeconds: number | null;
  readonly bFrames: number | null;
  readonly editLists: EditListPolicy;
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
  readonly labelLimits: LabelLimits;
  readonly viewportProfiles: readonly ViewportProfile[];
  readonly video: VideoTraits | null;
  readonly device: Device | null;
};

export type LoudnessTarget = {
  readonly integratedLufs: number;
  readonly toleranceLu: number;
  readonly truePeakDb: number;
};

export type LexiconEntry = { readonly id: string; readonly pattern: RegExp };

export type Catalog = {
  readonly slots: readonly Slot[];
  readonly devices: readonly Device[];
  readonly loudness: LoudnessTarget;
  readonly lexicon: Readonly<Record<StoreId, readonly LexiconEntry[]>>;
  readonly localesByLanguage: Readonly<Record<StoreId, Readonly<Record<Language, readonly string[]>>>>;
};

export type CatalogError = { readonly path: string; readonly message: string };

export type Parsed<T> =
  | { readonly ok: true; readonly value: T }
  | { readonly ok: false; readonly errors: readonly CatalogError[] };
