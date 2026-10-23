---
{
  "formato": "see/1",
  "id": "TOOL.SERVICE.HOVER",
  "titulo": "Información emergente y ayuda de firmas",
  "dominio": "herramienta",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-herramientas"
  ],
  "sujetos": [
    "service"
  ],
  "resumen": "Información de tipo estático, firmas de subprocesos y ayuda contextual sobre llamadas.",
  "depende_de": [
    {
      "id": "LANG.TYPES.INTEGER",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "LANG.SUBPROGRAM.CALL",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "LIB.CORE.MATH",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "LIB.CORE.TEXT",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "TOOL.SERVICE.INCREMENTAL",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "Hover and signature help service",
  "revisado_por": [
    "revision-independiente-automatizada-r9"
  ]
}
---

# Información emergente y ayuda de firmas

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Al posicionar el cursor sobre una variable, constante, parámetro, campo, clase o subproceso, el servicio devuelve su categoría, su tipo estático (indicando si fue declarado o inferido en modo flexible) y, para subprocesos/métodos, su firma canónica con modos de paso.",
  "verificacion": [
    "C1",
    "C2"
  ]
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Sobre una función intrínseca de la biblioteca estándar (no sombreada) o palabra clave, devuelve su firma y descripción breve en el idioma solicitado.",
  "verificacion": [
    "C4"
  ]
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Cuando el cursor está dentro de la lista de argumentos de una llamada, el servicio devuelve la firma del invocable y el índice del parámetro activo.",
  "verificacion": [
    "C3"
  ]
}
```

```regla
{
  "id": "R4",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La resolución por posición selecciona el token no trivia cuyo tramo original contiene la posición; una posición al inicio de un token selecciona ese token y gana sobre el final del token anterior. El final exacto de un token puede seleccionarlo, pero una posición posterior dentro de trivia, comentarios, saltos de línea, literales, EOF o fuera del documento no hereda ayuda. Los tokens compuestos conservan el lexema y el tramo completos, incluidos espacios o tabuladores horizontales internos; cada posición dentro del compuesto resuelve la misma identidad. Una referencia semántica de usuario tiene prioridad sobre una función incorporada homónima. La construcción y el papel contextual se asignan desde CST y análisis semántico; si la recuperación no demuestra el papel, solo se devuelve la identidad léxica con certeza parcial. Nunca se infiere una identidad desde palabras cercanas sin token. Los alias de un mismo lexema lógico comparten identidad, conservando el tramo original.",
  "verificacion": [
    "C5",
    "C6",
    "C7",
    "C8",
    "C9",
    "C10",
    "C11",
    "C12",
    "C13",
    "C14"
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
      "tipo": "Entero",
      "inferido": false
    }
  },
  "servicio": {
    "suboperacion": "hover",
    "documento": "Algoritmo Principal\n  Definir contador Como Entero;\n  contador <- 1;\nFinAlgoritmo\n",
    "posicion": {
      "line": 3,
      "column": 5
    },
    "proyeccion": "tipo"
  }
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
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "tipo": "Real",
      "inferido": true
    }
  },
  "servicio": {
    "suboperacion": "hover",
    "documento": "Algoritmo Principal\n  x <- 3.14\nFinAlgoritmo\n",
    "posicion": {
      "line": 2,
      "column": 3
    },
    "proyeccion": "tipo"
  }
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
  "operacion": "service",
  "espera": {
    "servicio": {
      "parametro_activo": 1,
      "firma": "Intercambiar(a Por Referencia, b Por Valor)"
    }
  },
  "servicio": {
    "suboperacion": "signature_help",
    "documento": "SubProceso Intercambiar(a Por Referencia, b Por Valor)\nFinSubProceso\n\nAlgoritmo Principal\n  Definir x, z Como Entero;\n  Intercambiar(x, );\nFinAlgoritmo\n",
    "posicion": {
      "line": 6,
      "column": 19
    }
  }
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
  "operacion": "service",
  "espera": {
    "servicio": {
      "es_intrinseca": true,
      "identificador": "Longitud"
    }
  },
  "servicio": {
    "suboperacion": "hover",
    "documento": "Algoritmo Principal\n  Definir n Como Entero;\n  n <- Longitud(\"hola\");\nFinAlgoritmo\n",
    "posicion": {
      "line": 3,
      "column": 10
    },
    "proyeccion": "intrinseca"
  }
}
```

```caso
{
  "id": "C5",
  "regla": "R4",
  "perfiles": ["es"],
  "rigor": ["estricto", "flexible"],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "resolucion": {
        "identity": {"kind": "construction", "id": "for", "role": "step_clause"},
        "certainty": "certain"
      }
    }
  },
  "servicio": {
    "suboperacion": "hover",
    "documento": "Algoritmo P\nPara i <- 1 Hasta 2 Con\tPaso 1 Hacer\nFinPara\nFinAlgoritmo\n",
    "posicion": {"line": 2, "column": 27},
    "proyeccion": "resolucion"
  }
}
```

```caso
{
  "id": "C6",
  "regla": "R4",
  "perfiles": ["es"],
  "rigor": ["estricto", "flexible"],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "resolucion": {
        "identity": {"kind": "construction", "id": "repeat", "role": "condition_start"},
        "certainty": "certain"
      }
    }
  },
  "servicio": {
    "suboperacion": "hover",
    "documento": "Algoritmo P\nRepetir\nHasta Que Verdadero\nFinAlgoritmo\n",
    "posicion": {"line": 3, "column": 7},
    "proyeccion": "resolucion"
  }
}
```

```caso
{
  "id": "C7",
  "regla": "R4",
  "perfiles": ["es"],
  "rigor": ["estricto", "flexible"],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "resolucion": {
        "identity": {"kind": "role", "id": "parameter", "role": "pass_by_reference"},
        "certainty": "certain"
      }
    }
  },
  "servicio": {
    "suboperacion": "hover",
    "documento": "SubProceso cambiar(valor Como Entero Por\tReferencia)\nFinSubProceso\nAlgoritmo P\nFinAlgoritmo\n",
    "posicion": {"line": 1, "column": 47},
    "proyeccion": "resolucion"
  }
}
```

```caso
{
  "id": "C8",
  "regla": "R4",
  "perfiles": ["es"],
  "rigor": ["estricto", "flexible"],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "resolucion": {
        "identity": {"kind": "keyword", "id": "elseKeyword", "role": "keyword"},
        "certainty": "certain"
      }
    }
  },
  "servicio": {
    "suboperacion": "hover",
    "documento": "Algoritmo P\nSi Verdadero Entonces\nEscribir 1;\nSiNo\nEscribir 2;\nFinSi\nFinAlgoritmo\n",
    "posicion": {"line": 4, "column": 2},
    "proyeccion": "resolucion"
  }
}
```

```caso
{
  "id": "C9",
  "regla": "R4",
  "perfiles": ["es"],
  "rigor": ["estricto", "flexible"],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "resolucion": {
        "identity": {"kind": "construction", "id": "for", "role": "body_start"},
        "certainty": "certain"
      }
    }
  },
  "servicio": {
    "suboperacion": "hover",
    "documento": "Algoritmo P\nPara i <- 1 Hasta 2 Hacer\nFinPara\nFinAlgoritmo\n",
    "posicion": {"line": 2, "column": 22},
    "proyeccion": "resolucion"
  }
}
```

```caso
{
  "id": "C10",
  "regla": "R4",
  "perfiles": ["es"],
  "rigor": ["estricto", "flexible"],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "resolucion": {
        "identity": {"kind": "construction", "id": "while", "role": "body_start"},
        "certainty": "certain"
      }
    }
  },
  "servicio": {
    "suboperacion": "hover",
    "documento": "Algoritmo P\nMientras Verdadero Hacer\nFinMientras\nFinAlgoritmo\n",
    "posicion": {"line": 2, "column": 22},
    "proyeccion": "resolucion"
  }
}
```

```caso
{
  "id": "C11",
  "regla": "R4",
  "perfiles": ["es"],
  "rigor": ["estricto", "flexible"],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "resolucion": {
        "identity": {"kind": "construction", "id": "switch", "role": "body_start"},
        "certainty": "certain"
      }
    }
  },
  "servicio": {
    "suboperacion": "hover",
    "documento": "Algoritmo P\nSegun 1 Hacer\n1: Escribir 1;\nFinSegun\nFinAlgoritmo\n",
    "posicion": {"line": 2, "column": 10},
    "proyeccion": "resolucion"
  }
}
```

```caso
{
  "id": "C12",
  "regla": "R4",
  "perfiles": ["es"],
  "rigor": ["estricto", "flexible"],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "resolucion": {
        "identity": {"kind": "construction", "id": "for", "role": "range_limit"},
        "certainty": "certain"
      }
    }
  },
  "servicio": {
    "suboperacion": "hover",
    "documento": "Algoritmo P\nPara i <- 1 Hasta 2 Hacer\nFinPara\nFinAlgoritmo\n",
    "posicion": {"line": 2, "column": 14},
    "proyeccion": "resolucion"
  }
}
```

```caso
{
  "id": "C13",
  "regla": "R4",
  "perfiles": ["es"],
  "rigor": ["estricto", "flexible"],
  "origen": "derivado",
  "operacion": "service",
  "espera": {"servicio": {"resolucion": null}},
  "servicio": {
    "suboperacion": "hover",
    "documento": "Algoritmo P\nEscribir 42; // nota\nFinAlgoritmo\n",
    "posicion": {"line": 2, "column": 12},
    "proyeccion": "resolucion"
  }
}
```

```caso
{
  "id": "C14",
  "regla": "R4",
  "perfiles": ["es"],
  "rigor": ["estricto", "flexible"],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "resolucion": {
        "identity": {"kind": "keyword", "id": "whileKeyword", "role": "keyword"},
        "certainty": "partial"
      }
    }
  },
  "servicio": {
    "suboperacion": "hover",
    "documento": "Algoritmo P\nMientras",
    "posicion": {"line": 2, "column": 5},
    "proyeccion": "resolucion"
  }
}
```
