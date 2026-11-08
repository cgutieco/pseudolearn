---
{
  "formato": "see/1",
  "id": "TOOL.MCP",
  "titulo": "Servidor MCP de la CLI",
  "dominio": "herramienta",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-herramientas"
  ],
  "sujetos": [
    "cli"
  ],
  "resumen": "Protocolo, herramientas y recursos del servidor MCP que pseudo mcp ofrece a los asistentes de código.",
  "depende_de": [
    {
      "id": "TOOL.CLI.CONVENTIONS",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "TOOL.CLI.TRANSLATE",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "TOOL.FORMAT.STYLE",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "API.EXECUTE",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "API.ANALYZE",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "ENG.LIMITS",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "DIAG.CATALOG",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "CLI MCP server",
  "revisado_por": [
    "cesar-antonio-gutierrez-contreras-2026-11-08"
  ]
}
---

# Servidor MCP de la CLI

```definicion
{
  "id": "D1",
  "termino": "herramientas del servidor",
  "texto": "Herramientas del servidor MCP en el orden en que tools/list las anuncia, cada una con name, description e inputSchema, en JSON compacto: [{\"name\":\"check\",\"description\":\"Analyses a program and returns its diagnostics.\",\"inputSchema\":{\"type\":\"object\",\"properties\":{\"source\":{\"type\":\"string\",\"description\":\"Complete PseudoLearn program.\"},\"profile\":{\"type\":\"string\",\"enum\":[\"es\",\"en\"]}},\"required\":[\"source\"]}},{\"name\":\"run\",\"description\":\"Runs a program without capabilities, feeding inputs in order.\",\"inputSchema\":{\"type\":\"object\",\"properties\":{\"source\":{\"type\":\"string\",\"description\":\"Complete PseudoLearn program.\"},\"profile\":{\"type\":\"string\",\"enum\":[\"es\",\"en\"]},\"inputs\":{\"type\":\"array\",\"items\":{\"type\":\"string\"}},\"step_limit\":{\"type\":\"integer\"}},\"required\":[\"source\"]}},{\"name\":\"format\",\"description\":\"Returns the canonical formatting of a valid program.\",\"inputSchema\":{\"type\":\"object\",\"properties\":{\"source\":{\"type\":\"string\",\"description\":\"Complete PseudoLearn program.\"},\"profile\":{\"type\":\"string\",\"enum\":[\"es\",\"en\"]}},\"required\":[\"source\"]}},{\"name\":\"translate\",\"description\":\"Translates a valid program to the other syntax profile.\",\"inputSchema\":{\"type\":\"object\",\"properties\":{\"source\":{\"type\":\"string\",\"description\":\"Complete PseudoLearn program.\"},\"target_profile\":{\"type\":\"string\",\"enum\":[\"es\",\"en\"]}},\"required\":[\"source\",\"target_profile\"]}},{\"name\":\"explain\",\"description\":\"Explains a diagnostic code.\",\"inputSchema\":{\"type\":\"object\",\"properties\":{\"code\":{\"type\":\"string\"},\"locale\":{\"type\":\"string\",\"enum\":[\"es\",\"en\"]}},\"required\":[\"code\"]}},{\"name\":\"search_reference\",\"description\":\"Searches the language sheet.\",\"inputSchema\":{\"type\":\"object\",\"properties\":{\"query\":{\"type\":\"string\"},\"locale\":{\"type\":\"string\",\"enum\":[\"es\",\"en\"]}},\"required\":[\"query\"]}},{\"name\":\"example\",\"description\":\"Lists the canonical examples or returns one by id.\",\"inputSchema\":{\"type\":\"object\",\"properties\":{\"id\":{\"type\":\"string\"},\"locale\":{\"type\":\"string\",\"enum\":[\"es\",\"en\"]}},\"required\":[]}}]"
}
```

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "pseudo mcp sirve el protocolo MCP sobre la entrada y la salida estándar: cada mensaje JSON-RPC 2.0 es una línea UTF-8 de como mucho 1048576 bytes y cada respuesta es una línea en JSON compacto cuyas claves van en este orden: jsonrpc, id y result o error; dentro de error, code y message. La salida estándar contiene solo protocolo. Las líneas vacías y las notificaciones, que son mensajes con method y sin id, no reciben respuesta. Una línea que no es JSON recibe el error -32700 Parse error con id null; una línea de más de 1048576 bytes, el error -32600 Invalid Request con id null; un mensaje sin method, el error -32600 Invalid Request con su id, o null si no lo tiene; un método desconocido con id, el error -32601 Method not found. Al terminar la entrada, el proceso termina con código 0.",
  "verificacion": [
    "C1"
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
  "origen": "derivado",
  "operacion": "cli",
  "espera": {
    "codigo_salida": 0,
    "salida": "{\"jsonrpc\":\"2.0\",\"id\":null,\"error\":{\"code\":-32700,\"message\":\"Parse error\"}}\n{\"jsonrpc\":\"2.0\",\"id\":7,\"error\":{\"code\":-32601,\"message\":\"Method not found\"}}\n{\"jsonrpc\":\"2.0\",\"id\":8,\"error\":{\"code\":-32600,\"message\":\"Invalid Request\"}}\n",
    "salida_error": ""
  },
  "cli": {
    "argumentos": [
      "mcp"
    ],
    "entorno": {},
    "entrada": "no es json\n{\"jsonrpc\":\"2.0\",\"id\":7,\"method\":\"nada\"}\n{\"jsonrpc\":\"2.0\",\"method\":\"notifications/initialized\"}\n\n{\"jsonrpc\":\"2.0\",\"id\":8}\n",
    "archivos": {}
  }
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "initialize responde protocolVersion 2025-06-18, capabilities con tools y resources vacíos, y serverInfo con name pseudolearn y version igual a la edición del lenguaje, 2026. ping responde un objeto vacío.",
  "verificacion": [
    "C2"
  ]
}
```

```caso
{
  "id": "C2",
  "regla": "R2",
  "perfiles": [
    "es"
  ],
  "origen": "derivado",
  "operacion": "cli",
  "espera": {
    "codigo_salida": 0,
    "salida": "{\"jsonrpc\":\"2.0\",\"id\":1,\"result\":{\"protocolVersion\":\"2025-06-18\",\"capabilities\":{\"tools\":{},\"resources\":{}},\"serverInfo\":{\"name\":\"pseudolearn\",\"version\":\"2026\"}}}\n{\"jsonrpc\":\"2.0\",\"id\":2,\"result\":{}}\n",
    "salida_error": ""
  },
  "cli": {
    "argumentos": [
      "mcp"
    ],
    "entorno": {},
    "entrada": "{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"initialize\",\"params\":{}}\n{\"jsonrpc\":\"2.0\",\"id\":2,\"method\":\"ping\"}\n",
    "archivos": {}
  }
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "tools/list responde las herramientas de D1, en su orden, cada una con name, description e inputSchema. tools/call con name y arguments responde result con content, un único bloque con type text y text igual al resultado de la herramienta en JSON compacto, e isError. Un name ausente o que no es una herramienta de D1 es el error -32602 Unknown tool. Antes de ejecutar la herramienta, arguments, que es un objeto vacío si falta, se valida contra el inputSchema de D1: un valor que no es un objeto, una propiedad requerida ausente, una propiedad declarada de tipo distinto (string, integer para un número JSON sin parte fraccionaria ni exponente, array de strings) o fuera de su enum producen isError verdadero con el resultado {\"error\":\"invalid_arguments\"} y la herramienta no se ejecuta. Las propiedades no declaradas se ignoran.",
  "verificacion": [
    "C3",
    "C4"
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
  "origen": "derivado",
  "operacion": "cli",
  "espera": {
    "codigo_salida": 0,
    "salida": "{\"jsonrpc\":\"2.0\",\"id\":3,\"result\":{\"tools\":[{\"name\":\"check\",\"description\":\"Analyses a program and returns its diagnostics.\",\"inputSchema\":{\"type\":\"object\",\"properties\":{\"source\":{\"type\":\"string\",\"description\":\"Complete PseudoLearn program.\"},\"profile\":{\"type\":\"string\",\"enum\":[\"es\",\"en\"]}},\"required\":[\"source\"]}},{\"name\":\"run\",\"description\":\"Runs a program without capabilities, feeding inputs in order.\",\"inputSchema\":{\"type\":\"object\",\"properties\":{\"source\":{\"type\":\"string\",\"description\":\"Complete PseudoLearn program.\"},\"profile\":{\"type\":\"string\",\"enum\":[\"es\",\"en\"]},\"inputs\":{\"type\":\"array\",\"items\":{\"type\":\"string\"}},\"step_limit\":{\"type\":\"integer\"}},\"required\":[\"source\"]}},{\"name\":\"format\",\"description\":\"Returns the canonical formatting of a valid program.\",\"inputSchema\":{\"type\":\"object\",\"properties\":{\"source\":{\"type\":\"string\",\"description\":\"Complete PseudoLearn program.\"},\"profile\":{\"type\":\"string\",\"enum\":[\"es\",\"en\"]}},\"required\":[\"source\"]}},{\"name\":\"translate\",\"description\":\"Translates a valid program to the other syntax profile.\",\"inputSchema\":{\"type\":\"object\",\"properties\":{\"source\":{\"type\":\"string\",\"description\":\"Complete PseudoLearn program.\"},\"target_profile\":{\"type\":\"string\",\"enum\":[\"es\",\"en\"]}},\"required\":[\"source\",\"target_profile\"]}},{\"name\":\"explain\",\"description\":\"Explains a diagnostic code.\",\"inputSchema\":{\"type\":\"object\",\"properties\":{\"code\":{\"type\":\"string\"},\"locale\":{\"type\":\"string\",\"enum\":[\"es\",\"en\"]}},\"required\":[\"code\"]}},{\"name\":\"search_reference\",\"description\":\"Searches the language sheet.\",\"inputSchema\":{\"type\":\"object\",\"properties\":{\"query\":{\"type\":\"string\"},\"locale\":{\"type\":\"string\",\"enum\":[\"es\",\"en\"]}},\"required\":[\"query\"]}},{\"name\":\"example\",\"description\":\"Lists the canonical examples or returns one by id.\",\"inputSchema\":{\"type\":\"object\",\"properties\":{\"id\":{\"type\":\"string\"},\"locale\":{\"type\":\"string\",\"enum\":[\"es\",\"en\"]}},\"required\":[]}}]}}\n",
    "salida_error": ""
  },
  "cli": {
    "argumentos": [
      "mcp"
    ],
    "entorno": {},
    "entrada": "{\"jsonrpc\":\"2.0\",\"id\":3,\"method\":\"tools/list\"}\n",
    "archivos": {}
  }
}
```

```caso
{
  "id": "C4",
  "regla": "R3",
  "perfiles": [
    "es"
  ],
  "origen": "derivado",
  "operacion": "cli",
  "espera": {
    "codigo_salida": 0,
    "salida": "{\"jsonrpc\":\"2.0\",\"id\":3,\"error\":{\"code\":-32602,\"message\":\"Unknown tool\"}}\n{\"jsonrpc\":\"2.0\",\"id\":4,\"error\":{\"code\":-32602,\"message\":\"Unknown tool\"}}\n{\"jsonrpc\":\"2.0\",\"id\":5,\"result\":{\"content\":[{\"type\":\"text\",\"text\":\"{\\\"error\\\":\\\"invalid_arguments\\\"}\"}],\"isError\":true}}\n{\"jsonrpc\":\"2.0\",\"id\":6,\"result\":{\"content\":[{\"type\":\"text\",\"text\":\"{\\\"error\\\":\\\"invalid_arguments\\\"}\"}],\"isError\":true}}\n{\"jsonrpc\":\"2.0\",\"id\":7,\"result\":{\"content\":[{\"type\":\"text\",\"text\":\"{\\\"error\\\":\\\"invalid_arguments\\\"}\"}],\"isError\":true}}\n{\"jsonrpc\":\"2.0\",\"id\":8,\"result\":{\"content\":[{\"type\":\"text\",\"text\":\"{\\\"error\\\":\\\"invalid_arguments\\\"}\"}],\"isError\":true}}\n{\"jsonrpc\":\"2.0\",\"id\":9,\"result\":{\"content\":[{\"type\":\"text\",\"text\":\"{\\\"error\\\":\\\"invalid_arguments\\\"}\"}],\"isError\":true}}\n{\"jsonrpc\":\"2.0\",\"id\":10,\"result\":{\"content\":[{\"type\":\"text\",\"text\":\"{\\\"error\\\":\\\"invalid_arguments\\\"}\"}],\"isError\":true}}\n{\"jsonrpc\":\"2.0\",\"id\":11,\"result\":{\"content\":[{\"type\":\"text\",\"text\":\"{\\\"error\\\":\\\"invalid_arguments\\\"}\"}],\"isError\":true}}\n{\"jsonrpc\":\"2.0\",\"id\":12,\"result\":{\"content\":[{\"type\":\"text\",\"text\":\"{\\\"error\\\":\\\"invalid_arguments\\\"}\"}],\"isError\":true}}\n{\"jsonrpc\":\"2.0\",\"id\":13,\"result\":{\"content\":[{\"type\":\"text\",\"text\":\"{\\\"error\\\":\\\"invalid_arguments\\\"}\"}],\"isError\":true}}\n",
    "salida_error": ""
  },
  "cli": {
    "argumentos": [
      "mcp"
    ],
    "entorno": {},
    "entrada": "{\"jsonrpc\":\"2.0\",\"id\":3,\"method\":\"tools/call\",\"params\":{\"name\":\"nada\",\"arguments\":{}}}\n{\"jsonrpc\":\"2.0\",\"id\":4,\"method\":\"tools/call\",\"params\":{\"arguments\":{}}}\n{\"jsonrpc\":\"2.0\",\"id\":5,\"method\":\"tools/call\",\"params\":{\"name\":\"check\",\"arguments\":{\"source\":7}}}\n{\"jsonrpc\":\"2.0\",\"id\":6,\"method\":\"tools/call\",\"params\":{\"name\":\"check\",\"arguments\":{}}}\n{\"jsonrpc\":\"2.0\",\"id\":7,\"method\":\"tools/call\",\"params\":{\"name\":\"check\",\"arguments\":[]}}\n{\"jsonrpc\":\"2.0\",\"id\":8,\"method\":\"tools/call\",\"params\":{\"name\":\"run\",\"arguments\":{\"source\":\"Algoritmo P\\n  Escribir 1;\\nFinAlgoritmo\\n\",\"profile\":\"fr\"}}}\n{\"jsonrpc\":\"2.0\",\"id\":9,\"method\":\"tools/call\",\"params\":{\"name\":\"run\",\"arguments\":{\"source\":\"Algoritmo P\\n  Escribir 1;\\nFinAlgoritmo\\n\",\"inputs\":\"1\"}}}\n{\"jsonrpc\":\"2.0\",\"id\":10,\"method\":\"tools/call\",\"params\":{\"name\":\"run\",\"arguments\":{\"source\":\"Algoritmo P\\n  Escribir 1;\\nFinAlgoritmo\\n\",\"inputs\":[1]}}}\n{\"jsonrpc\":\"2.0\",\"id\":11,\"method\":\"tools/call\",\"params\":{\"name\":\"run\",\"arguments\":{\"source\":\"Algoritmo P\\n  Escribir 1;\\nFinAlgoritmo\\n\",\"step_limit\":\"5\"}}}\n{\"jsonrpc\":\"2.0\",\"id\":12,\"method\":\"tools/call\",\"params\":{\"name\":\"run\",\"arguments\":{\"source\":\"Algoritmo P\\n  Escribir 1;\\nFinAlgoritmo\\n\",\"step_limit\":1.5}}}\n{\"jsonrpc\":\"2.0\",\"id\":13,\"method\":\"tools/call\",\"params\":{\"name\":\"translate\",\"arguments\":{\"source\":\"Algoritmo P\\n  Escribir 1;\\nFinAlgoritmo\\n\"}}}\n",
    "archivos": {}
  }
}
```

```regla
{
  "id": "R4",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "check analiza source en el perfil profile, es o en; si falta, el autodeclarado según TOOL.CLI.CONVENTIONS R3. Devuelve diagnostics y executable. Cada diagnóstico lleva code, severity, line y column, que son la línea y la columna, ambas desde 1 y contadas en puntos de código, del inicio de su tramo, y message, la plantilla del código en el idioma locale, es o en y es por omisión, con sus argumentos sustituidos. executable es falso si algún diagnóstico tiene severity error.",
  "verificacion": [
    "C5",
    "C6"
  ]
}
```

```caso
{
  "id": "C5",
  "regla": "R4",
  "perfiles": [
    "es"
  ],
  "origen": "derivado",
  "operacion": "cli",
  "espera": {
    "codigo_salida": 0,
    "salida": "{\"jsonrpc\":\"2.0\",\"id\":5,\"result\":{\"content\":[{\"type\":\"text\",\"text\":\"{\\\"diagnostics\\\":[],\\\"executable\\\":true}\"}],\"isError\":false}}\n",
    "salida_error": ""
  },
  "cli": {
    "argumentos": [
      "mcp"
    ],
    "entorno": {},
    "entrada": "{\"jsonrpc\":\"2.0\",\"id\":5,\"method\":\"tools/call\",\"params\":{\"name\":\"check\",\"arguments\":{\"source\":\"Algoritmo P\\n  Escribir 1;\\nFinAlgoritmo\\n\",\"profile\":\"es\"}}}\n",
    "archivos": {}
  }
}
```

```caso
{
  "id": "C6",
  "regla": "R4",
  "perfiles": [
    "es"
  ],
  "origen": "derivado",
  "operacion": "cli",
  "espera": {
    "codigo_salida": 0,
    "salida": "{\"jsonrpc\":\"2.0\",\"id\":6,\"result\":{\"content\":[{\"type\":\"text\",\"text\":\"{\\\"diagnostics\\\":[{\\\"code\\\":\\\"unrecognizedCharacter\\\",\\\"severity\\\":\\\"error\\\",\\\"line\\\":2,\\\"column\\\":12,\\\"message\\\":\\\"Carácter no reconocido: @\\\"}],\\\"executable\\\":false}\"}],\"isError\":false}}\n{\"jsonrpc\":\"2.0\",\"id\":7,\"result\":{\"content\":[{\"type\":\"text\",\"text\":\"{\\\"diagnostics\\\":[{\\\"code\\\":\\\"unrecognizedCharacter\\\",\\\"severity\\\":\\\"error\\\",\\\"line\\\":2,\\\"column\\\":12,\\\"message\\\":\\\"Unrecognized character: @\\\"}],\\\"executable\\\":false}\"}],\"isError\":false}}\n",
    "salida_error": ""
  },
  "cli": {
    "argumentos": [
      "mcp"
    ],
    "entorno": {},
    "entrada": "{\"jsonrpc\":\"2.0\",\"id\":6,\"method\":\"tools/call\",\"params\":{\"name\":\"check\",\"arguments\":{\"source\":\"Algoritmo P\\nEscribir 1 @;\\nFinAlgoritmo\\n\"}}}\n{\"jsonrpc\":\"2.0\",\"id\":7,\"method\":\"tools/call\",\"params\":{\"name\":\"check\",\"arguments\":{\"source\":\"Algoritmo P\\nEscribir 1 @;\\nFinAlgoritmo\\n\",\"locale\":\"en\"}}}\n",
    "archivos": {}
  }
}
```

```regla
{
  "id": "R5",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "run analiza source como check; si algún diagnóstico es error, devuelve el resultado de check con isError verdadero y no ejecuta. En otro caso ejecuta source según API.EXECUTE, sin conceder ninguna capacidad, con las entradas inputs consumidas en orden y ninguna por omisión, y con un presupuesto de sentencias step_limit: el entero pedido acotado al intervalo [1, 100000], 10000 por omisión. Devuelve output y termination, el kind de la terminación, más limit, el tipo de límite, cuando la terminación es limit_reached. Como ENG.LIMITS R14 cuenta como sentencia cada iteración de un bucle de cuerpo vacío, toda ejecución termina por completarse, fallar o agotar el presupuesto, sin guarda de reloj.",
  "verificacion": [
    "C7",
    "C8",
    "C9",
    "C10"
  ]
}
```

```caso
{
  "id": "C7",
  "regla": "R5",
  "perfiles": [
    "es"
  ],
  "origen": "derivado",
  "operacion": "cli",
  "espera": {
    "codigo_salida": 0,
    "salida": "{\"jsonrpc\":\"2.0\",\"id\":6,\"result\":{\"content\":[{\"type\":\"text\",\"text\":\"{\\\"output\\\":\\\"8\\\\n\\\",\\\"termination\\\":\\\"completed\\\"}\"}],\"isError\":false}}\n{\"jsonrpc\":\"2.0\",\"id\":7,\"result\":{\"content\":[{\"type\":\"text\",\"text\":\"{\\\"output\\\":\\\"1\\\\n\\\",\\\"termination\\\":\\\"completed\\\"}\"}],\"isError\":false}}\n",
    "salida_error": ""
  },
  "cli": {
    "argumentos": [
      "mcp"
    ],
    "entorno": {},
    "entrada": "{\"jsonrpc\":\"2.0\",\"id\":6,\"method\":\"tools/call\",\"params\":{\"name\":\"run\",\"arguments\":{\"source\":\"Algoritmo P\\n  Definir x Como Entero;\\n  Leer x;\\n  Escribir x * 2;\\nFinAlgoritmo\\n\",\"inputs\":[\"4\"]}}}\n{\"jsonrpc\":\"2.0\",\"id\":7,\"method\":\"tools/call\",\"params\":{\"name\":\"run\",\"arguments\":{\"source\":\"Algoritmo P\\n  Escribir 1;\\nFinAlgoritmo\\n\",\"step_limit\":1}}}\n",
    "archivos": {}
  }
}
```

```caso
{
  "id": "C8",
  "regla": "R5",
  "perfiles": [
    "es"
  ],
  "origen": "derivado",
  "operacion": "cli",
  "espera": {
    "codigo_salida": 0,
    "salida": "{\"jsonrpc\":\"2.0\",\"id\":8,\"result\":{\"content\":[{\"type\":\"text\",\"text\":\"{\\\"diagnostics\\\":[{\\\"code\\\":\\\"unrecognizedCharacter\\\",\\\"severity\\\":\\\"error\\\",\\\"line\\\":2,\\\"column\\\":12,\\\"message\\\":\\\"Carácter no reconocido: @\\\"}],\\\"executable\\\":false}\"}],\"isError\":true}}\n",
    "salida_error": ""
  },
  "cli": {
    "argumentos": [
      "mcp"
    ],
    "entorno": {},
    "entrada": "{\"jsonrpc\":\"2.0\",\"id\":8,\"method\":\"tools/call\",\"params\":{\"name\":\"run\",\"arguments\":{\"source\":\"Algoritmo P\\nEscribir 1 @;\\nFinAlgoritmo\\n\"}}}\n",
    "archivos": {}
  }
}
```

```caso
{
  "id": "C9",
  "regla": "R5",
  "perfiles": [
    "es"
  ],
  "origen": "derivado",
  "operacion": "cli",
  "espera": {
    "codigo_salida": 0,
    "salida": "{\"jsonrpc\":\"2.0\",\"id\":9,\"result\":{\"content\":[{\"type\":\"text\",\"text\":\"{\\\"output\\\":\\\"1\\\\n2\\\\n\\\",\\\"termination\\\":\\\"limit_reached\\\",\\\"limit\\\":\\\"statements\\\"}\"}],\"isError\":false}}\n{\"jsonrpc\":\"2.0\",\"id\":10,\"result\":{\"content\":[{\"type\":\"text\",\"text\":\"{\\\"output\\\":\\\"1\\\\n\\\",\\\"termination\\\":\\\"limit_reached\\\",\\\"limit\\\":\\\"statements\\\"}\"}],\"isError\":false}}\n{\"jsonrpc\":\"2.0\",\"id\":11,\"result\":{\"content\":[{\"type\":\"text\",\"text\":\"{\\\"output\\\":\\\"1\\\\n\\\",\\\"termination\\\":\\\"limit_reached\\\",\\\"limit\\\":\\\"statements\\\"}\"}],\"isError\":false}}\n{\"jsonrpc\":\"2.0\",\"id\":12,\"result\":{\"content\":[{\"type\":\"text\",\"text\":\"{\\\"output\\\":\\\"1\\\\n2\\\\n3\\\\n\\\",\\\"termination\\\":\\\"completed\\\"}\"}],\"isError\":false}}\n",
    "salida_error": ""
  },
  "cli": {
    "argumentos": [
      "mcp"
    ],
    "entorno": {},
    "entrada": "{\"jsonrpc\":\"2.0\",\"id\":9,\"method\":\"tools/call\",\"params\":{\"name\":\"run\",\"arguments\":{\"source\":\"Algoritmo P\\n  Escribir 1;\\n  Escribir 2;\\n  Escribir 3;\\nFinAlgoritmo\\n\",\"step_limit\":2}}}\n{\"jsonrpc\":\"2.0\",\"id\":10,\"method\":\"tools/call\",\"params\":{\"name\":\"run\",\"arguments\":{\"source\":\"Algoritmo P\\n  Escribir 1;\\n  Escribir 2;\\n  Escribir 3;\\nFinAlgoritmo\\n\",\"step_limit\":0}}}\n{\"jsonrpc\":\"2.0\",\"id\":11,\"method\":\"tools/call\",\"params\":{\"name\":\"run\",\"arguments\":{\"source\":\"Algoritmo P\\n  Escribir 1;\\n  Escribir 2;\\n  Escribir 3;\\nFinAlgoritmo\\n\",\"step_limit\":-5}}}\n{\"jsonrpc\":\"2.0\",\"id\":12,\"method\":\"tools/call\",\"params\":{\"name\":\"run\",\"arguments\":{\"source\":\"Algoritmo P\\n  Escribir 1;\\n  Escribir 2;\\n  Escribir 3;\\nFinAlgoritmo\\n\",\"step_limit\":100000000}}}\n",
    "archivos": {}
  }
}
```

```caso
{
  "id": "C10",
  "regla": "R5",
  "perfiles": [
    "es"
  ],
  "origen": "derivado",
  "operacion": "cli",
  "espera": {
    "codigo_salida": 0,
    "salida": "{\"jsonrpc\":\"2.0\",\"id\":13,\"result\":{\"content\":[{\"type\":\"text\",\"text\":\"{\\\"output\\\":\\\"\\\",\\\"termination\\\":\\\"limit_reached\\\",\\\"limit\\\":\\\"statements\\\"}\"}],\"isError\":false}}\n{\"jsonrpc\":\"2.0\",\"id\":14,\"result\":{\"content\":[{\"type\":\"text\",\"text\":\"{\\\"output\\\":\\\"\\\",\\\"termination\\\":\\\"limit_reached\\\",\\\"limit\\\":\\\"statements\\\"}\"}],\"isError\":false}}\n{\"jsonrpc\":\"2.0\",\"id\":15,\"result\":{\"content\":[{\"type\":\"text\",\"text\":\"{\\\"output\\\":\\\"\\\",\\\"termination\\\":\\\"limit_reached\\\",\\\"limit\\\":\\\"statements\\\"}\"}],\"isError\":false}}\n{\"jsonrpc\":\"2.0\",\"id\":16,\"result\":{\"content\":[{\"type\":\"text\",\"text\":\"{\\\"output\\\":\\\"\\\",\\\"termination\\\":\\\"completed\\\"}\"}],\"isError\":false}}\n",
    "salida_error": ""
  },
  "cli": {
    "argumentos": [
      "mcp"
    ],
    "entorno": {},
    "entrada": "{\"jsonrpc\":\"2.0\",\"id\":13,\"method\":\"tools/call\",\"params\":{\"name\":\"run\",\"arguments\":{\"source\":\"Algoritmo P\\nMientras Verdadero Hacer\\nFinMientras\\nFinAlgoritmo\\n\",\"step_limit\":5}}}\n{\"jsonrpc\":\"2.0\",\"id\":14,\"method\":\"tools/call\",\"params\":{\"name\":\"run\",\"arguments\":{\"source\":\"Algoritmo P\\nMientras Verdadero Hacer\\nFinMientras\\nFinAlgoritmo\\n\",\"step_limit\":1}}}\n{\"jsonrpc\":\"2.0\",\"id\":15,\"method\":\"tools/call\",\"params\":{\"name\":\"run\",\"arguments\":{\"source\":\"Algoritmo P\\nMientras Verdadero Hacer\\nFinMientras\\nFinAlgoritmo\\n\"}}}\n{\"jsonrpc\":\"2.0\",\"id\":16,\"method\":\"tools/call\",\"params\":{\"name\":\"run\",\"arguments\":{\"source\":\"Algoritmo P\\nMientras Falso Hacer\\nFinMientras\\nFinAlgoritmo\\n\",\"step_limit\":10}}}\n",
    "archivos": {}
  }
}
```

```regla
{
  "id": "R6",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "format devuelve source con el formato canónico de TOOL.FORMAT.STYLE, o isError verdadero con error syntax_errors si el programa no se analiza. translate devuelve source traducido a target_profile como TOOL.CLI.TRANSLATE, o isError verdadero con error translation_rejected. explain devuelve code, template, la plantilla sin sustituir en el idioma locale, y severity de un código del catálogo de DIAG.CATALOG, o isError verdadero con error unknown_code.",
  "verificacion": [
    "C11",
    "C12"
  ]
}
```

```caso
{
  "id": "C11",
  "regla": "R6",
  "perfiles": [
    "es"
  ],
  "origen": "derivado",
  "operacion": "cli",
  "espera": {
    "codigo_salida": 0,
    "salida": "{\"jsonrpc\":\"2.0\",\"id\":8,\"result\":{\"content\":[{\"type\":\"text\",\"text\":\"{\\\"source\\\":\\\"Algorithm P\\\\n  Write 1;\\\\nEndAlgorithm\\\\n\\\"}\"}],\"isError\":false}}\n{\"jsonrpc\":\"2.0\",\"id\":9,\"result\":{\"content\":[{\"type\":\"text\",\"text\":\"{\\\"source\\\":\\\"Algoritmo P\\\\n  Escribir 1;\\\\nFinAlgoritmo\\\\n\\\"}\"}],\"isError\":false}}\n",
    "salida_error": ""
  },
  "cli": {
    "argumentos": [
      "mcp"
    ],
    "entorno": {},
    "entrada": "{\"jsonrpc\":\"2.0\",\"id\":8,\"method\":\"tools/call\",\"params\":{\"name\":\"translate\",\"arguments\":{\"source\":\"Algoritmo P\\n  Escribir 1;\\nFinAlgoritmo\\n\",\"target_profile\":\"en\"}}}\n{\"jsonrpc\":\"2.0\",\"id\":9,\"method\":\"tools/call\",\"params\":{\"name\":\"format\",\"arguments\":{\"source\":\"algoritmo P\\nescribir 1;\\nfinalgoritmo\"}}}\n",
    "archivos": {}
  }
}
```

```caso
{
  "id": "C12",
  "regla": "R6",
  "perfiles": [
    "es"
  ],
  "origen": "derivado",
  "operacion": "cli",
  "espera": {
    "codigo_salida": 0,
    "salida": "{\"jsonrpc\":\"2.0\",\"id\":10,\"result\":{\"content\":[{\"type\":\"text\",\"text\":\"{\\\"error\\\":\\\"syntax_errors\\\"}\"}],\"isError\":true}}\n{\"jsonrpc\":\"2.0\",\"id\":11,\"result\":{\"content\":[{\"type\":\"text\",\"text\":\"{\\\"error\\\":\\\"translation_rejected\\\"}\"}],\"isError\":true}}\n{\"jsonrpc\":\"2.0\",\"id\":12,\"result\":{\"content\":[{\"type\":\"text\",\"text\":\"{\\\"error\\\":\\\"unknown_code\\\"}\"}],\"isError\":true}}\n{\"jsonrpc\":\"2.0\",\"id\":13,\"result\":{\"content\":[{\"type\":\"text\",\"text\":\"{\\\"code\\\":\\\"unrecognizedCharacter\\\",\\\"template\\\":\\\"Unrecognized character: {lexeme}\\\",\\\"severity\\\":\\\"error\\\"}\"}],\"isError\":false}}\n{\"jsonrpc\":\"2.0\",\"id\":14,\"result\":{\"content\":[{\"type\":\"text\",\"text\":\"{\\\"code\\\":\\\"zeroStepInCountedLoop\\\",\\\"template\\\":\\\"El paso de un bucle contado no puede ser cero\\\",\\\"severity\\\":\\\"error\\\"}\"}],\"isError\":false}}\n",
    "salida_error": ""
  },
  "cli": {
    "argumentos": [
      "mcp"
    ],
    "entorno": {},
    "entrada": "{\"jsonrpc\":\"2.0\",\"id\":10,\"method\":\"tools/call\",\"params\":{\"name\":\"format\",\"arguments\":{\"source\":\"Algoritmo P\\nEscribir 1 @;\\nFinAlgoritmo\\n\"}}}\n{\"jsonrpc\":\"2.0\",\"id\":11,\"method\":\"tools/call\",\"params\":{\"name\":\"translate\",\"arguments\":{\"source\":\"Algoritmo P\\nEscribir 1 @;\\nFinAlgoritmo\\n\",\"target_profile\":\"en\"}}}\n{\"jsonrpc\":\"2.0\",\"id\":12,\"method\":\"tools/call\",\"params\":{\"name\":\"explain\",\"arguments\":{\"code\":\"noExiste\"}}}\n{\"jsonrpc\":\"2.0\",\"id\":13,\"method\":\"tools/call\",\"params\":{\"name\":\"explain\",\"arguments\":{\"code\":\"unrecognizedCharacter\",\"locale\":\"en\"}}}\n{\"jsonrpc\":\"2.0\",\"id\":14,\"method\":\"tools/call\",\"params\":{\"name\":\"explain\",\"arguments\":{\"code\":\"zeroStepInCountedLoop\"}}}\n",
    "archivos": {}
  }
}
```

```regla
{
  "id": "R7",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "resources/list anuncia pseudolearn://language-sheet/es y pseudolearn://language-sheet/en, ambos con name language-sheet-es o language-sheet-en y mimeType text/markdown. resources/read de una de esas URI devuelve en contents un único elemento con uri, mimeType y text, la ficha del lenguaje para agentes de ese idioma generada desde este corpus; una URI desconocida o ausente es el error -32602 Unknown resource.",
  "verificacion": [
    "C13"
  ]
}
```

```caso
{
  "id": "C13",
  "regla": "R7",
  "perfiles": [
    "es"
  ],
  "origen": "derivado",
  "operacion": "cli",
  "espera": {
    "codigo_salida": 0,
    "salida": "{\"jsonrpc\":\"2.0\",\"id\":12,\"result\":{\"resources\":[{\"uri\":\"pseudolearn://language-sheet/es\",\"name\":\"language-sheet-es\",\"mimeType\":\"text/markdown\"},{\"uri\":\"pseudolearn://language-sheet/en\",\"name\":\"language-sheet-en\",\"mimeType\":\"text/markdown\"}]}}\n{\"jsonrpc\":\"2.0\",\"id\":13,\"error\":{\"code\":-32602,\"message\":\"Unknown resource\"}}\n{\"jsonrpc\":\"2.0\",\"id\":14,\"error\":{\"code\":-32602,\"message\":\"Unknown resource\"}}\n",
    "salida_error": ""
  },
  "cli": {
    "argumentos": [
      "mcp"
    ],
    "entorno": {},
    "entrada": "{\"jsonrpc\":\"2.0\",\"id\":12,\"method\":\"resources/list\"}\n{\"jsonrpc\":\"2.0\",\"id\":13,\"method\":\"resources/read\",\"params\":{\"uri\":\"pseudolearn://otra\"}}\n{\"jsonrpc\":\"2.0\",\"id\":14,\"method\":\"resources/read\",\"params\":{}}\n",
    "archivos": {}
  }
}
```

```regla
{
  "id": "R8",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "search_reference toma las palabras de query, separadas por espacios en blanco, en minúsculas y de más de un carácter, y puntúa cada sección de la ficha del idioma locale, es por omisión: una sección empieza en una línea que comienza con «## » o «### » y termina en la siguiente de esas líneas, y su título es el encabezado sin almohadillas ni espacios laterales. Cada palabra suma 3 por cada aparición en el título en minúsculas y hasta 3 por sus apariciones en el cuerpo en minúsculas. Devuelve en results, de mayor a menor puntuación y en el orden de la ficha entre empates, hasta cinco secciones de puntuación positiva, cada una con title y excerpt, que son los primeros 400 caracteres del cuerpo. example sin id devuelve en examples los títulos, sin comillas invertidas, de las secciones de la ficha cuyo título es una identidad de ejemplo de la forma ID#Cn; con id devuelve id, program y expected_output de ese ejemplo, que son los del caso del corpus; un id desconocido es isError verdadero con error not_found.",
  "verificacion": [
    "C14",
    "C15"
  ]
}
```

```caso
{
  "id": "C14",
  "regla": "R8",
  "perfiles": [
    "es"
  ],
  "origen": "derivado",
  "operacion": "cli",
  "espera": {
    "codigo_salida": 0,
    "salida": "{\"jsonrpc\":\"2.0\",\"id\":15,\"result\":{\"content\":[{\"type\":\"text\",\"text\":\"{\\\"results\\\":[{\\\"title\\\":\\\"Reglas de oro\\\",\\\"excerpt\\\":\\\"- Comprueba cada programa con la herramienta de análisis antes de mostrarlo; nunca enseñes código que no pase.\\\\n- Escribe en el perfil del documento. Si generas en otro perfil, tradúcelo con la herramienta de traducción, no a mano.\\\\n- Toda sentencia simple termina en punto y coma.\\\\n- Los arreglos empiezan en 0.\\\\n- Toda variable se declara con su tipo antes de usarla.\\\\n- Ante la duda, busca en la especi\\\"}]}\"}],\"isError\":false}}\n{\"jsonrpc\":\"2.0\",\"id\":16,\"result\":{\"content\":[{\"type\":\"text\",\"text\":\"{\\\"results\\\":[]}\"}],\"isError\":false}}\n{\"jsonrpc\":\"2.0\",\"id\":17,\"result\":{\"content\":[{\"type\":\"text\",\"text\":\"{\\\"results\\\":[]}\"}],\"isError\":false}}\n",
    "salida_error": ""
  },
  "cli": {
    "argumentos": [
      "mcp"
    ],
    "entorno": {},
    "entrada": "{\"jsonrpc\":\"2.0\",\"id\":15,\"method\":\"tools/call\",\"params\":{\"name\":\"search_reference\",\"arguments\":{\"query\":\"tradúcelo\"}}}\n{\"jsonrpc\":\"2.0\",\"id\":16,\"method\":\"tools/call\",\"params\":{\"name\":\"search_reference\",\"arguments\":{\"query\":\"zzzz\"}}}\n{\"jsonrpc\":\"2.0\",\"id\":17,\"method\":\"tools/call\",\"params\":{\"name\":\"search_reference\",\"arguments\":{\"query\":\" \"}}}\n",
    "archivos": {}
  }
}
```

```caso
{
  "id": "C15",
  "regla": "R8",
  "perfiles": [
    "es"
  ],
  "origen": "derivado",
  "operacion": "cli",
  "espera": {
    "codigo_salida": 0,
    "salida": "{\"jsonrpc\":\"2.0\",\"id\":18,\"result\":{\"content\":[{\"type\":\"text\",\"text\":\"{\\\"examples\\\":[\\\"LANG.PROGRAM.STRUCTURE#C6\\\",\\\"LANG.DECL.VARIABLE#C4\\\",\\\"LANG.DECL.CONSTANT#C2\\\",\\\"LANG.IO.OUTPUT#C1\\\",\\\"LANG.CONTROL.IF#C1\\\",\\\"LANG.CONTROL.SWITCH#C1\\\",\\\"LANG.CONTROL.WHILE#C2\\\",\\\"LANG.CONTROL.REPEAT#C1\\\",\\\"LANG.CONTROL.FOR#C20\\\",\\\"LANG.CONTROL.FOR-EACH#C1\\\",\\\"LANG.ARRAY.ACCESS#C1\\\",\\\"LANG.ARRAY.DIMENSION#C6\\\",\\\"LANG.OPS.DIVISION#C1\\\",\\\"LANG.OPS.CONCATENATION#C1\\\",\\\"LANG.TYPES.TEXT#C1\\\",\\\"LANG.TYPES.RECORD#C1\\\",\\\"LANG.SUBPROGRAM.DECLARATION#C1\\\",\\\"LANG.SUBPROGRAM.RETURN#C1\\\",\\\"LANG.SUBPROGRAM.BY-REFERENCE#C4\\\",\\\"LANG.SUBPROGRAM.RECURSION#C1\\\",\\\"LANG.CLASS.DECLARATION#C4\\\"]}\"}],\"isError\":false}}\n{\"jsonrpc\":\"2.0\",\"id\":19,\"result\":{\"content\":[{\"type\":\"text\",\"text\":\"{\\\"id\\\":\\\"LANG.CONTROL.FOR#C20\\\",\\\"program\\\":\\\"Algoritmo P\\\\nPara i <- 1 Hasta 1 Hacer\\\\nEscribir i;\\\\nFinPara\\\\nFinAlgoritmo\\\\n\\\",\\\"expected_output\\\":\\\"1\\\\n\\\"}\"}],\"isError\":false}}\n{\"jsonrpc\":\"2.0\",\"id\":20,\"result\":{\"content\":[{\"type\":\"text\",\"text\":\"{\\\"error\\\":\\\"not_found\\\"}\"}],\"isError\":true}}\n",
    "salida_error": ""
  },
  "cli": {
    "argumentos": [
      "mcp"
    ],
    "entorno": {},
    "entrada": "{\"jsonrpc\":\"2.0\",\"id\":18,\"method\":\"tools/call\",\"params\":{\"name\":\"example\",\"arguments\":{}}}\n{\"jsonrpc\":\"2.0\",\"id\":19,\"method\":\"tools/call\",\"params\":{\"name\":\"example\",\"arguments\":{\"id\":\"LANG.CONTROL.FOR#C20\"}}}\n{\"jsonrpc\":\"2.0\",\"id\":20,\"method\":\"tools/call\",\"params\":{\"name\":\"example\",\"arguments\":{\"id\":\"NADA\"}}}\n",
    "archivos": {}
  }
}
```
