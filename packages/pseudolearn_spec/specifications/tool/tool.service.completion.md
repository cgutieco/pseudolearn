---
{
  "formato": "see/1",
  "id": "TOOL.SERVICE.COMPLETION",
  "titulo": "Servicio de autocompletado",
  "dominio": "herramienta",
  "estado": "estable",
  "version": "0.1.0",
  "duenos": [
    "responsable-herramientas"
  ],
  "sujetos": [
    "service"
  ],
  "resumen": "Autocompletado de código sensible al contexto, bilingüe, con plantillas sintácticas y cierre de bloques.",
  "depende_de": [
    {
      "id": "LANG.SYNTAX.GRAMMAR",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    },
    {
      "id": "LANG.PROFILE.VOCABULARY",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    },
    {
      "id": "LANG.TYPES.INTEGER",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    },
    {
      "id": "LANG.CLASS.DECLARATION",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    },
    {
      "id": "TOOL.SERVICE.INCREMENTAL",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    },
    {
      "id": "PERF.PROTOCOL",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "Code completion service",
  "revisado_por": [
    "revision-independiente-automatizada-r9"
  ],
  "cambio": {
    "clase": "editorial",
    "impacto_usuarios": "Contrato existente respaldado; no cambia su comportamiento observable.",
    "impacto_implementaciones": "Se conserva la versión numérica y las exenciones explícitas de cada sujeto.",
    "justificacion": "Promoción revisada con evidencias vigentes y verificadores locales ejecutados.",
    "revisado_por": "revision-independiente-automatizada-r9"
  }
}
---

# Servicio de autocompletado

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El servicio ofrece candidatos acordes con la posición del cursor (sentencia, expresión, tipo tras Como/:, miembro tras ., cabecera de unidad) y no ofrece candidatos dentro de comentarios ni literales de cadena.",
  "verificacion": [
    "C1",
    "C6",
    "P1"
  ]
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "En posición de expresión o sentencia se incluyen las variables, constantes y parámetros visibles en el alcance actual; tras <instancia>. se ofrecen únicamente los campos y métodos de la clase estática del receptor y sus superclases.",
  "verificacion": [
    "C3"
  ]
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Cuando existen bloques abiertos sin cerrar, el servicio propone como candidato prioritario el token de cierre correspondiente al bloque abierto más interno.",
  "verificacion": [
    "C2"
  ]
}
```

```regla
{
  "id": "R4",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Todas las palabras clave, funciones estándar y marcadores de plantilla se emiten exclusivamente en el idioma del perfil activo (es o en). Si el prefijo escrito coincide con un término del otro idioma, se sugiere el término canónico del perfil activo indicando la correspondencia bilingüe.",
  "verificacion": [
    "C4",
    "C5"
  ]
}
```

```regla
{
  "id": "R5",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Para un mismo documento, perfil y posición de cursor, la lista de candidatos devuelta es estrictamente determinista en contenido y orden.",
  "verificacion": [
    "C1",
    "C7",
    "M1"
  ]
}
```

```regla
{
  "id": "R6",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Sobre los programas de referencia en ambos idiomas, con un prefijo de dos caracteres, el candidato esperado figura entre los cinco primeros en al menos el 85 % de las consultas de cada idioma, es el primero en al menos el 60 % y el ahorro de pulsaciones alcanza el 35 %.",
  "verificacion": [
    "C8",
    "M2",
    "M3",
    "M4"
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
  "operacion": "service",
  "espera": {
    "servicio": {
      "contiene": [
        "Entero",
        "Real",
        "Logico",
        "Caracter",
        "Cadena"
      ],
      "excluye": [
        "Escribir",
        "Mientras"
      ]
    }
  },
  "servicio": {
    "suboperacion": "completion",
    "documento": "Algoritmo Principal\n  Definir total Como \nFinAlgoritmo\n",
    "posicion": {
      "line": 2,
      "column": 22
    },
    "proyeccion": "contiene",
    "contiene": [
      "Entero",
      "Real",
      "Logico",
      "Caracter",
      "Cadena"
    ],
    "excluye": [
      "Escribir",
      "Mientras"
    ]
  }
}
```

```caso
{
  "id": "C2",
  "regla": "R3",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "primer_candidato": "FinMientras"
    }
  },
  "servicio": {
    "suboperacion": "completion",
    "documento": "Algoritmo Principal\n  Mientras x < 10 Hacer\n    \nFinAlgoritmo\n",
    "posicion": {
      "line": 3,
      "column": 5
    },
    "proyeccion": "primer_candidato"
  }
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
  "operacion": "service",
  "espera": {
    "servicio": {
      "contiene": [
        "x",
        "Mover"
      ],
      "excluye": [
        "total",
        "Escribir",
        "Algoritmo"
      ]
    }
  },
  "servicio": {
    "suboperacion": "completion",
    "documento": "Clase Punto\n  Definir x Como Entero;\n  Metodo Mover()\n  FinMetodo\nFinClase\n\nAlgoritmo Principal\n  Definir p Como Punto;\n  Definir total Como Entero;\n  p.\nFinAlgoritmo\n",
    "posicion": {
      "line": 10,
      "column": 5
    },
    "proyeccion": "contiene",
    "contiene": [
      "x",
      "Mover"
    ],
    "excluye": [
      "total",
      "Escribir",
      "Algoritmo"
    ]
  }
}
```

```caso
{
  "id": "C4",
  "regla": "R4",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "plantilla": "Segun expresion Hacer\n  valor:\n    \n  De Otro Modo:\n    \nFinSegun"
    }
  },
  "esperas": {
    "es": {
      "servicio": {
        "plantilla": "Segun expresion Hacer\n  valor:\n    \n  De Otro Modo:\n    \nFinSegun"
      }
    },
    "en": {
      "servicio": {
        "plantilla": "Switch expression Do\n  value:\n    \n  Otherwise:\n    \nEndSwitch"
      }
    }
  },
  "servicio": {
    "suboperacion": "completion_template",
    "construccion": "switch"
  }
}
```

```caso
{
  "id": "C5",
  "regla": "R4",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "sugerencia_bilingue": {
        "etiqueta": "Mientras",
        "origen": "while"
      }
    }
  },
  "servicio": {
    "suboperacion": "completion",
    "documento": "Algoritmo Principal\n  whi\nFinAlgoritmo\n",
    "posicion": {
      "line": 2,
      "column": 6
    },
    "proyeccion": "sugerencia_bilingue"
  }
}
```

```caso
{
  "id": "C6",
  "regla": "R1",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "vacio": true
    }
  },
  "servicio": {
    "suboperacion": "completion",
    "documento": "Algoritmo Principal\n  // Escr\n  s <- \"Escr\";\nFinAlgoritmo\n",
    "posicion": {
      "line": 2,
      "column": 10
    },
    "proyeccion": "vacio"
  }
}
```

```caso
{
  "id": "C7",
  "regla": "R5",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "determinista": true
    }
  },
  "servicio": {
    "suboperacion": "completion",
    "proyeccion": "determinista",
    "documento": "Algoritmo Principal\n  Definir a Como Entero;\n  Definir b Como Entero;\n  \nFinAlgoritmo\n",
    "posicion": {
      "line": 4,
      "column": 3
    }
  }
}
```

```caso
{
  "id": "C8",
  "regla": "R6",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "rango": 1
    }
  },
  "servicio": {
    "suboperacion": "completion",
    "proyeccion": "rango",
    "esperado": "Escribir",
    "documento": "Algoritmo Principal\n  Esc\nFinAlgoritmo\n",
    "posicion": {
      "line": 2,
      "column": 6
    }
  }
}
```

```propiedad
{
  "id": "P1",
  "regla": "R1",
  "generador": {
    "programas": "todas las plantillas sintácticas del servicio insertadas en su contexto válido"
  },
  "propiedad": "El 100 % de las plantillas insertadas en un programa base producen un árbol sin errores sintácticos nuevos.",
  "oraculo": "Ausencia de diagnósticos de error sintáctico tras inserción de plantilla.",
  "justificacion": "La ejecuta el sujeto service verificando cada plantilla del catálogo."
}
```

```medicion
{
  "id": "M1",
  "metrica": "latencia_p95",
  "unidad": "milisegundos",
  "suite": "servicio",
  "comparador": "<=",
  "umbral": 50.0,
  "provisional": false,
  "plataformas": [
    "macos-aarch64",
    "linux-x86_64"
  ],
  "protocolo": "PERF.PROTOCOL#R1"
}
```

```medicion
{
  "id": "M2",
  "metrica": "precision_en_5",
  "unidad": "porcentaje",
  "suite": "servicio",
  "comparador": ">=",
  "umbral": 85.0,
  "provisional": false,
  "plataformas": [
    "macos-aarch64",
    "linux-x86_64"
  ],
  "protocolo": "PERF.PROTOCOL#R1"
}
```

```medicion
{
  "id": "M3",
  "metrica": "precision_en_1",
  "unidad": "porcentaje",
  "suite": "servicio",
  "comparador": ">=",
  "umbral": 60.0,
  "provisional": false,
  "plataformas": [
    "macos-aarch64",
    "linux-x86_64"
  ],
  "protocolo": "PERF.PROTOCOL#R1"
}
```

```medicion
{
  "id": "M4",
  "metrica": "ahorro_de_pulsaciones",
  "unidad": "porcentaje",
  "suite": "servicio",
  "comparador": ">=",
  "umbral": 35.0,
  "provisional": false,
  "plataformas": [
    "macos-aarch64",
    "linux-x86_64"
  ],
  "protocolo": "PERF.PROTOCOL#R1"
}
```
