---
{
  "formato": "see/1",
  "id": "LANG.SOURCE.POSITION",
  "titulo": "Posiciones y tramos de fuente",
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
    "app"
  ],
  "resumen": "Posiciones y tramos de fuente.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LANG.SOURCE.ENCODING",
      "version": ">=1.0.0, <2.0.0",
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
  "texto": "Una posición usa desplazamiento desde cero en puntos de código Unicode y línea/columna desde uno. El motor puede conservar offsets UTF-8, pero cada conversión a escalares Unicode o UTF-16 conserva el límite exacto; una posición dentro del par sustituto de un escalar suplementario es inválida. Un tramo es semiabierto entre inicio y fin del texto original; CRLF avanza una línea y el BOM inicial permanece en las coordenadas originales. Cada tramo pertenece a una identidad de fuente dentro de un proyecto y una revisión; un nombre visible repetido no identifica ni sustituye al archivo. Los tramos relacionados señalan el origen de la restricción y no se eliminan por normalización.",
  "verificacion": [
    "C1",
    "C2",
    "C3"
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

```caso
{
  "id": "C3",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "analyze",
  "programas": {
    "es": "﻿Algoritmo P\r\nEscribir \"😀\" @;\r\nFinAlgoritmo\r\n",
    "en": "﻿algorithm P\r\nwrite \"😀\" @;\r\nendAlgorithm\r\n"
  },
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "unrecognizedCharacter",
        "severidad": "error",
        "tramo": {
          "start": {
            "line": 2,
            "column": 14
          },
          "end": {
            "line": 2,
            "column": 15
          }
        }
      }
    ]
  },
  "esperas": {
    "en": {
      "arbol": "presente",
      "diagnosticos": [
        {
          "codigo": "unrecognizedCharacter",
          "severidad": "error",
          "tramo": {
            "start": {
              "line": 2,
              "column": 11
            },
            "end": {
              "line": 2,
              "column": 12
            }
          }
        }
      ]
    }
  }
}
```
