import type { APIRoute } from 'astro';
import { llmsFull, plainText } from '@shared/agent-sheet/llms';

export const GET: APIRoute = () => new Response(llmsFull(), { headers: plainText });
