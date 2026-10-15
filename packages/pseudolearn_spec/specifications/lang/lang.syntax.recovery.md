---
{
  "formato": "see/1",
  "id": "LANG.SYNTAX.RECOVERY",
  "titulo": "Recuperación sintáctica",
  "dominio": "lenguaje",
  "estado": "experimental",
  "version": "0.3.0",
  "duenos": [
    "responsable-lenguaje"
  ],
  "sujetos": [
    "reference",
    "engine"
  ],
  "resumen": "Recuperación sintáctica.",
  "depende_de": [],
  "edicion": {
    "introducida_en": "2026"
  }
}
---

# Recuperación sintáctica

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Una sentencia malformada produce como máximo un diagnóstico sintáctico principal; no se duplica al sincronizar.",
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
  "texto": "El análisis devuelve un árbol también para el texto vacío o inválido.",
  "verificacion": [
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
  "rigor": [
    "flexible"
  ],
  "programas": {
    "es": "Algoritmo P\n  Escribir 1 +\nFinAlgoritmo\n",
    "en": "algorithm P\n  write 1 +\nendAlgorithm\n"
  },
  "operacion": "analyze",
  "espera": {
    "diagnosticos": [
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      }
    ]
  },
  "origen": "derivado",
  "etiquetas": [
    "limite"
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
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Algoritmo P\n  Escribir 1;\nFinAlgoritmo\n",
    "en": "algorithm P\n  write 1;\nendAlgorithm\n"
  },
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": []
  },
  "origen": "derivado",
  "etiquetas": [
    "limite"
  ]
}
```

```caso
{
  "id": "C3",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programa": "",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "expectedAlgorithmStart",
        "severidad": "error"
      }
    ]
  },
  "origen": "derivado",
  "etiquetas": [
    "limite"
  ]
}
```

```caso
{
  "id": "C4",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Algoritmo P\nFinAlgoritmo\n",
    "en": "algorithm P\nendAlgorithm\n"
  },
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": []
  },
  "origen": "derivado",
  "etiquetas": [
    "limite"
  ]
}
```

```caso
{
  "id": "C5",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "flexible"
  ],
  "programas": {
    "es": "Algoritmo P\n Escribir 1 +\nFinAlgoritmo\n",
    "en": "algorithm P\n write 1 +\nendAlgorithm\n"
  },
  "operacion": "analyze",
  "espera": {
    "arbol": "presente"
  },
  "origen": "derivado",
  "etiquetas": [
    "limite"
  ]
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "sintactica",
  "texto": "La recuperación sincroniza en fin de línea, terminador y fronteras de bloque; suprime diagnósticos cuyo inicio cae en tokens descartados. Las sentencias irrecuperables conservan estructura de error sin impedir reconocer las siguientes.",
  "verificacion": [
    "C6"
  ]
}
```

```regla
{
  "id": "R4",
  "fuerza": "DEBE",
  "clase": "sintactica",
  "texto": "Un bloque sin cerrar produce un diagnóstico sintáctico principal con tramo relacionado de apertura, sin cascada por cada bloque exterior pendiente.",
  "verificacion": [
    "C7",
    "C8"
  ]
}
```

```regla
{
  "id": "R5",
  "fuerza": "DEBE",
  "clase": "sintactica",
  "texto": "Se informan como máximo cien diagnósticos sintácticos principales; al alcanzar el tope se añade maxDiagnosticsExceeded como resumen. El árbol recuperable no se elimina al alcanzar el límite.",
  "verificacion": [
    "C9"
  ]
}
```

```caso
{
  "id": "C6",
  "regla": "R3",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir 1 +;\nEscribir 7;\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite 1 +;\nwrite 7;\nendAlgorithm\n"
  },
  "operacion": "analyze",
  "espera": {
    "arbol": "presente"
  },
  "origen": "derivado"
}
```

```caso
{
  "id": "C7",
  "regla": "R4",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Algoritmo P\n",
    "en": "algorithm P\n"
  },
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "unclosedAlgorithm",
        "severidad": "error"
      }
    ]
  },
  "origen": "derivado"
}
```

```caso
{
  "id": "C8",
  "regla": "R4",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Algoritmo P\nSi Verdadero Entonces\nMientras Verdadero Hacer\n",
    "en": "algorithm P\nif true then\nwhile true do\n"
  },
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "unclosedWhileStatement",
        "severidad": "error"
      }
    ]
  },
  "origen": "derivado"
}
```

```caso
{
  "id": "C9",
  "regla": "R5",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nEscribir 1 +;\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nwrite 1 +;\nendAlgorithm\n"
  },
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "maxDiagnosticsExceeded",
        "severidad": "error"
      }
    ]
  },
  "origen": "derivado"
}
```
