---
{
  "formato": "see/1",
  "id": "LANG.CLASS.DECLARATION",
  "titulo": "Declaración de clases",
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
  "resumen": "Declaración de clases.",
  "edicion": {
    "introducida_en": "2027"
  },
  "depende_de": [
    {
      "id": "LANG.TYPES.CLASS",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Declaración de clases

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Una clase con nombre y cierre contiene atributos, métodos y constructor; es hermana del algoritmo y subprogramas. No se admite anidamiento, subprograma dentro de clase ni clase dentro de unidad. El orden no restringe referencias a clases posteriores. La inicial mayúscula es estilo y no requisito. Nombre duplicado y ciclos son semánticos.",
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
    "es": "Clase C\nFinClase\nAlgoritmo P\nDefinir x Como C <- Nuevo C();\nFinAlgoritmo\n",
    "en": "class C\nendClass\nalgorithm P\ndefine x as C <- new C();\nendAlgorithm\n"
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
    "es": "Algoritmo P\nClase C\nFinClase\nFinAlgoritmo\n",
    "en": "algorithm P\nclass C\nendClass\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "classInsideAlgorithm",
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
    "es": "Clase\nFinClase\nAlgoritmo P\n\nFinAlgoritmo\n",
    "en": "class\nendClass\nalgorithm P\n\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "expectedClassName",
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
    "es": "Clase Rectangulo\n  Definir ancho Como Entero;\n  Definir alto Como Entero;\n  Metodo Area() Como Entero\n    Retornar Este.ancho * Este.alto;\n  FinMetodo\nFinClase\n\nAlgoritmo Figuras\n  Definir mesa Como Rectangulo <- Nuevo Rectangulo();\n  mesa.ancho <- 4;\n  mesa.alto <- 3;\n  Escribir mesa.Area();\nFinAlgoritmo\n",
    "en": "Class Rectangle\n  Define width As Integer;\n  Define height As Integer;\n  Method Area() As Integer\n    Return This.width * This.height;\n  EndMethod\nEndClass\n\nAlgorithm Shapes\n  Define table As Rectangle <- New Rectangle();\n  table.width <- 4;\n  table.height <- 3;\n  Write table.Area();\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "12\n",
    "terminacion": "completed"
  }
}
```
