import type { APIRoute } from 'astro';
import {
  sectionMarkdownResponse,
  sectionStaticPaths,
  type SectionRouteProps,
} from '@views/specification/specification-pages';

export const getStaticPaths = () => sectionStaticPaths('en');

export const GET: APIRoute = ({ props }) =>
  sectionMarkdownResponse('en', (props as SectionRouteProps).sectionId);
