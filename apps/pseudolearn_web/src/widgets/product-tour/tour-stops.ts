import type { TranslationKey } from '@shared/i18n/translator';
import type { ShotScene } from '@widgets/product-preview/shot-sources';

export interface TourPoint {
  readonly titleKey: TranslationKey;
  readonly textKey: TranslationKey;
}

export interface TourStop {
  readonly scene: ShotScene;
  readonly titleKey: TranslationKey;
  readonly altKey: TranslationKey;
  readonly points: readonly TourPoint[];
}

export const TOUR_STOPS: readonly TourStop[] = [
  {
    scene: 'editor',
    titleKey: 'home.tour.editor.title',
    altKey: 'home.tour.editor.alt',
    points: [
      { titleKey: 'home.tour.editor.stepping.title', textKey: 'home.tour.editor.stepping.text' },
      { titleKey: 'home.tour.editor.diagrams.title', textKey: 'home.tour.editor.diagrams.text' },
      { titleKey: 'home.tour.editor.trace.title', textKey: 'home.tour.editor.trace.text' },
    ],
  },
  {
    scene: 'tasks',
    titleKey: 'home.tour.tasks.title',
    altKey: 'home.tour.tasks.alt',
    points: [
      { titleKey: 'home.tour.tasks.timeline.title', textKey: 'home.tour.tasks.timeline.text' },
      { titleKey: 'home.tour.tasks.state.title', textKey: 'home.tour.tasks.state.text' },
      { titleKey: 'home.tour.tasks.arguments.title', textKey: 'home.tour.tasks.arguments.text' },
    ],
  },
];
