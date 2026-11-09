---
{
  "formato": "see/1",
  "id": "LANG.CLASS.SELF-AND-SUPER",
  "titulo": "Objeto actual y superclase",
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
  "resumen": "Objeto actual y superclase.",
  "edicion": {
    "introducida_en": "2027"
  },
  "depende_de": [
    {
      "id": "LANG.CLASS.METHODS",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Objeto actual y superclase

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Este.<miembro> es obligatorio dentro de métodos y constructor para miembros del objeto actual. Un nombre suelto solo refiere local o parámetro; si no hay uno con ese nombre y coincide con un atributo del objeto actual, produce identifierMatchesFieldWithoutThis y no además undeclaredVariable. Super solo se usa dentro de subclase y seguido de llamada a método o constructor; usa implementación de superclase sobre el mismo objeto. Este o Super fuera de método y Super sin superclase son sintácticos.",
  "verificacion": [
    "C1",
    "C2",
    "C3",
    "C4",
    "C5"
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
    "es": "Clase C\nPrivado Definir value Como Entero;\nMetodo Constructor(value Como Entero)\nEste.value <- value;\nFinMetodo\nMetodo get() Como Entero\nRetornar Este.value;\nFinMetodo\nFinClase\nAlgoritmo P\nEscribir Nuevo C(5).get();\nFinAlgoritmo\n",
    "en": "class C\nprivate define value as integer;\nmethod constructor(value as integer)\nthis.value <- value;\nendMethod\nmethod get() as integer\nreturn this.value;\nendMethod\nendClass\nalgorithm P\nwrite new C(5).get();\nendAlgorithm\n"
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
  "id": "C2",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir Este.value;\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite this.value;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "thisOutsideMethod",
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
    "es": "Algoritmo P\nSuper.f();\nFinAlgoritmo\n",
    "en": "algorithm P\nsuper.f();\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "superOutsideMethod",
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
    "es": "Clase Animal\n  Definir nombre Como Cadena;\n  Metodo Presentar()\n    Escribir Este.nombre;\n  FinMetodo\nFinClase\n\nClase Gato Hereda De Animal\n  Metodo Presentar()\n    Super.Presentar();\n    Escribir \"Miau\";\n  FinMetodo\nFinClase\n\nAlgoritmo Casa\n  Definir michi Como Gato <- Nuevo Gato();\n  michi.nombre <- \"Michi\";\n  michi.Presentar();\nFinAlgoritmo\n",
    "en": "Class Animal\n  Define name As String;\n  Method Introduce()\n    Write This.name;\n  EndMethod\nEndClass\n\nClass Cat Inherits From Animal\n  Method Introduce()\n    Super.Introduce();\n    Write \"Miau\";\n  EndMethod\nEndClass\n\nAlgorithm Home\n  Define michi As Cat <- New Cat();\n  michi.name <- \"Michi\";\n  michi.Introduce();\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "Michi\nMiau\n",
    "terminacion": "completed"
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
    "es": "Clase Contador\nDefinir total Como Entero;\nMetodo Incrementar()\ntotal <- total + 1;\nFinMetodo\nFinClase\nAlgoritmo P\nEscribir 1;\nFinAlgoritmo\n",
    "en": "class Counter\ndefine total as integer;\nmethod Increment()\ntotal <- total + 1;\nendMethod\nendClass\nalgorithm P\nwrite 1;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "identifierMatchesFieldWithoutThis",
        "severidad": "error",
        "argumentos": {
          "lexeme": "total"
        }
      }
    ]
  }
}
```
