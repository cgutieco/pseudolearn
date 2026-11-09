---
{
  "formato": "see/1",
  "id": "LANG.CLASS.INSTANTIATION",
  "titulo": "Instanciación explícita",
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
    "reference",
    "engine",
    "aot"
  ],
  "resumen": "Instanciación explícita.",
  "edicion": {
    "introducida_en": "2027"
  },
  "depende_de": [
    {
      "id": "LANG.CLASS.CONSTRUCTOR",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Instanciación explícita

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Nuevo seguido de nombre de clase, argumentos de tipo opcionales entre ángulos para una plantilla de clase (LANG.TYPES.GENERIC#R2) y paréntesis es expresión primaria. No se crea objeto al declarar una variable. Constructor recibe argumentos según su firma. No hay nulo escribible. Acceder a una referencia no instanciada falla en ejecución. Se admite acceso encadenado sobre el resultado de Nuevo.",
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
    "es": "Clase C\nPrivado Definir value Como Entero;\nMetodo Constructor(value Como Entero)\nEste.value <- value;\nFinMetodo\nMetodo get() Como Entero\nRetornar Este.value;\nFinMetodo\nFinClase\nAlgoritmo P\nEscribir Nuevo C(9).get();\nFinAlgoritmo\n",
    "en": "class C\nprivate define value as integer;\nmethod constructor(value as integer)\nthis.value <- value;\nendMethod\nmethod get() as integer\nreturn this.value;\nendMethod\nendClass\nalgorithm P\nwrite new C(9).get();\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "9\n",
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
    "es": "Clase C\nFinClase\nAlgoritmo P\nDefinir x Como C <- Nuevo C;\nFinAlgoritmo\n",
    "en": "class C\nendClass\nalgorithm P\ndefine x as C <- new C;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "missingInstantiationParentheses",
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
    "es": "Clase C\nFinClase\nAlgoritmo P\nDefinir x Como C <- Nuevo C(1);\nEscribir x = x;\nFinAlgoritmo\n",
    "en": "class C\nendClass\nalgorithm P\ndefine x as C <- new C(1);\nwrite x = x;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "argumentCountMismatch",
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
    "es": "Clase Punto\n  Definir x Como Entero;\nFinClase\n\nAlgoritmo Objetos\n  Definir primero Como Punto <- Nuevo Punto();\n  Definir segundo Como Punto <- Nuevo Punto();\n  primero.x <- 1;\n  segundo.x <- 2;\n  Escribir primero.x;\n  Escribir segundo.x;\nFinAlgoritmo\n",
    "en": "Class Point\n  Define x As Integer;\nEndClass\n\nAlgorithm Objects\n  Define first As Point <- New Point();\n  Define second As Point <- New Point();\n  first.x <- 1;\n  second.x <- 2;\n  Write first.x;\n  Write second.x;\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "1\n2\n",
    "terminacion": "completed"
  }
}
```
