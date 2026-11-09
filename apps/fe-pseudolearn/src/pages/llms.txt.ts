import type { APIRoute } from 'astro';
import { llmsIndex, plainText } from '@shared/agent-sheet/llms';
import { specificationAgentLinks } from '@views/specification/specification-pages';

export const GET: APIRoute = () => new Response(llmsIndex(specificationAgentLinks()), { headers: plainText });
