---
{
  "formato": "see/1",
  "id": "LANG.IO.OUTPUT",
  "titulo": "Salida",
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
  "resumen": "Salida.",
  "edicion": {
    "introducida_en": "2027"
  },
  "depende_de": [
    {
      "id": "LANG.TYPES.RELATIONS",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Salida

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Escribir evalúa cero o más expresiones separadas por coma, izquierda a derecha y una vez. Concatena representaciones sin separador. Sin Saltar solo aparece una vez al final; ausente agrega salto de línea. La salida vacía agrega una línea; vacía sin salto no emite nada.",
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
    "es": "Algoritmo P\nEscribir;\nEscribir Sin Saltar;\nEscribir 1, 2 Sin Saltar;\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite;\nwrite without newline;\nwrite 1, 2 without newline;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "\n12",
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
    "es": "Algoritmo P\nEscribir Sin Saltar \"ab\";\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite without newline \"ab\";\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "unexpectedModifierPosition",
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
    "es": "Algoritmo P\nEscribir 1 Sin Saltar Sin Saltar;\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite 1 without newline without newline;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "duplicateModifier",
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
    "es": "Algoritmo Mensajes\n  Definir total Como Entero <- 3 + 4;\n  Escribir \"Total: \", total;\n  Escribir \"Hola \" Sin Saltar;\n  Escribir \"mundo\";\nFinAlgoritmo\n",
    "en": "Algorithm Messages\n  Define total As Integer <- 3 + 4;\n  Write \"Total: \", total;\n  Write \"Hola \" Without Newline;\n  Write \"mundo\";\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "Total: 7\nHola mundo\n",
    "terminacion": "completed"
  }
}
```
