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
    "snapshot": {"lexemas": {"es": "Instantanea", "en": "snapshot"}, "alias": {"es": [], "en": []}, "parametros": ["anySnapshot"], "retorno": "immutableOfFirstArgument"},
    "shallowCopy": {
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
  "texto": "D1 declara las dieciocho funciones incorporadas, lexemas canónicos, alias bilingües y firmas, y D2 (capabilityLibrary) declara el constructor Bytes(), sus consultas posicionales y UTF-8, las solicitudes de capacidades explícitas y los métodos de capacidad con sus receptores, parámetros, retorno en Resultado<T, ErrorES> y clasificación de efecto. Sus nombres no son palabras reservadas; un subprograma homónimo oculta la función libre. La cantidad y los tipos de argumentos se comprueban estáticamente antes de la ejecución. D3 declara el constructor contextual y Enviar, Recibir y Cerrar con sus tipos y necesidad de Aguardar; no son operaciones del anfitrión.",
  "verificacion": [
    "C1",
    "C2",
    "C3",
    "C4",
    "C5"
  ]
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
  "texto": "Operaciones de capacidades y bytes con identidad estable, receptor, formas bilingües, parámetros, resultado y clasificación de efectos.",
  "valor": {
    "operations": [
      {
        "identity": "request_console",
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
        "receiver": "bytes",
        "es": "TextoUtf8",
        "en": "utf8Text",
        "parameters": [],
        "result": "text",
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
comprobado. TextoUtf8 devuelve Resultado<Cadena,ErrorES> y rechaza UTF-8 inválido. ErrorES contiene
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
