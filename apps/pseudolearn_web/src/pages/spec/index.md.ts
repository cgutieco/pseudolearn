import type { APIRoute } from 'astro';
import { contentsMarkdownResponse } from '@views/specification/specification-pages';

export const GET: APIRoute = () => contentsMarkdownResponse('es');
