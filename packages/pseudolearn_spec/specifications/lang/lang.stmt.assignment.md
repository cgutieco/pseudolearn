---
{
  "formato": "see/1",
  "id": "LANG.STMT.ASSIGNMENT",
  "titulo": "Asignación",
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
  "resumen": "Asignación.",
  "edicion": {
    "introducida_en": "2027"
  },
  "depende_de": [
    {
      "id": "LANG.DECL.DESIGNATOR",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Asignación

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La asignación evalúa el receptor e índices del destino en orden, luego la derecha, luego almacena. Destino no designador es sintáctico; tipos incompatibles son semánticos; índice fuera de rango es de ejecución. Asignar una referencia de objeto conserva identidad; un arreglo completo no se asigna.",
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
    "es": "Algoritmo P\nDefinir x Como Entero <- 3;\nx <- x + 1;\nEscribir x;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine x as integer <- 3;\nx <- x + 1;\nwrite x;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "4\n",
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
    "es": "Algoritmo P\n1 + 2 <- 3;\nFinAlgoritmo\n",
    "en": "algorithm P\n1 + 2 <- 3;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "invalidAssignmentTarget",
        "severidad": "error"
      }
    ]
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
    "es": "Algoritmo P\n  Definir x Como Entero <- \"ab\";\n  Escribir x;\nFinAlgoritmo\n",
    "en": "Algorithm P\n  Define x As Integer <- \"ab\";\n  Write x;\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "incompatibleTypesInAssignment",
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
    "es": "Algoritmo Cumpleanos\n  Definir edad Como Entero;\n  edad <- 15;\n  edad <- edad + 1;\n  Escribir edad;\nFinAlgoritmo\n",
    "en": "Algorithm Birthday\n  Define age As Integer;\n  age <- 15;\n  age <- age + 1;\n  Write age;\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "16\n",
    "terminacion": "completed"
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
    "es": "Algoritmo Cumpleanos\n  Definir edad Como Entero <- 10;\n  15 <- edad;\n  Escribir edad;\nFinAlgoritmo\n",
    "en": "Algorithm Birthday\n  Define age As Integer <- 10;\n  15 <- age;\n  Write age;\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "invalidAssignmentTarget",
        "severidad": "error"
      }
    ]
  }
}
```
