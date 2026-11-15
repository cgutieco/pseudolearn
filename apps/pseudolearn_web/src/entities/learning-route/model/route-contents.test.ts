import { describe, expect, it } from 'vitest';
import { isRouteLesson, routeLessons, routeParts } from './route-contents';
import { routeMetrics } from './route-metrics';

describe('generated learning route', () => {
  it('publishes the same parts and lessons in both languages', () => {
    expect(routeParts('en').map((part) => part.id)).toEqual(routeParts('es').map((part) => part.id));
    expect(routeLessons('en').map((lesson) => lesson.id)).toEqual(
      routeLessons('es').map((lesson) => lesson.id),
    );
  });

  it('has lessons and exercises to count', () => {
    const metrics = routeMetrics(routeParts('es'));
    expect(metrics.lessons).toBeGreaterThan(0);
    expect(metrics.exercises).toBeGreaterThan(metrics.lessons);
  });

  it('recognises a published lesson and rejects an unknown one', () => {
    const [lesson] = routeLessons('es');
    expect(isRouteLesson(lesson?.id ?? '')).toBe(true);
    expect(isRouteLesson('CON-A1')).toBe(false);
    expect(isRouteLesson('')).toBe(false);
  });
});
