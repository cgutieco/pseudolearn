---
{
  "formato": "see/1",
  "id": "TOOL.SERVICE.NAVIGATION",
  "titulo": "Navegación de código y referencias",
  "dominio": "herramienta",
  "estado": "experimental",
  "version": "0.1.0",
  "duenos": [
    "responsable-herramientas"
  ],
  "sujetos": [
    "service"
  ],
  "resumen": "Definición, referencias y resaltado de ocurrencias con resolución semántica de alcance.",
  "depende_de": [
    {
      "id": "LANG.DECL.VARIABLE",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    },
    {
      "id": "LANG.SUBPROGRAM.CALL",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    },
    {
      "id": "LANG.CLASS.DECLARATION",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    },
    {
      "id": "TOOL.SERVICE.INCREMENTAL",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "Code navigation service"
}
---

# Navegación de código y referencias

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Dada una posición de cursor sobre un uso o declaración de variable, constante, parámetro, subproceso, función, clase, campo o método, el servicio devuelve el rango exacto de su declaración en el alcance correspondiente.",
  "verificacion": [
    "C1",
    "C3"
  ]
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Dada una posición sobre un símbolo, devuelve en orden de aparición todos los rangos del documento que referencian ese mismo símbolo semántico, sin confundirlo con símbolos homónimos de otros alcances.",
  "verificacion": [
    "C2"
  ]
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El resaltado de documento devuelve las ocurrencias del símbolo bajo el cursor clasificando cada una como lectura o escritura/declaración.",
  "verificacion": [
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
  "operacion": "service",
  "espera": {
    "servicio": {
      "definicion": {
        "start": { "line": 2, "column": 11 },
        "end": { "line": 2, "column": 16 }
      }
    }
  },
  "servicio": {
    "suboperacion": "definition",
    "documento": "Algoritmo Principal\n  Definir total Como Entero;\n  total <- 10;\n  Escribir total;\nFinAlgoritmo\n",
    "posicion": { "line": 4, "column": 13 }
  }
}
```

```caso
{
  "id": "C2",
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
      "referencias": [
        {
          "start": { "line": 2, "column": 11 },
          "end": { "line": 2, "column": 12 }
        },
        {
          "start": { "line": 3, "column": 3 },
          "end": { "line": 3, "column": 4 }
        }
      ]
    }
  },
  "servicio": {
    "suboperacion": "references",
    "documento": "SubProceso Uno()\n  Definir i Como Entero;\n  i <- 1;\nFinSubProceso\n\nSubProceso Dos()\n  Definir i Como Entero;\n  i <- 2;\nFinSubProceso\n",
    "posicion": { "line": 3, "column": 3 }
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
  "operacion": "service",
  "espera": {
    "servicio": {
      "definicion": {
        "start": { "line": 2, "column": 10 },
        "end": { "line": 2, "column": 15 }
      }
    }
  },
  "servicio": {
    "suboperacion": "definition",
    "documento": "Clase Punto\n  Metodo Mover()\n  FinMetodo\nFinClase\n\nAlgoritmo Principal\n  Definir p Como Punto;\n  p.Mover();\nFinAlgoritmo\n",
    "posicion": { "line": 8, "column": 6 }
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
      "destacados": [
        {
          "rango": {
            "start": { "line": 2, "column": 3 },
            "end": { "line": 2, "column": 4 }
          },
          "tipo": "write"
        },
        {
          "rango": {
            "start": { "line": 3, "column": 12 },
            "end": { "line": 3, "column": 13 }
          },
          "tipo": "read"
        }
      ]
    }
  },
  "servicio": {
    "suboperacion": "highlight",
    "documento": "Algoritmo Principal\n  x <- 1;\n  Escribir x;\nFinAlgoritmo\n",
    "posicion": { "line": 2, "column": 3 }
  }
}
```
