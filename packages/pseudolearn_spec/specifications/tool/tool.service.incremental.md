---
{
  "formato": "see/1",
  "id": "TOOL.SERVICE.INCREMENTAL",
  "titulo": "Análisis incremental de documentos",
  "dominio": "herramienta",
  "estado": "estable",
  "version": "0.1.0",
  "duenos": [
    "responsable-herramientas"
  ],
  "sujetos": [
    "service"
  ],
  "resumen": "Sesión de documento y reanálisis incremental por unidad con equivalencia al análisis en frío.",
  "depende_de": [
    {
      "id": "TOOL.SERVICE.LOSSLESS-TREE",
      "version": ">=0.2.0, <1.0.0",
      "tipo": "usa"
    },
    {
      "id": "TOOL.SERVICE.NODE-IDENTITY",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    },
    {
      "id": "PERF.PROTOCOL",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "Incremental document analysis",
  "revisado_por": [
    "revision-independiente-automatizada-r9"
  ],
  "cambio": {
    "clase": "editorial",
    "impacto_usuarios": "Contrato existente respaldado; no cambia su comportamiento observable.",
    "impacto_implementaciones": "Se conserva la versión numérica y las exenciones explícitas de cada sujeto.",
    "justificacion": "Promoción revisada con evidencias vigentes y verificadores locales ejecutados.",
    "revisado_por": "revision-independiente-automatizada-r9"
  }
}
---

# Análisis incremental de documentos

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Tras cualquier secuencia de ediciones incrementales sobre una sesión de documento, el texto reconstruido, el árbol sintáctico, los diagnósticos y el modelo semántico producidos por el análisis incremental son idénticos a los obtenidos analizando el documento resultante desde cero.",
  "verificacion": [
    "C1",
    "P1"
  ]
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Cuando una edición modifica únicamente el cuerpo de una unidad de nivel superior sin alterar su firma ni las firmas de las demás unidades del documento, el servicio informa cuáles unidades conservan su huella y cuáles quedan afectadas, y no invalida las firmas del documento.",
  "verificacion": [
    "C2",
    "C3",
    "M1"
  ]
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Durante la escritura con bloques abiertos o expresiones truncadas, la sesión incremental actualiza los diagnósticos y conserva los símbolos declarados antes del punto de edición.",
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
      "coincide_con_frio": true
    }
  },
  "servicio": {
    "suboperacion": "incremental",
    "documento": "Algoritmo Principal\n  Definir x Como Entero;\nFinAlgoritmo\n",
    "ediciones": [
      {
        "rango": {
          "start": { "line": 3, "column": 1 },
          "end": { "line": 3, "column": 1 }
        },
        "texto": "  x <- \"hola\";\n"
      },
      {
        "rango": {
          "start": { "line": 3, "column": 8 },
          "end": { "line": 3, "column": 14 }
        },
        "texto": "42"
      }
    ],
    "comprobacion": "equivalencia_frio"
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
      "sin_cambios": 2,
      "afectadas": 1
    }
  },
  "servicio": {
    "suboperacion": "incremental",
    "documento": "SubProceso Uno()\n  x <- 1;\nFinSubProceso\n\nSubProceso Dos()\n  w <- 2;\nFinSubProceso\n\nAlgoritmo Tres\n  z <- 3;\nFinAlgoritmo\n",
    "ediciones": [
      {
        "rango": {
          "start": {
            "line": 6,
            "column": 8
          },
          "end": {
            "line": 6,
            "column": 9
          }
        },
        "texto": "20"
      }
    ],
    "comprobacion": "reutilizacion_unidades"
  }
}
```

```caso
{
  "id": "C3",
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
      "invalido_firmas": true
    }
  },
  "servicio": {
    "suboperacion": "incremental",
    "documento": "SubProceso Sumar(a)\nFinSubProceso\n\nAlgoritmo Principal\n  Sumar(1, 2);\nFinAlgoritmo\n",
    "ediciones": [
      {
        "rango": {
          "start": {
            "line": 1,
            "column": 18
          },
          "end": {
            "line": 1,
            "column": 20
          }
        },
        "texto": "a, b)"
      }
    ],
    "comprobacion": "invalidation_firma"
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
      "simbolos_previos_conservados": true
    }
  },
  "servicio": {
    "suboperacion": "incremental",
    "documento": "Algoritmo Principal\n  Definir limite Como Entero;\n  limite <- 10;\n  Si limite > 0 Entonces\n",
    "comprobacion": "estado_incompleto",
    "simbolos": [
      "limite"
    ]
  }
}
```

```propiedad
{
  "id": "P1",
  "regla": "R1",
  "generador": {
    "programas": "secuencias de ediciones aleatorias sobre programas del corpus"
  },
  "propiedad": "El estado tras k ediciones incrementales es idéntico al análisis desde cero del texto resultante.",
  "oraculo": "Igualdad de texto, árbol, diagnósticos y tipos con el análisis en frío.",
  "justificacion": "La ejecuta el sujeto service mediante comprobación incremental."
}
```

```medicion
{
  "id": "M1",
  "metrica": "latencia_p95",
  "unidad": "milisegundos",
  "suite": "servicio",
  "comparador": "<=",
  "umbral": 16.0,
  "provisional": false,
  "plataformas": [
    "macos-aarch64",
    "linux-x86_64"
  ],
  "protocolo": "PERF.PROTOCOL#R1"
}
```
