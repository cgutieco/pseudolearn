---
{
  "formato": "see/1",
  "id": "LANG.CONTROL.REPEAT",
  "titulo": "Bucle posterior",
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
  "resumen": "Bucle posterior.",
  "edicion": {
    "introducida_en": "2027"
  },
  "depende_de": [
    {
      "id": "LANG.TYPES.BOOLEAN",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Bucle posterior

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Repetir ejecuta el cuerpo al menos una vez y termina cuando la condición de Hasta Que es verdadera. La condición se evalúa después del cuerpo y debe ser lógica. Hasta Que cierra el bloque; no hay cierre adicional. El cuerpo vacío comprueba la condición una vez.",
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
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nRepetir\nEscribir 1;\nHasta Que Verdadero\nFinAlgoritmo\n",
    "en": "algorithm P\nrepeat\nwrite 1;\nuntil true\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "1\n",
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
    "es": "Algoritmo P\nRepetir\nHasta Que Verdadero\nFinAlgoritmo\n",
    "en": "algorithm P\nrepeat\nuntil true\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "",
    "terminacion": "completed"
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
    "es": "Algoritmo P\n  Repetir\n  Hasta Que 1\nFinAlgoritmo\n",
    "en": "Algorithm P\n  Repeat\n  Until 1\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "nonBooleanCondition",
        "severidad": "error"
      }
    ]
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
    "es": "Algoritmo Duplicar\n  Definir numero Como Entero <- 1;\n  Repetir\n    Escribir numero;\n    numero <- numero * 2;\n  Hasta Que numero > 10\nFinAlgoritmo\n",
    "en": "Algorithm Doubling\n  Define number As Integer <- 1;\n  Repeat\n    Write number;\n    number <- number * 2;\n  Until number > 10\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "1\n2\n4\n8\n",
    "terminacion": "completed"
  }
}
```
