import type { APIRoute } from 'astro';
import {
  sectionMarkdownResponse,
  sectionStaticPaths,
  type SectionRouteProps,
} from '@views/specification/specification-pages';

export const getStaticPaths = () => sectionStaticPaths('es');

export const GET: APIRoute = ({ props }) =>
  sectionMarkdownResponse('es', (props as SectionRouteProps).sectionId);
