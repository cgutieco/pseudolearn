---
{
  "formato": "see/1",
  "id": "LANG.CLASS.OUT-OF-SCOPE",
  "titulo": "Diagnósticos de construcciones ajenas a la edición",
  "dominio": "lenguaje",
  "estado": "experimental",
  "version": "0.3.0",
  "duenos": [
    "responsable-lenguaje"
  ],
  "sujetos": [
    "reference",
    "engine"
  ],
  "resumen": "Diagnósticos de construcciones ajenas a la edición.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LANG.CLASS.DECLARATION",
      "version": ">=0.1.0, <1.0.0",
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
  "texto": "D1 define las formas reconocibles y sus cierres; el reconocimiento solo actúa ante otra palabra de una cabecera o, cuando allow_line lo permite, una apertura sola en su línea. Una asignación o llamada que usa el nombre permanece ordinaria. Interfaces, clases abstractas, miembros estáticos, visibilidad protegida, genéricos y manejo de excepciones no son construcciones de la edición vigente. En posición estructural inequívoca sus formas reconocibles producen diagnóstico pedagógico específico. Estas palabras no se añaden al vocabulario reservado y pueden ser nombres en posiciones ordinarias.",
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
    "es": "Algoritmo P\nInterfaz X\nFinInterfaz\nFinAlgoritmo\n",
    "en": "algorithm P\nInterfaz X\nFinInterfaz\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "unsupportedInterfaceConstruct",
        "severidad": "error"
      }
    ]
  },
  "rigor": [
    "estricto",
    "flexible"
  ]
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
    "es": "Algoritmo P\nDefinir interface Como Entero;\ninterface <- 2;\nEscribir interface;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine interface as integer;\ninterface <- 2;\nwrite interface;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "2\n",
    "terminacion": "completed"
  },
  "rigor": [
    "estricto",
    "flexible"
  ]
}
```

```definicion
{
  "id": "D1",
  "termino": "unsupportedConstructs",
  "texto": "Formas reconocibles solo en posición estructural; no son palabras reservadas.",
  "valor": {
    "interface": {
      "code": "unsupportedInterfaceConstruct",
      "openings": [
        "Interfaz",
        "interface"
      ],
      "closings": [
        "FinInterfaz",
        "endInterface"
      ],
      "allow_line": false
    },
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
    "generic": {
      "code": "unsupportedGenericsConstruct",
      "openings": [
        "Generico",
        "Genérico",
        "generic"
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
