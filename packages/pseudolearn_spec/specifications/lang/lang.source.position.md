---
{
  "formato": "see/1",
  "id": "LANG.SOURCE.POSITION",
  "titulo": "Posiciones y tramos de fuente",
  "dominio": "lenguaje",
  "estado": "experimental",
  "version": "0.2.0",
  "duenos": [
    "responsable-lenguaje"
  ],
  "sujetos": [
    "reference",
    "engine"
  ],
  "resumen": "Posiciones y tramos de fuente.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LANG.SOURCE.ENCODING",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Posiciones y tramos de fuente

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Una posición usa desplazamiento desde cero en puntos de código Unicode y línea/columna desde uno. Un tramo es semiabierto entre inicio y fin del texto original; CRLF avanza una línea. Los tramos relacionados señalan el origen de la restricción y no se eliminan por normalización.",
  "verificacion": [
    "C1",
    "C2"
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
    "es": "Algoritmo P\nEscribir @;\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite @;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "unrecognizedCharacter",
        "severidad": "error"
      }
    ]
  },
  "rigor": [
    "estricto",
    "flexible"
  ],
  "esperas": {
    "es": {
      "arbol": "presente",
      "diagnosticos": [
        {
          "codigo": "unrecognizedCharacter",
          "severidad": "error",
          "clase": "lexical",
          "tramo": {
            "start": {
              "line": 2,
              "column": 10
            },
            "end": {
              "line": 2,
              "column": 11
            }
          },
          "argumentos": {
            "lexeme": "@"
          }
        }
      ]
    },
    "en": {
      "arbol": "presente",
      "diagnosticos": [
        {
          "codigo": "unrecognizedCharacter",
          "severidad": "error",
          "clase": "lexical",
          "tramo": {
            "start": {
              "line": 2,
              "column": 7
            },
            "end": {
              "line": 2,
              "column": 8
            }
          },
          "argumentos": {
            "lexeme": "@"
          }
        }
      ]
    }
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
    "es": "Algoritmo P\nEscribir \"😀\";\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite \"😀\";\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": []
  },
  "rigor": [
    "estricto",
    "flexible"
  ]
}
```
