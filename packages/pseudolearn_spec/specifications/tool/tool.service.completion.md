---
{
  "formato": "see/1",
  "id": "TOOL.SERVICE.COMPLETION",
  "titulo": "Servicio de autocompletado",
  "dominio": "herramienta",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-herramientas"
  ],
  "sujetos": [
    "service"
  ],
  "resumen": "Autocompletado de código sensible al contexto, bilingüe, con plantillas sintácticas navegables, tipo esperado y cierre de bloques.",
  "depende_de": [
    {
      "id": "LANG.SYNTAX.GRAMMAR",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "LANG.PROFILE.VOCABULARY",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "LANG.TYPES.INTEGER",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "LANG.CLASS.DECLARATION",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "TOOL.SERVICE.INCREMENTAL",
      "version": ">=1.0.0, <2.0.0",
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
  ]
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
  "texto": "Cuando existen bloques abiertos sin cerrar, el servicio propone como candidato prioritario el token de cierre correspondiente al bloque abierto más interno. El emparejamiento considera el documento completo por tipo y anidamiento; un bloque ya cerrado no ofrece otro cierre para insertarlo antes del existente.",
  "verificacion": [
    "C2",
    "C34"
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

```regla
{
  "id": "R7",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Cada plantilla sintáctica se entrega como texto con paradas numeradas: índice, rol (expression o new_identifier) y tramo. Los marcadores son identificadores válidos del perfil y el tramo de cada parada cae sobre un token del rol declarado, de modo que el programa analiza sin errores sintácticos mientras se rellena. La plantilla declara además una parada final, siempre sobre la primera línea de cuerpo, y su equivalente en formato de fragmento LSP derivado de la misma estructura: la numeración del fragmento sigue a la de las paradas y la parada final es $0.",
  "verificacion": [
    "C9",
    "C10",
    "C11",
    "P1"
  ]
}
```

```regla
{
  "id": "R8",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Aceptar un candidato inserta su texto sobre el tramo de reemplazo y re-sangra cada línea posterior de una plantilla multilínea con la sangría de la línea destino, usando la unidad de sangría del formateador. El resultado indica el tramo que debe quedar seleccionado: el de la primera parada o, sin paradas, el punto de inserción final. Si una plantilla tiene un cierre correspondiente ya presente a la derecha, reutiliza ese cierre sin insertarlo de nuevo, conservando las paradas de la cabecera y el cuerpo insertados; los cierres de otros bloques no se reutilizan.",
  "verificacion": [
    "C12",
    "C13",
    "C32",
    "C33"
  ]
}
```

```regla
{
  "id": "R9",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Cuando el contexto fija un tipo esperado (condición tras Si, Mientras, Hasta Que, No, Y u O; lado derecho de una asignación a una variable de tipo conocido; argumento de una llamada a un subproceso de usuario), los candidatos de un mismo nivel se ordenan por compatibilidad: idéntico, ampliable (Entero a Real), sin dato e incompatible. Un candidato incompatible se conserva y nunca se oculta.",
  "verificacion": [
    "C14"
  ]
}
```

```regla
{
  "id": "R10",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Aceptar un subproceso, función o método de usuario con parámetros inserta la llamada con un marcador por parámetro, con el nombre del parámetro como marcador y una parada por cada uno, y deja la parada final tras el paréntesis de cierre. Sin parámetros inserta los paréntesis vacíos y la parada final tras ellos.",
  "verificacion": [
    "C15",
    "C16"
  ]
}
```

```regla
{
  "id": "R11",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El detalle de un candidato se entrega como clave estable con argumentos, no como prosa: close_block, structure, bilingual_equivalent, primitive_type, class, standard_function, type_name y signature. La localización a un idioma de interfaz es responsabilidad del consumidor y no altera lexemas, firmas ni orden.",
  "verificacion": [
    "C17",
    "C18"
  ]
}
```

```regla
{
  "id": "R12",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Además del prefijo directo, un prefijo coincide con las iniciales de los segmentos de una etiqueta compuesta (los separados por espacio o por cambio de minúscula a mayúscula). Un candidato que coincide solo por iniciales se ordena después de todo candidato del mismo nivel que coincide por prefijo directo.",
  "verificacion": [
    "C19"
  ]
}
```

```regla
{
  "id": "R13",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Un candidato se marca como sugerencia en línea solo con intención explícita: prefijo directo de al menos dos caracteres con un único candidato contextual no exacto, sin coincidencia exclusiva por iniciales ni equivalencia bilingüe, o continuación de asignación tras un identificador completo. Sin prefijo no se marcan cierres. La continuación de asignación ofrece el mismo identificador seguido de un espacio, <- y un espacio; exige una variable o parámetro declarado antes y visible, de tipo conocido asignable como unidad, como único token significativo de una línea de sentencia y sin código ni comentario a la derecha. Admite espacios posteriores al identificador, nombres de un carácter y referencias a objetos; excluye arreglos completos, destinos ambiguos o con errores locales, miembros e índices. No completa el valor derecho ni añade terminador. Un cierre solo se marca si falta realmente para su apertura, considerando tipos, anidamiento y texto posterior; ante incertidumbre no se marca. El cursor intermedio de un token no recibe sugerencias en línea.",
  "verificacion": [
    "C20",
    "C21",
    "C22",
    "C23",
    "C24",
    "C25",
    "C26",
    "C27",
    "C28",
    "C29",
    "C30",
    "C31"
  ]
}
```

```caso
{
  "id": "C9",
  "regla": "R7",
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
      "paradas": [
        {
          "indice": 1,
          "rol": "expression",
          "marcador": "condicion"
        }
      ],
      "fragmento": "Si ${1:condicion} Entonces\n  $0\nSino\n  \nFinSi"
    }
  },
  "servicio": {
    "suboperacion": "completion_stops",
    "construccion": "if"
  }
}
```

```caso
{
  "id": "C10",
  "regla": "R7",
  "perfiles": [
    "en"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "paradas": [
        {
          "indice": 1,
          "rol": "new_identifier",
          "marcador": "index"
        },
        {
          "indice": 2,
          "rol": "expression",
          "marcador": "limit"
        }
      ],
      "fragmento": "For ${1:index} <- 1 To ${2:limit} Step 1 Do\n  $0\nEndFor"
    }
  },
  "servicio": {
    "suboperacion": "completion_stops",
    "construccion": "for"
  }
}
```

```caso
{
  "id": "C11",
  "regla": "R7",
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
      "paradas": [
        {
          "indice": 1,
          "rol": "expression",
          "marcador": "condicion"
        }
      ],
      "fragmento": "Repetir\n  $0\nHasta Que ${1:condicion}"
    }
  },
  "servicio": {
    "suboperacion": "completion_stops",
    "construccion": "repeat"
  }
}
```

```caso
{
  "id": "C12",
  "regla": "R8",
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
      "texto": "Algoritmo Principal\n  Mientras condicion Hacer\n    \n  FinMientras\nFinAlgoritmo\n",
      "seleccion": {
        "inicio": {
          "line": 2,
          "column": 12
        },
        "fin": {
          "line": 2,
          "column": 21
        }
      }
    }
  },
  "servicio": {
    "suboperacion": "completion_accept",
    "documento": "Algoritmo Principal\n  Mie\nFinAlgoritmo\n",
    "posicion": {
      "line": 2,
      "column": 6
    },
    "candidato": "Mientras"
  }
}
```

```caso
{
  "id": "C13",
  "regla": "R8",
  "perfiles": [
    "en"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "texto": "Algorithm Main\n  While condition Do\n    \n  EndWhile\nEndAlgorithm\n",
      "seleccion": {
        "inicio": {
          "line": 2,
          "column": 9
        },
        "fin": {
          "line": 2,
          "column": 18
        }
      }
    }
  },
  "servicio": {
    "suboperacion": "completion_accept",
    "documento": "Algorithm Main\n  Whi\nEndAlgorithm\n",
    "posicion": {
      "line": 2,
      "column": 6
    },
    "candidato": "While"
  }
}
```

```caso
{
  "id": "C14",
  "regla": "R9",
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
      "primer_candidato": "valido"
    }
  },
  "servicio": {
    "suboperacion": "completion",
    "proyeccion": "primer_candidato",
    "documento": "Algoritmo Principal\n  Definir cantidad Como Entero;\n  Definir valido Como Logico;\n  Mientras \nFinAlgoritmo\n",
    "posicion": {
      "line": 4,
      "column": 12
    }
  }
}
```

```caso
{
  "id": "C15",
  "regla": "R10",
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
      "texto": "SubProceso Sumar(a Por Valor, b Por Valor)\nFinSubProceso\n\nAlgoritmo Principal\n  Sumar(a, b)\nFinAlgoritmo\n",
      "seleccion": {
        "inicio": {
          "line": 5,
          "column": 9
        },
        "fin": {
          "line": 5,
          "column": 10
        }
      }
    }
  },
  "servicio": {
    "suboperacion": "completion_accept",
    "documento": "SubProceso Sumar(a Por Valor, b Por Valor)\nFinSubProceso\n\nAlgoritmo Principal\n  Sum\nFinAlgoritmo\n",
    "posicion": {
      "line": 5,
      "column": 6
    },
    "candidato": "Sumar"
  }
}
```

```caso
{
  "id": "C16",
  "regla": "R10",
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
      "texto": "SubProceso Avisar()\nFinSubProceso\n\nAlgoritmo Principal\n  Avisar()\nFinAlgoritmo\n",
      "seleccion": {
        "inicio": {
          "line": 5,
          "column": 11
        },
        "fin": {
          "line": 5,
          "column": 11
        }
      }
    }
  },
  "servicio": {
    "suboperacion": "completion_accept",
    "documento": "SubProceso Avisar()\nFinSubProceso\n\nAlgoritmo Principal\n  Avi\nFinAlgoritmo\n",
    "posicion": {
      "line": 5,
      "column": 6
    },
    "candidato": "Avisar"
  }
}
```

```caso
{
  "id": "C17",
  "regla": "R11",
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
      "detalle": {
        "etiqueta": "FinMientras",
        "clave": "close_block",
        "argumentos": []
      }
    }
  },
  "servicio": {
    "suboperacion": "completion",
    "proyeccion": "detalle",
    "candidato": "FinMientras",
    "documento": "Algoritmo Principal\n  Mientras x < 10 Hacer\n    \nFinAlgoritmo\n",
    "posicion": {
      "line": 3,
      "column": 5
    }
  }
}
```

```caso
{
  "id": "C18",
  "regla": "R11",
  "perfiles": [
    "en"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "detalle": {
        "etiqueta": "total",
        "clave": "type_name",
        "argumentos": [
          "Integer"
        ]
      }
    }
  },
  "servicio": {
    "suboperacion": "completion",
    "proyeccion": "detalle",
    "candidato": "total",
    "documento": "Algorithm Main\n  Define total As Integer;\n  tot\nEndAlgorithm\n",
    "posicion": {
      "line": 3,
      "column": 6
    }
  }
}
```

```caso
{
  "id": "C19",
  "regla": "R12",
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
        "De Otro Modo"
      ],
      "excluye": []
    }
  },
  "servicio": {
    "suboperacion": "completion",
    "proyeccion": "contiene",
    "documento": "Algoritmo Principal\n  Segun 1 Hacer\n    dom\nFinAlgoritmo\n",
    "posicion": {
      "line": 3,
      "column": 8
    },
    "contiene": [
      "De Otro Modo"
    ]
  }
}
```

```caso
{
  "id": "C20",
  "regla": "R13",
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
      "en_linea": "FinMientras"
    }
  },
  "servicio": {
    "suboperacion": "completion",
    "proyeccion": "en_linea",
    "documento": "Algoritmo Principal\n  Mientras x < 10 Hacer\n    FinM\nFinAlgoritmo\n",
    "posicion": {
      "line": 3,
      "column": 9
    }
  }
}
```

```caso
{
  "id": "C21",
  "regla": "R13",
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
      "en_linea": null
    }
  },
  "servicio": {
    "suboperacion": "completion",
    "proyeccion": "en_linea",
    "documento": "Algoritmo Principal\n  \nFinAlgoritmo\n",
    "posicion": {
      "line": 2,
      "column": 3
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
  "propiedad": "El 100 % de las plantillas insertadas en un programa base producen un árbol sin errores sintácticos nuevos y cada parada declarada cae sobre un token de su rol.",
  "oraculo": "Ausencia de diagnósticos de error sintáctico tras inserción de plantilla y clasificación léxica del token bajo cada parada.",
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

```caso
{
  "id": "C22",
  "regla": "R13",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "en_linea": "segundos"
    }
  },
  "servicio": {
    "suboperacion": "completion",
    "documento": "Algoritmo P\n  Definir segundos Como Entero;\n  segundos\nFinAlgoritmo\n",
    "posicion": {
      "line": 3,
      "column": 11
    },
    "proyeccion": "en_linea"
  }
}
```

```caso
{
  "id": "C23",
  "regla": "R13",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "texto": "Algoritmo P\n  Definir segundos Como Entero;\n  segundos <- \nFinAlgoritmo\n",
      "seleccion": {
        "inicio": {
          "line": 3,
          "column": 15
        },
        "fin": {
          "line": 3,
          "column": 15
        }
      }
    }
  },
  "servicio": {
    "suboperacion": "completion_accept",
    "documento": "Algoritmo P\n  Definir segundos Como Entero;\n  segundos\nFinAlgoritmo\n",
    "posicion": {
      "line": 3,
      "column": 11
    },
    "candidato": "segundos"
  }
}
```

```caso
{
  "id": "C24",
  "regla": "R13",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "en_linea": null
    }
  },
  "servicio": {
    "suboperacion": "completion",
    "documento": "Algoritmo P\n  segundos\nFinAlgoritmo\n",
    "posicion": {
      "line": 2,
      "column": 11
    },
    "proyeccion": "en_linea"
  }
}
```

```caso
{
  "id": "C25",
  "regla": "R13",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "en_linea": null
    }
  },
  "servicio": {
    "suboperacion": "completion",
    "documento": "Algoritmo P\n  Definir segundos[3] Como Entero;\n  segundos\nFinAlgoritmo\n",
    "posicion": {
      "line": 3,
      "column": 11
    },
    "proyeccion": "en_linea"
  }
}
```

```caso
{
  "id": "C26",
  "regla": "R13",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "en_linea": null
    }
  },
  "servicio": {
    "suboperacion": "completion",
    "documento": "Algoritmo P\n  Mientras Verdadero Hacer\n    \nFinAlgoritmo\n",
    "posicion": {
      "line": 3,
      "column": 5
    },
    "proyeccion": "en_linea"
  }
}
```

```caso
{
  "id": "C27",
  "regla": "R13",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "en_linea": null
    }
  },
  "servicio": {
    "suboperacion": "completion",
    "documento": "Algoritmo P\n  Mientras Verdadero Hacer\n    fm\nFinAlgoritmo\n",
    "posicion": {
      "line": 3,
      "column": 7
    },
    "proyeccion": "en_linea"
  }
}
```

```caso
{
  "id": "C28",
  "regla": "R13",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "en_linea": null
    }
  },
  "servicio": {
    "suboperacion": "completion",
    "documento": "Algoritmo P\n  FinA\nFinAlgoritmo\n",
    "posicion": {
      "line": 2,
      "column": 7
    },
    "proyeccion": "en_linea"
  }
}
```

```caso
{
  "id": "C29",
  "regla": "R13",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "en_linea": "x"
    }
  },
  "servicio": {
    "suboperacion": "completion",
    "documento": "Algoritmo P\n  Definir x Como Real;\n  x\nFinAlgoritmo\n",
    "posicion": {
      "line": 3,
      "column": 4
    },
    "proyeccion": "en_linea"
  }
}
```

```caso
{
  "id": "C30",
  "regla": "R13",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "texto": "Algoritmo P\n  Definir segundos Como Entero;\n  segundos <- \nFinAlgoritmo\n",
      "seleccion": {
        "inicio": {
          "line": 3,
          "column": 15
        },
        "fin": {
          "line": 3,
          "column": 15
        }
      }
    }
  },
  "servicio": {
    "suboperacion": "completion_accept",
    "documento": "Algoritmo P\n  Definir segundos Como Entero;\n  segundos   \nFinAlgoritmo\n",
    "posicion": {
      "line": 3,
      "column": 14
    },
    "candidato": "segundos"
  }
}
```

```caso
{
  "id": "C31",
  "regla": "R13",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "en_linea": null
    }
  },
  "servicio": {
    "suboperacion": "completion",
    "documento": "Algoritmo P\n  Definir segundos Como Entero;\n  Escribir segundos\nFinAlgoritmo\n",
    "posicion": {
      "line": 3,
      "column": 20
    },
    "proyeccion": "en_linea"
  }
}
```

```caso
{
  "id": "C32",
  "regla": "R8",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "texto": "Algoritmo P\n  Mientras condicion Hacer\n    \n  FinMientras\nFinAlgoritmo\n",
      "seleccion": {
        "inicio": {
          "line": 2,
          "column": 12
        },
        "fin": {
          "line": 2,
          "column": 21
        }
      }
    }
  },
  "servicio": {
    "suboperacion": "completion_accept",
    "documento": "Algoritmo P\n  Mie\n  FinMientras\nFinAlgoritmo\n",
    "posicion": {
      "line": 2,
      "column": 6
    },
    "candidato": "Mientras"
  }
}
```

```caso
{
  "id": "C33",
  "regla": "R8",
  "perfiles": [
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "texto": "Algorithm Main\n  Define value As Integer;\n  value <- \nEndAlgorithm\n",
      "seleccion": {
        "inicio": {
          "line": 3,
          "column": 12
        },
        "fin": {
          "line": 3,
          "column": 12
        }
      }
    }
  },
  "servicio": {
    "suboperacion": "completion_accept",
    "documento": "Algorithm Main\n  Define value As Integer;\n  value\nEndAlgorithm\n",
    "posicion": {
      "line": 3,
      "column": 8
    },
    "candidato": "value"
  }
}
```

```caso
{
  "id": "C34",
  "regla": "R3",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "contiene": [],
      "excluye": [
        "FinAlgoritmo"
      ]
    }
  },
  "servicio": {
    "suboperacion": "completion",
    "documento": "Algoritmo P\n  FinA\nFinAlgoritmo\n",
    "posicion": {
      "line": 2,
      "column": 7
    },
    "proyeccion": "contiene",
    "contiene": [],
    "excluye": [
      "FinAlgoritmo"
    ]
  }
}
```
