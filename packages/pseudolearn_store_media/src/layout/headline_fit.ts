export type MeasureText = (text: string, fontSize: number) => number;

export type HeadlineFitRequest = {
  readonly lines: readonly string[];
  readonly boxWidth: number;
  readonly boxHeight: number;
  readonly maximumFontSize: number;
  readonly minimumFontSize: number;
  readonly lineHeight: number;
  readonly measure: MeasureText;
};

export type HeadlineFit =
  | { readonly fits: true; readonly fontSize: number; readonly width: number; readonly height: number }
  | { readonly fits: false; readonly fontSize: number; readonly overflowingLines: readonly string[] };

const FONT_STEP = 1;

export function fitHeadline(request: HeadlineFitRequest): HeadlineFit {
  for (const size of candidateSizes(request)) {
    const width = widest(request, size);
    const height = request.lines.length * size * request.lineHeight;
    if (width <= request.boxWidth && height <= request.boxHeight) {
      return { fits: true, fontSize: size, width, height };
    }
  }
  const size = request.minimumFontSize;
  return {
    fits: false,
    fontSize: size,
    overflowingLines: request.lines.length * size * request.lineHeight > request.boxHeight
      ? request.lines
      : request.lines.filter((line) => request.measure(line, size) > request.boxWidth),
  };
}

function candidateSizes(request: HeadlineFitRequest): readonly number[] {
  const sizes: number[] = [];
  for (let size = Math.floor(request.maximumFontSize); size > request.minimumFontSize; size -= FONT_STEP) {
    sizes.push(size);
  }
  return [...sizes, request.minimumFontSize];
}

function widest(request: HeadlineFitRequest, size: number): number {
  return Math.max(0, ...request.lines.map((line) => request.measure(line, size)));
}
