---
{
  "formato": "see/1",
  "id": "LANG.CLASS.OUT-OF-SCOPE",
  "titulo": "Diagnósticos de construcciones ajenas a la edición",
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
  "resumen": "Diagnósticos de construcciones ajenas a la edición.",
  "edicion": {
    "introducida_en": "2027"
  },
  "depende_de": [
    {
      "id": "LANG.CLASS.DECLARATION",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Diagnósticos de construcciones ajenas a la edición

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "D1 define las formas reconocibles y sus cierres; el reconocimiento solo actúa ante otra palabra de una cabecera o, cuando allow_line lo permite, una apertura sola en su línea. Una asignación o llamada que usa el nombre permanece ordinaria. Clases abstractas, miembros estáticos, visibilidad protegida y manejo de excepciones no son construcciones de la edición vigente; las clases genéricas sí lo son, con parámetros de tipo entre ángulos, y una palabra como Generico es un nombre ordinario también tras Clase. En posición estructural inequívoca sus formas reconocibles producen diagnóstico pedagógico específico; la recuperación salta hasta el cierre de la construcción rechazada, de modo que las unidades siguientes se analizan sin diagnósticos derivados. Estas palabras no se añaden al vocabulario reservado y pueden ser nombres en posiciones ordinarias.",
  "verificacion": [
    "C1",
    "C2",
    "C3",
    "C4",
    "C5",
    "C6"
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
    "es": "Algoritmo P\nInterfaz X\nFinInterfaz\nFinAlgoritmo\n",
    "en": "algorithm P\ninterface X\nendInterface\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "interfaceInsideAlgorithm",
        "severidad": "error"
      }
    ]
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
    "es": "Algoritmo P\nDefinir interface Como Entero <- 2;\nEscribir interface;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine interface as integer <- 2;\nwrite interface;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "2\n",
    "terminacion": "completed"
  }
}
```

```definicion
{
  "id": "D1",
  "termino": "unsupportedConstructs",
  "texto": "Formas reconocibles solo en posición estructural; no son palabras reservadas.",
  "valor": {
    "abstract": {
      "code": "unsupportedAbstractConstruct",
      "openings": [
        "Abstracta",
        "Abstracto",
        "abstract"
      ],
      "closings": [
        "FinClase",
        "endClass"
      ],
      "allow_line": false
    },
    "static": {
      "code": "unsupportedStaticConstruct",
      "openings": [
        "Estatico",
        "Estático",
        "static"
      ],
      "closings": [
        "FinMetodo",
        "endMethod"
      ],
      "allow_line": false
    },
    "protected": {
      "code": "unsupportedProtectedConstruct",
      "openings": [
        "Protegido",
        "protected"
      ],
      "closings": [],
      "allow_line": false
    },
    "exception": {
      "code": "unsupportedExceptionConstruct",
      "openings": [
        "Intentar",
        "try"
      ],
      "closings": [
        "FinIntentar",
        "endTry"
      ],
      "allow_line": true
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
    "es": "Algoritmo P\nFinAlgoritmo\nInterfaz Figura\n",
    "en": "algorithm P\nendAlgorithm\ninterface Shape\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "unclosedInterface",
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
    "es": "Clase C\nEstatico Definir total Como Entero;\nFinClase\nAlgoritmo P\nFinAlgoritmo\n",
    "en": "class C\nstatic define total as integer;\nendClass\nalgorithm P\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "unsupportedStaticConstruct",
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
    "es": "Clase Generico\nMetodo valor() Como Entero\nRetornar 5;\nFinMetodo\nFinClase\nAlgoritmo P\nDefinir g Como Generico <- Nuevo Generico();\nEscribir g.valor();\nFinAlgoritmo\n",
    "en": "class generic\nmethod value() as integer\nreturn 5;\nendMethod\nendClass\nalgorithm P\ndefine g as generic <- new generic();\nwrite g.value();\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "5\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C6",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Clase Abstracta Figura\nFinClase\nAlgoritmo P\nEscribir 1;\nFinAlgoritmo\n",
    "en": "class abstract Shape\nendClass\nalgorithm P\nwrite 1;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "unsupportedAbstractConstruct",
        "severidad": "error"
      }
    ]
  }
}
```
