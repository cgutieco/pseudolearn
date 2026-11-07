---
{
  "formato": "see/1",
  "id": "LANG.CONTROL.WHILE",
  "titulo": "Bucle anterior",
  "dominio": "lenguaje",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-lenguaje"
  ],
  "revisado_por": [
    "Cesar Antonio Gutierrez Contreras"
  ],
  "sujetos": [
    "reference",
    "engine",
    "aot"
  ],
  "resumen": "Bucle anterior.",
  "edicion": {
    "introducida_en": "2026"
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

# Bucle anterior

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Mientras exige condición lógica y Hacer. Comprueba antes de cada iteración, incluida la primera; ejecuta cero o más veces. El cuerpo puede estar vacío y anidarse. Falta de Hacer o cierre es sintáctica, condición no lógica es semántica.",
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
    "es": "Algoritmo P\nMientras Falso Hacer\nEscribir 1;\nFinMientras\nFinAlgoritmo\n",
    "en": "algorithm P\nwhile false do\nwrite 1;\nendWhile\nendAlgorithm\n"
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
  "id": "C2",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir x Como Entero <- 0;\nMientras x < 2 Hacer\nx <- x + 1;\nFinMientras\nEscribir x;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine x as integer <- 0;\nwhile x < 2 do\nx <- x + 1;\nendWhile\nwrite x;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "2\n",
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
    "es": "Algoritmo P\n  Mientras 1 Hacer\n  FinMientras\nFinAlgoritmo\n",
    "en": "Algorithm P\n  While 1 Do\n  EndWhile\nEndAlgorithm\n"
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
    "es": "Algoritmo Contar\n  Definir contador Como Entero <- 1;\n  Mientras contador <= 3 Hacer\n    Escribir contador;\n    contador <- contador + 1;\n  FinMientras\nFinAlgoritmo\n",
    "en": "Algorithm Count\n  Define counter As Integer <- 1;\n  While counter <= 3 Do\n    Write counter;\n    counter <- counter + 1;\n  EndWhile\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "1\n2\n3\n",
    "terminacion": "completed"
  }
}
```
