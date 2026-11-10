import { getImage } from 'astro:assets';
import type { Locale } from '@shared/i18n/locales';
import { FORMATS, mediaQueryFor } from './picture-media';

export type ShotScene = 'editor' | 'tasks' | 'lesson' | 'route';
export type ShotDevice = 'mobile' | 'desktop';
export type ShotLayout = 'responsive' | 'phone';
type Scheme = 'light' | 'dark';

export interface ShotSource {
  readonly format: string;
  readonly scheme: Scheme;
  readonly query: string;
  readonly media: string;
  readonly srcSet: string;
  readonly sizes: string;
}

export interface ShotPicture {
  readonly sources: readonly ShotSource[];
  readonly fallback: string;
  readonly width: number;
  readonly height: number;
}

interface DeviceVariant {
  readonly device: ShotDevice;
  readonly query: string;
  readonly widths: number[];
  readonly sizes: string;
}

const SHOT_FILES = import.meta.glob<ImageMetadata>('../../assets/product/*/*.png', {
  eager: true,
  import: 'default',
});

const SCHEMES: readonly Scheme[] = ['dark', 'light'];
const PHONE: DeviceVariant = { device: 'mobile', query: 'all', widths: [320, 640], sizes: '320px' };
const RESPONSIVE: readonly DeviceVariant[] = [
  {
    device: 'desktop',
    query: '(min-width: 900px)',
    widths: [800, 1280, 1920],
    sizes: '(min-width: 1100px) min(1100px, calc(100vw - 192px)), calc(100vw - 88px)',
  },
  { ...PHONE, sizes: 'min(390px, calc(100vw - 32px))', widths: [390, 780] },
];

export interface ShotRequest {
  readonly locale: Locale;
  readonly scene: ShotScene;
  readonly device: ShotDevice;
  readonly scheme: Scheme;
}

export function shotFile({ locale, scene, device, scheme }: ShotRequest): ImageMetadata {
  const path = `../../assets/product/${locale}/${scene}-${device}-${scheme}.png`;
  const file = SHOT_FILES[path];
  if (file === undefined) throw new Error(`Missing product shot ${path}`);
  return file;
}

export function shotVariants(layout: ShotLayout): readonly DeviceVariant[] {
  return layout === 'phone' ? [PHONE] : RESPONSIVE;
}

async function sourcesFor(locale: Locale, scene: ShotScene, variant: DeviceVariant): Promise<ShotSource[]> {
  const sources: ShotSource[] = [];
  for (const scheme of SCHEMES) {
    for (const format of FORMATS) {
      const src = shotFile({ locale, scene, device: variant.device, scheme });
      const image = await getImage({ src, widths: variant.widths, sizes: variant.sizes, format });
      const media = mediaQueryFor(variant.query, scheme);
      sources.push({
        format,
        scheme,
        query: variant.query,
        media,
        srcSet: image.srcSet.attribute,
        sizes: variant.sizes,
      });
    }
  }
  return sources;
}

export async function shotPicture(
  locale: Locale,
  scene: ShotScene,
  layout: ShotLayout,
): Promise<ShotPicture> {
  const groups = await Promise.all(shotVariants(layout).map((variant) => sourcesFor(locale, scene, variant)));
  const light = shotFile({ locale, scene, device: 'mobile', scheme: 'light' });
  const fallback = await getImage({ src: light, width: 390, format: 'png' });
  return { sources: groups.flat(), fallback: fallback.src, width: light.width, height: light.height };
}
