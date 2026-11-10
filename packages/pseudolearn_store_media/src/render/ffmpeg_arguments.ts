import type { EncodeRequest, StillRequest } from "../pipeline/ports.ts";

const COLOR_PARAMETERS = "colorprim=bt709:transfer=bt709:colormatrix=bt709:range=tv";
const CONSTANT_RATE_PARAMETERS = "nal-hrd=cbr:force-cfr=1";
const COLOR_TAGS = ["-color_primaries", "bt709", "-color_trc", "bt709", "-colorspace", "bt709", "-color_range", "tv"];

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
    ...rateArguments(request),
    ...gopArguments(request),
    "-x264-params", profile.rateControl === "cbr" ? `${CONSTANT_RATE_PARAMETERS}:${COLOR_PARAMETERS}` : COLOR_PARAMETERS,
    ...COLOR_TAGS,
    "-r", String(fps),
  ];
  const audio = request.audioPath
    ? ["-c:a", "aac", "-b:a", `${profile.audio.bitrateKbps}k`, "-ar", String(profile.audio.sampleRate), "-ac", String(profile.audio.channels)]
    : ["-an"];
  return ["-y", "-hide_banner", "-loglevel", "error", ...inputs, ...audioInput, ...mapping, ...video, ...audio,
    "-shortest", "-movflags", "+faststart", request.outputPath];
}

function rateArguments(request: EncodeRequest): readonly string[] {
  const { profile } = request;
  if (profile.rateControl === "cbr") {
    const rate = `${profile.bitrateMbps}M`;
    return ["-b:v", rate, "-minrate", rate, "-maxrate", rate, "-bufsize", rate];
  }
  return ["-b:v", `${profile.bitrateMbps}M`, "-maxrate", `${profile.maxBitrateMbps}M`, "-bufsize", `${profile.maxBitrateMbps * 2}M`];
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

export function plateAssemblyArguments(framePattern: string, fps: number, outputPath: string): readonly string[] {
  return ["-y", "-hide_banner", "-loglevel", "error", "-framerate", String(fps), "-start_number", "1", "-i", framePattern,
    "-c:v", "libx264rgb", "-crf", "0", "-preset", "ultrafast", "-pix_fmt", "rgb24", outputPath];
}

export function stillArguments(request: StillRequest): readonly string[] {
  const scale = request.longSide === null
    ? []
    : [`scale=w='if(gt(iw,ih),${request.longSide},-2)':h='if(gt(iw,ih),-2,${request.longSide})':flags=area`];
  return ["-y", "-hide_banner", "-loglevel", "error", "-i", request.videoPath,
    "-vf", [`select=eq(n\\,${request.frameIndex})`, ...scale].join(","), "-fps_mode", "passthrough",
    "-frames:v", "1", "-pix_fmt", "rgb24", request.outputPath];
}
