export const NETWORK_CAPABILITIES = Object.freeze({
  tls_validation: true,
  wire_limit: 'unavailable',
  certificate_errors_distinguished: false,
  redirect_location_visible: false,
  ssrf_policy: 'browser',
  compression: 'browser',
});

export function declareFetchHost(session) {
  const response = JSON.parse(session.call(
    'negotiate',
    JSON.stringify({ network_capabilities: NETWORK_CAPABILITIES }),
  ));
  if (response.value?.network_capabilities === undefined) {
    throw new Error('Fetch host negotiation failed');
  }
  return response.value.network_capabilities;
}

export async function performFetch(effect, options = {}) {
  const request = requestValue(effect);
  if (request === null) return failure('peticion_invalida');
  const allowedOrigins = new Set(options.allowedOrigins ?? []);
  let parsedUrl;
  try {
    parsedUrl = new URL(request.url);
  } catch {
    return failure('url_invalida');
  }
  if (!['http:', 'https:'].includes(parsedUrl.protocol)
      || parsedUrl.username !== ''
      || parsedUrl.password !== '') {
    return failure('url_invalida');
  }
  if (!allowedOrigins.has(parsedUrl.origin)) return failure('destino_denegado');
  const fetchImplementation = options.fetchImplementation ?? globalThis.fetch;
  if (typeof fetchImplementation !== 'function') return failure('conexion_fallida');
  const timeoutNanos = request.effective_timeout_nanos ?? request.timeout_nanos ?? 30_000_000_000;
  if (!Number.isSafeInteger(timeoutNanos) || timeoutNanos <= 0) return failure('tiempo_agotado');
  const responseLimit = request.effective_response_limit ?? request.response_limit ?? 8_388_608;
  if (!Number.isSafeInteger(responseLimit) || responseLimit < 0) return failure('peticion_invalida');
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), Math.max(1, Math.ceil(timeoutNanos / 1_000_000)));
  let sent = false;
  try {
    sent = true;
    const response = await fetchImplementation(request.url, {
      method: request.method,
      headers: request.headers,
      body: request.body === null ? undefined : Uint8Array.from(request.body),
      credentials: 'omit',
      cache: 'no-store',
      redirect: 'manual',
      signal: controller.signal,
    });
    if (response.type === 'opaqueredirect' || response.status === 0
        || (response.status >= 300 && response.status < 400)) {
      return failure('redireccion_denegada');
    }
    const headers = Array.from(response.headers.entries());
    const headerBytes = headers.reduce(
      (total, [name, value]) => total + utf8Length(name) + utf8Length(value),
      0,
    );
    if (headers.length > (request.headers_limit ?? 64)
        || headerBytes > (request.header_bytes_limit ?? 16_384)) {
      return failure('limite_excedido');
    }
    const body = await readBody(response.body, responseLimit, controller.signal);
    if (body === null) return failure('limite_excedido');
    return {
      outcome: 'committed',
      value: {
        kind: 'http_response',
        value: {
          status: response.status,
          headers,
          body,
          final_url: response.url || request.url,
        },
      },
    };
  } catch {
    return controller.signal.aborted
      ? failure('tiempo_agotado', sent && mutates(request.method))
      : failure('conexion_fallida', sent && mutates(request.method));
  } finally {
    clearTimeout(timeout);
  }
}

function requestValue(effect) {
  const request = effect?.operation === 'network_send'
    ? effect.arguments?.[0]?.value
    : null;
  if (request === null || typeof request !== 'object') return null;
  if (!['GET', 'HEAD', 'POST', 'PUT', 'PATCH', 'DELETE'].includes(request.method)) return null;
  if (typeof request.url !== 'string' || !Array.isArray(request.headers)) return null;
  if (!request.headers.every((header) => Array.isArray(header) && header.length === 2
      && header.every((part) => typeof part === 'string'))) return null;
  if (request.body !== null && (!Array.isArray(request.body)
      || !request.body.every((byte) => Number.isInteger(byte) && byte >= 0 && byte <= 255))) return null;
  return request;
}

async function readBody(stream, limit, signal) {
  if (stream === null) return [];
  const reader = stream.getReader();
  const body = [];
  let count = 0;
  while (!signal.aborted) {
    const part = await reader.read();
    if (part.done) return body;
    count += part.value.byteLength;
    if (count > limit) {
      await reader.cancel();
      return null;
    }
    for (const byte of part.value) body.push(byte);
  }
  return null;
}

function mutates(method) {
  return ['POST', 'PUT', 'PATCH', 'DELETE'].includes(method);
}

function utf8Length(value) {
  return new TextEncoder().encode(value).byteLength;
}

function failure(code, uncertain = false) {
  return {
    outcome: uncertain ? 'uncertain' : 'failed',
    value: { code, uncertain },
  };
}
