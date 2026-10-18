---
{
  "formato": "see/1",
  "id": "TOOL.CLI.RUN",
  "titulo": "Orden ejecutar",
  "dominio": "herramienta",
  "estado": "experimental",
  "version": "0.2.0",
  "duenos": [
    "responsable-herramientas"
  ],
  "sujetos": [
    "cli"
  ],
  "resumen": "pseudo ejecutar con entrada estándar, semilla, límites y traza.",
  "depende_de": [
    {
      "id": "TOOL.CLI.MESSAGES",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    },
    {
      "id": "API.EXECUTE",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "Run command",
}
---

# Orden ejecutar

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "pseudo ejecutar analiza el archivo y, si no hay errores, lo ejecuta: la salida del programa va sin traducir a la salida estándar y la entrada estándar alimenta Leer, una línea por valor sin su fin de línea. Los diagnósticos de análisis y de ejecución van a la salida de error con las plantillas de diagnóstico.",
  "verificacion": [
    "C1",
    "C2",
    "C3",
    "C4"
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
    "codigo_salida": 0,
    "salida": "1\n",
    "salida_error": ""
  },
  "cli": {
    "argumentos": [
      "ejecutar",
      "p.pseudo"
    ],
    "entorno": {},
    "archivos": {
      "p.pseudo": "Algoritmo P\nEscribir 1;\nFinAlgoritmo\n"
    }
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
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "cli",
  "espera": {
    "codigo_salida": 0,
    "salida": "1\n",
    "salida_error": ""
  },
  "cli": {
    "argumentos": [
      "run",
      "p.pseudo"
    ],
    "entorno": {},
    "archivos": {
      "p.pseudo": "Algoritmo P\nEscribir 1;\nFinAlgoritmo\n"
    }
  }
}
```

```caso
{
  "id": "C3",
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
    "codigo_salida": 0,
    "salida": "42\n",
    "salida_error": ""
  },
  "cli": {
    "argumentos": [
      "ejecutar",
      "p.pseudo"
    ],
    "entorno": {},
    "archivos": {
      "p.pseudo": "Algoritmo P\nDefinir x Como Entero;\nLeer x;\nEscribir x * 2;\nFinAlgoritmo\n"
    },
    "entrada": "21\n"
  }
}
```

```caso
{
  "id": "C4",
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
    "salida": "",
    "salida_error": "p.pseudo:2:10: error: Variable no declarada: total [undeclaredVariable]\n"
  },
  "cli": {
    "argumentos": [
      "ejecutar",
      "p.pseudo"
    ],
    "entorno": {},
    "archivos": {
      "p.pseudo": "Algoritmo P\nEscribir total;\nFinAlgoritmo\n"
    }
  }
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El código de salida es 0 si la ejecución termina con completed y 1 en cualquier otro caso. Un fallo escribe su diagnóstico; un límite alcanzado escribe statementBudgetExhausted; la entrada estándar agotada mientras Leer espera escribe inputExhausted.",
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
  "regla": "R2",
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
    "salida": "",
    "salida_error": "p.pseudo:4:12: error: División por cero [divisionByZero]\n"
  },
  "cli": {
    "argumentos": [
      "ejecutar",
      "p.pseudo"
    ],
    "entorno": {},
    "archivos": {
      "p.pseudo": "Algoritmo P\nDefinir x Como Entero;\nx <- 0;\nEscribir 1 div x;\nFinAlgoritmo\n"
    }
  }
}
```

```caso
{
  "id": "C6",
  "regla": "R2",
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
    "salida": "",
    "salida_error": "p.pseudo: la entrada estándar terminó mientras el programa esperaba un valor\n"
  },
  "cli": {
    "argumentos": [
      "ejecutar",
      "p.pseudo"
    ],
    "entorno": {},
    "archivos": {
      "p.pseudo": "Algoritmo P\nDefinir x Como Entero;\nLeer x;\nEscribir x;\nFinAlgoritmo\n"
    }
  }
}
```

```caso
{
  "id": "C7",
  "regla": "R2",
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
    "salida": "1\n2\n",
    "salida_error": "p.pseudo:4:1: información: Se agotó el presupuesto de sentencias: 2 [statementBudgetExhausted]\n"
  },
  "cli": {
    "argumentos": [
      "ejecutar",
      "--sentencias",
      "2",
      "p.pseudo"
    ],
    "entorno": {},
    "archivos": {
      "p.pseudo": "Algoritmo P\nEscribir 1;\nEscribir 2;\nEscribir 3;\nFinAlgoritmo\n"
    }
  }
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "--semilla fija la semilla de RT.HOST.INTERFACE; sin ella se usa 42. --profundidad, --sentencias y --celdas fijan los límites de ENG.LIMITS; por omisión la CLI admite 100 000 marcos y no tiene presupuesto de sentencias.",
  "verificacion": [
    "C8",
    "C9"
  ]
}
```

```caso
{
  "id": "C8",
  "regla": "R3",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "cli",
  "espera": {
    "codigo_salida": 0,
    "salida": "5415695640260286\n",
    "salida_error": ""
  },
  "cli": {
    "argumentos": [
      "ejecutar",
      "--semilla",
      "0",
      "p.pseudo"
    ],
    "entorno": {},
    "archivos": {
      "p.pseudo": "Algoritmo P\nEscribir trunc(azar() * 9007199254740992.0);\nFinAlgoritmo\n"
    }
  }
}
```

```caso
{
  "id": "C9",
  "regla": "R3",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "cli",
  "espera": {
    "codigo_salida": 0,
    "salida": "fin\n",
    "salida_error": ""
  },
  "cli": {
    "argumentos": [
      "ejecutar",
      "p.pseudo"
    ],
    "entorno": {},
    "archivos": {
      "p.pseudo": "SubProceso f(n Como Entero)\nSi n > 0 Entonces\nf(n - 1);\nFinSi\nFinSubProceso\nAlgoritmo P\nf(5000);\nEscribir \"fin\";\nFinAlgoritmo\n"
    }
  }
}
```

```regla
{
  "id": "R4",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "--traza narra cada evento de ENG.TRACE.EVENTS en la salida de error, una línea por evento, con las plantillas trace* en el idioma de interfaz. source es el texto de la línea de la sentencia sin espacios iniciales ni finales y text muestra cada salto de línea como \\n. La salida del programa y sus lexemas no se traducen.",
  "verificacion": [
    "C10",
    "C11"
  ]
}
```

```caso
{
  "id": "C10",
  "regla": "R4",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "cli",
  "espera": {
    "codigo_salida": 0,
    "salida": "1\n",
    "salida_error": "p.pseudo:2  entra en sentencia  Escribir 1;\np.pseudo:2  escribe  1\\n\np.pseudo:2  sale de sentencia  Escribir 1;\n"
  },
  "cli": {
    "argumentos": [
      "ejecutar",
      "--traza",
      "p.pseudo"
    ],
    "entorno": {},
    "archivos": {
      "p.pseudo": "Algoritmo P\nEscribir 1;\nFinAlgoritmo\n"
    }
  }
}
```

```caso
{
  "id": "C11",
  "regla": "R4",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "cli",
  "espera": {
    "codigo_salida": 0,
    "salida": "1\n",
    "salida_error": "p.pseudo:2  enters statement  Escribir 1;\np.pseudo:2  writes  1\\n\np.pseudo:2  exits statement  Escribir 1;\n"
  },
  "cli": {
    "argumentos": [
      "run",
      "--trace",
      "--language",
      "en",
      "p.pseudo"
    ],
    "entorno": {},
    "archivos": {
      "p.pseudo": "Algoritmo P\nEscribir 1;\nFinAlgoritmo\n"
    }
  }
}
```
