---
{
  "formato": "see/1",
  "id": "API.WIRE-FORMAT",
  "titulo": "Formato de intercambio",
  "dominio": "motor",
  "estado": "experimental",
  "version": "0.1.0",
  "duenos": [
    "responsable-motor"
  ],
  "sujetos": [
    "engine",
    "app"
  ],
  "resumen": "Un esquema con JSON canónico y lotes binarios columnares.",
  "depende_de": [
    {
      "id": "API.MODEL",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    },
    {
      "id": "ENG.TRACE.EVENTS",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "Wire format",
  "cambio": {
    "clase": "verificacion_anadida",
    "impacto_usuarios": "Se conserva la versión numérica por autorización y no se añaden construcciones.",
    "impacto_implementaciones": "Sujetos retirados, alcance de casos y verificaciones de contratos existentes explícitos.",
    "justificacion": "Migración autorizada; la evidencia histórica, AOT y de plataforma conserva sus límites.",
    "revisado_por": "revision-independiente-automatizada"
  }
}
---

# Formato de intercambio

```definicion
{
  "id": "D1",
  "termino": "esquema de intercambio",
  "texto": "Claves ASCII en inglés y snake_case, independientes del idioma de interfaz. Diagnóstico: code, class, severity, span {start, end} con line y column, related y arguments. Resultado de análisis: tree y diagnostics. Resultado de ejecución: output, termination {kind, code, limit}, diagnostics y events. Evento: class, line, data y source opcional; source contiene revisión, identificador opaco de nodo y tramo cuando procede de una construcción de fuente, o null para un evento sintético. Las mismas formas son las respuestas de see-protocol/1."
}
```

```definicion
{
  "id": "D2",
  "termino": "lote binario de eventos",
  "texto": "Encabezado de 16 bytes: firma ASCII PLEV, versión u16 igual a 1, reservado u16 igual a 0 y número de eventos n como u64. Siguen cuatro columnas de n elementos en little endian: clase u8 (posición de la clase en el alfabeto de ENG.TRACE.EVENTS), línea u32, profundidad de marco u32 y desplazamiento u32 en el pool. El pool final contiene, precedido por su longitud total u32, un objeto JSON canónico UTF-8 por evento con las claves data y source; source es null para un evento sintético y contiene revisión, node_id y tramo para un evento originado por el programa. Los desplazamientos apuntan al inicio de cada objeto y las claves se ordenan por puntos de código."
}
```

```definicion
{
  "id": "D3",
  "termino": "valores enteros de 64 bits en JSON",
  "texto": "Los enteros con tipo i64 o u64 se codifican como cadenas decimales ASCII con signo menos solo para negativos, sin ceros iniciales salvo el cero y sin representación de menos cero. Los demás enteros se codifican como números JSON decimales exactos. Un consumidor no convierte una cadena i64 o u64 a un número IEEE 754 de doble precisión."
}
```

```definicion
{
  "id": "D4",
  "termino": "propiedad de los lotes y texto",
  "texto": "Las cadenas conservan sus escalares Unicode sin normalización y se codifican como UTF-8. Un lote binario es una respuesta propia e inmutable hasta que el consumidor la descarta. Un envoltorio Wasm copia los bytes necesarios antes de la siguiente llamada que pueda crecer la memoria; ninguna vista prestada de memoria Wasm sobrevive a esa llamada."
}
```

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El JSON canónico es UTF-8, sin espacios entre símbolos y con las claves de cada objeto ordenadas por puntos de código. Los enteros i64 y u64 siguen D3 y el resto de números enteros se escribe en decimal exacto. Las cadenas preservan los escalares y bytes UTF-8 del texto fuente sin normalización.",
  "verificacion": [
    "C1",
    "C2"
  ]
}
```

```caso
{
  "id": "C2",
  "regla": "R1",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "app",
  "aplicacion": {
    "scenario": "boundary",
    "input": {
      "wire_response": "{\"kind\":\"document\",\"id\":\"9007199254740993\"}",
      "source": "Algoritmo P\nEscribir \"é🧩\";\nFinAlgoritmo\n"
    }
  },
  "espera": {
    "aplicacion": {
      "decoded_id": "9007199254740993",
      "source_equal": true,
      "source_utf8_hex": "416c676f7269746d6f20500a4573637269626972202265cc81f09fa7a9223b0a46696e416c676f7269746d6f0a"
    }
  },
  "sujetos": [
    "app"
  ]
}
```

```caso
{
  "id": "C1",
  "regla": "R1",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "cli",
  "espera": {
    "codigo_salida": 1,
    "json": {
      "files": [
        {
          "path": "p.pseudo",
          "diagnostics": [
            {
              "code": "undeclaredVariable",
              "class": "semantic",
              "severity": "error",
              "span": {
                "start": {
                  "line": 2,
                  "column": 10
                },
                "end": {
                  "line": 2,
                  "column": 15
                }
              },
              "related": [],
              "arguments": {
                "lexeme": "total"
              }
            }
          ]
        }
      ]
    },
    "salida_error": ""
  },
  "cli": {
    "argumentos": [
      "comprobar",
      "--json",
      "p.pseudo"
    ],
    "entorno": {},
    "archivos": {
      "p.pseudo": "Algoritmo P\nEscribir total;\nFinAlgoritmo\n"
    }
  },
  "sujetos": [
    "engine"
  ]
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Los lotes de eventos se codifican en el binario columnar de D2. Decodificar un lote binario produce los mismos eventos, incluidos datos y fuente, que su codificación JSON; codificar y decodificar en cualquiera de las dos formas devuelve el valor original.",
  "verificacion": [
    "P1"
  ]
}
```

```propiedad
{
  "id": "P1",
  "regla": "R2",
  "generador": {
    "lotes": "trazas de los casos trace del corpus partidas en lotes"
  },
  "propiedad": "decodificar(codificar(x)) = x en las dos codificaciones y las dos decodificaciones coinciden.",
  "oraculo": "Igualdad estructural de los eventos.",
  "justificacion": "La ejecuta el sujeto engine en R5."
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "sistema",
  "texto": "Los bytes de una respuesta binaria no dependen de la vida de la sesión después de que el transporte los entrega. El consumidor puede conservar o descartar la respuesta; el emisor puede reutilizar su almacenamiento solo después de completar esa entrega. En Wasm, el adaptador copia cualquier segmento necesario antes de una operación que pueda crecer la memoria lineal.",
  "verificacion": [
    "C3"
  ]
}
```

```caso
{
  "id": "C3",
  "regla": "R3",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "app",
  "aplicacion": {
    "scenario": "boundary",
    "input": {
      "transport": "wasm",
      "response_bytes": [
        80,
        76,
        69,
        86,
        1,
        0,
        0,
        0,
        1,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        1,
        0,
        0,
        0,
        1,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        153,
        0,
        0,
        0,
        123,
        34,
        100,
        97,
        116,
        97,
        34,
        58,
        123,
        125,
        44,
        34,
        115,
        111,
        117,
        114,
        99,
        101,
        34,
        58,
        123,
        34,
        110,
        111,
        100,
        101,
        95,
        105,
        100,
        34,
        58,
        34,
        110,
        34,
        44,
        34,
        114,
        101,
        118,
        105,
        115,
        105,
        111,
        110,
        95,
        105,
        100,
        34,
        58,
        34,
        114,
        34,
        44,
        34,
        115,
        112,
        97,
        110,
        34,
        58,
        123,
        34,
        101,
        110,
        100,
        34,
        58,
        123,
        34,
        99,
        111,
        108,
        117,
        109,
        110,
        34,
        58,
        50,
        44,
        34,
        108,
        105,
        110,
        101,
        34,
        58,
        49,
        125,
        44,
        34,
        101,
        110,
        100,
        95,
        98,
        121,
        116,
        101,
        34,
        58,
        34,
        49,
        34,
        44,
        34,
        115,
        116,
        97,
        114,
        116,
        34,
        58,
        123,
        34,
        99,
        111,
        108,
        117,
        109,
        110,
        34,
        58,
        49,
        44,
        34,
        108,
        105,
        110,
        101,
        34,
        58,
        49,
        125,
        44,
        34,
        115,
        116,
        97,
        114,
        116,
        95,
        98,
        121,
        116,
        101,
        34,
        58,
        34,
        48,
        34,
        125,
        125,
        125
      ],
      "memory_growth_before_next_decode": true
    }
  },
  "espera": {
    "aplicacion": {
      "response_owned": true,
      "survives_next_call": true,
      "borrowed_view_retained": false,
      "source_equal_after_growth": true
    }
  },
  "sujetos": [
    "app"
  ]
}
```
