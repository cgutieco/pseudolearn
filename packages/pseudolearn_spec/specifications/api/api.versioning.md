---
{
  "formato": "see/1",
  "id": "API.VERSIONING",
  "titulo": "Versión y capacidades de la API",
  "dominio": "motor",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-motor"
  ],
  "sujetos": [
    "engine"
  ],
  "resumen": "Versión, ediciones soportadas y negociación de capacidades.",
  "depende_de": [
    {
      "id": "API.MODEL",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "LANG.EDITION.MODEL",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "API versioning",
  "revisado_por": [
    "revision-independiente-automatizada-r9"
  ]
}
---

# Versión y capacidades de la API

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La API declara una versión semántica, las ediciones del lenguaje que admite (la vigente es 2026) y las capacidades que ofrece. El conjunto de capacidades reconocidas incluye analyze, execute, observe, seek, interface_language, program_view, state_pages, service_completion, service_help, generated_vocabulary, source_identity y event_binary (definidas por API.WIRE-FORMAT). Una capacidad opcional que el sujeto no ofrece se omite de su anuncio y no puede negociarse como disponible.",
  "verificacion": [
    "P1"
  ]
}
```

```propiedad
{
  "id": "P1",
  "regla": "R1",
  "generador": {
    "sesiones": "sesiones nuevas"
  },
  "propiedad": "La declaración incluye versión, ediciones y capacidades.",
  "oraculo": "Esquema de API.WIRE-FORMAT.",
  "justificacion": "La ejecuta el sujeto engine en R4."
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Un consumidor negocia las capacidades que usará; pedir una capacidad o una edición no declarada devuelve un error de versión y no cambia el estado de la sesión. seek permite consultar el estado en un evento pasado. program_view se anuncia solo cuando está disponible la proyección definida por API.PROGRAM.VIEW; state_pages se anuncia solo cuando se admite la consulta paginada de API.STATE.QUERY; service_help se anuncia solo cuando help_query opera sobre una sesión de edición vigente y devuelve el resultado estructurado definido por API.MODEL. generated_vocabulary se anuncia solo cuando el borde ofrece los lexemas, las funciones incorporadas con su firma, la tabla de precedencia y las plantillas de mensaje de diagnóstico del perfil activo, todos derivados de los datos del lenguaje y no de tablas del consumidor.",
  "verificacion": [
    "P2"
  ]
}
```

```caso
{
  "id": "C3",
  "regla": "R2",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "api",
  "api": {
    "calls": [
      {
        "operation": "version",
        "arguments": {}
      },
      {
        "operation": "operations",
        "arguments": {}
      },
      {
        "operation": "negotiate",
        "arguments": {
          "capabilities": "service_help"
        }
      }
    ]
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "capabilities": [
              "analyze",
              "interface_language",
              "ir",
              "execute",
              "observe",
              "seek",
              "gc_stress",
              "api",
              "program_view",
              "state_pages",
              "service_completion",
              "service_help",
              "generated_vocabulary",
              "source_identity",
              "event_binary"
            ]
          }
        },
        {
          "value": [
            "analysis",
            "document",
            "advance",
            "input",
            "cancel",
            "complete",
            "completion_templates",
            "open_edit_session",
            "apply_edit",
            "edit_complete",
            "edit_accept",
            "edit_insert_template",
            "edit_on_type",
            "edit_navigate_stop",
            "help_query",
            "query_state",
            "release"
          ]
        },
        {
          "value": null
        }
      ]
    }
  },
  "sujetos": [
    "engine"
  ]
}
```

```caso
{
  "id": "C4",
  "regla": "R2",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "api",
  "api": {
    "calls": [
      {
        "operation": "negotiate",
        "arguments": {
          "capabilities": "unknown_help"
        }
      }
    ]
  },
  "espera": {
    "api": {
      "results": [
        {
          "failure": {
            "family": "version"
          }
        }
      ]
    }
  },
  "sujetos": [
    "engine"
  ]
}
```

```propiedad
{
  "id": "P2",
  "regla": "R2",
  "generador": {
    "peticiones": "capacidades y ediciones declaradas y no declaradas"
  },
  "propiedad": "Las no declaradas producen error de versión sin efectos.",
  "oraculo": "Lista declarada.",
  "justificacion": "La ejecuta el sujeto engine en R4."
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Un anfitrión puede declarar sus garantías de red en negotiate mediante network_capabilities. El descriptor contiene exactamente tls_validation (true), wire_limit (available o unavailable), certificate_errors_distinguished (booleano), redirect_location_visible (booleano), ssrf_policy (adapter o browser) y compression (gzip o browser). La respuesta devuelve el descriptor sin modificarlo; un descriptor incompleto, con campos extra o con valores fuera de esas alternativas produce un error de uso. La declaración no concede permisos de red ni amplía los orígenes de la ejecución.",
  "verificacion": [
    "C5",
    "C6",
    "C7"
  ]
}
```

```caso
{
  "id": "C5",
  "regla": "R3",
  "perfiles": ["es"],
  "rigor": ["estricto"],
  "origen": "derivado",
  "operacion": "api",
  "api": {
    "calls": [
      {
        "operation": "negotiate",
        "arguments": {
          "network_capabilities": {
            "tls_validation": true,
            "wire_limit": "available",
            "certificate_errors_distinguished": true,
            "redirect_location_visible": true,
            "ssrf_policy": "adapter",
            "compression": "gzip"
          }
        }
      }
    ]
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "network_capabilities": {
              "tls_validation": true,
              "wire_limit": "available",
              "certificate_errors_distinguished": true,
              "redirect_location_visible": true,
              "ssrf_policy": "adapter",
              "compression": "gzip"
            }
          }
        }
      ]
    }
  },
  "sujetos": ["engine"]
}
```

```caso
{
  "id": "C6",
  "regla": "R3",
  "perfiles": ["es"],
  "rigor": ["estricto"],
  "origen": "derivado",
  "operacion": "api",
  "api": {
    "calls": [
      {
        "operation": "negotiate",
        "arguments": {
          "network_capabilities": {
            "tls_validation": true,
            "wire_limit": "unavailable",
            "certificate_errors_distinguished": false,
            "redirect_location_visible": false,
            "ssrf_policy": "browser",
            "compression": "browser"
          }
        }
      }
    ]
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "network_capabilities": {
              "tls_validation": true,
              "wire_limit": "unavailable",
              "certificate_errors_distinguished": false,
              "redirect_location_visible": false,
              "ssrf_policy": "browser",
              "compression": "browser"
            }
          }
        }
      ]
    }
  },
  "sujetos": ["engine"]
}
```

```caso
{
  "id": "C7",
  "regla": "R3",
  "perfiles": ["es"],
  "rigor": ["estricto"],
  "origen": "derivado",
  "operacion": "api",
  "api": {
    "calls": [
      {
        "operation": "negotiate",
        "arguments": {
          "network_capabilities": {
            "tls_validation": true,
            "wire_limit": "unavailable",
            "certificate_errors_distinguished": false,
            "redirect_location_visible": false,
            "ssrf_policy": "browser"
          }
        }
      }
    ]
  },
  "espera": {
    "api": {
      "results": [
        {
          "failure": {
            "family": "usage"
          }
        }
      ]
    }
  },
  "sujetos": ["engine"]
}
```
