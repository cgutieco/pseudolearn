import assert from 'node:assert/strict';
import { describe, it } from 'node:test';
import { NETWORK_CAPABILITIES, declareFetchHost, performFetch } from './fetch_host.mjs';

function options(overrides = {}) {
  return { allowedOrigins: ['https://example.test'], ...overrides };
}

function effect(overrides = {}) {
  return {
    effect_seq: 1,
    operation: 'network_send',
    arguments: [{
      kind: 'http_request',
      value: {
        method: 'GET',
        url: 'https://example.test/resource',
        headers: [],
        body: null,
        effective_response_limit: 8,
        effective_timeout_nanos: 1_000_000_000,
        ...overrides,
      },
    }],
  };
}

describe('fetch host adapter', () => {
  it('declares browser guarantees explicitly', () => {
    assert.deepEqual(NETWORK_CAPABILITIES, {
      tls_validation: true,
      wire_limit: 'unavailable',
      certificate_errors_distinguished: false,
      redirect_location_visible: false,
      ssrf_policy: 'browser',
      compression: 'browser',
    });
  });

  it('declares the browser profile through API negotiation', () => {
    let operation;
    let argumentsJson;
    const declared = declareFetchHost({
      call: (name, value) => {
        operation = name;
        argumentsJson = value;
        return JSON.stringify({ value: { network_capabilities: NETWORK_CAPABILITIES } });
      },
    });
    assert.equal(operation, 'negotiate');
    assert.deepEqual(JSON.parse(argumentsJson), { network_capabilities: NETWORK_CAPABILITIES });
    assert.deepEqual(declared, NETWORK_CAPABILITIES);
  });

  it('sends without credentials, cache reuse, or redirect following', async () => {
    let actualUrl;
    let actualOptions;
    const response = await performFetch(effect(), options({
      fetchImplementation: async (url, options) => {
        actualUrl = url;
        actualOptions = options;
        return new Response(new Uint8Array([111, 107]), {
          status: 200,
          headers: [['content-type', 'text/plain']],
        });
      },
    }));
    assert.equal(actualUrl, 'https://example.test/resource');
    assert.equal(actualOptions.credentials, 'omit');
    assert.equal(actualOptions.cache, 'no-store');
    assert.equal(actualOptions.redirect, 'manual');
    assert.deepEqual(response.value.value.body, [111, 107]);
    assert.equal(response.value.value.final_url, actualUrl);
  });

  it('maps browser transport failures to connection failures', async () => {
    const response = await performFetch(effect({ method: 'POST' }), options({
      fetchImplementation: async () => {
        throw new TypeError('network failure');
      },
    }));
    assert.equal(response.outcome, 'uncertain');
    assert.deepEqual(response.value, { code: 'conexion_fallida', uncertain: true });
  });

  it('denies an origin outside the host grant before calling fetch', async () => {
    let called = false;
    const response = await performFetch(effect(), {
      allowedOrigins: ['https://other.example.test'],
      fetchImplementation: async () => {
        called = true;
        return new Response(null);
      },
    });
    assert.equal(called, false);
    assert.equal(response.value.code, 'destino_denegado');
  });

  it('rejects opaque redirects without exposing a location', async () => {
    const response = await performFetch(effect(), options({
      fetchImplementation: async () => ({
        type: 'opaqueredirect',
        status: 0,
        headers: new Headers(),
        url: '',
      }),
    }));
    assert.equal(response.outcome, 'failed');
    assert.equal(response.value.code, 'redireccion_denegada');
  });

  it('stops reading at the decoded body limit', async () => {
    const response = await performFetch(effect({ effective_response_limit: 2 }), options({
      fetchImplementation: async () => new Response(new Uint8Array([1, 2, 3]), {
        status: 200,
      }),
    }));
    assert.equal(response.outcome, 'failed');
    assert.deepEqual(response.value, { code: 'limite_excedido', uncertain: false });
  });

  it('counts response header limits in UTF-8 bytes', async () => {
    const response = await performFetch(effect({ header_bytes_limit: 2 }), options({
      fetchImplementation: async () => ({
        status: 200,
        headers: { entries: () => [['x', 'é']] },
        body: null,
        url: 'https://example.test/resource',
      }),
    }));
    assert.equal(response.outcome, 'failed');
    assert.equal(response.value.code, 'limite_excedido');
  });

  it('maps an aborted deadline to a timeout', async () => {
    const response = await performFetch(effect({ effective_timeout_nanos: 1 }), options({
      fetchImplementation: (_url, options) => new Promise((_resolve, reject) => {
        options.signal.addEventListener('abort', () => {
          reject(new DOMException('aborted', 'AbortError'));
        }, { once: true });
      }),
    }));
    assert.equal(response.outcome, 'failed');
    assert.equal(response.value.code, 'tiempo_agotado');
  });

  it('rejects malformed effect payloads before calling fetch', async () => {
    let called = false;
    const response = await performFetch({ operation: 'network_send', arguments: [] }, options({
      fetchImplementation: async () => {
        called = true;
        return new Response(null);
      },
    }));
    assert.equal(called, false);
    assert.equal(response.value.code, 'peticion_invalida');
  });
});
