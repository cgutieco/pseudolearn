import type { EncodeRequest } from "../pipeline/ports.ts";

const COLOR_TAGS = [
  "-x264-params", "colorprim=bt709:transfer=bt709:colormatrix=bt709:range=tv",
  "-color_primaries", "bt709", "-color_trc", "bt709", "-colorspace", "bt709", "-color_range", "tv",
];

export function encoderArguments(request: EncodeRequest): readonly string[] {
  const { profile, fps } = request;
  const inputs = ["-framerate", String(fps), "-start_number", String(request.startNumber), "-i", request.framePattern];
  const audioInput = request.audioPath ? ["-i", request.audioPath] : [];
  const mapping = request.audioPath ? ["-map", "0:v:0", "-map", "1:a:0"] : ["-map", "0:v:0"];
  const video = [
    "-c:v", "libx264", "-profile:v", profile.profile,
    ...(profile.level ? ["-level:v", profile.level] : []),
    "-preset", "slow",
    "-vf", "scale=out_color_matrix=bt709:out_range=tv,format=yuv420p",
    "-b:v", `${profile.bitrateMbps}M`, "-maxrate", `${profile.maxBitrateMbps}M`, "-bufsize", `${profile.maxBitrateMbps * 2}M`,
    ...gopArguments(request),
    ...COLOR_TAGS,
    "-r", String(fps),
  ];
  const audio = request.audioPath
    ? ["-c:a", "aac", "-b:a", `${profile.audio.bitrateKbps}k`, "-ar", String(profile.audio.sampleRate), "-ac", String(profile.audio.channels)]
    : ["-an"];
  return ["-y", "-hide_banner", "-loglevel", "error", ...inputs, ...audioInput, ...mapping, ...video, ...audio,
    "-shortest", "-movflags", "+faststart", request.outputPath];
}

function gopArguments(request: EncodeRequest): readonly string[] {
  const { closedGopSeconds, bFrames } = request.profile;
  const gop = closedGopSeconds === null
    ? []
    : ["-g", String(Math.max(1, Math.round(request.fps * closedGopSeconds))), "-keyint_min", String(Math.max(1, Math.round(request.fps * closedGopSeconds))),
      "-sc_threshold", "0", "-flags", "+cgop"];
  return [...gop, ...(bFrames === null ? [] : ["-bf", String(bFrames)])];
}

export function frameSampleArguments(path: string, frameIndex: number, width: number): readonly string[] {
  return ["-hide_banner", "-loglevel", "error", "-i", path,
    "-vf", `select=eq(n\\,${frameIndex}),scale=${width}:-2:flags=area`, "-fps_mode", "passthrough",
    "-frames:v", "1", "-f", "rawvideo", "-pix_fmt", "rgb24", "pipe:1"];
}

export function loudnessArguments(path: string): readonly string[] {
  return ["-hide_banner", "-nostats", "-i", path, "-filter_complex", "ebur128=peak=true", "-f", "null", "-"];
}

export function probeArguments(path: string): readonly string[] {
  return ["-v", "error", "-print_format", "json", "-show_streams", "-show_format", path];
}

export function flattenArguments(inputPath: string, outputPath: string): readonly string[] {
  return ["-y", "-hide_banner", "-loglevel", "error", "-i", inputPath, "-frames:v", "1", "-pix_fmt", "rgb24", outputPath];
}
