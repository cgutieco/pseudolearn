export const FORMATS = ['avif', 'webp'] as const;

export function mediaQueryFor(query: string, scheme: string): string {
  const preference = `(prefers-color-scheme: ${scheme})`;
  return query === 'all' ? preference : `${query} and ${preference}`;
}
