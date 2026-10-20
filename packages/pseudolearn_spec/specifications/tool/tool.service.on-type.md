---
{
  "formato": "see/1",
  "id": "TOOL.SERVICE.ON-TYPE",
  "titulo": "Asistencia al teclear",
  "dominio": "herramienta",
  "estado": "experimental",
  "version": "0.1.0",
  "duenos": [
    "responsable-herramientas"
  ],
  "sujetos": [
    "service"
  ],
  "resumen": "Ediciones deterministas que acompañan una pulsación: sangría, cierre de bloques, terminador, realineado y pares.",
  "depende_de": [
    {
      "id": "LANG.SYNTAX.RECOVERY",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    },
    {
      "id": "LANG.STMT.TERMINATION",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    },
    {
      "id": "TOOL.SERVICE.COMPLETION",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    },
    {
      "id": "TOOL.FORMAT.STYLE",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    },
    {
      "id": "LANG.SOURCE.POSITION",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "Typing assistance"
}
---

# Asistencia al teclear

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Tras insertar un salto de línea, si la línea anterior abre un bloque que el análisis informa sin cerrar, el servicio sangra la línea nueva una unidad respecto de la apertura e inserta en la línea siguiente el cierre canónico del perfil, alineado con la apertura. La repetición (Repetir) solo se sangra, porque su cierre exige una condición. Si el resto de la línea del cursor no está en blanco, solo se sangra.",
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
  "texto": "Tras un salto de línea, si la línea anterior abre un bloque ya cerrado o es Sino, la línea nueva se sangra una unidad respecto de ella; en cualquier otro caso conserva la sangría de la línea anterior. No se insertan cierres.",
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
  "texto": "En rigor estricto, tras un salto de línea, si la línea anterior es una sentencia simple completa sin terminador, se inserta ; al final de esa línea. En rigor flexible no se inserta.",
  "verificacion": [
    "C4",
    "C5"
  ]
}
```

```regla
{
  "id": "R4",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Al teclear un espacio, un salto de línea o ; tras una línea que comienza por un cierre, Sino o De Otro Modo (con los dos puntos opcionales), la línea se realinea con la sangría de la apertura que le corresponde; De Otro Modo queda una unidad más adentro que su Segun. Las etiquetas de caso con valor no se realinean.",
  "verificacion": [
    "C6"
  ]
}
```

```regla
{
  "id": "R5",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Al teclear ( \" ' o [ fuera de comentarios y literales, y con un carácter siguiente que no sea de identificador, se inserta el cierre del par tras el cursor. Teclear el carácter de cierre cuando el siguiente ya es ese carácter lo atraviesa sin duplicarlo.",
  "verificacion": [
    "C7",
    "C8",
    "C9",
    "C10"
  ]
}
```

```regla
{
  "id": "R6",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Las ediciones devueltas nunca aumentan el número de diagnósticos sintácticos del documento respecto de su texto previo. Tras un salto de línea, aplicar de nuevo la asistencia sobre el resultado, con el cursor al inicio de la línea nueva, no produce ediciones; la repetición de un par equivale a otra pulsación y queda fuera de esa garantía. Si el terminador produciría un diagnóstico nuevo, se aplica el resto de la asistencia sin él.",
  "verificacion": [
    "C11",
    "C12"
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
      "texto": "Algoritmo Principal\n  Mientras x < 10 Hacer\n    \n  FinMientras\nFinAlgoritmo\n",
      "cursor": {
        "line": 3,
        "column": 5
      }
    }
  },
  "servicio": {
    "suboperacion": "on_type",
    "documento": "Algoritmo Principal\n  Mientras x < 10 Hacer\n\nFinAlgoritmo\n",
    "posicion": {
      "line": 3,
      "column": 1
    },
    "caracter": "\n"
  }
}
```

```caso
{
  "id": "C2",
  "regla": "R1",
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
      "texto": "Algorithm Main\n  If x < 10 Then\n    \n  EndIf\nEndAlgorithm\n",
      "cursor": {
        "line": 3,
        "column": 5
      }
    }
  },
  "servicio": {
    "suboperacion": "on_type",
    "documento": "Algorithm Main\n  If x < 10 Then\n\nEndAlgorithm\n",
    "posicion": {
      "line": 3,
      "column": 1
    },
    "caracter": "\n"
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
      "texto": "Algoritmo Principal\n  Mientras x < 10 Hacer\n    \n  FinMientras\nFinAlgoritmo\n",
      "cursor": {
        "line": 3,
        "column": 5
      }
    }
  },
  "servicio": {
    "suboperacion": "on_type",
    "documento": "Algoritmo Principal\n  Mientras x < 10 Hacer\n\n  FinMientras\nFinAlgoritmo\n",
    "posicion": {
      "line": 3,
      "column": 1
    },
    "caracter": "\n"
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
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "texto": "Algoritmo Principal\n  Escribir 1;\n  \nFinAlgoritmo\n",
      "cursor": {
        "line": 3,
        "column": 3
      }
    }
  },
  "servicio": {
    "suboperacion": "on_type",
    "documento": "Algoritmo Principal\n  Escribir 1\n\nFinAlgoritmo\n",
    "posicion": {
      "line": 3,
      "column": 1
    },
    "caracter": "\n"
  }
}
```

```caso
{
  "id": "C5",
  "regla": "R3",
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
      "texto": "Algoritmo Principal\n  Escribir 1\n  \nFinAlgoritmo\n",
      "cursor": {
        "line": 3,
        "column": 3
      }
    }
  },
  "servicio": {
    "suboperacion": "on_type",
    "documento": "Algoritmo Principal\n  Escribir 1\n\nFinAlgoritmo\n",
    "posicion": {
      "line": 3,
      "column": 1
    },
    "caracter": "\n"
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
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "texto": "Algoritmo Principal\n  Mientras x < 10 Hacer\n  FinMientras \nFinAlgoritmo\n",
      "cursor": {
        "line": 3,
        "column": 15
      }
    }
  },
  "servicio": {
    "suboperacion": "on_type",
    "documento": "Algoritmo Principal\n  Mientras x < 10 Hacer\n    FinMientras \nFinAlgoritmo\n",
    "posicion": {
      "line": 3,
      "column": 17
    },
    "caracter": " "
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
      "texto": "Algoritmo Principal\n  Escribir ()\nFinAlgoritmo\n",
      "cursor": {
        "line": 2,
        "column": 13
      }
    }
  },
  "servicio": {
    "suboperacion": "on_type",
    "documento": "Algoritmo Principal\n  Escribir (\nFinAlgoritmo\n",
    "posicion": {
      "line": 2,
      "column": 13
    },
    "caracter": "("
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
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "texto": "Algoritmo Principal\n  Escribir (1)\nFinAlgoritmo\n",
      "cursor": {
        "line": 2,
        "column": 15
      }
    }
  },
  "servicio": {
    "suboperacion": "on_type",
    "documento": "Algoritmo Principal\n  Escribir (1))\nFinAlgoritmo\n",
    "posicion": {
      "line": 2,
      "column": 15
    },
    "caracter": ")"
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
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "texto": "Algoritmo Principal\n  // nota (\nFinAlgoritmo\n",
      "cursor": {
        "line": 2,
        "column": 12
      }
    }
  },
  "servicio": {
    "suboperacion": "on_type",
    "documento": "Algoritmo Principal\n  // nota (\nFinAlgoritmo\n",
    "posicion": {
      "line": 2,
      "column": 12
    },
    "caracter": "("
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
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "texto": "Algoritmo Principal\n  Escribir \"\"\nFinAlgoritmo\n",
      "cursor": {
        "line": 2,
        "column": 13
      }
    }
  },
  "servicio": {
    "suboperacion": "on_type",
    "documento": "Algoritmo Principal\n  Escribir \"\nFinAlgoritmo\n",
    "posicion": {
      "line": 2,
      "column": 13
    },
    "caracter": "\""
  }
}
```

```caso
{
  "id": "C11",
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
      "texto": "Algoritmo Principal\n  x <- 1 +\n  \nFinAlgoritmo\n",
      "cursor": {
        "line": 3,
        "column": 3
      }
    }
  },
  "servicio": {
    "suboperacion": "on_type",
    "documento": "Algoritmo Principal\n  x <- 1 +\n\nFinAlgoritmo\n",
    "posicion": {
      "line": 3,
      "column": 1
    },
    "caracter": "\n"
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
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "texto": "Algoritmo Principal\n  Mientras x < 10 Hacer\n    \n  FinMientras\nFinAlgoritmo\n",
      "cursor": {
        "line": 3,
        "column": 1
      }
    }
  },
  "servicio": {
    "suboperacion": "on_type",
    "documento": "Algoritmo Principal\n  Mientras x < 10 Hacer\n    \n  FinMientras\nFinAlgoritmo\n",
    "posicion": {
      "line": 3,
      "column": 1
    },
    "caracter": "\n"
  }
}
```
