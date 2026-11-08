import type { APIRoute } from 'astro';
import { llmsIndex, plainText } from '@shared/agent-sheet/llms';

export const GET: APIRoute = () => new Response(llmsIndex(), { headers: plainText });
