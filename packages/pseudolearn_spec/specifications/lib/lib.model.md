---
{
  "formato": "see/1",
  "id": "LIB.MODEL",
  "titulo": "Modelo de funciones incorporadas",
  "dominio": "biblioteca",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-lenguaje"
  ],
  "sujetos": [
    "reference",
    "engine",
    "aot"
  ],
  "resumen": "Modelo de funciones incorporadas.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LANG.TYPES.RELATIONS",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    },
    {
      "id": "DIAG.MODEL",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    }
  ],
  "revisado_por": [
    "revision-independiente-automatizada-r9"
  ]
}
---

# Modelo de funciones incorporadas

```definicion
 {
  "id": "D1",
  "termino": "functions",
  "texto": "Identidad, nombres, alias y firma de cada función incorporada.",
  "valor": {
    "squareRoot": {
      "family": "numbers",
      "lexemas": {
        "es": "rc",
        "en": "sqrt"
      },
      "alias": {
        "es": [
          "raiz"
        ],
        "en": []
      },
      "parametros": [
        "numeric"
      ],
      "retorno": "real"
    },
    "absoluteValue": {
      "family": "numbers",
      "lexemas": {
        "es": "abs",
        "en": "abs"
      },
      "alias": {
        "es": [],
        "en": []
      },
      "parametros": [
        "numeric"
      ],
      "retorno": "real"
    },
    "naturalLogarithm": {
      "family": "numbers",
      "lexemas": {
        "es": "ln",
        "en": "ln"
      },
      "alias": {
        "es": [],
        "en": [
          "log"
        ]
      },
      "parametros": [
        "numeric"
      ],
      "retorno": "real"
    },
    "exponential": {
      "family": "numbers",
      "lexemas": {
        "es": "exp",
        "en": "exp"
      },
      "alias": {
        "es": [],
        "en": []
      },
      "parametros": [
        "numeric"
      ],
      "retorno": "real"
    },
    "sine": {
      "family": "numbers",
      "lexemas": {
        "es": "sen",
        "en": "sin"
      },
      "alias": {
        "es": [
          "sin"
        ],
        "en": []
      },
      "parametros": [
        "numeric"
      ],
      "retorno": "real"
    },
    "cosine": {
      "family": "numbers",
      "lexemas": {
        "es": "cos",
        "en": "cos"
      },
      "alias": {
        "es": [],
        "en": []
      },
      "parametros": [
        "numeric"
      ],
      "retorno": "real"
    },
    "arcTangent": {
      "family": "numbers",
      "lexemas": {
        "es": "atan",
        "en": "atan"
      },
      "alias": {
        "es": [
          "arctan"
        ],
        "en": []
      },
      "parametros": [
        "numeric"
      ],
      "retorno": "real"
    },
    "truncate": {
      "family": "numbers",
      "lexemas": {
        "es": "trunc",
        "en": "trunc"
      },
      "alias": {
        "es": [],
        "en": []
      },
      "parametros": [
        "real"
      ],
      "retorno": "integer"
    },
    "round": {
      "family": "numbers",
      "lexemas": {
        "es": "redon",
        "en": "round"
      },
      "alias": {
        "es": [],
        "en": []
      },
      "parametros": [
        "real"
      ],
      "retorno": "integer"
    },
    "random": {
      "family": "numbers",
      "lexemas": {
        "es": "azar",
        "en": "random"
      },
      "alias": {
        "es": [
          "aleatorio"
        ],
        "en": [
          "rand"
        ]
      },
      "parametros": [],
      "retorno": "real"
    },
    "toText": {
      "family": "text",
      "lexemas": {
        "es": "ATexto",
        "en": "toText"
      },
      "alias": {
        "es": [
          "ConvertirATexto"
        ],
        "en": []
      },
      "parametros": [
        "anyPrimitive"
      ],
      "retorno": "string"
    },
    "textToInteger": {
      "family": "numbers",
      "lexemas": {
        "es": "AEntero",
        "en": "toInteger"
      },
      "alias": {
        "es": [],
        "en": []
      },
      "parametros": [
        "string"
      ],
      "retorno": "integer"
    },
    "textToReal": {
      "family": "numbers",
      "lexemas": {
        "es": "AReal",
        "en": "toReal"
      },
      "alias": {
        "es": [],
        "en": []
      },
      "parametros": [
        "string"
      ],
      "retorno": "real"
    },
    "length": {
      "family": "text",
      "lexemas": {
        "es": "Longitud",
        "en": "length"
      },
      "alias": {
        "es": [],
        "en": []
      },
      "parametros": [
        "string"
      ],
      "retorno": "integer"
    },
    "characterAt": {
      "family": "text",
      "lexemas": {
        "es": "CaracterEn",
        "en": "charAt"
      },
      "alias": {
        "es": [],
        "en": []
      },
      "parametros": [
        "string",
        "integer"
      ],
      "retorno": "character"
    },
    "characterCode": {
      "family": "text",
      "lexemas": {
        "es": "CodigoDe",
        "en": "charCode"
      },
      "alias": {
        "es": [],
        "en": []
      },
      "parametros": [
        "character"
      ],
      "retorno": "integer"
    },
    "characterFromCode": {
      "family": "text",
      "lexemas": {
        "es": "CaracterDesde",
        "en": "charFromCode"
      },
      "alias": {
        "es": [],
        "en": []
      },
      "parametros": [
        "integer"
      ],
      "retorno": "character"
    },
    "snapshot": {
      "family": "collections",
      "lexemas": {
        "es": "Instantanea",
        "en": "snapshot"
      },
      "alias": {
        "es": [],
        "en": []
      },
      "parametros": [
        "anySnapshot"
      ],
      "retorno": "immutableOfFirstArgument"
    },
    "substring": {
      "family": "text",
      "lexemas": {
        "es": "Subcadena",
        "en": "substring"
      },
      "alias": {
        "es": [],
        "en": []
      },
      "parametros": [
        "string",
        "integer",
        "integer"
      ],
      "retorno": "string"
    },
    "contains": {
      "family": "text",
      "lexemas": {
        "es": "Contiene",
        "en": "contains"
      },
      "alias": {
        "es": [],
        "en": []
      },
      "parametros": [
        "string",
        "string"
      ],
      "retorno": "boolean"
    },
    "positionOf": {
      "family": "text",
      "lexemas": {
        "es": "PosicionDe",
        "en": "indexOf"
      },
      "alias": {
        "es": [],
        "en": []
      },
      "parametros": [
        "string",
        "string"
      ],
      "retorno": "optionalInteger"
    },
    "startsWith": {
      "family": "text",
      "lexemas": {
        "es": "EmpiezaCon",
        "en": "startsWith"
      },
      "alias": {
        "es": [],
        "en": []
      },
      "parametros": [
        "string",
        "string"
      ],
      "retorno": "boolean"
    },
    "endsWith": {
      "family": "text",
      "lexemas": {
        "es": "TerminaCon",
        "en": "endsWith"
      },
      "alias": {
        "es": [],
        "en": []
      },
      "parametros": [
        "string",
        "string"
      ],
      "retorno": "boolean"
    },
    "replaceAll": {
      "family": "text",
      "lexemas": {
        "es": "Reemplazar",
        "en": "replace"
      },
      "alias": {
        "es": [],
        "en": []
      },
      "parametros": [
        "string",
        "string",
        "string"
      ],
      "retorno": "string"
    },
    "split": {
      "family": "text",
      "lexemas": {
        "es": "Dividir",
        "en": "split"
      },
      "alias": {
        "es": [],
        "en": []
      },
      "parametros": [
        "string",
        "string"
      ],
      "retorno": "stringVector"
    },
    "join": {
      "family": "text",
      "lexemas": {
        "es": "Unir",
        "en": "join"
      },
      "alias": {
        "es": [],
        "en": []
      },
      "parametros": [
        "stringVector",
        "string"
      ],
      "retorno": "string"
    },
    "trim": {
      "family": "text",
      "lexemas": {
        "es": "Recortar",
        "en": "trim"
      },
      "alias": {
        "es": [],
        "en": []
      },
      "parametros": [
        "string"
      ],
      "retorno": "string"
    },
    "shallowCopy": {
      "family": "collections",
      "lexemas": {
        "es": "Copiar",
        "en": "copy"
      },
      "alias": {
        "es": [],
        "en": []
      },
      "parametros": [
        "anyClass"
      ],
      "retorno": "sameAsFirstArgument"
    }
  }
}

```

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "D1 declara las veintiocho funciones incorporadas con lexemas canónicos, alias bilingües, firmas y familia; D2 declara las operaciones de capacidad y de biblioteca con su identidad, familia, receptor, formas, parámetros, retorno y efecto. D3 declara el constructor contextual y Enviar, Recibir y Cerrar con sus tipos y necesidad de Aguardar; no son operaciones del anfitrión. Los nombres no son palabras reservadas; un subprograma homónimo oculta la función libre. La cantidad y los tipos de argumentos se comprueban estáticamente antes de la ejecución.",
  "verificacion": [
    "C1",
    "C2",
    "C3",
    "C4",
    "C5"
  ]
}
```

```regla
{
  "id": "M1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Cada símbolo de biblioteca tiene una identidad única y estable. Sus facetas es y en, incluidos sus alias, nombran esa identidad y conservan la misma firma, efecto y falibilidad.",
  "verificacion": [
    "estructural"
  ],
  "justificacion": "La estructura bilingüe y la identidad canónica se verifican desde el recurso generado y su fixture negativo."
}
```

```regla
{
  "id": "M2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Dentro de cada perfil, las funciones sin receptor tienen formas únicas; las operaciones con receptor tienen pares únicos de receptor y forma. Una forma no puede identificar dos símbolos distintos en el mismo contexto.",
  "verificacion": [
    "estructural"
  ],
  "justificacion": "La estructura bilingüe y la identidad canónica se verifican desde el recurso generado y su fixture negativo."
}
```

```regla
{
  "id": "M3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Cada identidad de biblioteca tiene una ficha de ayuda disponible en español e inglés. La ausencia de una faceta o de una ficha invalida el corpus.",
  "verificacion": [
    "estructural"
  ],
  "justificacion": "La estructura bilingüe y la identidad canónica se verifican desde el recurso generado y su fixture negativo."
}
```

```regla
{
  "id": "M4",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Cada fila de D1 y D2 declara una familia de biblioteca: text, bytes, numbers, collections, io, time, json, network o tasks. Las fichas de ayuda permiten auditar los símbolos por esa familia.",
  "verificacion": [
    "estructural"
  ],
  "justificacion": "La estructura bilingüe y la identidad canónica se verifican desde el recurso generado y su fixture negativo."
}
```

```caso
{
  "id": "C1",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir Longitud(\"ab\");\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite length(\"ab\");\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "2\n",
    "terminacion": "completed"
  },
  "rigor": [
    "estricto",
    "flexible"
  ]
}
```

```caso
{
  "id": "C2",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir Longitud(1);\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite length(1);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "incompatibleArgumentType",
        "severidad": "error"
      }
    ]
  },
  "rigor": [
    "estricto",
    "flexible"
  ]
}
```

```caso
{
  "id": "C3",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir Longitud();\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite length();\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "argumentCountMismatch",
        "severidad": "error"
      }
    ]
  },
  "rigor": [
    "estricto",
    "flexible"
  ]
}
```

```caso
{
  "id": "C4",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir b Como Bytes <- Bytes();\nEscribir b.Longitud();\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine b as Bytes <- Bytes();\nwrite b.length();\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "0\n",
    "terminacion": "completed"
  },
  "rigor": [
    "estricto",
    "flexible"
  ]
}
```

```definicion
 {
  "id": "D2",
  "termino": "capabilityLibrary",
  "texto": "Operaciones de biblioteca y de capacidades con identidad estable, familia, receptor, formas bilingües, parámetros, resultado y clasificación de efectos.",
  "valor": {
    "operations": [
      {
        "identity": "request_console",
        "family": "io",
        "receiver": null,
        "es": "SolicitarConsola",
        "en": "requestConsole",
        "parameters": [],
        "result": "console",
        "effect": true,
        "fallible": true
      },
      {
        "identity": "request_arguments",
        "family": "io",
        "receiver": null,
        "es": "SolicitarArgumentos",
        "en": "requestArguments",
        "parameters": [],
        "result": "arguments",
        "effect": true,
        "fallible": true
      },
      {
        "identity": "request_directory",
        "family": "io",
        "receiver": null,
        "es": "SolicitarDirectorio",
        "en": "requestDirectory",
        "parameters": [
          "text"
        ],
        "result": "directory",
        "effect": true,
        "fallible": true
      },
      {
        "identity": "request_clock",
        "family": "time",
        "receiver": null,
        "es": "SolicitarReloj",
        "en": "requestClock",
        "parameters": [],
        "result": "clock",
        "effect": true,
        "fallible": true
      },
      {
        "identity": "request_timer",
        "family": "time",
        "receiver": null,
        "es": "SolicitarTemporizador",
        "en": "requestTimer",
        "parameters": [],
        "result": "timer",
        "effect": true,
        "fallible": true
      },
      {
        "identity": "console_write",
        "family": "io",
        "receiver": "console",
        "es": "Escribir",
        "en": "write",
        "parameters": [
          "text"
        ],
        "result": "integer",
        "effect": true,
        "fallible": true
      },
      {
        "identity": "arguments_values",
        "family": "io",
        "receiver": "arguments",
        "es": "Valores",
        "en": "values",
        "parameters": [],
        "result": "text_list",
        "effect": true,
        "fallible": true
      },
      {
        "identity": "directory_derive",
        "family": "io",
        "receiver": "directory",
        "es": "Subdirectorio",
        "en": "subdirectory",
        "parameters": [
          "text",
          "text"
        ],
        "result": "directory",
        "effect": true,
        "fallible": true
      },
      {
        "identity": "file_open",
        "family": "io",
        "receiver": "directory",
        "es": "Abrir",
        "en": "open",
        "parameters": [
          "text",
          "text"
        ],
        "result": "file",
        "effect": true,
        "fallible": true
      },
      {
        "identity": "directory_close",
        "family": "io",
        "receiver": "directory",
        "es": "Cerrar",
        "en": "close",
        "parameters": [],
        "result": "boolean",
        "effect": true,
        "fallible": true
      },
      {
        "identity": "file_read_bytes",
        "family": "io",
        "receiver": "file",
        "es": "LeerBytes",
        "en": "readBytes",
        "parameters": [],
        "result": "bytes",
        "effect": true,
        "fallible": true
      },
      {
        "identity": "file_read_text",
        "family": "io",
        "receiver": "file",
        "es": "LeerTexto",
        "en": "readText",
        "parameters": [],
        "result": "text",
        "effect": true,
        "fallible": true
      },
      {
        "identity": "file_write_bytes",
        "family": "io",
        "receiver": "file",
        "es": "EscribirBytes",
        "en": "writeBytes",
        "parameters": [
          "bytes"
        ],
        "result": "integer",
        "effect": true,
        "fallible": true
      },
      {
        "identity": "file_write_text",
        "family": "io",
        "receiver": "file",
        "es": "EscribirTexto",
        "en": "writeText",
        "parameters": [
          "text"
        ],
        "result": "integer",
        "effect": true,
        "fallible": true
      },
      {
        "identity": "file_close",
        "family": "io",
        "receiver": "file",
        "es": "Cerrar",
        "en": "close",
        "parameters": [],
        "result": "boolean",
        "effect": true,
        "fallible": true
      },
      {
        "identity": "clock_now",
        "family": "time",
        "receiver": "clock",
        "es": "Ahora",
        "en": "now",
        "parameters": [],
        "result": "integer",
        "effect": true,
        "fallible": true
      },
      {
        "identity": "timer_wait",
        "family": "time",
        "receiver": "timer",
        "es": "Esperar",
        "en": "wait",
        "parameters": [
          "integer"
        ],
        "result": "integer",
        "effect": true,
        "fallible": true
      },
      {
        "identity": "bytes_new",
        "family": "bytes",
        "receiver": null,
        "es": "Bytes",
        "en": "Bytes",
        "parameters": [],
        "result": "bytes",
        "effect": false,
        "fallible": false
      },
      {
        "identity": "bytes_length",
        "family": "bytes",
        "receiver": "bytes",
        "es": "Longitud",
        "en": "length",
        "parameters": [],
        "result": "integer",
        "effect": false,
        "fallible": false
      },
      {
        "identity": "bytes_at",
        "family": "bytes",
        "receiver": "bytes",
        "es": "En",
        "en": "at",
        "parameters": [
          "integer"
        ],
        "result": "integer",
        "effect": false,
        "fallible": false
      },
      {
        "identity": "bytes_utf8",
        "family": "bytes",
        "receiver": "bytes",
        "es": "TextoUtf8",
        "en": "utf8Text",
        "parameters": [],
        "result": "text",
        "effect": false,
        "fallible": true
      },
      {
        "identity": "bytes_from_text",
        "family": "bytes",
        "receiver": null,
        "es": "BytesDesdeTexto",
        "en": "bytesFromText",
        "parameters": [
          "text"
        ],
        "result": "bytes",
        "effect": false,
        "fallible": false
      },
      {
        "identity": "bytes_segment",
        "family": "bytes",
        "receiver": "bytes",
        "es": "Segmento",
        "en": "segment",
        "parameters": [
          "integer",
          "integer"
        ],
        "result": "bytes",
        "effect": false,
        "fallible": false
      },
      {
        "identity": "bytes_join",
        "family": "bytes",
        "receiver": "bytes",
        "es": "Unir",
        "en": "join",
        "parameters": [
          "bytes"
        ],
        "result": "bytes",
        "effect": false,
        "fallible": false
      },
      {
        "identity": "json_parse",
        "family": "json",
        "receiver": null,
        "es": "AnalizarJson",
        "en": "parseJson",
        "parameters": [
          "text"
        ],
        "result": "json_result",
        "effect": false,
        "fallible": false
      },
      {
        "identity": "json_text",
        "family": "json",
        "receiver": null,
        "es": "TextoJson",
        "en": "jsonText",
        "parameters": [
          "json_value"
        ],
        "result": "text",
        "effect": false,
        "fallible": false
      },
      {
        "identity": "json_null",
        "family": "json",
        "receiver": null,
        "es": "JsonNulo",
        "en": "jsonNull",
        "parameters": [],
        "result": "json_value",
        "effect": false,
        "fallible": false
      },
      {
        "identity": "json_boolean",
        "family": "json",
        "receiver": null,
        "es": "JsonLogico",
        "en": "jsonBoolean",
        "parameters": [
          "boolean"
        ],
        "result": "json_value",
        "effect": false,
        "fallible": false
      },
      {
        "identity": "json_integer",
        "family": "json",
        "receiver": null,
        "es": "JsonEntero",
        "en": "jsonInteger",
        "parameters": [
          "integer"
        ],
        "result": "json_value",
        "effect": false,
        "fallible": false
      },
      {
        "identity": "json_real",
        "family": "json",
        "receiver": null,
        "es": "JsonReal",
        "en": "jsonReal",
        "parameters": [
          "real"
        ],
        "result": "json_value",
        "effect": false,
        "fallible": true
      },
      {
        "identity": "json_string",
        "family": "json",
        "receiver": null,
        "es": "JsonCadena",
        "en": "jsonString",
        "parameters": [
          "text"
        ],
        "result": "json_value",
        "effect": false,
        "fallible": false
      },
      {
        "identity": "json_array",
        "family": "json",
        "receiver": null,
        "es": "ArregloJson",
        "en": "jsonArray",
        "parameters": [],
        "result": "json_value",
        "effect": false,
        "fallible": true
      },
      {
        "identity": "json_object",
        "family": "json",
        "receiver": null,
        "es": "ObjetoJson",
        "en": "jsonObject",
        "parameters": [],
        "result": "json_value",
        "effect": false,
        "fallible": true
      },
      {
        "identity": "json_kind",
        "family": "json",
        "receiver": "json_value",
        "es": "Tipo",
        "en": "kind",
        "parameters": [],
        "result": "json_kind",
        "effect": false,
        "fallible": false
      },
      {
        "identity": "json_as_boolean",
        "family": "json",
        "receiver": "json_value",
        "es": "ComoLogico",
        "en": "asBoolean",
        "parameters": [],
        "result": "optional_boolean",
        "effect": false,
        "fallible": false
      },
      {
        "identity": "json_as_integer",
        "family": "json",
        "receiver": "json_value",
        "es": "ComoEntero",
        "en": "asInteger",
        "parameters": [],
        "result": "optional_integer",
        "effect": false,
        "fallible": false
      },
      {
        "identity": "json_as_real",
        "family": "json",
        "receiver": "json_value",
        "es": "ComoReal",
        "en": "asReal",
        "parameters": [],
        "result": "optional_real",
        "effect": false,
        "fallible": false
      },
      {
        "identity": "json_as_text",
        "family": "json",
        "receiver": "json_value",
        "es": "ComoCadena",
        "en": "asText",
        "parameters": [],
        "result": "optional_text",
        "effect": false,
        "fallible": false
      },
      {
        "identity": "json_length",
        "family": "json",
        "receiver": "json_value",
        "es": "Longitud",
        "en": "length",
        "parameters": [],
        "result": "integer",
        "effect": false,
        "fallible": false
      },
      {
        "identity": "json_element",
        "family": "json",
        "receiver": "json_value",
        "es": "Elemento",
        "en": "element",
        "parameters": [
          "integer"
        ],
        "result": "optional_json_value",
        "effect": false,
        "fallible": false
      },
      {
        "identity": "json_field",
        "family": "json",
        "receiver": "json_value",
        "es": "Campo",
        "en": "field",
        "parameters": [
          "text"
        ],
        "result": "optional_json_value",
        "effect": false,
        "fallible": false
      },
      {
        "identity": "json_keys",
        "family": "json",
        "receiver": "json_value",
        "es": "Claves",
        "en": "keys",
        "parameters": [],
        "result": "text_list",
        "effect": false,
        "fallible": true
      },
      {
        "identity": "json_with_element",
        "family": "json",
        "receiver": "json_value",
        "es": "ConElemento",
        "en": "withElement",
        "parameters": [
          "json_value"
        ],
        "result": "json_value",
        "effect": false,
        "fallible": true
      },
      {
        "identity": "json_with_field",
        "family": "json",
        "receiver": "json_value",
        "es": "ConCampo",
        "en": "withField",
        "parameters": [
          "text",
          "json_value"
        ],
        "result": "json_value",
        "effect": false,
        "fallible": true
      }
    ]
  }
}

