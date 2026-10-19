---
{
  "formato": "see/1",
  "id": "TOOL.SERVICE.NODE-IDENTITY",
  "titulo": "Identidad estable de nodos sintácticos",
  "dominio": "herramienta",
  "estado": "experimental",
  "version": "0.1.0",
  "duenos": [
    "responsable-herramientas"
  ],
  "sujetos": [
    "service"
  ],
  "resumen": "Identificadores estables deterministas para nodos del árbol sintáctico ante ediciones incrementales.",
  "depende_de": [
    {
      "id": "TOOL.SERVICE.LOSSLESS-TREE",
      "version": ">=0.2.0, <1.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "Syntax node identity"
}
---

# Identidad estable de nodos sintácticos

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Todo nodo del árbol sintáctico posee un identificador estable determinado por su unidad superior contenedora (Algoritmo, SubProceso, Clase y miembro), su categoría sintáctica y su posición estructural relativa dentro de esa unidad.",
  "verificacion": [
    "C1",
    "C2",
    "C3",
    "C4",
    "P1"
  ]
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Una edición de texto contenida dentro de una unidad de nivel superior no altera el identificador estable de ninguna otra unidad de nivel superior ni de los nodos contenidos en ellas.",
  "verificacion": [
    "C1",
    "P1"
  ]
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Añadir, modificar o eliminar una sentencia dentro de un bloque conserva el identificador estable de la unidad contenedora, de sus parámetros y de las sentencias anteriores al punto de edición.",
  "verificacion": [
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
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "conservados": true
    }
  },
  "servicio": {
    "suboperacion": "node_identity",
    "documento": "SubProceso Previo()\nFinSubProceso\n\nAlgoritmo Principal\n  x <- 1;\nFinAlgoritmo\n\nSubProceso Posterior()\nFinSubProceso\n",
    "edicion": {
      "rango": {
        "start": { "line": 5, "column": 3 },
        "end": { "line": 5, "column": 9 }
      },
      "texto": "x <- 2;\n  y <- 3;"
    },
    "comprobacion": "unidades_vecinas_estables"
  }
}
```

```caso
{
  "id": "C2",
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
      "conservados": true
    }
  },
  "servicio": {
    "suboperacion": "node_identity",
    "documento": "Algoritmo Principal\n  Si x > 0 Entonces\n    Escribir x;\n  FinSi\nFinAlgoritmo\n",
    "edicion": {
      "rango": {
        "start": { "line": 4, "column": 1 },
        "end": { "line": 4, "column": 1 }
      },
      "texto": "    Escribir 2;\n"
    },
    "comprobacion": "sentencias_previas_estables"
  }
}
```

```caso
{
  "id": "C3",
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
      "conservados": true
    }
  },
  "servicio": {
    "suboperacion": "node_identity",
    "documento": "Algoritmo Principal\n  x <- 1;\nFinAlgoritmo\n",
    "edicion": {
      "rango": {
        "start": { "line": 2, "column": 1 },
        "end": { "line": 2, "column": 1 }
      },
      "texto": "  // comentario\n"
    },
    "comprobacion": "nodos_semanticos_estables"
  }
}
```

```caso
{
  "id": "C4",
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
      "conservados": true
    }
  },
  "servicio": {
    "suboperacion": "node_identity",
    "documento": "SubProceso Uno()\nFinSubProceso\n\nSubProceso Dos()\nFinSubProceso\n",
    "edicion": {
      "rango": {
        "start": { "line": 1, "column": 12 },
        "end": { "line": 1, "column": 15 }
      },
      "texto": "Renombrado"
    },
    "comprobacion": "otras_unidades_invariantes"
  }
}
```

```propiedad
{
  "id": "P1",
  "regla": "R1",
  "generador": {
    "programas": "programas multi-unidad del corpus con ediciones sintácticas en un cuerpo de unidad"
  },
  "propiedad": "Los identificadores de nodos en todas las demás unidades permanecen invariantes tras la edición.",
  "oraculo": "Invarianza estricta de identificadores estables de nodos ajenos.",
  "justificacion": "La ejecuta el sujeto service mediante comprobación de identidad de nodos."
}
```
