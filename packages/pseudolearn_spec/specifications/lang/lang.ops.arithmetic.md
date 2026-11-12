---
{
  "formato": "see/1",
  "id": "LANG.OPS.ARITHMETIC",
  "titulo": "Aritmética básica",
  "dominio": "lenguaje",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-lenguaje"
  ],
  "revisado_por": [
    "César Antonio Gutiérrez Contreras"
  ],
  "sujetos": [
    "engine",
    "aot"
  ],
  "resumen": "Aritmética básica.",
  "edicion": {
    "introducida_en": "2027"
  },
  "depende_de": [
    {
      "id": "LANG.TYPES.INTEGER",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    },
    {
      "id": "LANG.TYPES.REAL",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Aritmética básica

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Los signos unarios y + - * binarios requieren números. Dos enteros producen entero comprobado en 64 bits; si algún operando es real producen real finito. El desbordamiento detiene con integerOverflow; no hay giro modular. El menos del mínimo entero también desborda.",
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
    "es": "Algoritmo P\nEscribir -3 + 5, \":\", 2 * 3, \":\", 2 + 0.5;\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite -3 + 5, \":\", 2 * 3, \":\", 2 + 0.5;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "2:6:2.5\n",
    "terminacion": "completed"
  }
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
    "es": "Algoritmo P\nEscribir 9223372036854775807 * 2;\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite 9223372036854775807 * 2;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "fallo": {
      "codigo": "integerOverflow"
    }
  }
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
    "es": "Algoritmo P\nEscribir -(-9223372036854775807 - 1);\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite -(-9223372036854775807 - 1);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "fallo": {
      "codigo": "integerOverflow"
    }
  }
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
    "es": "Algoritmo P\n  Escribir \"ab\" - \"cd\";\nFinAlgoritmo\n",
    "en": "Algorithm P\n  Write \"ab\" - \"cd\";\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "incompatibleOperandTypes",
        "severidad": "error"
      }
    ]
  }
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
  "programas": {
    "es": "Algoritmo Manzanas\n  Definir manzanas Como Entero <- 17;\n  Escribir manzanas + 3;\n  Escribir manzanas - 7;\n  Escribir manzanas * 2;\n  Escribir manzanas / 2;\n  Escribir manzanas div 5;\n  Escribir manzanas mod 5;\nFinAlgoritmo\n",
    "en": "Algorithm Apples\n  Define apples As Integer <- 17;\n  Write apples + 3;\n  Write apples - 7;\n  Write apples * 2;\n  Write apples / 2;\n  Write apples Div 5;\n  Write apples Mod 5;\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "20\n10\n34\n8.5\n3\n2\n",
    "terminacion": "completed"
  }
}
```