```


Las solicitudes de consola, argumentos, directorio identificado por nombre, reloj y temporizador
devuelven Resultado del tipo de capacidad y ErrorES; no construyen capacidades sin concesión.
Los métodos de capacidad definidos en capabilityLibrary también devuelven Resultado. Abrir y
Subdirectorio reciben un modo lectura, escritura o lectura_escritura (read, write o read_write en
inglés); la apertura de escritura crea o trunca, y una derivación nunca amplía los derechos.
LeerBytes y LeerTexto leen el contenido completo del archivo. EscribirBytes y EscribirTexto
devuelven la cantidad de bytes escritos; Valores devuelve Vector<Cadena>. Ahora devuelve el
instante grabado en nanosegundos y Esperar recibe una duración no negativa en nanosegundos y devuelve
el instante lógico de resolución. Cerrar devuelve Verdadero al cerrar y CapacidadCerrada al repetir.
Bytes() construye la secuencia vacía; Longitud y En consultan longitud y un octeto con índice
comprobado. BytesDesdeTexto codifica UTF-8, Segmento copia un intervalo de octetos y Unir concatena
dos secuencias inmutables. TextoUtf8 devuelve Resultado<Cadena,ErrorES> y rechaza UTF-8 inválido. ErrorES contiene
Codigo y Incierto (code y uncertain): el código es la variante portable, y la bandera informa
incertidumbre de una operación con potencial de escritura.

Los parámetros text admiten Cadena o Caracter; un carácter se convierte sin pérdida a una cadena
de un punto de código antes de emitir la solicitud. Esto conserva rutas de un solo carácter sin
alterar las reglas generales de asignación entre ambos tipos.

```definicion
{
  "id": "D3",
  "termino": "channelLibrary",
  "texto": "Canal(n) con contexto Canal<T> crea capacidad positiva explícita, como máximo 65 536 por omisión. Aguardar canal.Enviar(T) retorna Logico; Aguardar canal.Recibir() retorna Opcional<T>; canal.Cerrar() no retorna valor, no suspende y es idempotente. Son operaciones internas del runtime, nunca del anfitrión."
}
```

```caso
{
  "id": "C5",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir stream Como Canal<Entero> <- Canal(1);\nstream.Cerrar();\nElegir\nRecibir first Desde stream:\nRecibir second Desde stream:\nFinElegir\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine stream as channel<integer> <- channel(1);\nstream.close();\nselect\nreceive first from stream:\nreceive second from stream:\nendSelect\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "",
    "terminacion": "completed"
  }
}
```
